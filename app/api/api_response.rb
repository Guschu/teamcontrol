class ApiResponse
  attr_reader :code, :message

  def initialize(code, message)
    @code = code
    @message = message
  end

  def entity
    Entity.new(self)
  end

  class Entity < Grape::Entity
    expose :code, as: :status, documentation: { type: 'String', desc: 'Severity', values: %w(success info error) }
    expose :message,           documentation: { type: 'String', desc: 'Response message' }
  end

  def self.success(message)
    new 'success', message
  end

  def self.error(message)
    new 'error', message
  end

  def self.info(message)
    new 'info', message
  end
end
