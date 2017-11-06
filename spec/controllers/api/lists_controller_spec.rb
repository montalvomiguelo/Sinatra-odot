require_relative '../../../controllers/api/application_controller'
require_relative '../../../controllers/api/lists_controller'

describe Api::ListsController do
  include Rack::Test::Methods

  def app
    Api::ListsController
  end

  it "Retreives all lists" do
    user = create(:user_with_lists)

    get '/api/lists'
    expect(last_response).to be_ok
  end

  describe "Retreiving a single list" do
    let(:user_one) { create(:user_with_lists) }
    let(:list) { user_one.lists.first }

    context "with valid id" do
      it "finds the list" do
        expect_any_instance_of(Api::ListsController).to receive(:find_list).and_return(list)
        get "/api/lists/#{list.id}"
      end

      it "responds 200 ok" do
        get "/api/lists/#{list.id}"
        expect(last_response.status).to eq(200)
      end

      it "shows the resource" do
        get "/api/lists/#{list.id}"
        expect(last_response.body).to include(list.title)
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

    context "with valid params" do
      it "responds 200 ok" do
        post '/api/lists', { title: 'A new list' }
        expect(last_response.status).to eq(200)
      end

      it "retrieves the resource" do
        post '/api/lists', { title: 'A new list' }
        expect(last_response.body).to include('A new list')
      end
    end

    context "with invalid params" do
      it "it responds 422 error" do
        post '/api/lists', { title: '' }
        expect(last_response.status).to eq(422)
        expect(last_response.body).to include('title')
      end
    end
  end

  describe "Deleting a list" do
    let(:user_one) { create(:user_with_lists) }
    let(:list) { user_one.lists.first }

    context "with valid id" do
      it "finds the list" do
        expect_any_instance_of(Api::ListsController).to receive(:find_list).and_return(list)
        delete "/api/lists/#{list.id}"
      end

      it "responds 200 ok" do
        delete "/api/lists/#{list.id}"
        expect(last_response.status).to eq(200)
        expect(last_response.body).to eq('List deleted successfully')
      end
    end

    context "with invalid id" do
      it "responds 404 error" do
        delete "/api/lists/1234567890"
        expect(last_response.status).to eq(404)
        expect(last_response.body).to eq('Not found')
      end
    end
  end

  describe "Updating a list" do
    let(:user_one) { create(:user_with_lists) }
    let(:list) { user_one.lists.first }

    context "with valid params" do
      it "finds the list" do
        expect_any_instance_of(Api::ListsController).to receive(:find_list).and_return(list)
        put "/api/lists/#{list.id}", {title: 'Title has changed'}
      end

      it "it saves the new data" do
        expect_any_instance_of(List).to receive(:save)
        put "/api/lists/#{list.id}", {title: 'Title has changed'}
      end

      it "returns updated list" do
        put "/api/lists/#{list.id}", {title: 'Title has changed'}
        expect(last_response.body).to include('Title has changed')
      end
    end

    context "with invalid id" do
      it "responds 404 error" do
        put "/api/lists/1234567890", {title: 'Title has changed'}
        expect(last_response.status).to eq(404)
      end
    end

    context "with invalid params" do
      it "responds 422 error" do
        put "/api/lists/#{list.id}", {title: ''}
        expect(last_response.status).to eq(422)
        expect(last_response.body).to include('blank')
      end
    end
  end
end
