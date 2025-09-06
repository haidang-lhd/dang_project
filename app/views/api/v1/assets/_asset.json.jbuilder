json.extract! asset, :id, :name, :type, :created_at, :updated_at
json.category do
  json.extract! asset.category, :id, :name
end
