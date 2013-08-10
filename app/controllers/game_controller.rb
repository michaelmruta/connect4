require 'json'

class GameController < ApplicationController

	def index
		@status = "Join or Create a game"
	end

	def play

		@player = params[:player]

		# create
		if params[:choice] == "Create Game"
			game = Game.new
			game.gamestate = [[0,0,0,0,0,0],
							 [0,0,0,0,0,0],
							 [0,0,0,0,0,0],
							 [0,0,0,0,0,0],
							 [0,0,0,0,0,0],
							 [0,0,0,0,0,0]].to_json
			game.player1 = @player;
			game.turn = 1
			game.save()

			@id = game.id
			@gamestate = game.gamestate
			@status = 1

			session[:gameId] = game.id
			session[:playerId] = 1

			render "waiting"
		end

		#join
		if params[:choice] == "Join Game"
			@status = 2
			session[:playerId] = 2

			render "waiting"
		end
	end

	def findPlayer
		game = Game.find(session[:gameId])
		if(game.player2)
			render :text => "Ok"
		else
			render :text => "..."
		end
	end

	def joinGame
		game = Game.where("player2 is NULL").first()
		if(game)
			game.player2 = params[:p]
			game.save()
			session[:gameId] = game.id
			render :text => "Ok"
		else
			render :text => "..."
		end
	end

	def connect4
		if session[:playerId] == nil
			render action: "index"
		end

		game = Game.find(session[:gameId])
		@gamestate = JSON.parse game.gamestate

		@player1 = game.player1
		@player2 = game.player2

		if session[:playerId] == 1
			@myColor = "red"
		else
			@myColor = "blue"
		end
	end

	def gamestate
		game = Game.find(session[:gameId])
		gamestate = JSON.parse game.gamestate
		
		state = ""

		(1..2).each do |player|

			connect = 0

				# check -
				(0..5).each do |y|
					(0..5).each do |x|
						if gamestate[x][y] == player
						 	if connect != 4
						 		connect = connect + 1
						 	end
						else
							if connect != 4
								connect = 0
							end
						end
					end
				end

				if connect != 4
					connect = 0
				end

				# check |
				(0..5).each do |x|
					(0..5).each do |y|
						if gamestate[x][y] == player
						 	if connect != 4
						 		connect = connect + 1
						 	end
						else
							if connect != 4
								connect = 0
							end
						end
					end
				end

				if connect != 4
					connect = 0
				end

				# # check \

				(0..3).each do |x|
					(0..3).each do |y|
						if gamestate[x][y] == player && 
						   gamestate[x+1][y+1] == player &&
						   gamestate[x+2][y+2] == player &&
						   gamestate[x+3][y+3] == player
						 	if connect != 4
						 		connect = 4
						 	end
						else
							if connect != 4
								connect = 0
							end
						end
					end
				end

				if connect != 4
					connect = 0
				end

				# # check / 

				(3..5).each do |x|
					(0..3).each do |y|
						if gamestate[x][y] == player && 
						   gamestate[x-1][y+1] == player &&
						   gamestate[x-2][y+2] == player &&
						   gamestate[x-3][y+3] == player
						 	if connect != 4
						 		connect = 4
						 	end
						else
							if connect != 4
								connect = 0
							end
						end
					end
				end

				if connect != 4
					connect = 0
				end

			if player.to_i == 1
				if connect == 4
					state = game.player1 + " WINS!"
				end
			end

			if player.to_i == 2
				if connect == 4
					state = game.player2 + " WINS!"
				end
			end

		end

	  	render :json => ["turn" => game.turn, "grid" =>gamestate, "state" => state]
	end

	def buttonPressed

		x = params[:x].to_i
		y = params[:y].to_i

		game = Game.find(session[:gameId])

		if( session[:playerId] == 1 )
			if (game.turn == 1)
				gamestate = JSON.parse game.gamestate
				gamestate[x-1][y-1] = session[:playerId]
				game.gamestate = gamestate.to_json
				game.turn = 2
				game.save()
			end
		end
		if ( session[:playerId] == 2 )
			if (game.turn == 2)
				gamestate = JSON.parse game.gamestate
				gamestate[x-1][y-1] = session[:playerId]
				game.gamestate = gamestate.to_json
				game.turn = 1
				game.save()
			end
		end

		render :text => (game.turn % 2) + 1

	end

end
