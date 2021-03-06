class PapersController < ApplicationController

  before_filter :new_paper, :only => [:new, :create]
  before_filter :load_paper, :only => [:show, :edit, :update, :delete]
  before_filter :load_papers, :only => [:index]

  def index
    @papers = Paper.eligible(current_user)
  end

  def show
  end

  def new
    @paper = current_user.papers.build
  end

  def create
    if @paper.save(params[:paper])
      redirect_to new_paper_post_url(@paper)
    else
      render 'new'
    end
  end

  private

  def load_papers
    @papers = current_user.papers
  end

  def load_paper
    @paper = current_user.papers.find_by_id(params[:id])
  end

  def new_paper
    @paper = current_user.papers.build
  end
end
