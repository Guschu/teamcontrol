# == Schema Information
#
# Table name: races
#
#  id              :integer          not null, primary key
#  name            :string(255)
#  duration        :integer
#  max_drive       :integer
#  max_turn        :integer
#  break_time      :integer
#  waiting_period  :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  slug            :string(255)
#  state           :integer          default(0)
#  mode            :integer          default(0)
#  scheduled       :date
#  started_at      :datetime
#  finished_at     :datetime
#  min_turn        :integer
#  prebooking_open :boolean          default(FALSE)
#
# Indexes
#
#  index_races_on_mode  (mode)
#  index_races_on_slug  (slug)
#

class Race < ActiveRecord::Base
  extend FriendlyId
  include AASM

  enum state: {
    planned: 0,
    active: 5,
    finished: 10
  }

  enum mode: {
    both: 0,
    leaving: 5
  }

  aasm column: :state do
    state :planned, initial: true
    state :active
    state :finished

    event :start do
      after do
        self.started_at = Time.zone.now
      end
      transitions from: :planned, to: :active
    end

    event :finish do
      after do
        create_events_on_finish
        self.finished_at = Time.zone.now
      end
      transitions from: :active, to: :finished
    end
  end

  has_many :teams

  validates :name, :scheduled, presence: true
  friendly_id :name, use: :slugged

  def attendances
    Attendance.where(team_id: teams.select(:id))
  end

  def drivers
    Driver.where(id: Attendance.where(team_id: teams.select(:id)).select(:driver_id))
  end

  def events
    Event.where(team_id: teams.select(:id))
  end

  def create_events_on_finish
    active_drivers = to_stats
      .group_by_team
      .reject{|team_id, stats| stats.current_driver_id.nil? }
      .map{|team_id, stats| [team_id, stats.current_driver_id] }

    active_drivers.each do |team_id, driver_id|
      Event.create team_id:team_id, driver_id:driver_id
    end
  end

  def penalties
    Penalty.where(team_id: teams.select(:id))
  end

  def race_duration
    return 0 unless active?
    return finished_at.to_time - started_at.to_time if finished?

    Time.zone.now - started_at.to_time
  end

  def race_time
    return unless active?
    return finished_at.to_time if finished?

    Time.at(race_duration)
  end

  def to_stats
    events = Event.where(team_id: teams.select(:id)).map do |e|
      ts = if self.started_at.present?
        e.created_at < self.started_at ? self.started_at : e.created_at
      else
        e.created_at
      end
      [e.team_id, e.driver_id, ts.to_time.utc.to_i, e.mode]
    end
    turns  = Turn.where(team_id: teams.select(:id)).map { |t| [t.team_id, t.driver_id, t.duration] }
    penalties = Penalty.where(team_id: teams.select(:id)).map { |pe| [pe.team_id, pe.driver_id, pe.created_at.to_time.utc.to_i, pe.reason] }
    Stats.new events, turns, penalties, mode
  end

  def self.current_race?
    current_race.present?
  end

  def self.current_race
    Race.active.first || Race.planned.where('scheduled>=?', Date.current).order(scheduled: :asc).first
  end
end
