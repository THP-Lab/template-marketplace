require "rails_helper"

RSpec.describe AboutPagesController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/about_pages").to route_to("about_pages#index")
    end

    it "routes to #new" do
      expect(get: "/about_pages/new").to route_to("about_pages#new")
    end

    it "routes to #show" do
      expect(get: "/about_pages/1").to route_to("about_pages#show", id: "1")
    end

    it "routes to #edit" do
      expect(get: "/about_pages/1/edit").to route_to("about_pages#edit", id: "1")
    end


    it "routes to #create" do
      expect(post: "/about_pages").to route_to("about_pages#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/about_pages/1").to route_to("about_pages#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/about_pages/1").to route_to("about_pages#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/about_pages/1").to route_to("about_pages#destroy", id: "1")
    end
  end
end
