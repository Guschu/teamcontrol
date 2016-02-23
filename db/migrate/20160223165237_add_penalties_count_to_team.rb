class AddPenaltiesCountToTeam < ActiveRecord::Migration
  def change
    add_column :teams, :penalties_count, :integer
  end
end
