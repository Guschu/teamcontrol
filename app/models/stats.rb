class Stats
  include ActiveModel::Serializers::JSON
  attr_reader :mode, :events, :turns, :penalties

  def attributes
    instance_values
  end

  def as_json(_opts = nil)
    super(
      only: [:mode],
      methods: [
        :active_driver_count, :average_drive_time, :maximum_drive_time,
        :minimum_drive_time, :current_driver_id, :current_drive_time,
        :last_break_time, :last_driver_id, :last_drive_time,
        :total_drive_time
      ]
    )
  end

  def initialize(events, turns, penalties, mode = :both)
    @events = events.sort { |e1, e2| e1[2] <=> e2[2] }
    @turns = turns
    @penalties = penalties
    @mode = mode.to_sym
  end

  def active_driver_count
    @events.map(&:second).uniq.size
  end

  def average_drive_time
    c = @turns.size
    return 0.0 if c == 0
    total_drive_time.to_f / c
  end

  def maximum_drive_time
    @turns.map(&:third).max
  end

  def minimum_drive_time
    @turns.map(&:third).min
  end

  def current_driver
    id = current_driver_id
    return if id.nil?
    Driver.find(id) rescue nil
  end

  def current_driver_id
    return if @mode == :leaving

    evt = @events.reverse_each.find { |e| e[3] == 'arriving' }
    if evt.present?
      # find leaving from same driver later in the events
      later_leaving = @events.select do |e|
        e[2]>evt[2] && # only where timestamp is greater
        e[1] == evt[1] && #same driver id
        e[3] == 'leaving'
      end
      evt[1] unless later_leaving.any?
    end
  end

  def current_drive_time
    return if @mode == :leaving
    return if current_driver_id.nil?

    now = Time.zone.now.to_i

    evt = @events.reverse_each.find { |e| e[3] == 'leaving' }.first
    
    start_time =
      if evt
        evt[2] # timestamp of last leaving event of the team
      else
        race.start_time.to_i # fallback to race start
      end

    now - start_time
  end

  def group_by_team
    eg = @events.group_by(&:first)
    tg = @turns.group_by(&:first)
    pg = @penalties.group_by(&:first)
    keys = (eg.keys + tg.keys + pg.keys).uniq.sort
    h = Hash[keys.map do |k|
      [k, Stats.new(eg[k] || [], tg[k] || [], pg[k] || [], mode)]
    end]
    h.default_proc = proc {|h, k| h[k] = Stats.new [], [], [], mode}
    h
  end

  def group_by_driver
    eg = @events.group_by(&:second)
    tg = @turns.group_by(&:second)
    pg = @penalties.group_by(&:second)
    keys = (eg.keys + tg.keys + pg.keys).uniq.sort
    h = Hash[keys.map do |k|
      [k, Stats.new(eg[k] || [], tg[k] || [], pg[k] || [], mode)]
    end]
    h.default_proc = proc {|h, k| h[k] = Stats.new [], [], [], mode}
    h
  end

  def last_break_time
    now = Time.zone.now.to_i
    evt = @events.reverse_each.find { |e| e[3] == 'leaving' }
    return now - evt[2] if evt.present?
  end

  def last_driver
    id = last_driver_id
    return if id.nil?
    Driver.find(id) rescue nil
  end

  def last_driver_id
    idx = current_driver_id.nil? ? -1 : -2
    direction = case @mode
                when :both then 'arriving'
                when :leaving then 'leaving'
                end
    evt = @events.select { |e| e[3] == direction }[idx]
    evt[1] if evt.present?
  end

  def last_drive_time
    @turns.map(&:third)[-1]
  end

  def penalty_count
    @penalties.size
  end

  def total_drive_time
    @turns.map(&:third).reduce(&:+)
  end
end
