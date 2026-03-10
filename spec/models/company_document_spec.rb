require "rails_helper"

RSpec.describe CompanyDocument, type: :model do
  def build_pdf_file(name = "fiche")
    { io: StringIO.new("%PDF-1.4 fake content"), filename: "#{name}.pdf", content_type: "application/pdf" }
  end

  def build_non_pdf_file
    { io: StringIO.new("not a pdf"), filename: "image.png", content_type: "image/png" }
  end

  it "is valid with title and pdf file" do
    company_information = CompanyInformation.instance
    document = company_information.company_documents.new(title: "Fiche technique")
    document.file.attach(build_pdf_file)

    expect(document).to be_valid
  end

  it "is invalid without file" do
    company_information = CompanyInformation.instance
    document = company_information.company_documents.new(title: "Sans fichier")

    expect(document).not_to be_valid
    expect(document.errors[:file]).to include("doit être ajouté")
  end

  it "is invalid with non-pdf file" do
    company_information = CompanyInformation.instance
    document = company_information.company_documents.new(title: "Mauvais type")
    document.file.attach(build_non_pdf_file)

    expect(document).not_to be_valid
    expect(document.errors[:file]).to include("doit être au format PDF")
  end
end
