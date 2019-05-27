json.extract! mailing, :id, :name, :from, :subject, :created_at, :updated_at
json.url admin_mailing_url(mailing, format: :json)
