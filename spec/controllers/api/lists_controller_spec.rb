require_relative '../../../controllers/api/application_controller'
require_relative '../../../controllers/api/lists_controller'

describe Api::ListsController do
  include Rack::Test::Methods

  def app
    Api::ListsController
  end

  describe "Retreiving all lists" do
    let(:user) { create(:user_with_lists) }

    before do
      basic_authorize user.email, user.password
    end

    context "with user authenticated" do
      it "protects the route" do
        allow_any_instance_of(Api::ListsController).to receive(:current_user).and_return(user)
        expect_any_instance_of(Api::ListsController).to receive(:protected!).and_return(nil)
        get '/lists'
      end

      it "authenticates the user" do
        allow_any_instance_of(Api::ListsController).to receive(:current_user).and_return(user)
        expect_any_instance_of(Api::ListsController).to receive(:authorized?).and_return(true)
        get '/lists'
      end

      it "gets the current user" do
        allow_any_instance_of(Api::ListsController).to receive(:authorized?).and_return(true)
        expect_any_instance_of(Api::ListsController).to receive(:current_user).and_return(user)
        get '/lists'
      end

      it "responds 200 ok" do
        get '/lists'
        expect(last_response.status).to eq(200)
      end

      it "scopes the query to only the lists of current user" do
        expect_any_instance_of(User).to receive(:lists).and_return(user.lists)
        get '/lists'
      end

      it "responds with the lists" do
        list = user.lists.first
        get '/lists'
        expect(last_response.body).to include(list.title)
      end
    end

    context "with no user authenticated" do
      it "responds 401" do
        basic_authorize 'no@valid.com', 'password'
        get '/lists'
        expect(last_response.status).to eq(401)
      end
    end
  end

  describe "Retreiving a single list" do
    let(:user_one) { create(:user_with_lists) }
    let(:list) { user_one.lists.first }

    before do
      basic_authorize user_one.email, user_one.password
    end

    context "with no authorized user" do
      it "halts 401 error" do
        allow_any_instance_of(Api::ListsController).to receive(:authorized?).and_return(false)
        get "/lists/#{list.id}"
        expect(last_response.status).to eq(401)
      end
    end

    context "with valid id" do
      it "finds the list" do
        expect_any_instance_of(Api::ListsController).to receive(:find_list).and_return(list)
        get "/lists/#{list.id}"
      end

      it "responds 200 ok" do
        get "/lists/#{list.id}"
        expect(last_response.status).to eq(200)
      end

      it "shows the resource" do
        get "/lists/#{list.id}"
        expect(last_response.body).to include(list.title)
      end

      it "contains its tasks" do
        get "/lists/#{list.id}"
        expect(last_response.body).to include('Task title')
      end
    end

    context "with invalid id" do
      it "responds 404 error" do
        get "api/lists/1234567890"
        expect(last_response.status).to eq(404)
      end
    end
  end

  describe "Creating a list" do
    let(:user_one) { create(:user_with_lists) }

    before do
      basic_authorize user_one.email, user_one.password
    end

    context "with valid params" do
      it "responds 200 ok" do
        post '/lists', { title: 'A new list' }
        expect(last_response.status).to eq(200)
      end

      it "belongs to current user" do
        post '/lists', { title: 'A new list' }
        expect(user_one.lists.last.user_id).to eq(user_one.id)
      end

      it "retrieves the resource" do
        post '/lists', { title: 'A new list' }
        expect(last_response.body).to include('A new list')
      end
    end

    context "with invalid params" do
      it "it responds 422 error" do
        post '/lists', { title: '' }
        expect(last_response.status).to eq(422)
        expect(last_response.body).to include('title')
      end
    end
  end

  describe "Deleting a list" do
    let(:user_one) { create(:user_with_lists) }
    let(:list) { user_one.lists.first }

    before do
      basic_authorize user_one.email, user_one.password
    end

    context "with valid id" do
      it "finds the list" do
        expect_any_instance_of(Api::ListsController).to receive(:find_list).and_return(list)
        delete "/lists/#{list.id}"
      end

      it "responds 200 ok" do
        delete "/lists/#{list.id}"
        expect(last_response.status).to eq(200)
        expect(last_response.body).to eq('List deleted successfully')
      end
    end

    context "with invalid id" do
      it "responds 404 error" do
        delete "/lists/1234567890"
        expect(last_response.status).to eq(404)
        expect(last_response.body).to eq('Not found')
      end
    end

    context "when list does not belong to user" do
      it "halts 404 error" do
        user_two = create(:user_with_lists)
        list_two = user_two.lists.last
        delete "/lists/#{list_two.id}"

        expect(last_response.status).to eq(404)
        expect(last_response.body).to eq('Not found')
      end
    end
  end

  describe "Updating a list" do
    let(:user_one) { create(:user_with_lists) }
    let(:list) { user_one.lists.first }

    before do
      basic_authorize user_one.email, user_one.password
    end

    context "with valid params" do
      it "finds the list" do
        expect_any_instance_of(Api::ListsController).to receive(:find_list).and_return(list)
        put "/lists/#{list.id}", {title: 'Title has changed'}
      end

      it "it saves the new data" do
        expect_any_instance_of(List).to receive(:save)
        put "/lists/#{list.id}", {title: 'Title has changed'}
      end

      it "returns updated list" do
        put "/lists/#{list.id}", {title: 'Title has changed'}
        expect(last_response.body).to include('Title has changed')
      end
    end

    context "with invalid id" do
      it "responds 404 error" do
        put "/lists/1234567890", {title: 'Title has changed'}
        expect(last_response.status).to eq(404)
      end
    end

    context "with invalid params" do
      it "responds 422 error" do
        put "/lists/#{list.id}", {title: ''}
        expect(last_response.status).to eq(422)
        expect(last_response.body).to include('blank')
      end
    end

    context "when list does not belong to current user" do
      it "halts 404 error" do
        user_two = create(:user_with_lists)
        list_two = user_two.lists.last

        put "/lists/#{list_two.id}", {title: 'Changed'}
        expect(last_response.status).to eq(404)
        expect(last_response.body).to include('Not found')
      end
    end
  end
end
