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

FactoryGirl.define do
  factory :race do
    name 'My Test Race'
    scheduled { Date.current }
    duration 540
    max_drive 170
    min_turn 20
    max_turn 40
    break_time 45
    waiting_period 3
    state 0
    mode 0
    prebooking_open false

    trait :started do
      started_at { Time.now.beginning_of_hour }
      state :active
    end

    trait :finished do
      started_at { (Time.now - duration.minutes).beginning_of_hour }
      finished_at { started_at + duration.minutes }
      state :finished
    end

    trait :with_teams do
      teams { build_list :team, 3 }
    end
  end
end
