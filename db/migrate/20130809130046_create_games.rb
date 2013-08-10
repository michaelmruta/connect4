class CreateGames < ActiveRecord::Migration
  def change
    create_table :games do |t|
      t.string :player1
      t.string :player2
      t.string :gamestate
      t.integer :turn

      t.timestamps
    end
  end
end
