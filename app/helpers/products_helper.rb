module ProductsHelper
  def product_option_value_label(value)
    delta = value.price_delta.to_d
    return value.label if delta.zero?

    formatted_delta = number_to_currency(delta.abs, unit: "€", format: "%n %u")
    suffix = delta.positive? ? " (+#{formatted_delta})" : " (-#{formatted_delta})"
    "#{value.label}#{suffix}"
  end
end
