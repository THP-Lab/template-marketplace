require "faker"

CartProduct.destroy_all
Cart.destroy_all
Product.destroy_all
User.destroy_all

SEED_USER_COUNT = 10
SEED_PRODUCT_COUNT = 200
SEED_USER_PASSWORD = "123456"
USER_EMAIL_DOMAIN = "mail.com"
PRODUCT_TYPES = %w[armure bijoux accesoires vetements armes].freeze

def seed_user_emails
  Array.new(SEED_USER_COUNT) { |index| "user#{index + 1}@#{USER_EMAIL_DOMAIN}" }
end

puts "Purging invalid and previously seeded data..."

# Remove blank or incomplete entries to keep the environment predictable.
Product.where(title: [ nil, "" ])
      .or(Product.where(description: [ nil, "" ]))
      .delete_all
User.where(email: [ nil, "" ]).delete_all

User.where(email: seed_user_emails).delete_all

puts "Creating #{SEED_USER_COUNT} users..."
seed_user_emails.each do |email|
  User.create!(
    email: email,
    password: SEED_USER_PASSWORD,
    password_confirmation: SEED_USER_PASSWORD
  )
end

puts "Creating #{SEED_PRODUCT_COUNT} products..."
SEED_PRODUCT_COUNT.times do
  Product.create!(
    title: Faker::Commerce.product_name,
    description: Faker::Lorem.paragraph(sentence_count: 3),
    price: rand(500..5000),
    stock: Faker::Number.within(range: 0..250),
    type: PRODUCT_TYPES.sample
  )
end


puts "Seed complete."
