require "rails_helper"

RSpec.describe AboutSectionsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/about_sections").to route_to("about_sections#index")
    end

    it "routes to #new" do
      expect(get: "/about_sections/new").to route_to("about_sections#new")
    end

    it "routes to #show" do
      expect(get: "/about_sections/1").to route_to("about_sections#show", id: "1")
    end

    it "routes to #edit" do
      expect(get: "/about_sections/1/edit").to route_to("about_sections#edit", id: "1")
    end


    it "routes to #create" do
      expect(post: "/about_sections").to route_to("about_sections#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/about_sections/1").to route_to("about_sections#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/about_sections/1").to route_to("about_sections#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/about_sections/1").to route_to("about_sections#destroy", id: "1")
    end
  end
end
