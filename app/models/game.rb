class Game < ActiveRecord::Base
  attr_accessible :gamestate, :player1, :player2, :turn
end
