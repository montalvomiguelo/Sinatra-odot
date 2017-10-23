require_relative '../../controllers/user_sessions_controller'

describe UserSessionsController do
  include Rack::Test::Methods

  def app
    UserSessionsController
  end

  it "has a login page" do
    get "/sessions/login"

    expect(last_response).to be_ok
    expect(last_response.body).to include('Login')
  end

  describe "logging in a user" do
    context "with valid credentials" do
      let!(:user) { create(:user, email: 'johndoe@example.com', password: '123456') }

      it "stores user's ID in the session hash" do
        post '/sessions', { email: 'johndoe@example.com', password: '123456' }

        expect(last_request.env['rack.session']['id']).to eq(user.id)
      end

      it "redirects to lists page" do
        post '/sessions', { email: 'johndoe@example.com', password: '123456' }

        follow_redirect!
      end
    end

    context "with invalid credentials" do
      it "redirects to login page" do
        post '/sessions', { email: '', password: '' }

        follow_redirect!
        expect(last_response.body).to include('Login')
      end
    end
  end

end
