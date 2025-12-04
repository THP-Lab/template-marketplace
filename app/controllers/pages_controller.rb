class PagesController < ApplicationController
  def reparation
    @repair_sections = RepairSection.order(:position)
  end

  def cgu
  end

  def confidentialite
  end
end
