require_relative '../../controllers/application_controller'
require_relative '../../controllers/lists_controller'

describe ListsController do
  include Rack::Test::Methods

  def app
    ListsController
  end

  describe "Fetching lists" do
    context "when user is logged out" do
      it "halts an error" do
        get '/lists'

        expect(last_response.status).to eq(401)
        expect(last_response.body).to include('Not authorized')
      end

      context "when user is logged in" do
        it "retreives all lists" do
          list = create(:list)

          allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(create(:user))

          get '/lists'

          expect(last_response).to be_ok
          expect(last_response.body).to include('Lists')

          expect(List.all.size).to eq(1)
          expect(last_response.body).to include('List title')
        end
      end
    end
  end

  describe "Showing a form to create a new todo list" do
    context "when user is logged in" do
      it "success" do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(create(:user))

        get '/lists/new'

        expect(last_response).to be_ok
        expect(last_response.body).to include('New list')
      end
    end

    context "when user is logged out" do
      it "halts an error" do
        get '/lists/new'

        expect(last_response.status).to eq(401)
      end
    end
  end

  describe "Creating a list" do
    context "when user is logged out" do
      it "halts an error" do
        post '/lists', { title: 'Clean the car' }

        expect(last_response.status).to eq(401)
      end
    end

    context 'with valid params' do
      it 'success' do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(create(:user))

        post '/lists', { title: 'Clean the car' }

        follow_redirect!

        expect(last_response.body).to include('Clean the car')
      end
    end

    context 'with invalid params' do
      it 'fails' do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(create(:user))

        post '/lists', { title: '' }

        expect(last_response.status).to eq(500)
      end
    end
  end

  describe "Showing a single list" do
    let(:list) { create(:list_with_tasks, title: "Groceries list") }

    it "halts an error when no user is logged in" do
      get "/lists/#{list.id}"

      expect(last_response.status).to eq(401)
    end

    it "success with logged in user" do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(create(:user))

      get "/lists/#{list.id}"

      expect(last_response).to be_ok
      expect(last_response.body).to include('Groceries list')

      expect(list.tasks.size).to eq(5)
      expect(last_response.body).to include('Task title')
    end
  end

  describe "Showing a form to edit a list" do
    let(:list) { create(:list, title: "Groceries list") }

    it "halts an error for not logged in user" do
      get "/lists/#{list.id}/edit"

      expect(last_response.status).to eq(401)
    end

    it "is ok for logged in users" do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(create(:user))
      get "/lists/#{list.id}/edit"

      expect(last_response).to be_ok
      expect(last_response.body).to include('Edit list')
      expect(last_response.body).to include("lists/#{list.id}")
      expect(last_response.body).to include('value="Groceries list"')
    end
  end

  describe 'Updating a list' do
    let (:list) { create(:list, title: "Groceries list") }

    it "halts an error when user is not logged in" do
      put "/lists/#{list.id}", { title: 'Title updated' }

      expect(last_response.status).to eq(401)
    end

    context 'with valid params' do
      it 'success' do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(create(:user))

        put "/lists/#{list.id}", { title: 'Title updated' }

        follow_redirect!

        expect(last_response).to be_ok
        expect(last_response.body).to include('Title updated')
      end
    end

    context 'with invalid params' do
      it 'fails' do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(create(:user))

        put "/lists/#{list.id}", { title: '' }

        expect(last_response.status).to eq(500)
      end
    end
  end

  describe "Deleting a list and its related tasks" do
    let(:list) { create(:list_with_tasks, title: "Groceries list") }

    it "is ok for logged in user" do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(create(:user))

      delete "/lists/#{list.id}"

      follow_redirect!

      expect(last_response.body).not_to include('Groceries list')
      expect(Task.all.size).to eq(0)
    end

    it "halts an error when user is not logged in" do
      delete "/lists/#{list.id}"

      expect(last_response.status).to eq(401)
    end
  end

end
