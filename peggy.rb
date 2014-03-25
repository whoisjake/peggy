require 'httparty'

class Peggy
  include HTTParty
  base_uri '10.105.4.251/peggy'

  def clear(board)
    self.class.get("/clear", { query: { board: board } })
  end

  def write(board,x,y,text = "")
    self.class.get("/write", { query: { board: board, x: x, y: y, text: text} })
  end

end
