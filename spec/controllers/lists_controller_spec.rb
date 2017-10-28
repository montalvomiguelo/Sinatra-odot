require_relative '../../controllers/application_controller'
require_relative '../../controllers/lists_controller'

describe ListsController do
  include Rack::Test::Methods

  def app
    ListsController
  end

  describe "Listing lists" do
    context "when user is logged out" do
      it "halts an error" do
        get '/lists'

        expect(last_response.status).to eq(401)
        expect(last_response.body).to include('Not authorized')
      end

      context "when user is logged in" do
        it "retreives all user's lists" do
          user_one = create(:user_with_lists)
          user_two = create(:user_with_lists)

          allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user_one)

          get '/lists'

          expect(last_response).to be_ok
          expect(last_response.body).to include('Lists')
          expect(last_response.body).not_to include("#{user_two.lists.first.title}")

          expect(user_one.lists.all.size).to eq(2)
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

      it 'belongs to current user' do
        user = create(:user)

        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)

        post '/lists', { title: 'Clean the car' }

        follow_redirect!

        expect(List.last.user).to eq(user)
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
    it "halts an error when no user is logged in" do
      list = create(:list_with_tasks, title: "Groceries list")
      get "/lists/#{list.id}"

      expect(last_response.status).to eq(401)
    end

    context "when user is logged in" do
      it "success if list belongs to user" do
        user = create(:user_with_lists)
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)

        list = user.lists.first

        get "/lists/#{list.id}"

        expect(last_response).to be_ok
        expect(last_response.body).to include('List title')

        expect(list.tasks.size).to eq(5)
        expect(last_response.body).to include('Task title')
      end

      it "fails if list does not belong to user" do
        user_one = create(:user_with_lists)
        user_two = create(:user_with_lists)

        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user_one)

        list = user_two.lists.first

        get "/lists/#{list.id}"

        expect(last_response).not_to be_ok
      end
    end

  end

  describe "Showing a form to edit a list" do
    it "halts an error for not logged in user" do
      list = create(:list, title: "Groceries list")
      get "/lists/#{list.id}/edit"

      expect(last_response.status).to eq(401)
    end

    context "when user is logged in" do
      let (:user_one) { create(:user_with_lists) }
      let (:user_two) { create(:user_with_lists) }

      it "is ok if list belongs to user" do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user_one)

        list = user_one.lists.first
        get "/lists/#{list.id}/edit"

        expect(last_response).to be_ok
        expect(last_response.body).to include('Edit list')
        expect(last_response.body).to include("lists/#{list.id}")
        expect(last_response.body).to include("#{list.title}")
      end

      it "fails if list does not belong to user" do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user_one)

        list = user_two.lists.first

        get "/lists/#{list.id}/edit"

        expect(last_response).not_to be_ok
      end
    end
  end

  describe 'Updating a list' do
    it "halts an error when user is not logged in" do
      list = create(:list, title: "Groceries list")
      put "/lists/#{list.id}", { title: 'Title updated' }

      expect(last_response.status).to eq(401)
    end

    context 'when user is logged in' do
      let(:user_one) { create(:user_with_lists) }
      let(:user_two) { create(:user_with_lists) }

      it "success with valid params" do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user_one)

        list = user_one.lists.first
        put "/lists/#{list.id}", { title: 'Title updated' }

        follow_redirect!

        expect(last_response).to be_ok
        expect(last_response.body).to include('Title updated')
      end

      it 'fails with inavlid params' do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user_one)

        list = user_one.lists.first
        put "/lists/#{list.id}", { title: '' }

        expect(last_response.status).to eq(500)
      end

      it 'fails if list does not belong to user' do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user_one)

        list = user_two.lists.last
        put "/lists/#{list.id}", { title: 'Title updated' }

        expect(last_response.status).to eq(500)
      end
    end
  end

  describe "Deleting a list" do
    context "when user is logged in" do
      let(:user_one) { create(:user_with_lists) }
      let(:user_two) { create(:user_with_lists) }

      it "is ok if list belongs to user" do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user_one)

        list = user_one.lists.last
        delete "/lists/#{list.id}"

        follow_redirect!

        expect(user_one.lists.all.size).to eq(1)
      end

      it "fails if list does not belong to user" do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user_one)

        list = user_two.lists.last
        delete "/lists/#{list.id}"

        expect(last_response.status).to eq(500)
      end
    end

    it "halts an error when user is not logged in" do
      list = create(:list)

      delete "/lists/#{list.id}"

      expect(last_response.status).to eq(401)
    end
  end

end
