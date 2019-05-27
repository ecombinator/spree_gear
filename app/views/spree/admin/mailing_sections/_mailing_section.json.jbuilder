json.extract! mailing_section, :id, :mailing_id, :url, :created_at, :updated_at
json.url admin_mailing_section_url(mailing_section, format: :json)
