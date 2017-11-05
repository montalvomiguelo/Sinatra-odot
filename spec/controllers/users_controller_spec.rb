require_relative '../../controllers/application_controller'
require_relative '../../controllers/users_controller'

describe UsersController do
  include Rack::Test::Methods

  def app
    UsersController
  end

  before do
    env "rack.session", {:csrf => "Mi65Gq3AdKNU74OOsaOgWKdXdBq2RvCoHHcc6cVPpBo="}
  end

  it "returns an HTML form for creating a new user" do
    get "/users/new"

    expect(last_response).to be_ok
    expect(last_response.body).to include('New user')
  end

  context "creating a new user" do

    describe "with valid params" do
      let!(:token) { "Mi65Gq3AdKNU74OOsaOgWKdXdBq2RvCoHHcc6cVPpBo=" }

      it "success" do
        post "/users", {
          first_name: 'John',
          last_name: 'Doe',
          email: 'johndoe@example.com',
          password: '123456'
        }, 'HTTP_X_CSRF_TOKEN' => token

        expect(User.all.size).to eq(1)
        expect(User.first.first_name).to eq('John')
        expect(User.first.last_name).to eq('Doe')
        expect(User.first.email).to eq('johndoe@example.com')
        expect(last_request.env['rack.session']['id']).to eq(User.first.id)
      end
    end

    describe "with invalid params" do
      let!(:token) { "Mi65Gq3AdKNU74OOsaOgWKdXdBq2RvCoHHcc6cVPpBo=" }

      it "fails" do
        post "/users", {
          email: 'email',
          password: 'password'
        }, 'HTTP_X_CSRF_TOKEN' => token

        expect(last_response.status).to eq(400)
        expect(last_response.body).to eq('Invalid data')

        post '/users', {
          email: 'user@example.com',
          password: ''
        }, 'HTTP_X_CSRF_TOKEN' => token

        expect(last_response.status).to eq(400)
        expect(last_response.body).to eq('Invalid data')
      end
    end

  end
end
