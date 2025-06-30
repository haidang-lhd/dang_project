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
      Rails.logger.error("Failed to sync price for GoldAsset #{id}: #{e.message}")
      nil
    end
    # rubocop:enable Security/Open
  end
end
