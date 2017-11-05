require_relative '../../controllers/application_controller'
require_relative '../../controllers/user_sessions_controller'

describe UserSessionsController do
  include Rack::Test::Methods

  def app
    UserSessionsController
  end

  before do
    env "rack.session", {:csrf => "Mi65Gq3AdKNU74OOsaOgWKdXdBq2RvCoHHcc6cVPpBo="}
  end

  it "has a login page" do
    get "/sessions/login"

    expect(last_response).to be_ok
    expect(last_response.body).to include('Login')
  end

  describe "Logs out the user" do
    let(:user) { create(:user, email: 'johndoe@example.com', password: '123456') }

    it "clears the session hash" do
      env "rack.session", {:id => user.id}

      get "/sessions/logout"
      expect(last_request.env['rack.session']).to be_blank
    end
  end

  describe "logging in a user" do
    context "with valid credentials" do
      let!(:user) { create(:user, email: 'johndoe@example.com', password: '123456') }
      let!(:token) { "Mi65Gq3AdKNU74OOsaOgWKdXdBq2RvCoHHcc6cVPpBo=" }

      it "stores user's ID in the session hash" do

        post '/sessions', { email: 'johndoe@example.com', password: '123456' }, 'HTTP_X_CSRF_TOKEN' => token

        expect(last_request.env['rack.session']['id']).to eq(user.id)
      end

      it "redirects to lists page" do
        post '/sessions', { email: 'johndoe@example.com', password: '123456' }, 'HTTP_X_CSRF_TOKEN' => token

        follow_redirect!
      end
    end

    context "with invalid credentials" do
      let!(:token) { "Mi65Gq3AdKNU74OOsaOgWKdXdBq2RvCoHHcc6cVPpBo=" }

      it "redirects to login page" do
        post '/sessions', { email: '', password: '' }, 'HTTP_X_CSRF_TOKEN' => token

        follow_redirect!
        expect(last_response.body).to include('Login')
      end
    end
  end

end
