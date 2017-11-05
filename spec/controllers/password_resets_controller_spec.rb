require_relative '../../controllers/application_controller'
require_relative '../../controllers/password_resets_controller'
require_relative '../../controllers/user_sessions_controller'

Pony.override_options = { :via => :test }

describe PasswordResetsController do
  include Rack::Test::Methods

  def app
    PasswordResetsController.new(UserSessionsController)
  end

  before do
    env "rack.session", {:csrf => "Mi65Gq3AdKNU74OOsaOgWKdXdBq2RvCoHHcc6cVPpBo="}
  end

  it "Shows a page to create a new password reset" do
    get '/password_resets/new'

    expect(last_response).to be_ok
    expect(last_response.body).to include('Reset password')
  end

  describe "Creating a new password reset" do
    let(:token) { "Mi65Gq3AdKNU74OOsaOgWKdXdBq2RvCoHHcc6cVPpBo=" }

    context "with valid user and email" do
      let(:user) { create(:user) }

      it "finds the user" do
        expect(User).to receive(:find_by).with(email: user.email).and_return(user)

        post '/password_resets', { email: user.email }, 'HTTP_X_CSRF_TOKEN' => token
      end

      it "generates a new password reset token" do
        expect{ post '/password_resets', { email: user.email }, 'HTTP_X_CSRF_TOKEN' => token; user.reload }.to change{user.password_reset_token}
      end

      it "sends a password reset email" do
        expect{ post '/password_resets', { email: user.email }, 'HTTP_X_CSRF_TOKEN' => token }.to change(Mail::TestMailer.deliveries, :length)
      end

      it "redirects to login page" do
        post '/password_resets', { email: user.email }, 'HTTP_X_CSRF_TOKEN' => token

        follow_redirect!
      end
    end

    context "with no user found" do
      it "renders the new page" do
        post '/password_resets', { email: 'not@exists.com' }, 'HTTP_X_CSRF_TOKEN' => token

        follow_redirect!

        expect(last_response.body).to include('Reset password')
      end
    end
  end

  describe "Shows a page to edit password" do
    context "with valid password reset token" do
      let(:user) { create(:user) }
      before { user.generate_password_reset_token! }

      it "renders the edit template" do
        get "/password_resets/#{user.password_reset_token}/edit"

        expect(last_response).to be_ok
        expect(last_response.body).to include('Password reset')
      end

      it "finds the user" do
        expect(User).to receive(:find_by).with(password_reset_token: user.password_reset_token).and_return(user)

        get "/password_resets/#{user.password_reset_token}/edit"
      end
    end

    context "with invalid password reset token" do
      it "redirects to new page" do
        get "/password_resets/n0t3x15t/edit"

        follow_redirect!

        expect(last_response.body).to include('Reset password')
      end
    end
  end

  describe "Updates user's password" do
    let(:token) { "Mi65Gq3AdKNU74OOsaOgWKdXdBq2RvCoHHcc6cVPpBo=" }

    context "with valid user and email" do
      let(:user) { create(:user) }

      it "finds the user" do
        expect(User).to receive(:find_by).with(email: user.email).and_return(user)

        post '/password_resets', { email: user.email }, 'HTTP_X_CSRF_TOKEN' => token
      end

      it "generates a new password reset token" do
        expect{ post '/password_resets', { email: user.email }, 'HTTP_X_CSRF_TOKEN' => token; user.reload; }.to change{user.password_reset_token}
      end

      it "sends a password reset email" do
        expect{ post '/password_resets', { email: user.email }, 'HTTP_X_CSRF_TOKEN' => token }.to change(Mail::TestMailer.deliveries, :length)
      end

      it "redirects to login page" do
        post '/password_resets', { email: user.email }, 'HTTP_X_CSRF_TOKEN' => token

        follow_redirect!
      end
    end

    context "with no user found" do
      it "renders the new page" do
        post '/password_resets', { email: 'not@exists.com' }, 'HTTP_X_CSRF_TOKEN' => token

        follow_redirect!

        expect(last_response.body).to include('Reset password')
      end
    end
    context "with valid token" do
      let(:user) { create(:user) }
      before { user.generate_password_reset_token! }

      it "finds the user" do
        expect(User).to receive(:find_by).with(password_reset_token: user.password_reset_token).and_return(user)

        put "/password_resets/#{user.password_reset_token}", { password: 'password' }, 'HTTP_X_CSRF_TOKEN' => token
      end

      it "changes the password" do
        expect{
          put "/password_resets/#{user.password_reset_token}", { password: 'password' }, 'HTTP_X_CSRF_TOKEN' => token
          user.reload
        }.to change{user.password_digest}
      end

      it "clears the password_reset_token" do
        put "/password_resets/#{user.password_reset_token}", { password: 'password' }, 'HTTP_X_CSRF_TOKEN' => token
        user.reload
        expect(user.password_reset_token).to be_nil
      end

      it "redirects to login page if new password is valid" do
        put "/password_resets/#{user.password_reset_token}", { password: 'password' }, 'HTTP_X_CSRF_TOKEN' => token

        follow_redirect!

        expect(last_response.body).to include('Login')
      end

      it "halts 422 if new password is invalid" do
        put "/password_resets/#{user.password_reset_token}", { password: '' }, 'HTTP_X_CSRF_TOKEN' => token

        expect(last_response.status).to eq(422)
        expect(last_response.body).to include('Invalid password')
      end
    end

    context "with invalid token" do
      it "halts 404" do
        put "/password_resets/n0t3x15t", {}, 'HTTP_X_CSRF_TOKEN' => token

        expect(last_response.status).to eq(404)
      end
    end
  end

end
