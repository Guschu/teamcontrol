class AddMinTurnToRace < ActiveRecord::Migration
  def change
    add_column :races, :min_turn, :integer
  end
end
