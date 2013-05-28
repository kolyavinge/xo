require 'contracts'
require 'Qt4'

class MainView < Qt::Widget

	attr_accessor :presenter

	slots 'update_timer_tick()'

	def initialize
		super
		@cell_size   = 24
		@offset_x    = 10
		@offset_y    = 10
		@white_brush = Qt::Brush.new(Qt::white)
    	@black_brush = Qt::Brush.new(Qt::black)
    	@black_pen   = Qt::Pen.new(Qt::black) { setStyle Qt::SolidLine }
    	@x_pen       = Qt::Pen.new
    	@x_pen.setBrush Qt::Brush.new(Qt::red)
    	@x_pen.setWidth 3
    	@o_pen       = Qt::Pen.new
    	@o_pen.setBrush Qt::Brush.new(Qt::blue)
    	@o_pen.setWidth 3
	end

	def showEvent event
   		setWindowTitle "X-O Game on RUBYYYY"
   		@field_size = @presenter.field_size
  		@size = @field_size * @cell_size
  		@presenter.update_event = Proc.new { update	}
  		start_update_timer
  	end

  	def mousePressEvent event
	    if event.button == Qt::LeftButton
	    	col = (event.pos.x - @offset_x) / @cell_size
	    	row = (event.pos.y - @offset_y) / @cell_size
	    	@presenter.step row, col
	    end
	end

  	def paintEvent event
	    @painter = Qt::Painter.new self
	    draw_field
	    @painter.end
  	end

  	private

  	def start_update_timer
  		@update_timer = Qt::Timer.new(self)
    	connect(@update_timer, SIGNAL('timeout()'), self, SLOT('update_timer_tick()'))
    	@update_timer.start 10
  	end

  	def update_timer_tick
  		@presenter.poll
  	end

  	def draw_field
  		draw_shadow
	    draw_background
	    draw_xo
	    draw_border
	    draw_horizontal_lines
	    draw_vertical_lines
  	end

  	def draw_xo
  		@painter.save
  		@painter.setRenderHint Qt::Painter::Antialiasing
  		@painter.setBrush Qt::NoBrush
  		@presenter.field.each{ |cell|
	    	if cell['value'] == X
	    		draw_x cell['row'], cell['col']
	    	elsif cell['value'] == O
	    		draw_o cell['row'], cell['col']
	    	else
	    		print "client: wrong cell value: #{cell['value']}"
	    	end
	    }
	    @painter.restore
  	end

  	def draw_x r, c
  		@painter.setPen @x_pen

		@painter.drawLine @offset_x + @cell_size * c + 4,
		                  @offset_y + @cell_size * r + 4,
		                  @offset_x + @cell_size * c + @cell_size - 4,
		                  @offset_y + @cell_size * r + @cell_size - 4
		
		@painter.drawLine @offset_x + @cell_size * c + @cell_size - 4,
		                  @offset_y + @cell_size * r + 4,
		                  @offset_x + @cell_size * c + 4,
		                  @offset_y + @cell_size * r + @cell_size - 4
  	end

  	def draw_o r, c
  		@painter.setPen @o_pen
  		@painter.drawEllipse @offset_x + @cell_size * c + 4, @offset_y + @cell_size * r + 4,
	     		             @cell_size - 8, @cell_size - 8
  	end

  	def draw_horizontal_lines
  		@painter.setPen @black_pen
  		@painter.setBrush Qt::NoBrush
  		(1...@field_size).each{ |y|
  			@painter.drawLine @offset_x, @offset_y + @cell_size * y, @offset_x + @size, @offset_y + @cell_size * y
  		}
  	end

  	def draw_vertical_lines
  		@painter.setPen @black_pen
  		@painter.setBrush Qt::NoBrush
  		(1...@field_size).each{ |x|
  			@painter.drawLine @offset_x + @cell_size * x, @offset_y, @offset_x + @cell_size * x, @offset_y + @size
  		}
  	end

  	def draw_border
  		@painter.setPen @black_pen
  		@painter.setBrush Qt::NoBrush
  		@painter.drawRect @offset_x, @offset_y, @size, @size
  	end

  	def draw_shadow
  		@painter.setPen Qt::NoPen
  		@painter.setBrush @black_brush
  		@painter.drawRect @offset_x + 3, @offset_y + 3, @size, @size
  	end

  	def draw_background
  		@painter.setPen Qt::NoPen
  		@painter.setBrush @white_brush
  		@painter.drawRect @offset_x, @offset_y, @size, @size
  	end
end
