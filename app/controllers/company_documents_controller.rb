class CompanyDocumentsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin!
  before_action :set_company_information
  before_action :set_company_document, only: [:edit, :update, :destroy]

  def index
    @company_document = @company_information.company_documents.new
    @company_documents = @company_information.company_documents.ordered
  end

  def create
    @company_document = @company_information.company_documents.new(company_document_params)

    if @company_document.save
      redirect_to company_information_documents_path, notice: "Document ajouté."
    else
      @company_documents = @company_information.company_documents.ordered
      flash.now[:alert] = "Impossible d'ajouter ce document."
      render :index, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @company_document.update(company_document_params)
      redirect_to company_information_documents_path, notice: "Document mis à jour."
    else
      flash.now[:alert] = "Impossible de mettre à jour ce document."
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @company_document.destroy
    redirect_to company_information_documents_path, notice: "Document supprimé.", status: :see_other
  end

  private

  def set_company_information
    @company_information = CompanyInformation.instance
  end

  def set_company_document
    @company_document = @company_information.company_documents.find(params.expect(:id))
  end

  def company_document_params
    params.expect(company_document: [:title, :file])
  end
end
