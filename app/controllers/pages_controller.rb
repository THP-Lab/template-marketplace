class PagesController < ApplicationController
  
  def a_propos
    @about_sections = AboutSection.order(:position)
  end
  def cgu
  end

  def confidentialite
  end
end
