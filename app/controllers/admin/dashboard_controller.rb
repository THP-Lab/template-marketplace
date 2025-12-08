class Admin::DashboardController < ApplicationController
  before_action :require_admin!

  def index
    @admin_sections = view_context.admin_navigation_sections
  end
end
