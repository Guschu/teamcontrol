# == Schema Information
#
# Table name: penalties
#
#  id         :integer          not null, primary key
#  team_id    :integer
#  driver_id  :integer
#  reason     :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_penalties_on_driver_id  (driver_id)
#  index_penalties_on_team_id    (team_id)
#
# Foreign Keys
#
#  fk_rails_2f83aa445f  (team_id => teams.id)
#  fk_rails_4bd86e846b  (driver_id => drivers.id)
#

class Penalty < ActiveRecord::Base
  belongs_to :team, counter_cache: true
  belongs_to :driver

  scope :for_team, ->(team) { where(team_id: team.id) }

  def self.for_event(evt)
    race = evt.team.race
    s = evt.team.to_stats.group_by_driver[evt.driver_id]
    val = { team:evt.team, driver:evt.driver }
    penalty = nil

    case evt.mode.to_sym
    when :arriving
      # Unterschreitung der Pausenzeit
      if s.last_break_time > 0 && s.last_break_time < race.break_time * 60
        penalty = Penalty.new val.merge( reason:"Unterschreitung der Pausenzeit: #{Time.at(s.last_break_time).utc.strftime('%H:%M:%S')}" )
      end
    when :leaving
      # Unterschreitung der Fahrzeit
      if s.current_drive_time && s.current_drive_time < race.min_turn * 60
        penalty = Penalty.new val.merge( reason:"Unterschreitung der minimalen Fahrzeit: #{Time.at(s.current_drive_time).utc.strftime('%H:%M:%S')}" )
      end
      # Überschreitung der Fahrzeit
      if s.current_drive_time && s.current_drive_time > (race.max_turn + race.waiting_period) * 60
        penalty = Penalty.new val.merge( reason:"Überschreitung der maximalen Fahrzeit: #{Time.at(s.current_drive_time).utc.strftime('%H:%M:%S')}" )
      end
    end

    penalty
  end
end
