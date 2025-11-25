# db/seeds.rb

require "faker"

puts "Nettoyage de la base..."

# IMPORTANT : respecter l'ordre des foreign keys
CartProduct.destroy_all
OrderProduct.destroy_all
Cart.destroy_all
Order.destroy_all
Product.destroy_all
User.destroy_all

puts "Base nettoyée."

SEED_USER_COUNT      = 10
SEED_PRODUCT_COUNT   = 200
SEED_USER_PASSWORD   = "123456"
USER_EMAIL_DOMAIN    = "mail.com"
PRODUCT_TYPES        = %w[armure bijoux accesoires vetements armes].freeze

def seed_user_emails
  Array.new(SEED_USER_COUNT) { |index| "user#{index + 1}@#{USER_EMAIL_DOMAIN}" }
end

puts "Création des utilisateurs..."

users = seed_user_emails.map do |email|
  User.create!(
    email: email,
    password: SEED_USER_PASSWORD,
    password_confirmation: SEED_USER_PASSWORD
  )
end

puts "Création des produits..."

products = Array.new(SEED_PRODUCT_COUNT) do
  Product.create!(
    title:       Faker::Commerce.product_name,
    description: Faker::Lorem.paragraph(sentence_count: 3),
    price:       rand(500..5000),
    stock:       Faker::Number.within(range: 0..250),
    type:        PRODUCT_TYPES.sample
  )
end

puts "Création des paniers et des produits de panier..."

users.each do |user|
  cart = Cart.create!(
    user:   user,
    status: "open"
  )

  # 0 à 5 produits par panier
  rand(0..5).times do
    product  = products.sample
    quantity = rand(1..3)

    CartProduct.create!(
      cart:       cart,
      product:    product,
      quantity:   quantity,
      unit_price: product.price
    )
  end
end

puts "Création des commandes et des produits de commande..."

users.each do |user|
  # 0 à 3 commandes par utilisateur
  rand(0..3).times do
    order = Order.create!(
      user:         user,
      order_date:   Faker::Date.between(from: 1.year.ago, to: Date.today),
      status:       %w[pending paid shipped cancelled].sample,
      total_amount: 0 # calculé juste après
    )

    # 1 à 5 produits par commande
    line_items      = []
    rand(1..5).times do
      product  = products.sample
      quantity = rand(1..3)

      line_items << OrderProduct.create!(
        order:      order,
        product:    product,
        quantity:   quantity,
        unit_price: product.price
      )
    end

    # Mise à jour du total de la commande
    total = line_items.sum { |li| li.quantity * li.unit_price }
    order.update!(total_amount: total)
  end
end

puts "Seed terminée."
