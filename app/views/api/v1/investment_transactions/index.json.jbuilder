json.array! @investment_transactions do |transaction|
  json.id transaction.id
  json.transaction_type transaction.transaction_type
  json.quantity transaction.quantity
  json.nav transaction.nav
  json.total_amount transaction.total_amount
  json.fee transaction.fee
  json.unit transaction.unit
  json.date transaction.date
  json.created_at transaction.created_at
  json.updated_at transaction.updated_at
  json.user do
    json.id transaction.user.id
    json.email transaction.user.email
  end
  json.asset do
    json.id transaction.asset.id
    json.name transaction.asset.name
    json.type transaction.asset.type
  end
end

