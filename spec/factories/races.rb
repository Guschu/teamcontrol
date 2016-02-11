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
#
# Indexes
#
#  index_races_on_slug  (slug)
#

FactoryGirl.define do
  factory :race do
    name 'My Test Race'
    duration 540
    max_drive 170
    max_turn 40
    break_time 45
    waiting_period 3
    state 0
    mode 0
  end
end
