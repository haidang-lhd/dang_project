# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Create default categories for assets
[ "Stocks", "Gold", "Bonds", "Real Estate", "Cryptocurrency", "Investment Fund Certificates" ].each do |category_name|
  Category.find_or_create_by!(name: category_name)
end

# Create default Assets
# Investment Fund Certificates
[ "VESAF", "VMEEF", "VEOF", "VDEF", "DCDS", "DCDE" ].each do |label_name|
  Asset.find_or_create_by!(name: label_name, category: Category.find_by(name: "Investment Fund Certificates"))
end

# Stocks
[ "VPB" ].each do |label_name|
  Asset.find_or_create_by!(name: label_name, category: Category.find_by(name: "Stocks"))
end

# Gold
[ "SJC", "DOJI", "Mi Hong" ].each do |label_name|
  Asset.find_or_create_by!(name: label_name, category: Category.find_by(name: "Gold"))
end
