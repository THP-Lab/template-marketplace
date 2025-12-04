require "rails_helper"

RSpec.describe RepairSectionsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/repair_sections").to route_to("repair_sections#index")
    end

    it "routes to #new" do
      expect(get: "/repair_sections/new").to route_to("repair_sections#new")
    end

    it "routes to #show" do
      expect(get: "/repair_sections/1").to route_to("repair_sections#show", id: "1")
    end

    it "routes to #edit" do
      expect(get: "/repair_sections/1/edit").to route_to("repair_sections#edit", id: "1")
    end


    it "routes to #create" do
      expect(post: "/repair_sections").to route_to("repair_sections#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/repair_sections/1").to route_to("repair_sections#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/repair_sections/1").to route_to("repair_sections#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/repair_sections/1").to route_to("repair_sections#destroy", id: "1")
    end
  end
end
