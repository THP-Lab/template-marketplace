class CartPricing
  Summary = Struct.new(
    :items_total,
    :shipping_amount,
    :tax_rate,
    :tax_amount,
    :total_amount,
    :total_weight,
    keyword_init: true
  )

  def initialize(line_items, company_information: CompanyInformation.instance, destination_country: nil)
    @line_items = Array(line_items)
    @company_information = company_information
    @destination_country = destination_country
  end

  def summary
    items_total = @line_items.sum { |item| unit_price_for(item) * quantity_for(item) }
    total_weight = @line_items.sum { |item| unit_weight_for(item) * quantity_for(item) }
    shipping_amount = @company_information.shipping_amount_for(total_weight, destination_country: @destination_country)
    tax_rate = @company_information.vat_rate_value
    tax_amount = (items_total + shipping_amount) * tax_rate / 100

    Summary.new(
      items_total: items_total,
      shipping_amount: shipping_amount,
      tax_rate: tax_rate,
      tax_amount: tax_amount,
      total_amount: items_total + shipping_amount + tax_amount,
      total_weight: total_weight
    )
  end

  private

  def quantity_for(item)
    raw_value = read_value(item, :quantity)
    raw_value.to_i
  end

  def unit_price_for(item)
    read_value(item, :unit_price).to_d
  end

  def unit_weight_for(item)
    if item.respond_to?(:unit_weight_value)
      item.unit_weight_value
    else
      read_value(item, :unit_weight).to_d
    end
  end

  def read_value(item, key)
    if item.is_a?(Hash)
      item[key] || item[key.to_s]
    elsif item.respond_to?(key)
      item.public_send(key)
    end
  end
end
