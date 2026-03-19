namespace :twitch do
  desc "Synchronise les abonnements EventSub Twitch et l'etat live courant"
  task sync: :environment do
    company_information = CompanyInformation.instance
    message = Twitch::SubscriptionSync.call(company_information: company_information)
    puts message
  end

  desc "Rafraichit uniquement l'etat live Twitch depuis l'API"
  task refresh_state: :environment do
    company_information = CompanyInformation.instance
    Twitch::StreamStateRefresh.call(company_information: company_information)
    puts "Etat Twitch rafraichi."
  end
end
