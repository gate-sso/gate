json.extract! api_resource, :id, :name, :description, :access_key, :created_at, :updated_at
json.url api_resource_url(api_resource, format: :json)
