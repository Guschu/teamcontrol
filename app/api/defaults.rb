module Defaults
  extend ActiveSupport::Concern

  included do
    content_type :xml, 'application/xml'
    content_type :json, 'application/json'

    default_format :json

    helpers do
      def permitted_params
        @permitted_params ||= declared(params, include_missing: false)
      end

      def logger
        Rails.logger
      end
    end

    rescue_from ActiveRecord::RecordNotFound do |e|
      env['api.endpoint'].logger.warn e.message
      error_response(message: e.message, status: 404)
    end

    rescue_from ActiveRecord::RecordInvalid do |e|
      env['api.endpoint'].logger.warn e.message
      error_response(message: e.message, status: 422)
    end

    rescue_from Grape::Exceptions::ValidationErrors do |e|
      env['api.endpoint'].logger.warn e.message
      error! e, 422
    end
  end
end
