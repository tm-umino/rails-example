json.extract! news, :id, :title, :writer, :contents, :memberOnly, :created_at, :updated_at, :created_at, :updated_at
json.url news_url(news, format: :json)
