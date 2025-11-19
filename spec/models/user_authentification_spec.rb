require 'rails_helper'

RSpec.describe "Authentification utilisateur", type: :system do
  let!(:user) do
    User.create!(
      email: "test@example.com",
      password: "password123",
      password_confirmation: "password123"
    )
  end

  it "permet de se connecter avec les bons identifiants" do
    visit new_user_session_path

    fill_in "Email", with: "test@example.com"
    fill_in "Password", with: "password123"
    click_button "Log in" # adapte si ton bouton a un autre texte

    # Adapte selon ton flash/message d'accueil
    expect(page).to have_content("Signed in successfully").or have_content("Connexion réussie")
  end

  it "refuse la connexion avec un mauvais mot de passe" do
    visit new_user_session_path

    fill_in "Email", with: "test@example.com"
    fill_in "Password", with: "wrongpassword"
    click_button "Log in"

    # Message d'erreur Devise par défaut (en anglais) sauf si tu l'as traduit
    expect(page).to have_content("Invalid Email or password").or have_content("Email ou mot de passe incorrect")
  end
end
