class ApiResponse
  attr_reader :code, :title, :message

  def initialize(code, title, message)
    @code = code
    @title = title
    @message = message
  end

  def entity
    Entity.new(self)
  end

  class Entity < Grape::Entity
    expose :code, as: :status, documentation: { type: 'String', desc: 'Severity', values: %w(success info error) }
    expose :title,             documentation: { type: 'String', desc: 'Response title' }
    expose :message,           documentation: { type: 'String', desc: 'Response message' }
  end

  def self.success(title, message)
    new 'success', title, message
  end

  def self.error(title, message)
    new 'error', title, message
  end

  def self.info(title, message)
    new 'info', title, message
  end
end
