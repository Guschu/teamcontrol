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
  has_one :event
  belongs_to :team, counter_cache: true
  belongs_to :driver

  scope :for_team, ->(team) { where(team_id: team.id) }

  def self.for_event(evt)
    race = evt.team.race
    val = { team:evt.team, driver:evt.driver }
    penalty = nil

    s = evt.team.to_stats.group_by_driver[evt.driver_id]

    case evt.mode.to_sym
    when :arriving

      # Unterschreitung der Pausenzeit
      if s.last_break_time.present? && s.last_break_time < race.break_time * 60
        penalty = Penalty.new val.merge( reason:"Unterschreitung der Pausenzeit: #{Time.at(s.last_break_time).utc.strftime('%H:%M:%S')}" )
      end
    when :leaving
      # Unterschreitung der Fahrzeit
      if evt.turn && evt.turn.duration < race.min_turn * 60
        penalty = Penalty.new val.merge( reason:"Unterschreitung der minimalen Fahrzeit: #{Time.at(evt.turn.duration).utc.strftime('%H:%M:%S')}" )
      end
      # Überschreitung der Fahrzeit
      if evt.turn && evt.turn.duration > (race.max_turn + race.waiting_period) * 60
        penalty = Penalty.new val.merge( reason:"Überschreitung der maximalen Fahrzeit: #{Time.at(evt.turn.duration).utc.strftime('%H:%M:%S')}" )
      end
      # Überschreitung der Gesamtfahrzeit
      if evt.turn && s.total_drive_time > race.maximum_drive_time * 60
        penalty = Penalty.new val.merge( reason:"Überschreitung der maximalen Gesamtfahrzeit für Fahrer #{evt.driver.name}: #{Time.at(s.total_drive_time).utc.strftime('%H:%M:%S')}" )
      end
    end

    penalty
  end
end
