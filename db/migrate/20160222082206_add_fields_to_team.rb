class AddFieldsToTeam < ActiveRecord::Migration
  def change
    add_column :teams, :position, :integer
    add_column :teams, :team_lead, :string
  end
end
