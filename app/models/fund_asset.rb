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
class FundAsset < Asset
  VINACAPITAL_FUNDS = %w[VESAF VMEEF VEOF VDEF].freeze
  DRAGONCAPITAL_FUNDS = %w[DCDS DCDE].freeze

  def sync_price
    # rubocop:disable Security/Open
    base_url = 'https://fmarket.vn/quy'
    nav_url = "#{base_url}/#{name.downcase}"

    begin
      html = URI.open(
        nav_url,
        'User-Agent' => 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)',
        'Accept' => 'text/html'
      )
      doc = Nokogiri::HTML(html)
      nav_text = doc.css('.nav').first&.text&.strip&.gsub(',', '')
      nav = nav_text.to_f if nav_text

      asset_prices.create!(
        price: nav || 0.0,
        synced_at: Time.current
      )
    rescue OpenURI::HTTPError, SocketError => e
      Rails.logger.error "HTTP error while syncing price for #{name}: #{e.message}\n#{e.backtrace.join("\n")}"
      asset_prices.create!(
        price: 0.0,
        synced_at: Time.current
      )
    rescue StandardError => e
      Rails.logger.error "Unexpected error while syncing price for #{name}: #{e.message}\n#{e.backtrace.join("\n")}"
      asset_prices.create!(
        price: 0.0,
        synced_at: Time.current
      )
    end
    # rubocop:enable Security/Open
  end
end
