class ApiResponse
  attr_reader :status, :message

  def initialize(status, message)
    @status = status
    @message = message
  end

  def entity
    Entity.new(self)
  end

  class Entity < Grape::Entity
    expose :status, :message
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
