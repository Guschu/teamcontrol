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
#
# Indexes
#
#  index_races_on_slug  (slug)
#

class Race < ActiveRecord::Base
  extend FriendlyId

  has_many :teams

  validates :name, presence:true
  friendly_id :name, use: :slugged

  DEFAULTS = {
    duration:540,
    max_drive:170,
    max_turn:40,
    break_time:45,
    waiting_period:3
  }
end
