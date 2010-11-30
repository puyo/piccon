class HomeController < ApplicationController
  def index
    redirect_to new_post_url
  end
end
