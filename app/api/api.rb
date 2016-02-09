require 'grape-swagger'

class API < Grape::API
  TOKEN_NAME = 'X-Tc-Token'.freeze

  logger.formatter = GrapeLogging::Formatters::Default.new
  use GrapeLogging::Middleware::RequestLogger, { logger: logger }

  mount Status
  # mount Merchants::Categories
  # mount Merchants::Products

  add_swagger_documentation(
    api_version:'v1',
    base_path:'/api',
    hide_documentation_path:true,
    hide_format:true,
    info:{
      description:'Data interface for TeamControl stations.',
      title:'TeamControl API',
      contact:'kontakt@software-berater.net'
    }
  )
end
