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
    @post = Post.new(params[:post])
  end
end
