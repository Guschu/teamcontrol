class AddRegistratingTeamToRace < ActiveRecord::Migration
  def change
    change_table :races do |t|
      t.references :registrating_team, references: :teams
    end
  end
end
