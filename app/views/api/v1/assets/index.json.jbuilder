json.array! @assets do |asset|
  json.id asset.id
  json.name asset.name
  json.type asset.type
  json.created_at asset.created_at
  json.updated_at asset.updated_at
  json.category do
    json.id asset.category.id
    json.name asset.category.name
  end
end

