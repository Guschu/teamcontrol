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
#  position          :integer
#  team_lead         :string(255)
#  attendances_count :integer
#  penalties_count   :integer
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
  has_many :drivers, through: :attendances
  has_many :events, dependent: :destroy
  has_many :penalties, dependent: :destroy

  accepts_nested_attributes_for :attendances, reject_if: :all_blank, allow_destroy: true

  has_attached_file :logo,
                    styles: { large: '256x256>', thumb: ['32x32>', :png] },
                    default_url: '/images/:style/missing.png'
  validates_attachment :logo, content_type: {
    content_type: %w(image/jpg image/jpeg image/png image/gif)
  }

  validates :name, :team_token, :team_lead, presence: true
  validates :team_token, uniqueness: { scope: :race_id }

  acts_as_list scope: :race

  before_validation :generate_token
  after_validation :batch_create_drivers!
  before_save :destroy_logo!

  attr_accessor :batch_create_drivers

  def has_unassigned_attendances?
    attendances.unassigned.any?
  end

  def is_registrating_team?
    race.registrating_team_id == id
  end

  def logo_delete
    @logo_delete ||= '0'
  end
  
  def turns_count
    leaving = self.events.select{|event| event.mode=="leaving" }.size                                                                                                                                                                            arriving = self.events.select{|event| event.mode=="arriving"}.size
    if arriving == 0
      arriving                                                                                                                                                                                                                                   else
      if leaving == arriving 
        leaving - 1
      else
        arriving - 1
      end
    end
  end

  attr_writer :logo_delete

  def to_stats
    events = Event.where(team_id: id).map do |e|
      ts = if race.started_at.present?
        e.created_at < race.started_at ? race.started_at : e.created_at
      else
        e.created_at
      end
      [e.team_id, e.driver_id, ts.to_time.utc.to_i, e.mode]
    end
    turns  = Turn.where(team_id: id).map { |t| [t.team_id, t.driver_id, t.duration] }
    penalties = Penalty.where(team_id: id).map { |pe| [pe.team_id, pe.driver_id, pe.created_at.to_time.utc.to_i, pe.reason] }
    Stats.new events, turns, penalties, race.mode
  end

  def position_and_name
    [self.position.to_s, self.name].join(' ')
  end

  private

  def batch_create_drivers!
    (@batch_create_drivers || '').lines.each do |line|
      l = line.chomp
      unless l.empty?
        d = Driver.find_or_create_by(name: l)
        unless attendances.where(driver_id: d.id).any?
          attendances.build(driver_id: d.id)
        end
      end
    end
  end

  def generate_token
    self.team_token ||= begin
      allowed = '23456789ABCDEFGHJKLMNPQRSTUVWXYZ'.chars
      Array.new(8) { allowed.sample }.join
    end
  end

  def destroy_logo!
    logo.clear if @logo_delete == '1'
  end
end
