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

  def create_event(opts = {})
    val = { team:self.team, driver:self.driver }.merge(opts)
    val[:mode] ||= case val[:team].race.mode.to_sym
                   when :leaving then :leaving
                   when :both
                     if val[:team].events.where(driver_id:val[:driver].id).count.even?
                       :arriving
                     else
                       :leaving
                     end
                   end

    evt = nil
    Event.transaction do
      evt = Event.new(val)
      if turn = Turn.for_event(evt)
        turn.save!
      end
      if penalty = Penalty.for_event(evt)
        penalty.save!
        evt.penalty = penalty
      end
      evt.save!
    end
    evt
  end
end
