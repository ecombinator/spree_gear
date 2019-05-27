Rails.application.configure do
  config.use_paperclip = ActiveModel::Type::Boolean.new.cast true
end
