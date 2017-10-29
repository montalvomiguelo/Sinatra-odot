require_relative '../../controllers/users_controller'

describe UsersController do
  include Rack::Test::Methods

  def app
    UsersController
  end

  it "returns an HTML form for creating a new user" do
    get "/users/new"

    expect(last_response).to be_ok
    expect(last_response.body).to include('New user')
  end

  context "creating a new user" do

    describe "with valid params" do
      it "success" do
        post "/users", {
          first_name: 'John',
          last_name: 'Doe',
          email: 'johndoe@example.com',
          password: '123456'
        }

        expect(User.all.size).to eq(1)
        expect(User.first.first_name).to eq('John')
        expect(User.first.last_name).to eq('Doe')
        expect(User.first.email).to eq('johndoe@example.com')
        expect(last_request.env['rack.session']['id']).to eq(User.first.id)
      end
    end

    describe "with invalid params" do
      it "fails" do
        post "/users", {
          email: 'email',
          password: 'password'
        }

        expect(last_response.status).to eq(500)

        post '/users', {
          email: 'user@example.com',
          password: ''
        }

        expect(last_response.status).to eq(500)
      end
    end

  end
end
