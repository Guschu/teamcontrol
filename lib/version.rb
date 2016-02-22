class Version
  MAJOR = 1
  MINOR = 0
  PATCH = 0

  def to_s
    [MAJOR, MINOR, PATCH].join('.') << ' ' << revision
  end

  def revision
    @revision ||= begin
      s = if Rails.env.development?
            `git rev-parse HEAD`
          else
            path = Rails.root.join('REVISION')
            path.exist? ? path.read : 'n/a'
          end
      s[0..7]
    end
  end
end
