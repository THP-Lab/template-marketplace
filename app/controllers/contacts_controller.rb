class ContactsController < ApplicationController
  def new
    @contact = Contact.new
  end

  def create
    @contact = Contact.new(contact_params)
    if @contact.save
      UserMailer.request_treatment_email(@contact).deliver_later
      UserMailer.admin_contact_email(@contact).deliver_later
      redirect_to new_contact_path, notice: "Merci pour votre message."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def contact_params
    params.require(:contact).permit(:name, :email, :subject, :message)
  end
end
