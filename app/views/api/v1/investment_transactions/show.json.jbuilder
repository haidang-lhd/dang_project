json.id @investment_transaction.id
json.transaction_type @investment_transaction.transaction_type
json.quantity @investment_transaction.quantity
json.nav @investment_transaction.nav
json.total_amount @investment_transaction.total_amount
json.fee @investment_transaction.fee
json.unit @investment_transaction.unit
json.date @investment_transaction.date
json.created_at @investment_transaction.created_at
json.updated_at @investment_transaction.updated_at
json.user do
  json.id @investment_transaction.user.id
  json.email @investment_transaction.user.email
end
json.asset do
  json.id @investment_transaction.asset.id
  json.name @investment_transaction.asset.name
  json.type @investment_transaction.asset.type
  json.category do
    json.id @investment_transaction.asset.category.id
    json.name @investment_transaction.asset.category.name
  end
end

