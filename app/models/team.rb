# == Schema Information
#
# Table name: teams
#
#  id                :integer          not null, primary key
#  race_id           :integer
#  name              :string(255)
#  logo_file_name    :string(255)
#  logo_content_type :string(255)
#  logo_file_size    :integer
#  logo_updated_at   :datetime
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
# Indexes
#
#  index_teams_on_race_id  (race_id)
#
# Foreign Keys
#
#  fk_rails_4a0c7e1679  (race_id => races.id)
#

class Team < ActiveRecord::Base
  belongs_to :race
  has_many :attendances, dependent: :destroy
  has_many :events, dependent: :destroy
  has_many :drivers, through: :attendances
  has_attached_file :logo
  validates_attachment :logo, content_type: {
    content_type: %w(image/jpg image/jpeg image/png image/gif)
  }

  def current_driver
    return if race.mode == :leaving
    if e = events.to_a.select(&:arriving?).sort { |a, b| a.created_at <=> b.created_at }.last
      return e.driver
    end
  end

  def last_driver
    if e = events.to_a.select(&:leaving?).sort { |a, b| a.created_at <=> b.created_at }.last
      return e.driver
    end
  end
end
