class PapersController < ApplicationController

  before_filter :load_paper, :only => [:edit, :update, :delete]

  def index
  end

  def new
    @paper = current_user.papers.build
  end

  def create
    if @paper = current_user.papers.create(params[:id])
      redirect_to new_paper_post_url(@paper)
    else
      render 'new'
    end
  end

  private

  def load_paper
    @paper = current_user.papers.find_by_id(params[:id])
  end
end
