# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GoldAsset, type: :model do
  let(:category) { create(:category) }
  let(:gold_asset) { create(:gold_asset, category: category) }
  let(:doji_asset) { create(:gold_asset, :doji, category: category) }
  let(:sjc_asset) { create(:gold_asset, :sjc, category: category) }

  describe '#sync_price' do
    context 'when asset name is DOJI' do
      let(:xml_response) do
        <<~XML
          <?xml version='1.0' encoding='utf-8'?>
          <GoldList><LED>
              <DateTime>09:28 02-07-2025</DateTime>
              <info Name='CÁC CH ĐÀ NẴNG, HUẾ' area='MIỀN TRUNG' hotline='' />
              <Row Name='Miếng SJC (Loại 1L) - Bán Lẻ' Key='doji_0' Sell='12,070' Buy='11,870' />
              <Row Name='Nhẫn Tròn 9999 (Hưng Thịnh Vượng) - Bán Lẻ' Key='doji_3' Sell='11,740' Buy='11,540' />
              <Row Name='Nữ Trang 9999 - Bán Lẻ' Key='doji_4' Sell='11,680' Buy='10,800' />
          </LED>
          <Source>DOJI GOLD : http://giavang.doji.vn</Source>
          </GoldList>
        XML
      end

      before do
        allow(doji_asset).to receive(:`).and_return(xml_response)
      end

      it 'calls sync_doji_price' do
        expect(doji_asset).to receive(:sync_doji_price).and_call_original
        doji_asset.sync_price
      end

      it 'successfully syncs DOJI price from XML response' do
        expect do
          doji_asset.sync_price
        end.to change { doji_asset.asset_prices.count }.by(1)

        latest_price = doji_asset.asset_prices.last
        expect(latest_price.price).to eq(11_740_000) # 11,740 * 1000
        expect(latest_price.synced_at).to be_present
      end

      context 'when DOJI API fails' do
        before do
          allow(doji_asset).to receive(:`).and_raise(StandardError.new('Network error'))
          allow(doji_asset).to receive(:sync_with_pnj_logic).and_return(1_200_000)
        end

        it 'falls back to PNJ logic' do
          expect(doji_asset).to receive(:sync_with_pnj_logic)
          expect(Rails.logger).to receive(:warn).with(/Failed to sync DOJI price.*falling back to PNJ/)

          result = doji_asset.sync_price
          expect(result).to eq(1_200_000)
        end
      end

      context 'when Nhẫn Tròn 9999 is not found in response' do
        let(:xml_response_without_nhan_tron) do
          <<~XML
            <?xml version='1.0' encoding='utf-8'?>
            <GoldList><LED>
                <DateTime>09:28 02-07-2025</DateTime>
                <Row Name='Miếng SJC (Loại 1L) - Bán Lẻ' Key='doji_0' Sell='12,070' Buy='11,870' />
            </LED>
            </GoldList>
          XML
        end

        before do
          allow(doji_asset).to receive(:`).and_return(xml_response_without_nhan_tron)
          allow(doji_asset).to receive(:sync_with_pnj_logic).and_return(1_200_000)
        end

        it 'falls back to PNJ logic' do
          expect(doji_asset).to receive(:sync_with_pnj_logic)
          expect(Rails.logger).to receive(:warn).with(/Could not find 'Nhẫn Tròn 9999' price.*falling back to PNJ/)

          result = doji_asset.sync_price
          expect(result).to eq(1_200_000)
        end
      end
    end

    context 'when asset name is not DOJI' do
      before do
        allow(gold_asset).to receive(:sync_with_pnj_logic).and_return(1_150_000)
      end

      it 'calls sync_with_pnj_logic directly' do
        expect(gold_asset).to receive(:sync_with_pnj_logic)
        expect(gold_asset).not_to receive(:sync_doji_price)

        gold_asset.sync_price
      end
    end
  end

  describe '#sync_with_pnj_logic' do
    let(:html_content) do
      <<~HTML
        <html>
          <body>
            <table>
              <tr>
                <td>Gold Type</td>
                <td>Buy Price</td>
                <td>11.500</td>
              </tr>
              <tr>
                <td>SJC</td>
                <td>12.000</td>
                <td>Sell Price</td>
              </tr>
            </table>
          </body>
        </html>
      HTML
    end

    before do
      allow(URI).to receive(:open).and_return(StringIO.new(html_content))
    end

    it 'syncs price from PNJ website for non-SJC assets' do
      expect do
        gold_asset.send(:sync_with_pnj_logic)
      end.to change { gold_asset.asset_prices.count }.by(1)

      latest_price = gold_asset.asset_prices.last
      expect(latest_price.price).to eq(1_150_000) # 11.500 -> 11500 * 100
    end

    it 'syncs price from PNJ website for SJC assets' do
      expect do
        sjc_asset.send(:sync_with_pnj_logic)
      end.to change { sjc_asset.asset_prices.count }.by(1)

      latest_price = sjc_asset.asset_prices.last
      expect(latest_price.price).to eq(1_200_000) # 12.000 -> 12000 * 100
    end

    context 'when PNJ website is unavailable' do
      before do
        allow(URI).to receive(:open).and_raise(StandardError.new('Connection failed'))
      end

      it 'logs error and returns nil' do
        expect(Rails.logger).to receive(:error).with(/Failed to sync price with PNJ fallback/)

        result = gold_asset.send(:sync_with_pnj_logic)
        expect(result).to be_nil
      end
    end
  end

  describe '#sync_doji_price' do
    let(:xml_response) do
      <<~XML
        <?xml version='1.0' encoding='utf-8'?>
        <GoldList><LED>
            <Row Name='Nhẫn Tròn 9999 (Hưng Thịnh Vượng) - Bán Lẻ' Key='doji_3' Sell='11,740' Buy='11,540' />
        </LED>
        </GoldList>
      XML
    end

    before do
      allow(doji_asset).to receive(:`).and_return(xml_response)
    end

    it 'extracts price from XML and creates asset_price record' do
      expect do
        doji_asset.send(:sync_doji_price)
      end.to change { doji_asset.asset_prices.count }.by(1)

      latest_price = doji_asset.asset_prices.last
      expect(latest_price.price).to eq(11_740_000) # 11,740 * 1000
    end

    it 'handles price format correctly' do
      price = doji_asset.send(:sync_doji_price)
      expect(price).to eq(11_740_000)
    end
  end
end
