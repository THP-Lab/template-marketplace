class Admin::DashboardController < ApplicationController
  before_action :require_admin!

  def index
    @admin_sections = [
      {
        id: "products",
        title: "Produits",
        icon: "bi-box-seam",
        description: "Gérez le catalogue et les stocks disponibles.",
        links: [
          { label: "Tous les produits", path: products_path },
          { label: "Créer un produit", path: new_product_path }
        ]
      },
      {
        id: "events",
        title: "Événements",
        icon: "bi-calendar-event",
        description: "Programmez les événements, ateliers et rencontres.",
        links: [
          { label: "Liste des événements", path: events_path },
          { label: "Ajouter un événement", path: new_event_path }
        ]
      },
      {
        id: "repair-pages",
        title: "Service réparation",
        icon: "bi-tools",
        description: "Pages dédiées aux offres de réparation.",
        links: [
          { label: "Pages réparation", path: repair_pages_path },
          { label: "Nouvelle page réparation", path: new_repair_page_path }
        ]
      },
      {
        id: "home-pages",
        title: "Page d’accueil",
        icon: "bi-house-door",
        description: "Sections et blocs de la page d’accueil.",
        links: [
          { label: "Blocs d’accueil", path: home_pages_path },
          { label: "Ajouter un bloc d’accueil", path: new_home_page_path }
        ]
      },
      {
        id: "about-pages",
        title: "À propos",
        icon: "bi-people",
        description: "Sections de la page À propos.",
        links: [
          { label: "Contenus À propos", path: about_pages_path },
          { label: "Ajouter une section", path: new_about_page_path }
        ]
      },
      {
        id: "privacy-pages",
        title: "Confidentialité",
        icon: "bi-shield-lock",
        description: "Contenus de politique de confidentialité.",
        links: [
          { label: "Pages confidentialité", path: privacy_pages_path },
          { label: "Nouvelle page confidentialité", path: new_privacy_page_path }
        ]
      },
      {
        id: "terms-pages",
        title: "CGV / CGU",
        icon: "bi-file-earmark-text",
        description: "Pages de conditions d’utilisation et ventes.",
        links: [
          { label: "Liste des pages légales", path: terms_pages_path },
          { label: "Ajouter une page légale", path: new_terms_page_path }
        ]
      }
    ]
  end
end
