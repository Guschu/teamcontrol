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
#  team_token        :string(255)
#
# Indexes
#
#  index_teams_on_race_id     (race_id)
#  index_teams_on_team_token  (team_token)
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

  accepts_nested_attributes_for :attendances, reject_if: :all_blank, allow_destroy: true

  has_attached_file :logo,
    styles: { large:'256x256>', thumb:['32x32>', :png] },
    default_url: "/images/:style/missing.png"
  validates_attachment :logo, content_type: {
    content_type: %w(image/jpg image/jpeg image/png image/gif)
  }

  validates :name, :team_token, presence:true
  validates :team_token, uniqueness:{ scope: :race_id }

  before_validation :generate_token
  after_validation :batch_create_drivers!
  before_save :destroy_logo!

  # intentionally returns nothing
  def batch_create_drivers
    @batch_create_drivers
  end

  def batch_create_drivers=(val)
    @batch_create_drivers = val
  end

  def has_unassigned_attendances?
    attendances.unassigned.any?
  end

  def logo_delete
    @logo_delete ||= '0'
  end

  def logo_delete=(val)
    @logo_delete = val
  end

  def to_stats
    events = Event.where(team_id:self.id).map{|e| [e.team_id, e.driver_id, e.created_at.to_time.utc.to_i, e.mode]}
    turns  = Turn.where(team_id:self.id).map{|t| [t.team_id, t.driver_id, t.duration]}
    Stats.new events, turns, race.mode
  end

  private

  def batch_create_drivers!
    (@batch_create_drivers || '').lines.each do |line|
      line.chomp!
      d = Driver.find_or_create_by(name:line)
      unless attendances.where(driver_id:d.id).any?
        attendances.build(driver_id:d.id)
      end
    end
  end

  def generate_token
    self.team_token ||= begin
      allowed = '23456789ABCDEFGHJKLMNPQRSTUVWXYZ'.chars
      8.times.map{ allowed.sample }.join
    end
  end

  def destroy_logo!
    self.logo.clear if @logo_delete == "1"
  end
end
