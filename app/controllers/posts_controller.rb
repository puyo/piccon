class PostsController < ApplicationController

  before_filter :load_paper
  before_filter :build_post, :only => [:new, :create]
  before_filter :check_new_user, :only => [:create]

  def new
  end

  def create
    logger.debug { "Creating a post with #{@post.pixels.size} pixels" }
    if @post.save
      flash.notice = 'Post created'
      redirect_to new_paper_post_url(@paper)
    else
      flash.notice = @post.errors.full_messages
      render :new
    end
  end

  private

  def load_paper
    @paper = current_user.papers.find(params[:paper_id])
  end

  def build_post
    @post = @paper.posts.build(params[:post])
  end

  def check_new_user
    if current_user.new?
      flash[:notice] = "You must sign in to post to a game"
      session[:attempted_post] = params[:post]
      redirect_to new_session_path
    end
  end

end

# new user... list public games... post to a public game... create account... back to game (successful post)
