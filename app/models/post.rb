class Post < ActiveRecord::Base

  belongs_to :author, :foreign_key => :author_user_id
  belongs_to :paper

  validates :pixels, :format => /^(?:2|3){16384}$/

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
      (0...height).each do |y|
        (0...width).each do |x|
          p [x, y]
          img[x, y] = @pixels[y*width + x].chr == '0' ? ChunkyPNG::Color::BLACK : ChunkyPNG::Color::WHITE
        end
      end
      img.save('filename.png', :interlace => true)
      system('which optipng && optipng filename.png')
    end
  end

  def must_not_be_blank
    errors.add_to_base('Must not be a blank drawing') unless @pixels.include?('1')
  end

  def width
    128
  end

  def height
    128
  end
end
