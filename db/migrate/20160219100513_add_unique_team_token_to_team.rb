class AddUniqueTeamTokenToTeam < ActiveRecord::Migration
  def up
    add_column :teams, :team_token, :string
    add_index :teams, :team_token
    Team.reset_column_information
    Team.find_each do |team|
      team.generate_token
    end
  end

  def down
    remove_column :teams, :team_token
  end
end
