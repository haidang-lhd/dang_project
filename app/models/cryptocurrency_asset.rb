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
class CryptocurrencyAsset < Asset
    COINGECKO_IDS = {
    'BTC'  => 'bitcoin',
    'ETH'  => 'ethereum',
    'BNB'  => 'binancecoin',
    'USDT' => 'tether',
    'USDC' => 'usd-coin',
    'SOL'  => 'solana',
    'ADA'  => 'cardano',
    'XRP'  => 'ripple',
    'DOGE' => 'dogecoin',
    'TRX'  => 'tron',
    'DOT'  => 'polkadot',
    'MATIC'=> 'polygon',
    'AVAX' => 'avalanche-2',
    'TON'  => 'the-open-network'
  }.freeze

  def sync_price
    symbol = name.to_s.upcase.strip
    cg_id  = COINGECKO_IDS[symbol] || symbol.downcase

    url = URI("https://api.coingecko.com/api/v3/simple/price?ids=#{CGI.escape(cg_id)}&vs_currencies=vnd")

    begin
      req = Net::HTTP::Get.new(url)
      api_key = ENV['COINGECKO_API_KEY']
      req['x-cg-demo-api-key'] = api_key if api_key.present?

      res = Net::HTTP.start(url.host, url.port, use_ssl: true, read_timeout: 10) do |http|
        http.request(req)
      end

      if res.is_a?(Net::HTTPSuccess)
        data = JSON.parse(res.body) rescue {}
        vnd  = data.dig(cg_id, 'vnd')

        if vnd
          asset_prices.create!(price: vnd.to_f, synced_at: Time.current)
          return vnd.to_f
        else
          Rails.logger.warn "CoinGecko returned no VND price for #{name} (id: #{cg_id}). Body: #{res.body}"
          asset_prices.create!(price: 0.0, synced_at: Time.current)
          return 0.0
        end
      else
        Rails.logger.error "HTTP #{res.code} from CoinGecko for #{name} (id: #{cg_id}). Body: #{res.body}"
        asset_prices.create!(price: 0.0, synced_at: Time.current)
        return 0.0
      end
    rescue StandardError => e
      Rails.logger.error "Failed to sync crypto price for #{name}: #{e.class} - #{e.message}\n#{e.backtrace.first(10).join("\n")}"
      asset_prices.create!(price: 0.0, synced_at: Time.current)
      return 0.0
    end
  end
end
