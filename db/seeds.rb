# frozen_string_literal: true

require "faker"

Faker::Config.locale = "fr"

SEED_PASSWORD = ENV.fetch("SEED_PASSWORD", "123456")
USER_EMAIL_DOMAIN = "mail.com"
PRODUCT_TYPES = %w[armure bijoux accessoires vetements armes].freeze
EVENT_CATEGORIES = ["Marché médiéval", "Atelier", "Reconstitution", "En ligne"].freeze
ORDER_STATUSES = %w[pending paid shipped cancelled].freeze

def separator(title)
  puts "\n#{'-' * 70}"
  puts title
  puts "#{'-' * 70}"
end

def clean_table(model)
  before = model.count
  model.destroy_all
  puts format("• %-16s supprimés : %d", model.name, before)
end

def sanitize_name(value, fallback)
  cleaned = I18n.transliterate(value.to_s).gsub(/[^a-zA-Z]/, "")
  cleaned.presence || fallback
end

separator("Nettoyage de la base")
[CartProduct, OrderProduct, Cart, Order, Event, Contact, Product, AboutPage, HomePage, PrivacyPage, RepairPage, TermsPage].each do |model|
  clean_table(model)
end
clean_table(User)

separator("Création des utilisateurs")
admin = User.create!(
  email: "admin@#{USER_EMAIL_DOMAIN}",
  password: SEED_PASSWORD,
  password_confirmation: SEED_PASSWORD,
  first_name: "Admin",
  last_name: "Templier",
  address: Faker::Address.street_address,
  city: Faker::Address.city,
  country: "France",
  zipcode: Faker::Address.zip_code,
  phone: Faker::PhoneNumber.cell_phone,
  cgu_accepted: true,
  is_admin: true
)
puts "• Admin : #{admin.email} (mot de passe: #{SEED_PASSWORD})"

regular_users = Array.new(8) do |index|
  first_name = sanitize_name(Faker::Name.first_name, "User#{index + 1}")
  last_name = sanitize_name(Faker::Name.last_name, "Demo#{index + 1}")
  User.create!(
    email: "user#{index + 1}@#{USER_EMAIL_DOMAIN}",
    password: SEED_PASSWORD,
    password_confirmation: SEED_PASSWORD,
    first_name: first_name,
    last_name: last_name,
    address: Faker::Address.street_address,
    city: Faker::Address.city,
    country: "France",
    zipcode: Faker::Address.zip_code,
    phone: Faker::PhoneNumber.cell_phone,
    cgu_accepted: true
  )
end

users = [admin] + regular_users
puts "• Utilisateurs créés : #{users.size} dont #{users.count(&:is_admin)} admin"
puts "• Les paniers sont générés automatiquement via le callback User#create_cart"

separator("Création des produits")
products = PRODUCT_TYPES.flat_map do |category|
  Array.new(5) do
    Product.create!(
      title: "#{category.capitalize} #{Faker::Commerce.product_name}",
      description: Faker::Lorem.paragraph(sentence_count: 3),
      price: Faker::Commerce.price(range: 40.0..400.0, as_string: false),
      stock: rand(5..80),
      type: category
    )
  end
end
puts "• #{products.size} produits créés (types : #{PRODUCT_TYPES.join(', ')})"

separator("Paniers en cours")
users.each do |user|
  cart = user.cart || user.create_cart
  cart.update!(status: "open")
  cart.cart_products.destroy_all

  sampled_products = products.sample(rand(1..4))
  sampled_products.each do |product|
    CartProduct.create!(
      cart: cart,
      product: product,
      quantity: rand(1..3),
      unit_price: product.price
    )
  end

  total = cart.cart_products.sum { |cp| cp.quantity * cp.unit_price }
  puts format("• %-25s : %2d articles (%6.2f €)", user.email, cart.cart_products.count, total)
end

separator("Commandes passées")
orders = []
users.each do |user|
  rand(1..2).times do
    order = user.orders.create!(
      order_date: Faker::Date.between(from: 5.months.ago, to: Date.today),
      status: ORDER_STATUSES.sample,
      total_amount: 0
    )

    line_items = products.sample(rand(1..4)).map do |product|
      order.order_products.create!(
        product: product,
        quantity: rand(1..3),
        unit_price: product.price
      )
    end

    total = line_items.sum { |li| li.quantity * li.unit_price }
    order.update!(total_amount: total)
    orders << order
  end
end
puts "• #{orders.count} commandes générées (statuts : #{ORDER_STATUSES.join(', ')})"

separator("Événements programmés")
events = Array.new(6) do |index|
  Event.create!(
    user: users.sample,
    title: "Événement #{index + 1} - #{Faker::Ancient.primordial}",
    description: Faker::Lorem.paragraph(sentence_count: 4),
    event_date: Faker::Time.between(from: 2.months.ago, to: 3.months.from_now),
    location: Faker::Address.city,
    image_url: "https://picsum.photos/seed/event#{index}/900/450",
    category: EVENT_CATEGORIES.sample
  )
end
puts "• #{events.count} événements créés"

separator("Messages de contact")
contacts = [
  {
    name: "Clara",
    email: users[2].email,
    subject: "Demande de devis",
    message: "Je souhaiterais restaurer une cotte de mailles familiale. Pouvez-vous me rappeler ?"
  },
  {
    name: "Mathieu",
    email: users[3].email,
    subject: "Personnalisation",
    message: "Est-il possible de graver un motif sur une dague existante ?"
  },
  {
    name: "Anais",
    email: users[4].email,
    subject: "Disponibilité atelier",
    message: "Avez-vous des créneaux pour une visite de l'atelier ce mois-ci ?"
  }
].map { |attrs| Contact.create!(attrs) }
puts "• #{contacts.count} messages de contact enregistrés"

separator("Pages statiques")
def seed_page(model, entries)
  entries.each_with_index do |attrs, index|
    model.create!(attrs.merge(position: attrs[:position] || index + 1))
  end
  puts format("• %-14s : %d entrées", model.name, model.count)
end

seed_page(HomePage, [
  { title: "Atelier & créations", content: "Forger la maille, c'est mêler patience et précision. Découvrez nos pièces uniques et les coulisses de l'atelier." },
  { title: "Commandes sur mesure", content: "Parlez-nous de votre projet : armure complète, bijoux ou accessoire, nous créons à partir de vos envies." },
  { title: "Engagés pour la qualité", content: "Acier, cuir, bois : nous choisissons des matériaux durables et vérifions chaque détail avant livraison." }
])

seed_page(AboutPage, [
  { title: "Notre histoire", content: "Templiers par passion, artisans par vocation. Nous façonnons chaque pièce pour qu'elle traverse le temps." },
  { title: "L'atelier", content: "Entre enclumes et maillets, nous testons, polissons et renforçons chaque création pour un rendu authentique." },
  { title: "Rencontrez l'équipe", content: "Des forgerons aux couteliers, nous partageons le même désir : créer des objets qui racontent une histoire." }
])

seed_page(RepairPage, [
  { title: "Diagnostic complet", content: "Avant toute réparation, nous évaluons l'état de votre pièce et proposons un devis clair." },
  { title: "Restauration fidèle", content: "Nous respectons les techniques d'époque pour redonner vie à vos équipements." },
  { title: "Suivi transparent", content: "Vous recevez des photos des étapes clés : démontage, remplacement, finitions." }
])

seed_page(PrivacyPage, [
  { title: "Protection des données", content: "Vos informations sont utilisées uniquement pour traiter vos commandes et demandes de contact." },
  { title: "Transparence", content: "Vous pouvez demander la suppression ou la modification de vos données à tout moment." }
])

seed_page(TermsPage, [
  { title: "Conditions générales", content: "En validant une commande, vous acceptez nos délais de fabrication et nos politiques de retour." },
  { title: "Paiements & sécurité", content: "Les transactions sont sécurisées et vos coordonnées bancaires ne sont jamais conservées." },
  { title: "Livraison", content: "Chaque envoi est protégé et suivi. Nous vous communiquons les informations de suivi dès l'expédition." }
])

separator("Résumé")
puts "Utilisateurs : #{User.count} (password commun : #{SEED_PASSWORD})"
puts "Produits     : #{Product.count}"
puts "Paniers      : #{Cart.count}"
puts "Commandes    : #{Order.count}"
puts "Événements   : #{Event.count}"
puts "Contacts     : #{Contact.count}"
puts "Pages        : #{HomePage.count} home, #{AboutPage.count} about, #{RepairPage.count} réparation, #{PrivacyPage.count} privacy, #{TermsPage.count} CGU"
puts "\nSeed terminée. Lance `bin/rails db:seed` pour charger ces données."
