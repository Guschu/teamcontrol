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
  has_one :event
  belongs_to :team
  belongs_to :driver

  validates :team, :driver, presence: true
  validates :duration, numericality: { greater_than: 0.0 }

  scope :for_team, ->(team) { where(team_id: team.id) }

  def self.for_event(evt)
    return if evt.nil? || evt.arriving?
    race = evt.team.race

    case race.mode.to_sym
    when :both
      evt_start = Event
                    .leaving
                    .where(team_id: evt.team_id)
                    .where('created_at < ?', evt.created_at)
                    .order('created_at desc')
                    .first
      start_at = evt_start.present? ? evt_start.created_at : race.started_at
      new team_id: evt.team_id, driver_id: evt.driver_id, duration: (evt.created_at - start_at.to_time).to_i

    when :leaving
      evt_start = Event
                    .leaving
                    .where(team_id: evt.team_id)
                    .where('created_at < ?', evt.created_at)
                    .order('created_at desc')
                    .first
      start_at = if evt_start.present?
                  evt_start.created_at > race.started_at ? evt_start.created_at : race.started_at
                else
                  race.started_at
                end
      new team_id: evt.team_id, driver_id: evt.driver_id, duration: ((race.finished_at.nil? ? evt.created_at : race.finished_at) - start_at.to_time).to_i
    end
  end
  
end
