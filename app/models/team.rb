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
  accepts_nested_attributes_for :drivers

  has_attached_file :logo,
    styles: { large:'256x256>', thumb:['32x32>', :png] },
    default_url: "/images/:style/missing.png"
  validates_attachment :logo, content_type: {
    content_type: %w(image/jpg image/jpeg image/png image/gif)
  }

  before_save :destroy_logo!
  after_create :generate_token

  def current_driver
    return if race.mode == :leaving
    if e = events.to_a.select(&:arriving?).sort { |a, b| a.created_at <=> b.created_at }.last
      return e.driver
    end
  end

  def current_drivetime
    return Time.at(0) if !race.active?

    if race.mode.to_sym == :leaving
      # Zeit seit der letzten Gehend-Buchung
      evt_start = events.leaving
        .order('created_at desc')
        .first
    else
      # Zeit seit der letzten Kommend-Buchung
      evt_start = events.arriving
        .order('created_at desc')
        .first
    end

    if evt_start.present?
      start_at = evt_start.created_at > race.started_at ? evt_start.created_at : race.started_at
    else
      start_at = race.started_at
    end

    Time.at(Time.zone.now - start_at.to_time)
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

  def to_stats
    @stats ||= begin
      events = Event.where(team_id:self.id).map{|e| [e.team_id, e.driver_id, e.created_at.to_time.utc.to_i, e.mode]}
      turns  = Turn.where(team_id:self.id).map{|t| [t.team_id, t.driver_id, t.duration]}
      Stats.new events, turns, race.mode
    end
  end

  def generate_token
    begin
      update_column :team_token, SecureRandom.urlsafe_base64(8)
    rescue ActiveRecord::RecordNotUnique
      retry
    end
  end

  private

  def destroy_logo!
    self.logo.clear if @logo_delete == "1"
  end
end
