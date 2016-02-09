class Status < Grape::API
  include Defaults
  include Authentication

  version 'v1', using: :path

  before do
    authenticate!
  end

  desc 'Check system status'
  get :ping do
    present status:'ok'
  end
end
