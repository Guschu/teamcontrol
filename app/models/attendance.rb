# == Schema Information
#
# Table name: attendances
#
#  id         :integer          not null, primary key
#  team_id    :integer
#  driver_id  :integer
#  tag_id     :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_attendances_on_driver_id  (driver_id)
#  index_attendances_on_tag_id     (tag_id)
#  index_attendances_on_team_id    (team_id)
#
# Foreign Keys
#
#  fk_rails_14314e17d1  (team_id => teams.id)
#  fk_rails_4581e8741f  (driver_id => drivers.id)
#

class Attendance < ActiveRecord::Base
  belongs_to :team
  belongs_to :driver

  # accepts_nested_attributes_for :driver, reject_if: :all_blank

  scope :unassigned, -> { where('tag_id IS NULL OR tag_id=""') }

  def create_event
    case team.race.mode.to_sym
    when :both
      event_map = team.events.group(:driver_id).count
      if (event_map[driver_id] || 0).even?
        team.events.create! driver: driver, mode: :arriving
      else
        team.events.create! driver: driver, mode: :leaving
      end
    when :leaving
      team.events.create! driver: driver, mode: :leaving
    end
  end
end
