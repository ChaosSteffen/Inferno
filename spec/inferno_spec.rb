require_relative 'spec_helper.rb'

describe 'Inferno' do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  it "renders a homepage" do
    get '/'

    last_response.should be_ok
    last_response.body.should include('Inferno')
  end
end
