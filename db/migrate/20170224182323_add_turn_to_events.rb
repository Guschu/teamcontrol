class AddTurnToEvents < ActiveRecord::Migration
  def change
    add_reference :events, :turn, index: true, foreign_key: true
  end
end
