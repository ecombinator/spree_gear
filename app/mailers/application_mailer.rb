class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch('INQUIRIES_EMAIL', 'no-reply@cannabis.com')
  layout 'mailer'
end

