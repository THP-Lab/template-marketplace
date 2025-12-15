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
          { label: "Plus d'informations", path: admin_cart_products_path }
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
        id: "company-information",
        title: "Information",
        icon: "bi-info-circle",
        description: "Coordonnées et mentions légales pour les factures.",
        links: [
          { label: "Information", path: admin_company_information_path }
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

  def render_structured_data
    parts = []
    parts << jsonld_tag(organization_schema)
    parts << jsonld_tag(webpage_schema(name: page_title_value, description: page_meta_description))
    parts << content_for(:structured_data) if content_for?(:structured_data)
    safe_join(parts.compact, "\n")
  end

  def canonical_link_tag
    url = canonical_url
    tag.link rel: "canonical", href: url if url.present?
  end

  def canonical_url
    explicit = content_for(:canonical).presence if content_for?(:canonical)
    return explicit if explicit
    return unless respond_to?(:request) && request.present?

    uri = URI.join(request.base_url, request.path.presence || "/")
    query = canonical_query_string
    uri.query = query if query.present?
    uri.to_s
  rescue StandardError
    nil
  end

  def canonical_query_string
    return if request.query_parameters.blank?

    filtered = request.query_parameters.except(
      :utm_source, :utm_medium, :utm_campaign, :utm_term, :utm_content,
      :utm_id, :utm_source_platform, :utm_creative_format, :utm_marketing_tactic,
      :fbclid, :gclid, :yclid
    )
    filtered.present? ? filtered.to_query : nil
  end

  def jsonld_tag(payload)
    return if payload.blank?

    tag.script(type: "application/ld+json") do
      raw(json_escape(payload.to_json))
    end
  end

  def organization_schema
    {
      "@context": "https://schema.org",
      "@type": "Organization",
      "name": site_name,
      "url": request.base_url,
      "logo": schema_image_url("icon.png")
    }.compact
  end

  def webpage_schema(name:, description:, type: "WebPage", url: request.original_url, has_part: nil)
    {
      "@context": "https://schema.org",
      "@type": type,
      "name": name,
      "url": url,
      "description": description,
      "isPartOf": {
        "@type": "Organization",
        "name": site_name,
        "url": request.base_url
      },
      "inLanguage": I18n.locale.to_s,
      "hasPart": has_part
    }.compact_blank
  end

  def product_schema(product)
    offer = {
      "@type": "Offer",
      "url": product_url(product),
      "priceCurrency": "EUR",
      "price": product.price,
      "availability": product.stock.to_i.positive? ? "https://schema.org/InStock" : "https://schema.org/OutOfStock"
    }.compact

    {
      "@context": "https://schema.org",
      "@type": "Product",
      "name": product.title,
      "description": meta_description_from(product.description),
      "image": schema_image_url(product.image),
      "category": product.category,
      "offers": offer
    }.compact_blank
  end

  def event_schema(event)
    location = event.location.presence && {
      "@type": "Place",
      "name": event.location,
      "address": event.location
    }

    image_url = schema_image_url(event.image_url.presence || event.image)

    {
      "@context": "https://schema.org",
      "@type": "Event",
      "name": event.title,
      "description": meta_description_from(event.description),
      "eventAttendanceMode": "https://schema.org/OfflineEventAttendanceMode",
      "eventStatus": "https://schema.org/EventScheduled",
      "startDate": event.event_date&.iso8601,
      "image": image_url,
      "location": location,
      "organizer": {
        "@type": "Organization",
        "name": site_name,
        "url": request.base_url
      },
      "offers": {
        "@type": "Offer",
        "url": event_url(event),
        "price": 0,
        "priceCurrency": "EUR"
      }
    }.compact_blank
  end

  def item_list_schema(collection, type:, name:, url_proc:)
    items = Array(collection).compact.first(20).each_with_index.map do |item, index|
      url = url_proc.call(item)
      next if url.blank?

      {
        "@type": "ListItem",
        "position": index + 1,
        "url": url,
        "name": item.try(:title) || item.try(:name),
        "item": {
          "@type": type,
          "name": item.try(:title) || item.try(:name),
          "url": url
        }.compact
      }.compact
    end.compact

    return if items.empty?

    {
      "@context": "https://schema.org",
      "@type": "ItemList",
      "name": name,
      "itemListOrder": "https://schema.org/ItemListOrderAscending",
      "itemListElement": items
    }
  end

  def service_schema(name:, description:, area_served: "France")
    {
      "@context": "https://schema.org",
      "@type": "Service",
      "name": name,
      "description": description,
      "provider": {
        "@type": "Organization",
        "name": site_name,
        "url": request.base_url
      },
      "areaServed": area_served
    }.compact_blank
  end

  def contact_page_schema
    {
      "@context": "https://schema.org",
      "@type": "ContactPage",
      "name": "#{site_name} - Contact",
      "url": request.original_url,
      "description": "Formulaire de contact et demandes de devis pour #{site_name}.",
      "potentialAction": {
        "@type": "CommunicateAction",
        "target": request.original_url,
        "description": "Envoyer un message à l'atelier"
      }
    }
  end

  def policy_page_schema(type:, name:, description:)
    {
      "@context": "https://schema.org",
      "@type": type,
      "name": name,
      "url": request.original_url,
      "description": description
    }
  end

  def checkout_page_schema(title:, description:)
    webpage_schema(name: title, description: description, type: "CheckoutPage")
  end

  def shopping_cart_schema(cart_products)
    items = Array(cart_products).map do |cart_product|
      product = cart_product.product
      next unless product

      {
        "@type": "Product",
        "name": product.title,
        "url": product_url(product),
        "image": schema_image_url(product.image),
        "offers": {
          "@type": "Offer",
          "priceCurrency": "EUR",
          "price": cart_product.unit_price || product.price,
          "availability": product.stock.to_i.positive? ? "https://schema.org/InStock" : "https://schema.org/OutOfStock"
        }
      }.compact_blank
    end.compact

    webpage_schema(
      name: "Panier - #{site_name}",
      description: "Vérification des articles et quantités avant paiement.",
      type: "ShoppingCartPage",
      has_part: items.presence
    )
  end

  def order_schema(order)
    return unless order

    items = order.order_products.map { |op| order_item_schema(op, embed_product: true) }.compact if order.respond_to?(:order_products)

    {
      "@context": "https://schema.org",
      "@type": "Order",
      "orderNumber": order.id,
      "price": order.total_amount,
      "priceCurrency": "EUR",
      "orderStatus": schema_order_status(order.status),
      "url": request.original_url,
      "orderedItem": items
    }.compact_blank
  end

  def order_item_schema(order_product, embed_product: false)
    return unless order_product

    product = order_product.product
    product_data = product && {
      "@type": "Product",
      "name": product.title,
      "url": product_url(product),
      "image": schema_image_url(product.image)
    }.compact_blank

    {
      "@type": "OrderItem",
      "orderItemNumber": order_product.id,
      "orderQuantity": order_product.quantity,
      "orderItemStatus": schema_order_status(order_product.order&.status),
      "price": order_product.unit_price || product&.price,
      "priceCurrency": "EUR",
      "orderedItem": embed_product ? product_data : product_data&.slice("@type", "name", "url")
    }.compact_blank
  end

  def schema_order_status(status)
    mapping = {
      "pending" => "OrderPaymentDue",
      "paid" => "OrderProcessing",
      "processing" => "OrderProcessing",
      "shipped" => "OrderInTransit",
      "delivered" => "OrderDelivered",
      "canceled" => "OrderCancelled"
    }
    "https://schema.org/#{mapping[status] || 'OrderProcessing'}"
  end

  def schema_image_url(source)
    return if source.blank?

    if source.respond_to?(:attached?) && source.attached?
      return rails_blob_url(source, host: request.base_url)
    end

    if source.respond_to?(:url)
      candidate = source.url
      return candidate if candidate.to_s.start_with?("http")
      return absolute_url(candidate)
    end

    source_path =
      if source.is_a?(String) && source.start_with?("http")
        source
      elsif source.is_a?(String)
        asset_path(source)
      end

    absolute_url(source_path)
  rescue StandardError
    nil
  end

  def absolute_url(path)
    return if path.blank?
    return path if path.to_s.start_with?("http")

    URI.join("#{request.base_url}/", path.to_s.sub(%r{\A/}, "")).to_s
  rescue StandardError
    nil
  end
end
