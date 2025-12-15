require "prawn"
require "prawn/table"

class InvoicePdf
  include ActionView::Helpers::NumberHelper

  def initialize(order, company_information)
    @order = order
    @company_information = company_information
  end

  def render
    Prawn::Document.new(page_size: "A4") do |pdf|
      header(pdf)
      customer_block(pdf)
      items_table(pdf)
      totals(pdf)
      footer(pdf)
    end.render
  end

  private

  def header(pdf)
    pdf.text @company_information.legal_name.presence || "Votre entreprise", size: 14, style: :bold
    company_address_lines.each { |line| pdf.text line }
    pdf.move_down 20

    pdf.text "Facture - Commande ##{@order.id}", size: 18, style: :bold
    pdf.text "Date de commande : #{formatted_order_date}"
    pdf.move_down 10
  end

  def customer_block(pdf)
    pdf.text "Client", style: :bold
    pdf.text customer_name
    pdf.text customer_email if @order.user&.email.present?
    pdf.move_down 10
  end

  def items_table(pdf)
    data = [
      ["Produit", "Quantité", "Prix unitaire", "Total"]
    ]

    if @order.order_products.any?
      @order.order_products.each do |order_product|
        product = order_product.product
        name = product&.title.presence || "Produit ##{order_product.product_id}"
        quantity = order_product.quantity.to_i
        unit_price = unit_price_for(order_product)
        data << [
          name,
          quantity,
          number_to_currency(unit_price, unit: "€"),
          number_to_currency(unit_price * quantity, unit: "€")
        ]
      end
    else
      data << ["Aucun produit associé", "", "", ""]
    end

    pdf.table(data, header: true, width: pdf.bounds.width) do
      row(0).font_style = :bold
      columns(1..3).align = :right
    end
    pdf.move_down 10
  end

  def totals(pdf)
    total = @order.total_amount || computed_total
    pdf.text "Total TTC : #{number_to_currency(total, unit: "€")}", size: 12, style: :bold
    pdf.text "Paiement traité via Stripe.", size: 10
    pdf.move_down 10
  end

  def footer(pdf)
    lines = []
    lines << "SIRET / SIREN : #{@company_information.siret}" if @company_information.siret.present?
    lines << "Numéro de TVA : #{@company_information.vat_number}" if @company_information.vat_number.present?
    lines << "Téléphone : #{@company_information.phone}" if @company_information.phone.present?
    lines << "Email : #{@company_information.email}" if @company_information.email.present?
    lines << @company_information.additional_info if @company_information.additional_info.present?

    return if lines.empty?

    pdf.stroke_horizontal_rule
    pdf.move_down 8
    lines.each { |line| pdf.text line, size: 9 }
  end

  def company_address_lines
    lines = []
    lines << @company_information.address_line1 if @company_information.address_line1.present?
    lines << @company_information.address_line2 if @company_information.address_line2.present?
    location = @company_information.location_line
    lines << location if location.present?
    lines
  end

  def formatted_order_date
    return "—" unless @order.order_date.present?
    @order.order_date.strftime("%d/%m/%Y")
  end

  def customer_name
    first = @order.user&.first_name
    last = @order.user&.last_name
    name = [first, last].compact.join(" ").strip
    return name unless name.blank?
    "Client ##{@order.user_id || '—'}"
  end

  def customer_email
    @order.user.email
  end

  def unit_price_for(order_product)
    (order_product.unit_price || order_product.product&.price || 0).to_d
  end

  def computed_total
    @order.order_products.sum do |order_product|
      unit_price_for(order_product) * order_product.quantity.to_i
    end
  end
end
