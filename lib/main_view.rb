require 'contracts'
require 'Qt4'

class MainView < Qt::Widget

	attr_accessor :presenter

	def initialize
		super
		@cell_size = 24
		@offset_x = 10
		@offset_y = 10
		@white_brush = Qt::Brush.new(Qt::white)
    	@black_brush = Qt::Brush.new(Qt::black)
    	@x_brush     = Qt::Brush.new(Qt::red)
    	@black_pen   = Qt::Pen.new(Qt::black) { setStyle Qt::SolidLine }
    	@x_pen       = Qt::Pen.new(Qt::green) { setStyle Qt::SolidLine }
	end

	def showEvent event
   		setWindowTitle "X-O Game on RUBYYYY"
   		@field_size = @presenter.field_size
  		@size = @field_size * @cell_size
  		@presenter.update_event = Proc.new {
  			print "client: update_event (#{@presenter.xo})\n"
  			update
  		}
  	end

  	def mousePressEvent event
	    if event.button == Qt::LeftButton
	    	col = (event.pos.x - @offset_x) / @cell_size
	    	row = (event.pos.y - @offset_y) / @cell_size
	    	@presenter.step row, col
	    end
	end

  	def paintEvent event
  		print "paint\n"
	    @painter = Qt::Painter.new self
	    draw_field @presenter.field
	    @painter.end
  	end

  	private

  	def draw_field field
  		draw_shadow
	    draw_background
	    @presenter.field.each{ |cell|
	    	if cell['value'] == X
	    		draw_x cell['row'], cell['col']
	    	elsif cell['value'] == O
	    		draw_o cell['row'], cell['col']
	    	else
	    		print "client: wrong cell value: #{cell['value']}"
	    	end
	    }
	    draw_border
	    draw_horizontal_lines
	    draw_vertical_lines
  	end

  	def draw_x r, c
		@painter.drawLine @offset_x + @cell_size * c + 2,
		                  @offset_y + @cell_size * r + 2,
		                  @offset_x + @cell_size * c + @cell_size - 2,
		                  @offset_y + @cell_size * r + @cell_size - 2
		
		@painter.drawLine @offset_x + @cell_size * c + @cell_size - 2,
		                  @offset_y + @cell_size * r + 2,
		                  @offset_x + @cell_size * c + 2,
		                  @offset_y + @cell_size * r + @cell_size - 2
  	end

  	def draw_o r, c
  		@painter.drawEllipse @offset_x + @cell_size * c + 2, @offset_y + @cell_size * r + 2,
	     		             @cell_size - 4, @cell_size - 4
  	end

  	def draw_horizontal_lines
  		(1...@field_size).each{ |y|
  			@painter.drawLine @offset_x, @offset_y + @cell_size * y, @offset_x + @size, @offset_y + @cell_size * y
  		}
  	end

  	def draw_vertical_lines
  		(1...@field_size).each{ |x|
  			@painter.drawLine @offset_x + @cell_size * x, @offset_y, @offset_x + @cell_size * x, @offset_y + @size
  		}
  	end

  	def draw_border
  		@painter.drawRect @offset_x, @offset_y, @size, @size
  	end

  	def draw_shadow
  		@painter.fillRect @offset_x + 3, @offset_y + 3, @size, @size, @black_brush
  	end

  	def draw_background
  		@painter.fillRect @offset_x, @offset_y, @size, @size, @white_brush
  	end
end
