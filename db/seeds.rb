# db/seeds.rb

require "faker"

puts "Nettoyage de la base..."

# IMPORTANT : respecter l'ordre des foreign keys (enfants -> parents)
AboutSection.destroy_all
PageSection.where(page_type: "reparation").destroy_all
CartProduct.destroy_all
OrderProduct.destroy_all
Cart.destroy_all
Order.destroy_all
Event.destroy_all
Product.destroy_all
User.destroy_all

puts "Base nettoyée."

SEED_USER_COUNT      = 10
SEED_PRODUCT_COUNT   = 20
SEED_EVENT_COUNT     = 20
SEED_USER_PASSWORD   = "123456"
USER_EMAIL_DOMAIN    = "mail.com"
PRODUCT_TYPES        = %w[armure bijoux accesoires vetements armes].freeze
EVENT_CATEGORIES     = %w[Twitch Salon Reconstitution].freeze

def seed_user_emails
  Array.new(SEED_USER_COUNT) { |index| "user#{index + 1}@#{USER_EMAIL_DOMAIN}" }
end

puts "Création des utilisateurs..."

users = seed_user_emails.map do |email|
  User.create!(
    email: email,
    password: SEED_USER_PASSWORD,
    password_confirmation: SEED_USER_PASSWORD,
    first_name: Faker::Name.first_name.gsub(/[^a-zA-ZÀ-ÿ]/, ''),
    last_name: Faker::Name.last_name.gsub(/[^a-zA-ZÀ-ÿ]/, ''),
    address: Faker::Address.street_address,
    city: Faker::Address.city,
    country: "France",
    zipcode: Faker::Address.zip_code,
    phone: Faker::PhoneNumber.cell_phone,
    cgu_accepted: true,
    is_admin: false
  )
end

# -------------------------------------------------------------------
# Admin d'office : user1 si possible
# -------------------------------------------------------------------
admin = User.find_by(email: "user1@#{USER_EMAIL_DOMAIN}") || users.first
admin.update!(is_admin: true)

puts "Admin créé : #{admin.email} (is_admin = #{admin.is_admin})"

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

# -------------------------------------------------------------------
# Création des événements
# -------------------------------------------------------------------
puts "Création des événements..."

events = Array.new(SEED_EVENT_COUNT) do
  Event.create!(
    user:        users.sample, # tu peux mettre admin si tu veux que tout lui appartienne
    title:       Faker::Lorem.sentence(word_count: 3),
    description: Faker::Lorem.paragraph(sentence_count: 4),
    event_date:  Faker::Time.between(from: 6.months.ago, to: 6.months.from_now),
    location:    Faker::Address.city,
    image_url:   "https://picsum.photos/seed/#{rand(1000)}/800/400",
    category:    EVENT_CATEGORIES.sample
  )
end

puts "#{events.count} événements créés."

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
    line_items = []
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

puts "Création des sections À propos..."

AboutSection.create!(
  title: "Qui sommes-nous ?",
  content: "Nous travaillons la maille artisanale avec passion depuis plusieurs années.",
  position: 1
)

AboutSection.create!(
  title: "Notre atelier",
  content: "Chaque pièce est fabriquée à la main avec des matériaux de qualité.",
  position: 2
)

puts "Seed À propos terminée."
puts "Création des sections pour la page réparation..."

PageSection.create!(
  page_type: "reparation",
  title: "Réparations artisanales",
  content: "Nous restaurons vos pièces avec un travail minutieux et fidèle aux techniques traditionnelles.",
  position: 1
)

PageSection.create!(
  page_type: "reparation",
  title: "Comment ça fonctionne ?",
  content: "Dépose ton article, nous analysons l’état, puis nous te proposons un devis clair avant toute intervention.",
  position: 2
)

puts "Seed réparation terminée."

puts "Seed terminée."
