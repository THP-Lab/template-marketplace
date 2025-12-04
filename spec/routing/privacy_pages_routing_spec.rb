require "rails_helper"

RSpec.describe PrivacyPagesController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/privacy_pages").to route_to("privacy_pages#index")
    end

    it "routes to #new" do
      expect(get: "/privacy_pages/new").to route_to("privacy_pages#new")
    end

    it "routes to #show" do
      expect(get: "/privacy_pages/1").to route_to("privacy_pages#show", id: "1")
    end

    it "routes to #edit" do
      expect(get: "/privacy_pages/1/edit").to route_to("privacy_pages#edit", id: "1")
    end


    it "routes to #create" do
      expect(post: "/privacy_pages").to route_to("privacy_pages#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/privacy_pages/1").to route_to("privacy_pages#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/privacy_pages/1").to route_to("privacy_pages#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/privacy_pages/1").to route_to("privacy_pages#destroy", id: "1")
    end
  end
end
