class Status < Grape::API
  include Defaults
  include Authentication

  version 'v1', using: :path

  before do
    authenticate!
  end

  desc 'Check system status' do
    success ApiResponse::Entity
    failure [
      [401, 'Unauthorized']
    ]
  end
  get :ping do
    present ApiResponse.success 'OK', 'OK'
  end
end
