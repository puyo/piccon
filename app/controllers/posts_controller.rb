class PostsController < ApplicationController

  before_filter :load_post

  def new
  end

  def create
    if @post.save
      flash.notice = 'Post created'
      redirect_to root_url
    else
      flash.notice = @post.errors.full_messages
      render :new
    end
  end

  private

  def load_post
    @paper = current_user.papers.find(params[:paper_id])
    @post = @paper.posts.build(params[:post])
  end
end
