module ApplicationHelper
  def admin_navigation_sections
    [
      {
        id: "products",
        title: "Produits",
        icon: "bi-box-seam",
        description: "Gérez le catalogue et les stocks disponibles.",
        links: [
          { label: "Tous les produits", path: admin_products_path },
          { label: "Créer un produit", path: new_product_path }
        ]
      },
      {
        id: "events",
        title: "Événements",
        icon: "bi-calendar-event",
        description: "Programmez les événements, ateliers et rencontres.",
        links: [
          { label: "Liste des événements", path: admin_events_path },
          { label: "Ajouter un événement", path: new_event_path }
        ]
      },
      {
        id: "carts",
        title: "Paniers",
        icon: "bi-bag",
        description: "Consultez les paniers des utilisateurs et leurs contenus.",
        links: [
          { label: "Liste des paniers", path: admin_carts_path },
          { label: "Produits des paniers", path: admin_cart_products_path }
        ]
      },
      {
        id: "orders",
        title: "Commandes",
        icon: "bi-receipt",
        description: "Suivez et gérez les commandes et leurs statuts.",
        links: [
          { label: "Commandes", path: admin_orders_path },
          { label: "Produits de commande", path: admin_order_products_path }
        ]
      },
      {
        id: "repair-pages",
        title: "Service réparation",
        icon: "bi-tools",
        description: "Pages dédiées aux offres de réparation.",
        links: [
          { label: "Blocs réparation", path: admin_repair_pages_path },
          { label: "Nouveau bloc réparation", path: new_repair_page_path }
        ]
      },
      {
        id: "home-pages",
        title: "Page d’accueil",
        icon: "bi-house-door",
        description: "Sections et blocs de la page d’accueil.",
        links: [
          { label: "Blocs d’accueil", path: admin_home_pages_path },
          { label: "Ajouter un bloc d’accueil", path: new_home_page_path }
        ]
      },
      {
        id: "about-pages",
        title: "À propos",
        icon: "bi-people",
        description: "Sections de la page À propos.",
        links: [
          { label: "Blocs À propos", path: admin_about_pages_path },
          { label: "Nouveau bloc À propos", path: new_about_page_path }
        ]
      },
      {
        id: "privacy-pages",
        title: "Confidentialité",
        icon: "bi-shield-lock",
        description: "Contenus de politique de confidentialité.",
        links: [
          { label: "Blocs confidentialité", path: admin_privacy_pages_path },
          { label: "Nouveau bloc confidentialité", path: new_privacy_page_path }
        ]
      },
      {
        id: "terms-pages",
        title: "CGV / CGU",
        icon: "bi-file-earmark-text",
        description: "Pages de conditions d’utilisation et ventes.",
        links: [
          { label: "Blocs légaux", path: admin_terms_pages_path },
          { label: "Nouveau bloc légal", path: new_terms_page_path }
        ]
      }
    ]
  end

  def render_admin_sidebar
    render partial: "admin/dashboard/sidebar", locals: { admin_sections: admin_navigation_sections }
  end

  def admin_page(title:, &block)
    content = capture(&block)
    render partial: "admin/shared/page_layout", locals: { title: title, content: content }
  end

  def admin_pagination(pagination)
    return unless pagination
    return if pagination[:total_pages].to_i <= 1

    render partial: "admin/shared/pagination",
           locals: { pagination: pagination, query_params: request.query_parameters }
  end

  def attachment_thumb(attachment, variant_options: nil, **options)
    return unless attachment&.attached?

    if variant_options && attachment.variable?
      image_tag attachment.variant(variant_options), **options
    else
      image_tag attachment, **options
    end
  end

  def order_status_options
    Order.status_options_for_select
  end

  def mask_email(email)
    return "****" unless email.present?
    local, domain = email.split("@", 2)
    masked_local = local[0].to_s + "****"
    "#{masked_local}@#{domain}"
  end

  def mask_name(first_name, last_name)
    return "****" if first_name.blank? && last_name.blank?
    "#{first_name.to_s.first}*** #{last_name.to_s.first}***".strip
  end

  def site_name
    "Template Marketplace"
  end

  def page_title_value
    raw_title = content_for(:title).presence || default_page_title
    [raw_title, site_name].compact.uniq.join(" | ")
  end

  def page_meta_description
    content_for(:meta_description).presence || default_meta_description
  end

  def default_page_title
    resource_label = controller_page_label
    action_label = page_action_label
    [resource_label, action_label].compact.join(" - ").presence || site_name
  end

  def default_meta_description
    base = "Boutique et atelier d'inspiration médiévale : créations sur mesure, réparations et équipements prêts à l'emploi."
    title = content_for(:title).presence || default_page_title
    [title, base].compact.join(" — ")
  end

  def controller_page_label
    {
      "home_pages" => "Accueil",
      "products" => "Boutique",
      "events" => "Événements",
      "repair_pages" => "Réparation",
      "about_pages" => "À propos",
      "privacy_pages" => "Confidentialité",
      "terms_pages" => "Conditions générales",
      "contacts" => "Contact",
      "carts" => "Panier",
      "checkout" => "Paiement",
      "orders" => "Commandes"
    }.fetch(controller_name, controller_name.to_s.humanize)
  end

  def page_action_label
    return nil if action_name == "index"
    {
      "new" => "Nouveau",
      "edit" => "Édition",
      "show" => "Détail",
      "admin" => "Administration"
    }.fetch(action_name, action_name.to_s.humanize)
  end

  def meta_description_from(text)
    truncated = truncate(strip_tags(text.to_s).squish, length: 155)
    truncated.presence
  end
end
