json.extract! page, :id, :url_string, :created_at, :updated_at
json.url page_url(page, format: :json)
