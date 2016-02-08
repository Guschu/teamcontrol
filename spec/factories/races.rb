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
    name "MyString"
    duration 1
    max_drive 1
    max_turn 1
    break_time 1
    waiting_period 1
  end
end
