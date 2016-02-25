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
  belongs_to :team, counter_cache: true
  belongs_to :driver

  scope :unassigned, -> { where('tag_id IS NULL OR tag_id=""') }

  def is_unassigned?
    tag_id.blank?
  end

  def create_event
    Event.create team_id:self.team_id, driver_id:self.driver_id
  end

  def destroy
    super if may_destroy?
  end

  def may_destroy?
    if Event.where(team_id: self.team_id, driver_id: self.driver_id).exists?
      return false
    end
    true
  end
end
