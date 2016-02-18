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

  def has_unassigned_attendance?(team_id)
    attendances.where(team_id:team_id).unassigned.any?
  end
end
