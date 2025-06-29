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
  VINACAPITAL_FUNDS = %w[VESAF, VMEEF, VEOF, VDEF]
  DRAGONCAPITAL_FUNDS = %w[DCDS, DCDE]

  def sync_price
    base_url = "https://fmarket.vn/quy"
    nav_url = "#{base_url}/#{self.name.downcase}"

    begin
      html = URI.open(
        nav_url,
        "User-Agent" => "Mozilla/5.0 (Windows NT 10.0; Win64; x64)",
        "Accept" => "text/html"
      )
      doc = Nokogiri::HTML(html)
      nav_text = doc.css(".nav").first&.text&.strip&.gsub(",", "")
      nav = nav_text.to_f if nav_text

      self.asset_prices.create!(
        price: nav || 0.0,
        synced_at: Time.current
      )
    rescue OpenURI::HTTPError, SocketError => e
      Rails.logger.error "HTTP error while syncing price for #{self.name}: #{e.message}\n#{e.backtrace.join("\n")}"
      self.asset_prices.create!(
        price: 0.0,
        synced_at: Time.current
      )
    rescue StandardError => e
      Rails.logger.error "Unexpected error while syncing price for #{self.name}: #{e.message}\n#{e.backtrace.join("\n")}"
      self.asset_prices.create!(
        price: 0.0,
        synced_at: Time.current
      )
    end
  end
end
