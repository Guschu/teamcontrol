require 'grape-swagger'

class API < Grape::API
  TOKEN_NAME = 'X-Tc-Token'.freeze

  logger.formatter = GrapeLogging::Formatters::Default.new
  use GrapeLogging::Middleware::RequestLogger, { logger: logger }

  mount Status
  # mount Merchants::Categories
  # mount Merchants::Products

  add_swagger_documentation hide_documentation_path:true, api_version:'v1', format: :json, info:{
      description:'Data interface for TeamControl',
      title:'TeamControl API'
    }
end
