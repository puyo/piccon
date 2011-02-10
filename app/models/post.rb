class Post < ActiveRecord::Base

  WIDTH = 128
  HEIGHT = 128

  belongs_to :author, :foreign_key => :author_user_id
  belongs_to :paper

  validates :pixels, :format => /^(?:0|1){#{WIDTH*HEIGHT}}$/

  def pixels
    @pixels
  end

  def pixels=(value)
    @pixels = value
    @dirty = true
  end

  private

  before_save :write_file

  def image_path
    Rails.root.join('public')
  end

  def write_file
    if @dirty
      @dirty = false
      # write pixels to file
      img = ChunkyPNG::Image.new(128, 128)
      (0...HEIGHT).each do |y|
        (0...WIDTH).each do |x|
          img[x, y] = @pixels[y*WIDTH + x].chr == '1' ? ChunkyPNG::Color::BLACK : ChunkyPNG::Color::WHITE
        end
      end
      img.save('filename.png', :interlace => true)
      system('which optipng && optipng filename.png')
    end
  end

  def must_not_be_blank
    errors.add_to_base('Must not be a blank drawing') unless @pixels.include?('1')
  end

end
