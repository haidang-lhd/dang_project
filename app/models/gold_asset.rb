# frozen_string_literal: true

# == Schema Information
#
# Table name: assets
#
#  id          :bigint           not null, primary key
#  name        :string           not null
#  type        :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  category_id :bigint           not null
#
# Indexes
#
#  index_assets_on_category_id  (category_id)
#  index_assets_on_type         (type)
#
# Foreign Keys
#
#  fk_rails_...  (category_id => categories.id)
#
class GoldAsset < Asset
  def sync_price
    # Handle DOJI case with curl request
    if name == 'DOJI'
      return sync_doji_price
    end

    sync_with_pnj_logic
  end

  private

  def sync_doji_price
    # Make curl request to DOJI API
    curl_command = %{
        curl 'http://update.giavang.doji.vn/banggia/doji_92411/92411' \
          -H 'Accept: application/json, text/plain, */*' \
          -H 'Accept-Language: en,vi-VN;q=0.9,vi;q=0.8,fr-FR;q=0.7,fr;q=0.6,en-US;q=0.5' \
          -H 'Connection: keep-alive' \
          -H 'If-Modified-Since: Wed, 01 Jul 2025 02:28:16 GMT' \
          -H 'Referer: http://update.giavang.doji.vn/system/doji_92411/92411' \
          -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36' \
          --insecure
      }.strip.gsub(/\s+/, ' ')

    xml_response = `#{curl_command}`
    # Parse XML response
    doc = Nokogiri::XML(xml_response)

    # Find the "Nhẫn Tròn 9999" row and extract sell price
    nhan_tron_row = doc.xpath("//Row[contains(@Name, 'Nhẫn Tròn 9999')]").first

    if nhan_tron_row
      sell_price_text = nhan_tron_row['Sell']
      # Remove commas and convert to float, then multiply by 1000 to get VND/chỉ
      price = sell_price_text.gsub(',', '').to_f * 1000

      asset_prices.create!(
        price: price,
        synced_at: Time.current
      )
      price
    else
      Rails.logger.warn("Could not find 'Nhẫn Tròn 9999' price in DOJI response, falling back to PNJ")
      sync_with_pnj_logic
    end
  rescue => e
    Rails.logger.warn("Failed to sync DOJI price for GoldAsset #{id}: #{e.message}, falling back to PNJ")
    sync_with_pnj_logic
  end

  def sync_with_pnj_logic
    # rubocop:disable Security/Open
    url = 'https://giavang.pnj.com.vn/'
    begin
      html = URI.open(
        url,
        'User-Agent' => 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)',
        'Accept' => 'text/html'
      )
      doc = Nokogiri::HTML(html)
      price_text = if name == 'SJC'
                     doc.css('table tr:nth-child(2) td:nth-child(2)').text.strip
                   else
                     # TODO: Handle other gold asset names following the PNJ pricing logic, need to update later
                     doc.css('table tr:nth-child(1) td:nth-child(3)').text.strip
                   end
      price_text = price_text.gsub('.', '').gsub(',', '.')
      price = price_text.to_f * 100 # Convert to VND
      asset_prices.create!(
        price: price,
        synced_at: Time.current
      )
      price
    rescue => e
      Rails.logger.error("Failed to sync price with PNJ fallback for GoldAsset #{id}: #{e.message}")
      nil
    end
    # rubocop:enable Security/Open
  end
end
