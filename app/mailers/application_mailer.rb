class ApplicationMailer < ActionMailer::Base
  default from: ENV["GMAIL_LOGIN"]
  layout "mailer"
end
