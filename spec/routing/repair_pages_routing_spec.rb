require "rails_helper"

RSpec.describe RepairPagesController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/repair_pages").to route_to("repair_pages#index")
    end

    it "routes to #new" do
      expect(get: "/repair_pages/new").to route_to("repair_pages#new")
    end

    it "routes to #show" do
      expect(get: "/repair_pages/1").to route_to("repair_pages#show", id: "1")
    end

    it "routes to #edit" do
      expect(get: "/repair_pages/1/edit").to route_to("repair_pages#edit", id: "1")
    end


    it "routes to #create" do
      expect(post: "/repair_pages").to route_to("repair_pages#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/repair_pages/1").to route_to("repair_pages#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/repair_pages/1").to route_to("repair_pages#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/repair_pages/1").to route_to("repair_pages#destroy", id: "1")
    end
  end
end
