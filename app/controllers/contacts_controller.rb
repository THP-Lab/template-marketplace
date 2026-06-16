class ContactsController < ApplicationController
  before_action :set_company_information, only: [:new, :create]

  def new
    @contact = Contact.new
  end

  def create
    @contact = Contact.new(contact_params)
    if @contact.save
      UserMailer.request_treatment_email(@contact).deliver_now
      UserMailer.admin_contact_email(@contact).deliver_now
      redirect_to new_contact_path, notice: "Merci pour votre message."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def contact_params
    params.require(:contact).permit(:name, :email, :subject, :message)
  end

  def set_company_information
    @company_information = CompanyInformation.instance
  end
end
