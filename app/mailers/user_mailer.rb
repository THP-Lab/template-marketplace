class UserMailer < Devise::Mailer
  default from: ENV["GMAIL_LOGIN"]
  layout "mailer"

  EXCLUDED_ADMIN_EMAILS = [ "lilian@thehackingproject.org" ].freeze

  def welcome_email(user)
    @user = user
    @login_url = "#{app_host}/users/sign_in"
    @home_url = app_host

    mail(to: @user.email, subject: "Bienvenue sur l'atelier")
  end

  def order_email(order)
    @order = order
    @user = order.user
    @order_url = "#{app_host}/orders/#{order.id}"

    mail(to: @user.email, subject: "Confirmation de commande ##{order.id}")
  end

  def admin_order_email(order)
    @admins = User.where(is_admin: true).where.not(email: EXCLUDED_ADMIN_EMAILS)
    @order = order
    @user = order.user
    @order_url = "#{app_host}/orders/#{order.id}"

    mail(
      to: @admins.pluck(:email),
      subject: "Nouvelle commande ##{@order.id}"
    )
  end

  def order_status_update_email(order, previous_status:)
    @order = order
    @user = order.user
    @order_url = "#{app_host}/orders/#{order.id}"
    @current_status = order.status_label
    if previous_status.present? && previous_status != order.status
      @previous_status = order.status_label(previous_status)
    end
    @tracking_number = order.tracking_number.presence

    mail(
      to: @user.email,
      subject: "Mise à jour de votre commande ##{order.id} : #{@current_status}"
    )
  end

  def request_treatment_email(contact)
    @contact = contact
    @contact_url = "#{app_host}/contacts/new"
    @home_url = app_host
    mail(to: @contact.email, subject: "Confirmation de réception de votre message")
  end

  def admin_contact_email(contact)
    @admins = User.where(is_admin: true).where.not(email: EXCLUDED_ADMIN_EMAILS)
    @contact = contact
    @contact_url = "#{app_host}/contacts/new"

    mail(
      to: @admins.pluck(:email),
      subject: "Nouvelle demande de contact"
    )
  end

  private

  def app_host
    ENV["APP_HOST"].to_s.chomp("/")
  end
end
