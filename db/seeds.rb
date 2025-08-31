# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

user = User.first

user ||= User.find_or_create_by!(email: "haidang.lhd.lhd@gmail.com") do |u|
  u.password = "Haidang_06092000"
  u.password_confirmation = "Haidang_06092000"
end

user.confirm

# Create default categories for assets
[ "Stocks", "Gold", "Bonds", "Real Estate", "Cryptocurrency", "Investment Fund Certificates" ].each do |category_name|
  Category.find_or_create_by!(name: category_name)
end

## Asset
# Create default Assets using STI
# Investment Fund Certificates
[ "VESAF", "VMEEF", "VEOF", "VDEF", "DCDS", "DCDE" ].each do |label_name|
  FundAsset.find_or_create_by!(name: label_name, category: Category.find_by(name: "Investment Fund Certificates"))
end

# Stocks
[ "VPB", "TCBS" ].each do |label_name|
  StockAsset.find_or_create_by!(name: label_name, category: Category.find_by(name: "Stocks"))
end

# Gold
[ "SJC", "DOJI", "Mi Hong", "PNJ", "PNJ" ].each do |label_name|
  GoldAsset.find_or_create_by!(name: label_name, category: Category.find_by(name: "Gold"))
end

# Cryptocurrency
[ "BTC", "ETH", "USDT" ].each do |label_name|
  CryptocurrencyAsset.find_or_create_by!(name: label_name, category: Category.find_by(name: "Cryptocurrency"))
end


## Investment History

# Stocks

# Buy 500 TCBS at 46800 VND on August 27, 2025
InvestmentTransaction.create!(
  asset: StockAsset.find_by(name: "TCBS"),
  quantity: 500,
  nav: 46800,
  fee: 0.00,
  transaction_type: "buy",
  unit: "share",
  date: Date.new(2025, 8, 27),
  user: user
)

# Cryptocurrency
# Buy 0.00166 BTC at 3,012,048,192.776 VND on August 6, 2025
InvestmentTransaction.create!(
  asset: CryptocurrencyAsset.find_by(name: "BTC"),
  quantity: 0.00166,
  nav: 3012048192.776,
  fee: 0.00,
  transaction_type: "buy",
  unit: "token",
  date: Date.new(2025, 8, 6),
  user: user
)
# Buy 568.35 USDT at 26,395 VND on June 10, 2025
InvestmentTransaction.create!(
  asset: CryptocurrencyAsset.find_by(name: "USDT"),
  quantity: 568.35,
  nav: 26395,
  fee: 0.00,
  transaction_type: "buy",
  unit: "token",
  date: Date.new(2025, 6, 10),
  user: user
)

# Sell 284.50 USDT at 26,750 VND on August 20, 2025
InvestmentTransaction.create!(
  asset: CryptocurrencyAsset.find_by(name: "USDT"),
  quantity: 284.50,
  nav: 26750,
  fee: 0.00,
  transaction_type: "sell",
  unit: "token",
  date: Date.new(2025, 8, 20),
  user: user
)

# Buy 0.0025 BTC at 3044150000 VND on August 20, 2025
InvestmentTransaction.create!(
  asset: CryptocurrencyAsset.find_by(name: "BTC"),
  quantity: 0.0025,
  nav: 3044150000,
  fee: 0.00,
  transaction_type: "buy",
  unit: "token",
  date: Date.new(2025, 8, 20),
  user: user
)

# Investment Fund Certificates
# Buy 40.35 VESAF at 24779.55 VND on July 20,2023
InvestmentTransaction.create!(
  asset: FundAsset.find_by(name: "VESAF"),
  quantity: 40.35,
  nav: 24779.55,
  fee: 0.00,
  transaction_type: "buy",
  unit: "unit",
  date: Date.new(2023, 7, 20),
  user: user
)

# Buy 20.17 VESAF at 24779.55 VND on July 20,2023
InvestmentTransaction.create!(
  asset: FundAsset.find_by(name: "VESAF"),
  quantity: 20.17,
  nav: 24779.55,
  fee: 0.00,
  transaction_type: "buy",
  unit: "unit",
  date: Date.new(2023, 7, 20),
  user: user
)

# Buy 73.68 VESAF at 27144.31 VND on September 7, 2023
InvestmentTransaction.create!(
  asset: FundAsset.find_by(name: "VESAF"),
  quantity: 73.68,
  nav: 27144.31,
  fee: 0.00,
  transaction_type: "buy",
  unit: "unit",
  date: Date.new(2023, 9, 7),
  user: user
)

# Buy 18.42 VESAF at 27144.31 VND on September 7, 2023
InvestmentTransaction.create!(
  asset: FundAsset.find_by(name: "VESAF"),
  quantity: 18.42,
  nav: 27144.31,
  fee: 0.00,
  transaction_type: "buy",
  unit: "unit",
  date: Date.new(2023, 9, 7),
  user: user
)

# Buy 127.43 VESAF at 26383.06 VND on October 3, 2023
InvestmentTransaction.create!(
  asset: FundAsset.find_by(name: "VESAF"),
  quantity: 127.43,
  nav: 26383.06,
  fee: 0.00,
  transaction_type: "buy",
  unit: "unit",
  date: Date.new(2023, 10, 3),
  user: user
)

# Buy 77.93 VESAF at 25662.04 VND on October 4, 2023
InvestmentTransaction.create!(
  asset: FundAsset.find_by(name: "VESAF"),
  quantity: 77.93,
  nav: 25662.04,
  fee: 0.00,
  transaction_type: "buy",
  unit: "unit",
  date: Date.new(2023, 10, 4),
  user: user
)

# Buy 39.35 VESAF at 25441.74 VND on October 24, 2023
InvestmentTransaction.create!(
  asset: FundAsset.find_by(name: "VESAF"),
  quantity: 39.35,
  nav: 25441.74,
  fee: 0.00,
  transaction_type: "buy",
  unit: "unit",
  date: Date.new(2023, 10, 24),
  user: user
)

# Buy 122.41 VESAF at 24507.40 VND on November 8, 2023
InvestmentTransaction.create!(
  asset: FundAsset.find_by(name: "VESAF"),
  quantity: 122.41,
  nav: 24507.40,
  fee: 0.00,
  transaction_type: "buy",
  unit: "unit",
  date: Date.new(2023, 11, 8),
  user: user
)

# Buy 116.69 VESAF at 25707.10 VND on December 5, 2023
InvestmentTransaction.create!(
  asset: FundAsset.find_by(name: "VESAF"),
  quantity: 116.69,
  nav: 25707.10,
  fee: 0.00,
  transaction_type: "buy",
  unit: "unit",
  date: Date.new(2023, 12, 5),
  user: user
)

# Buy 115.71 VESAF at 25926.10 VND on January 4, 2024
InvestmentTransaction.create!(
  asset: FundAsset.find_by(name: "VESAF"),
  quantity: 115.71,
  nav: 25926.10,
  fee: 0.00,
  transaction_type: "buy",
  unit: "unit",
  date: Date.new(2024, 1, 4),
  user: user
)

# Buy 185.59 VESAF at 26940.13 VND on February 2, 2024
InvestmentTransaction.create!(
  asset: FundAsset.find_by(name: "VESAF"),
  quantity: 185.59,
  nav: 26940.13,
  fee: 0.00,
  transaction_type: "buy",
  unit: "unit",
  date: Date.new(2024, 2, 2),
  user: user
)

# Buy 182.15 VESAF at 27449.89 VND on February 7, 2024
InvestmentTransaction.create!(
  asset: FundAsset.find_by(name: "VESAF"),
  quantity: 182.15,
  nav: 27449.89,
  fee: 0.00,
  transaction_type: "buy",
  unit: "unit",
  date: Date.new(2024, 2, 7),
  user: user
)

# Buy 175.88 VESAF at 28427.46 VND on March 5, 2024
InvestmentTransaction.create!(
  asset: FundAsset.find_by(name: "VESAF"),
  quantity: 175.88,
  nav: 28427.46,
  fee: 0.00,
  transaction_type: "buy",
  unit: "unit",
  date: Date.new(2024, 3, 5),
  user: user
)

# Buy 238.13 VESAF at 29395.44 VND on April 4, 2024
InvestmentTransaction.create!(
  asset: FundAsset.find_by(name: "VESAF"),
  quantity: 238.13,
  nav: 29395.44,
  fee: 0.00,
  transaction_type: "buy",
  unit: "unit",
  date: Date.new(2024, 4, 4),
  user: user
)

# Buy 68.03 VESAF at 29395.44 VND on April 4, 2024
InvestmentTransaction.create!(
  asset: FundAsset.find_by(name: "VESAF"),
  quantity: 68.03,
  nav: 29395.44,
  fee: 0.00,
  transaction_type: "buy",
  unit: "unit",
  date: Date.new(2024, 4, 4),
  user: user
)
# Buy 245.57 VESAF at 28504.65 VND on May 3, 2024
InvestmentTransaction.create!(
  asset: FundAsset.find_by(name: "VESAF"),
  quantity: 245.57,
  nav: 28504.65,
  fee: 0.00,
  transaction_type: "buy",
  unit: "unit",
  date: Date.new(2024, 5, 3),
  user: user
)

# Buy 163.04 VESAF at 30667.28 VND on Jun 4, 2024
InvestmentTransaction.create!(
  asset: FundAsset.find_by(name: "VESAF"),
  quantity: 163.04,
  nav: 30667.28,
  fee: 0.00,
  transaction_type: "buy",
  unit: "unit",
  date: Date.new(2024, 6, 4),
  user: user
)

# Buy 223.66 VESAF at 31296.52 VND on July 5, 2024
InvestmentTransaction.create!(
  asset: FundAsset.find_by(name: "VESAF"),
  quantity: 223.66,
  nav: 31296.52,
  fee: 0.00,
  transaction_type: "buy",
  unit: "unit",
  date: Date.new(2024, 7, 5),
  user: user
)

# Buy 235.34 VESAF at 29743.99 VND on August 2, 2024
InvestmentTransaction.create!(
  asset: FundAsset.find_by(name: "VESAF"),
  quantity: 235.34,
  nav: 29743.99,
  fee: 0.00,
  transaction_type: "buy",
  unit: "unit",
  date: Date.new(2024, 8, 2),
  user: user
)

# Buy 229.70 VESAF at 30473.49 VND on September 6, 2024
InvestmentTransaction.create!(
  asset: FundAsset.find_by(name: "VESAF"),
  quantity: 229.70,
  nav: 30473.49,
  fee: 0.00,
  transaction_type: "buy",
  unit: "unit",
  date: Date.new(2024, 9, 6),
  user: user
)

# Buy 496.83 VESAF at 30191.11 VND on September 11, 2024
InvestmentTransaction.create!(
  asset: FundAsset.find_by(name: "VESAF"),
  quantity: 496.83,
  nav: 30191.11,
  fee: 0.00,
  transaction_type: "buy",
  unit: "unit",
  date: Date.new(2024, 9, 11),
  user: user
)

# Buy 162.41 VESAF at 30784.67 VND on October 8, 2024
InvestmentTransaction.create!(
  asset: FundAsset.find_by(name: "VESAF"),
  quantity: 162.41,
  nav: 30784.67,
  fee: 0.00,
  transaction_type: "buy",
  unit: "unit",
  date: Date.new(2024, 10, 8),
  user: user
)

# Buy 164.96 VESAF at 30309.07 VND on November 5, 2024
InvestmentTransaction.create!(
  asset: FundAsset.find_by(name: "VESAF"),
  quantity: 164.96,
  nav: 30309.07,
  fee: 0.00,
  transaction_type: "buy",
  unit: "unit",
  date: Date.new(2024, 11, 5),
  user: user
)

# Buy 257.05 VESAF at 31121.70 VND on January 6, 2025
InvestmentTransaction.create!(
  asset: FundAsset.find_by(name: "VESAF"),
  quantity: 257.05,
  nav: 31121.70,
  fee: 0.00,
  transaction_type: "buy",
  unit: "unit",
  date: Date.new(2025, 1, 6),
  user: user
)

# Buy 224.09 VESAF at 31236.12 VND on February 6, 2025
InvestmentTransaction.create!(
  asset: FundAsset.find_by(name: "VESAF"),
  quantity: 224.09,
  nav: 31236.12,
  fee: 0.00,
  transaction_type: "buy",
  unit: "unit",
  date: Date.new(2025, 2, 6),
  user: user
)

# Buy 64.73 VESAF at 30892.91 VND on February 18, 2025
InvestmentTransaction.create!(
  asset: FundAsset.find_by(name: "VESAF"),
  quantity: 64.73,
  nav: 30892.91,
  fee: 0.00,
  transaction_type: "buy",
  unit: "unit",
  date: Date.new(2025, 2, 18),
  user: user
)

# Buy 126.18 VESAF at 31700.37 VND on March 4, 2025
InvestmentTransaction.create!(
  asset: FundAsset.find_by(name: "VESAF"),
  quantity: 126.18,
  nav: 31700.37,
  fee: 0.00,
  transaction_type: "buy",
  unit: "unit",
  date: Date.new(2025, 3, 4),
  user: user
)

# Buy 84 VESAF at 31546.37 on March 6, 2025
InvestmentTransaction.create!(
  asset: FundAsset.find_by(name: "VESAF"),
  quantity: 84,
  nav: 31546.37,
  fee: 0.00,
  transaction_type: "buy",
  unit: "unit",
  date: Date.new(2025, 3, 6),
  user: user
)

# Buy 65.53 VESAF at 30519.67 on April 2, 2025
InvestmentTransaction.create!(
  asset: FundAsset.find_by(name: "VESAF"),
  quantity: 65.53,
  nav: 30519.67,
  fee: 0.00,
  transaction_type: "buy",
  unit: "unit",
  date: Date.new(2025, 4, 2),
  user: user
)

# Buy 39.03 VESAF at 25614.98 on April 9, 2025
InvestmentTransaction.create!(
  asset: FundAsset.find_by(name: "VESAF"),
  quantity: 39.03,
  nav: 25614.98,
  fee: 0.00,
  transaction_type: "buy",
  unit: "unit",
  date: Date.new(2025, 4, 9),
  user: user
)

# Buy 39.03 VESAF at 25614.98 on April 9, 2025
InvestmentTransaction.create!(
  asset: FundAsset.find_by(name: "VESAF"),
  quantity: 39.03,
  nav: 25614.98,
  fee: 0.00,
  transaction_type: "buy",
  unit: "unit",
  date: Date.new(2025, 4, 9),
  user: user
)

# Buy 141.90 VESAF at 28188.23 on May 7, 2025
InvestmentTransaction.create!(
  asset: FundAsset.find_by(name: "VESAF"),
  quantity: 141.90,
  nav: 28188.23,
  fee: 0.00,
  transaction_type: "buy",
  unit: "unit",
  date: Date.new(2025, 5, 7),
  user: user
)

# Buy 169.45 VESAF at 29506.32 on Jun 2, 2025
InvestmentTransaction.create!(
  asset: FundAsset.find_by(name: "VESAF"),
  quantity: 169.45,
  nav: 29506.32,
  fee: 0.00,
  transaction_type: "buy",
  unit: "unit",
  date: Date.new(2025, 6, 2),
  user: user
)

# Buy 160.41 VESAF at 31168.45 on July 7, 2025
InvestmentTransaction.create!(
  asset: FundAsset.find_by(name: "VESAF"),
  quantity: 160.41,
  nav: 31168.45,
  fee: 0.00,
  transaction_type: "buy",
  unit: "unit",
  date: Date.new(2025, 7, 7),
  user: user
)

# Buy 141.75 VESAF at 35272.33 on August 26, 2025
InvestmentTransaction.create!(
  asset: FundAsset.find_by(name: "VESAF"),
  quantity: 141.75,
  nav: 35272.33,
  fee: 0.00,
  transaction_type: "buy",
  unit: "unit",
  date: Date.new(2025, 8, 26),
  user: user
)

# Buy 177.60 VEOF at 28151.83 on March 7, 2024
InvestmentTransaction.create!(
  asset: FundAsset.find_by(name: "VEOF"),
  quantity: 177.60,
  nav: 28151.83,
  fee: 0.00,
  transaction_type: "buy",
  unit: "unit",
  date: Date.new(2024, 3, 7),
  user: user
)

# Buy 103.10 VEOF at 29096.49 on April 2, 2024
InvestmentTransaction.create!(
  asset: FundAsset.find_by(name: "VEOF"),
  quantity: 103.10,
  nav: 29096.49,
  fee: 0.00,
  transaction_type: "buy",
  unit: "unit",
  date: Date.new(2024, 4, 2),
  user: user
)

# Buy 106.15 VEOF at 28258.27 on May 3, 2024
InvestmentTransaction.create!(
  asset: FundAsset.find_by(name: "VEOF"),
  quantity: 106.15,
  nav: 28258.27,
  fee: 0.00,
  transaction_type: "buy",
  unit: "unit",
  date: Date.new(2024, 5, 3),
  user: user
)

# Buy 166.5 VEOF at 30029.57 on June 4, 2024
InvestmentTransaction.create!(
  asset: FundAsset.find_by(name: "VEOF"),
  quantity: 166.5,
  nav: 30029.57,
  fee: 0.00,
  transaction_type: "buy",
  unit: "unit",
  date: Date.new(2024, 6, 4),
  user: user
)

# Buy 169.54 VEOF at 29490.25 on September 11, 2024
InvestmentTransaction.create!(
  asset: FundAsset.find_by(name: "VEOF"),
  quantity: 169.54,
  nav: 29490.25,
  fee: 0.00,
  transaction_type: "buy",
  unit: "unit",
  date: Date.new(2024, 9, 11),
  user: user
)

# Buy 66.91 VEOF at 29890.25 on November 5, 2024
InvestmentTransaction.create!(
  asset: FundAsset.find_by(name: "VEOF"),
  quantity: 66.91,
  nav: 29890.25,
  fee: 0.00,
  transaction_type: "buy",
  unit: "unit",
  date: Date.new(2024, 11, 5),
  user: user
)

# Buy 65.05 VEOF at 30741.15 on January 6, 2025
InvestmentTransaction.create!(
  asset: FundAsset.find_by(name: "VEOF"),
  quantity: 65.05,
  nav: 30741.15,
  fee: 0.00,
  transaction_type: "buy",
  unit: "unit",
  date: Date.new(2025, 1, 6),
  user: user
)

# Buy 32.21 VEOF at 31037.18 on February 6, 2024
InvestmentTransaction.create!(
  asset: FundAsset.find_by(name: "VEOF"),
  quantity: 32.21,
  nav: 31037.18,
  fee: 0.00,
  transaction_type: "buy",
  unit: "unit",
  date: Date.new(2025, 2, 6),
  user: user
)


# Buy 65.16 VEOF at 30693.39 on February 18, 2024
InvestmentTransaction.create!(
  asset: FundAsset.find_by(name: "VEOF"),
  quantity: 65.16,
  nav: 30693.39,
  fee: 0.00,
  transaction_type: "buy",
  unit: "unit",
  date: Date.new(2024, 2, 18),
  user: user
)

# Buy 63.50 VEOF at 31491.49 on March 4, 2025
InvestmentTransaction.create!(
  asset: FundAsset.find_by(name: "VEOF"),
  quantity: 63.50,
  nav: 31491.49,
  fee: 0.00,
  transaction_type: "buy",
  unit: "unit",
  date: Date.new(2025, 3, 4),
  user: user
)

# Buy 79.85 VEOF at 31306.04 on March 6, 2025
InvestmentTransaction.create!(
  asset: FundAsset.find_by(name: "VEOF"),
  quantity: 79.85,
  nav: 31306.04,
  fee: 0.00,
  transaction_type: "buy",
  unit: "unit",
  date: Date.new(2025, 3, 6),
  user: user
)

# Buy 32.68 VEOF at 30598.35 on April 2, 2025
InvestmentTransaction.create!(
  asset: FundAsset.find_by(name: "VEOF"),
  quantity: 32.68,
  nav: 30598.35,
  fee: 0.00,
  transaction_type: "buy",
  unit: "unit",
  date: Date.new(2025, 4, 2),
  user: user
)

# Buy 39.02 VEOF at 25621.83 on April 9, 2025
InvestmentTransaction.create!(
  asset: FundAsset.find_by(name: "VEOF"),
  quantity: 39.02,
  nav: 25621.83,
  fee: 0.00,
  transaction_type: "buy",
  unit: "unit",
  date: Date.new(2025, 4, 9),
  user: user
)

# Buy 72.72 VEOF at 27502.36 on May 7, 2025
InvestmentTransaction.create!(
  asset: FundAsset.find_by(name: "VEOF"),
  quantity: 72.72,
  nav: 27502.36,
  fee: 0.00,
  transaction_type: "buy",
  unit: "unit",
  date: Date.new(2025, 5, 7),
  user: user
)

# Buy 70.12 VEOF at 35648.89 on August 26, 2025
InvestmentTransaction.create!(
  asset: FundAsset.find_by(name: "VEOF"),
  quantity: 70.12,
  nav: 35648.89,
  fee: 0.00,
  transaction_type: "buy",
  unit: "unit",
  date: Date.new(2025, 8, 26),
  user: user
)

# Buy 182.57 VDEF at 10954.64 on March 4, 2025
InvestmentTransaction.create!(
  asset: FundAsset.find_by(name: "VDEF"),
  quantity: 182.57,
  nav: 10954.64,
  fee: 0.00,
  transaction_type: "buy",
  unit: "unit",
  date: Date.new(2025, 3, 4),
  user: user
)

# Buy 229.49 VDEF at 10893.63 on March 6, 2025
InvestmentTransaction.create!(
  asset: FundAsset.find_by(name: "VDEF"),
  quantity: 229.49,
  nav: 10893.63,
  fee: 0.00,
  transaction_type: "buy",
  unit: "unit",
  date: Date.new(2025, 3, 6),
  user: user
)

# Buy 94.94 VDEF at 10532.15 on April 2, 2025
InvestmentTransaction.create!(
  asset: FundAsset.find_by(name: "VDEF"),
  quantity: 94.94,
  nav: 10532.15,
  fee: 0.00,
  transaction_type: "buy",
  unit: "unit",
  date: Date.new(2025, 4, 2),
  user: user
)
# Buy 113.30 VDEF at 8825.75 on April 9, 2025
InvestmentTransaction.create!(
  asset: FundAsset.find_by(name: "VDEF"),
  quantity: 113.30,
  nav: 8825.75,
  fee: 0.00,
  transaction_type: "buy",
  unit: "unit",
  date: Date.new(2025, 4, 9),
  user: user
)

# Buy 109.38 VDEF at 9141.73 on May 7, 2025
InvestmentTransaction.create!(
  asset: FundAsset.find_by(name: "VDEF"),
  quantity: 109.38,
  nav: 9141.73,
  fee: 0.00,
  transaction_type: "buy",
  unit: "unit",
  date: Date.new(2025, 5, 7),
  user: user
)

# Buy 132.67 VMEEF at 15073.95 on February 6, 2025
InvestmentTransaction.create!(
  asset: FundAsset.find_by(name: "VMEEF"),
  quantity: 132.67,
  nav: 15073.95,
  fee: 0.00,
  transaction_type: "buy",
  unit: "unit",
  date: Date.new(2025, 2, 6),
  user: user
)

# Buy 133.84 VMEEF at 14942.17 on on February 18, 2025
InvestmentTransaction.create!(
  asset: FundAsset.find_by(name: "VMEEF"),
  quantity: 133.84,
  nav: 14942.17,
  fee: 0.00,
  transaction_type: "buy",
  unit: "unit",
  date: Date.new(2025, 2, 18),
  user: user
)

# Buy 130.59 VMEEF at 15315.04 on March 4, 2025
InvestmentTransaction.create!(
  asset: FundAsset.find_by(name: "VMEEF"),
  quantity: 130.59,
  nav: 15315.04,
  fee: 0.00,
  transaction_type: "buy",
  unit: "unit",
  date: Date.new(2025, 3, 4),
  user: user
)

# Buy 163.82 VMEEF at 15260.53 on March 6, 2025
InvestmentTransaction.create!(
  asset: FundAsset.find_by(name: "VMEEF"),
  quantity: 163.82,
  nav: 15260.53,
  fee: 0.00,
  transaction_type: "buy",
  unit: "unit",
  date: Date.new(2025, 3, 6),
  user: user
)
# Buy 67.60 VMEEF at 14791.86 on April 2, 2025
InvestmentTransaction.create!(
  asset: FundAsset.find_by(name: "VMEEF"),
  quantity: 67.60,
  nav: 14791.86,
  fee: 0.00,
  transaction_type: "buy",
  unit: "unit",
  date: Date.new(2025, 4, 2),
  user: user
)

# Buy 80.07 VMEEF at 12488.36 on April 9, 2025
InvestmentTransaction.create!(
  asset: FundAsset.find_by(name: "VMEEF"),
  quantity: 80.07,
  nav: 12488.36,
  fee: 0.00,
  transaction_type: "buy",
  unit: "unit",
  date: Date.new(2025, 4, 9),
  user: user
)

# Buy 217.77 VMEEF at 13776 on May 7, 2025
InvestmentTransaction.create!(
  asset: FundAsset.find_by(name: "VMEEF"),
  quantity: 217.77,
  nav: 13776,
  fee: 0.00,
  transaction_type: "buy",
  unit: "unit",
  date: Date.new(2025, 5, 7),
  user: user
)

# Buy 347.62 VMEEF at 14383.41 on Jun 2, 2025
InvestmentTransaction.create!(
  asset: FundAsset.find_by(name: "VMEEF"),
  quantity: 347.62,
  nav: 14383.41,
  fee: 0.00,
  transaction_type: "buy",
  unit: "unit",
  date: Date.new(2025, 6, 2),
  user: user
)

# Buy 333.48 VMEEF at 14993.33 on July 1, 2025
InvestmentTransaction.create!(
  asset: FundAsset.find_by(name: "VMEEF"),
  quantity: 333.48,
  nav: 14993.33,
  fee: 0.00,
  transaction_type: "buy",
  unit: "unit",
  date: Date.new(2025, 7, 1),
  user: user
)

# Buy 147.80 VMEEF at 16914.46 on August 26, 2025
InvestmentTransaction.create!(
  asset: FundAsset.find_by(name: "VMEEF"),
  quantity: 147.80,
  nav: 16914.46,
  fee: 0.00,
  transaction_type: "buy",
  unit: "unit",
  date: Date.new(2025, 8, 26),
  user: user
)

# Buy 56.38 DCDS at 88684.58 on July 1, 2025
InvestmentTransaction.create!(
  asset: FundAsset.find_by(name: "DCDS"),
  quantity: 56.38,
  nav: 88684.58,
  fee: 0.00,
  transaction_type: "buy",
  unit: "unit",
  date: Date.new(2025, 7, 4),
  user: user
)

# Buy 58.57 DCDS at 85388.99 on Jun 2, 2025
InvestmentTransaction.create!(
  asset: FundAsset.find_by(name: "DCDS"),
  quantity: 58.57,
  nav: 85388.99,
  fee: 0.00,
  transaction_type: "buy",
  unit: "unit",
  date: Date.new(2025, 6, 2),
  user: user
)

# Buy 36.41 DCDS at 82392.20 on March 13, 2025
InvestmentTransaction.create!(
  asset: FundAsset.find_by(name: "DCDS"),
  quantity: 36.41,
  nav: 82392.20,
  fee: 0.00,
  transaction_type: "buy",
  unit: "unit",
  date: Date.new(2025, 3, 13),
  user: user
)

# Buy 48.3 DCDS at 103519.66 on August 26, 2025
InvestmentTransaction.create!(
  asset: FundAsset.find_by(name: "DCDS"),
  quantity: 48.3,
  nav: 103519.66,
  fee: 0.00,
  transaction_type: "buy",
  unit: "unit",
  date: Date.new(2025, 8, 26),
  user: user
)

# Buy 70.79 DCDE at 28251.73 on July 1, 2025
InvestmentTransaction.create!(
  asset: FundAsset.find_by(name: "DCDE"),
  quantity: 70.79,
  nav: 28251.73,
  fee: 0.00,
  transaction_type: "buy",
  unit: "unit",
  date: Date.new(2025, 7, 1),
  user: user
)

# Buy 36.03 DCDE at 27753.40 on April 2, 2025
InvestmentTransaction.create!(
  asset: FundAsset.find_by(name: "DCDE"),
  quantity: 36.03,
  nav: 27753.40,
  fee: 0.00,
  transaction_type: "buy",
  unit: "unit",
  date: Date.new(2025, 4, 2),
  user: user
)

# Buy 104.39 DCDE at 28740.63 on March 13, 2025
InvestmentTransaction.create!(
  asset: FundAsset.find_by(name: "DCDE"),
  quantity: 104.39,
  nav: 28740.63,
  fee: 0.00,
  transaction_type: "buy",
  unit: "unit",
  date: Date.new(2025, 3, 13),
  user: user
)
