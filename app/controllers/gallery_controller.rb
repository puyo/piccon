class GalleryController < ApplicationController

  def index
    case params[:rating]
    when "r18"
      require_facebook_login
      games = Game.public_r18
      @rating = "r18"
    when "all"
      require_facebook_login
      games = Game.public_all
      @rating = "all"
    else # General gallery
      games = Game.public_g
      @rating = "g"
    end
    games = games.order_by(params[:order] || 'recency')
    @games = games.paginate(:page => params[:page], :per_page => 10)

    render :action => :index
  end
end
