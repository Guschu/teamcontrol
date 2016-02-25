# == Schema Information
#
# Table name: events
#
#  id         :integer          not null, primary key
#  team_id    :integer
#  driver_id  :integer
#  mode       :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  penalty_id :integer
#
# Indexes
#
#  index_events_on_driver_id   (driver_id)
#  index_events_on_penalty_id  (penalty_id)
#  index_events_on_team_id     (team_id)
#
# Foreign Keys
#
#  fk_rails_74371719e9  (driver_id => drivers.id)
#  fk_rails_f5fcdb65ec  (penalty_id => penalties.id)
#  fk_rails_f62361cf64  (team_id => teams.id)
#

class Event < ActiveRecord::Base
  belongs_to :team
  belongs_to :driver
  belongs_to :penalty

  enum mode: { arriving: 1, leaving: 2 }

  validates :team_id, :driver_id, :mode, presence: true
  validate :valid_sequence

  before_validation :set_mode
  before_create :create_turn
  before_create :create_penalty

  def create_turn
    if turn = Turn.for_event(self)
      turn.save!
    end
    true
  end

  def create_penalty
    if penalty = Penalty.for_event(self)
      penalty.save!
      self.penalty = penalty
    end
    true
  end

  def race
    @race ||= Race.joins(:teams).find_by teams:{ id:self.team_id }
  end

  def set_mode
    self.mode ||= case race.mode.to_sym
                  when :leaving then :leaving
                  when :both then similar_events.size.even? ? :arriving : :leaving
                  end
  end

  def similar_events
    @events ||= Event.where(team_id:self.team_id, driver_id:self.driver_id).order('created_at asc')
  end

  def valid_sequence
    if race.mode.to_sym == :both && !race.active?
      errors.add(:base, :prebooking_is_not_open) unless race.prebooking_open?
    end
    errors.add(:mode, :cant_leave_before_start) if self.leaving? && race.planned?
    if race.both?
      if similar_events.any?
        errors.add(:mode, :must_be_different_to_predecessor) if self.mode == similar_events.last.mode
      else
        errors.add(:mode, :invalid) if self.leaving?
      end
    else
      errors.add(:mode, :invalid) if self.arriving?
    end
  end
end
