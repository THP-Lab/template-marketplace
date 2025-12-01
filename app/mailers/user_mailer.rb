class UserMailer < Devise::Mailer
  default from: ENV["GMAIL_LOGIN"]
  layout "mailer"

  def welcome_email(user)
    # on récupère l'instance user pour ensuite pouvoir la passer à la view en @user
    @user = user

    # on définit une variable @url qu'on utilisera dans la view d’e-mail
    @url  = "http://monsite.fr/login"

    # c'est cet appel à mail() qui permet d'envoyer l’e-mail en définissant destinataire et sujet.
    mail(to: @user.email, subject: "Bienvenue Templier !")
  end

  def order_email(order)
    @order = order
    @user = order.user
    @url  = "http://localhost:3000/orders/#{order.id}"

    mail(to: @user.email, subject: "Confirmation de commande ##{order.id}")
  end

  def admin_order_email(order)
    @admins = User.where(is_admin: true)
    @order = order
    @user = order.user
    @url  = "http://localhost:3000/orders/#{order.id}"

    mail(
      to: @admins.pluck(:email),
      subject: "Nouvelle commande ##{@order.id} reçue !"
    )
  end

  def request_treatment_email(contact)
    @contact = contact
    @url = "http://localhost:3000/contacts/new"
    mail(to: @contact.email, subject: "Demande en cours de traitement")
  end

  def admin_contact_email(contact)
    @admins = User.where(is_admin: true)
    @contact = contact
    @url = "http://localhost:3000/contacts/new"
    
    mail(
      to: @admins.pluck(:email),
      subject: "Nouvelle demande de contact !"
    )
  end

end
