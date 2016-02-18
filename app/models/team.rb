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
  has_attached_file :logo,
    styles: { large:'256x256>', thumb:['32x32>', :png] },
    default_url: "/images/:style/missing.png"
  validates_attachment :logo, content_type: {
    content_type: %w(image/jpg image/jpeg image/png image/gif)
  }

  before_save :destroy_logo!

  def current_driver
    return if race.mode == :leaving
    if e = events.to_a.select(&:arriving?).sort { |a, b| a.created_at <=> b.created_at }.last
      return e.driver
    end
  end

  def has_unassigned_attendances?
    attendances.unassigned.any?
  end

  def last_driver
    if e = events.to_a.select(&:leaving?).sort { |a, b| a.created_at <=> b.created_at }.last
      return e.driver
    end
  end

  def logo_delete
    @logo_delete ||= '0'
  end

  def logo_delete=(val)
    @logo_delete = val
  end

  def turns
    Turn.where(team_id:self.id)
  end

  private

  def destroy_logo!
    self.logo.clear if @logo_delete == "1"
  end
end
