require 'sinatra/base'

class SwaggerUI < Sinatra::Base
  set :public_folder, Rails.root.join('vendor', 'swagger')
  set :static, true

  get '/' do
    send_file File.join(settings.public_folder, 'index.html')
  end
end
