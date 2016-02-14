# == Schema Information
#
# Table name: races
#
#  id             :integer          not null, primary key
#  name           :string(255)
#  duration       :integer
#  max_drive      :integer
#  max_turn       :integer
#  break_time     :integer
#  waiting_period :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  slug           :string(255)
#  state          :integer          default(0)
#  mode           :integer          default(0)
#  scheduled      :date
#  started_at     :datetime
#  finished_at    :datetime
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
        self.finished_at = Time.zone.now
      end
      transitions from: :active, to: :finished
    end
  end

  has_many :teams

  validates :name, :scheduled, presence: true
  friendly_id :name, use: :slugged

  def events
    Event.where(team_id: teams.select(:id))
  end

  def race_time
    return unless active?
    return self.finished_at.to_time - self.started_at.to_time if finished?

    Time.zone.now - self.started_at.to_time
  end

  def self.current_race?
    current_race.present?
  end

  def self.current_race
    Race.active.first || Race.planned.where('scheduled>=?', Date.current).order(scheduled: :asc).first
  end
end
