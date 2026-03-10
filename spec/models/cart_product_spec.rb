require "rails_helper"

RSpec.describe CartProduct, type: :model do
  it "builds a deterministic signature from selected options" do
    options = [
      { option_id: 4, value_id: 12 },
      { option_id: 2, value_id: 7 }
    ]

    expect(CartProduct.signature_for(options)).to eq("2:7|4:12")
  end

  it "exposes a readable label for selected options" do
    user = User.create!(email: "client-cart@example.com", password: "password", cgu_accepted: true)
    cart = user.create_cart!(status: "open")
    product = Product.create!(title: "Casque", price: 90, stock: 1)

    cart_product = cart.cart_products.create!(
      product: product,
      quantity: 1,
      unit_price: 90,
      selected_options: [
        { option_name: "Taille", value_label: "56", option_id: 1, value_id: 1 },
        { option_name: "Couleur", value_label: "Noir", option_id: 2, value_id: 2 }
      ]
    )

    expect(cart_product.selected_options_label).to include("Taille : 56")
    expect(cart_product.selected_options_label).to include("Couleur : Noir")
  end
end
