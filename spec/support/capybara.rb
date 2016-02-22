Capybara.asset_host = 'http://localhost:3000'

# see https://github.com/plataformatec/devise/wiki/How-To:-Test-with-Capybara
RSpec.configure do |config|
  config.include Warden::Test::Helpers
  config.before :suite do
    Warden.test_mode!
  end

  config.after :each do
    Warden.test_reset!
  end
end
