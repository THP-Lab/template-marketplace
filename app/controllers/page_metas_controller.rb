class PageMetasController < ApplicationController
  before_action :require_admin!
  before_action :set_page_meta, only: %i[edit update destroy]

  def index
    @page_metas = PageMeta.order(:page_key)
    @page_metas, @pagination = paginate(@page_metas)
  end

  def new
    @page_meta = PageMeta.new
  end

  def edit
  end

  def create
    @page_meta = PageMeta.new(page_meta_params)
    if @page_meta.save
      redirect_to page_metas_path, notice: "Description enregistrée."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @page_meta.update(page_meta_params)
      redirect_to page_metas_path, notice: "Description mise à jour."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @page_meta.destroy
    redirect_to page_metas_path, notice: "Description supprimée."
  end

  private

  def set_page_meta
    @page_meta = PageMeta.find(params[:id])
  end

  def page_meta_params
    params.require(:page_meta).permit(:page_key, :meta_title, :meta_description)
  end
end
