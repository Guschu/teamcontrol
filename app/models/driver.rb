# == Schema Information
#
# Table name: drivers
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Driver < ActiveRecord::Base
  has_many :attendances
  has_many :events
  has_many :penalties

  validates :name, presence: true

  def has_unassigned_attendance?(team_id)
    attendances.where(team_id: team_id).unassigned.any?
  end

  def self.free_for_race(race)
    Driver.where.not(id: Attendance.where(team_id: Team.where(race_id: race.id).select(:id)).pluck(:driver_id))
  end
end
