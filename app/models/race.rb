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
#  state          :integer
#  mode           :integer
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

  aasm :column => :state do
    state :planned, :initial => true
    state :active
    state :finished

    event :start do
      transitions :from => :planned, :to => :active
    end

    event :finish do
      transitions :from => :active, :to => :finished
    end
  end

  has_many :teams

  validates :name, presence:true
  friendly_id :name, use: :slugged

  DEFAULTS = {
    duration: 540,
    max_drive: 170,
    max_turn: 40,
    break_time: 45,
    waiting_period: 3
  }

  def self.current_race
    Race.active.first
  end
end
