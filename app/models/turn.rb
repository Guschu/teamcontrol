# == Schema Information
#
# Table name: turns
#
#  id         :integer          not null, primary key
#  team_id    :integer
#  driver_id  :integer
#  duration   :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_turns_on_driver_id  (driver_id)
#  index_turns_on_team_id    (team_id)
#
# Foreign Keys
#
#  fk_rails_a98f3bc47c  (driver_id => drivers.id)
#  fk_rails_d3380a493d  (team_id => teams.id)
#

class Turn < ActiveRecord::Base
  belongs_to :team
  belongs_to :driver

  validates :team, :driver, presence:true
  validates :duration, numericality:{ greater_than:0.0 }

  def self.for_event(evt)
    race = evt.team.race
    case race.mode.to_sym
    when :both
      # letzte kommend-Buchung des gleichen Fahrers, frühestens/alternativ Rennbeginn
      evt_start = Event
        .arriving
        .where(team_id:evt.team_id, driver_id:evt.driver_id)
        .where('created_at<?', evt.created_at)
        .order('created_at desc')
        .first

      if evt_start.present?
        start_at = evt_start.created_at > race.started_at ? evt_start.created_at : race.started_at
      else
        start_at = race.started_at
      end
      new team_id:evt.team_id, driver_id:evt.driver_id, duration:(Time.now - start_at.to_time)
    when :leaving
      # letzte gehend-Buchung des gleichen Teams, frühestens/alternativ Rennbeginn
      evt_start = Event
        .leaving
        .where(team_id:evt.team_id)
        .where('created_at<?', evt.created_at)
        .order('created_at desc')
        .second

      if evt_start.present?
        start_at = evt_start.created_at > race.started_at ? evt_start.created_at : race.started_at
      else
        start_at = race.started_at
      end
      new team_id:evt.team_id, driver_id:evt.driver_id, duration:(Time.now - start_at.to_time)
    end
  end
end
