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
  DOJI_URL = 'http://update.giavang.doji.vn/banggia/doji_92411/92411'.freeze

  def sync_price
    # rubocop:disable Security/Open

    require 'net/http'
    require 'nokogiri'

    uri = URI.parse(DOJI_URL)
    res = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
      http.get(uri.request_uri, {
        'Accept' => 'application/json, text/plain, */*',
        'User-Agent' => 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)'
      })
    end
    raise "HTTP #{res.code}" unless res.is_a?(Net::HTTPSuccess)

    doc = Nokogiri::XML(res.body)
    row_key = (name.to_s.strip.upcase == 'SJC') ? 'doji_1' : 'doji_3'
    row = doc.at_xpath("//Row[@Key='#{row_key}']")
    raise "Row not found for key #{row_key}" unless row

    buy_text = row['Buy'].to_s # e.g. "12,450"
    # "12,450" -> 12450 -> *1000 => 12_450_000 VND
    price_vnd = buy_text.gsub(/[^\d]/, '').to_i * 1_000 if buy_text
    price_vnd ||= 0

    asset_prices.create!(price: price_vnd, synced_at: Time.current)
    price_vnd
  rescue => e
    Rails.logger.error("Failed to sync price for GoldAsset #{id}: #{e.class} - #{e.message}")
    nil
    # rubocop:enable Security/Open
  end
end
