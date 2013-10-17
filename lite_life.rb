$LOAD_PATH.unshift(".")
require 'peggy'
require 'matrix'

MAX_H = 10
MAX_W = 80

# Let's MonkeyPatch Matrix because I'm lazy and Matrix is immutable
class Matrix
  def []=(i, j, x)
    @rows[i][j] = x
  end
end

def reset
  @peggy.clear
  @peggy.color(:red)
  @peggy.write(0,0,"GAME OF LIFE - v1")
  @peggy.color(:green)
end

def random_board
  @board = Matrix.build(MAX_H,MAX_W) { (rand(0..100) > 66) }
end

def update_board
  @board.each_with_index do |v,r,c|
    n_count = count_neighbors(r,c)
    @next_board[r,c] = false if (@board[r,c] && ((n_count < 2) || (n_count > 3))) # death
    @next_board[r,c] = true if (@board[r,c] && ((n_count == 2) || (n_count == 3))) # survival
    @next_board[r,c] = true if (!@board[r,c] && (n_count == 3)) # birth
  end
  @board = @next_board.clone
  @next_board = Matrix.build(MAX_H,MAX_W) { false }
  @last_update = Time.now
end

def count_neighbors(x,y)
  n = 0
  n += 1 if ((x > 0) && (y > 0)) and @board[(x-1),(y-1)]
  n += 1 if (y > 0) and @board[(x),(y-1)]
  n += 1 if (x > 0) and @board[(x-1),(y)]
  n += 1 if ((x > 0) && (y < MAX_H)) and @board[(x-1),(y+1)]
  n += 1 if ((x < MAX_W) && (y < MAX_H)) and @board[(x+1),(y+1)]
  n += 1 if (y < MAX_H) and @board[(x),(y+1)]
  n += 1 if (x < MAX_W) and @board[(x+1),(y)]
  n += 1 if ((x < MAX_W) && (y > 0)) and @board[(x+1),(y-1)]
  n
end

def print_board(b)
  b.row_count.times do |r|
    row_string = b.row(r).collect{|v| v ? "#" : " "}.to_a.join("")
    @peggy.write(r+1,0,row_string)
  end
end

@peggy = Peggy.new
@peggy.lease(3)
reset()

@board = Matrix.build(MAX_H,MAX_W) { false }
@next_board = Matrix.build(MAX_H,MAX_W) { false }

@last_update = Time.now
random_board
print_board(@board)

while !@peggy.expired? do
  if (Time.now - @last_update) > 3
    update_board()
    print_board(@board)
  end
end