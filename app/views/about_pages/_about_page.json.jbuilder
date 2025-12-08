json.extract! about_page, :id, :title, :content, :position, :created_at, :updated_at
json.url about_page_url(about_page, format: :json)
