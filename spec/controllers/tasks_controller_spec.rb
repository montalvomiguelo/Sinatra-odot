require_relative '../../controllers/application_controller'
require_relative '../../controllers/tasks_controller'

describe TasksController do
  include Rack::Test::Methods

  def app
    TasksController
  end

  before do
    env "rack.session", {:csrf => "Mi65Gq3AdKNU74OOsaOgWKdXdBq2RvCoHHcc6cVPpBo="}
  end

  describe "Listing tasks" do

    context "when user is not logged in " do
      it "halts an error" do
        get '/tasks'

        expect(last_response.status).to eq(401)
      end
    end

    context "when user is logged in" do
      let!(:user_one) { create(:user_with_lists) }
      let!(:user_two) { create(:user_with_lists) }

      it "shows all user's tasks" do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user_one)

        get '/tasks'

        expect(last_response).to be_ok
        expect(last_response.body).not_to include(user_two.lists.first.title)
        expect(last_response.body).not_to include(user_two.lists.last.title)
      end
    end
  end

  describe "Showing a form to create a new task" do
    context "when user is not logged in" do
      it "halts an error" do
        get '/tasks/new'

        expect(last_response.status).to eq(401)
      end
    end

    it "is allowed for logged in users" do
      user_one = create(:user_with_lists)
      user_two = create(:user_with_lists)

      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user_one)

      get '/tasks/new'

      expect(last_response).to be_ok
      expect(last_response.body).to include('New task')
      expect(last_response.body).to include("#{user_one.lists.first.title}")
      expect(last_response.body).to include("#{user_one.lists.last.title}")
      expect(last_response.body).to_not include("#{user_two.lists.first.title}")
      expect(last_response.body).to_not include("#{user_two.lists.last.title}")
    end
  end

  describe 'Creating a task' do
    let(:user_one) { create(:user_with_lists) }
    let(:user_two) { create(:user_with_lists) }
    let(:token) { "Mi65Gq3AdKNU74OOsaOgWKdXdBq2RvCoHHcc6cVPpBo=" }

    it "halts an error for non logged in users" do
      list = create(:list, title: "Tuts list")

      post '/tasks', { title: 'Learn ruby core', list_id: list.id }, 'HTTP_X_CSRF_TOKEN' => token

      expect(last_response.status).to eq(401)
    end

    context 'with valid params' do
      it 'success' do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user_one)

        list = user_one.lists.first

        post '/tasks', { title: 'Learn ruby core', list_id: list.id }, 'HTTP_X_CSRF_TOKEN' => token

        follow_redirect!

        expect(last_response.body).to include('Learn ruby core')
        expect(last_response.body).to include("#{list.title}")
        expect(list.tasks.last.title).to eq('Learn ruby core')
      end
    end

    context 'with invalid params' do
      it 'fails' do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user_one)

        list = user_two.lists.first

        post '/tasks', { title: '' }, 'HTTP_X_CSRF_TOKEN' => token

        expect(last_response.body).to include('Not found')
        expect(last_response.status).to eq(404)

        post '/tasks', { title: 'Vim tutor', list_id: list.id }, 'HTTP_X_CSRF_TOKEN' => token

        expect(last_response.status).to eq(404)
      end
    end
  end

  describe 'Showing a single task' do
    let!(:user_one) { create(:user_with_lists) }
    let!(:user_two) { create(:user_with_lists) }

    it "halts an error for non logged in users" do
      task = create(:task, title: "Study ruby")

      get "/tasks/#{task.id}"

      expect(last_response.status).to eq(401)
    end

    context 'with valid id' do

      it 'success if belongs to user' do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user_one)

        task = user_one.lists.first.tasks.first

        get "/tasks/#{task.id}"

        expect(last_response).to be_ok
        expect(last_response.body).to include("#{task.title}")
      end

      it 'fails if does not belong to user' do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user_one)

        task = user_two.lists.first.tasks.first

        get "/tasks/#{task.id}"

        expect(last_response).not_to be_ok
        expect(last_response.status).to eq(404)
        expect(last_response.body).to eq('Not found')

      end
    end

    context 'with invalid id' do
      it 'fails' do
        get '/tasks/23'
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user_one)

        expect(last_response).not_to be_ok
      end
    end
  end

  describe 'Showing a form to edit a task' do
    let(:user) { create(:user_with_lists) }
    let(:user_two) { create(:user_with_lists) }

    it "halts an error for non logged in users" do
      list = create(:list, title: "Tuts list")
      task = create(:task, title: "Study ruby")

      get "/tasks/#{task.id}/edit"

      expect(last_response.status).to eq(401)
    end

    it "is allowed for logged in users" do
      list = user.lists.first
      task = list.tasks.first
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)

      list_two = user_two.lists.first

      get "/tasks/#{task.id}/edit"

      expect(last_response).to be_ok
      expect(last_response.body).to include("#{list.title}")
      expect(last_response.body).to include("#{task.title}")
      expect(last_response.body).not_to include("#{list_two.title}")
      expect(last_response.body).to include('Complete')
    end
  end

  describe 'Updating a task' do
    let(:user) { create(:user_with_lists) }
    let(:list) { user.lists.first }
    let(:task) { list.tasks.last }
    let(:token) { "Mi65Gq3AdKNU74OOsaOgWKdXdBq2RvCoHHcc6cVPpBo=" }

    it "halts an error for non logged in users" do
      put "/tasks/#{task.id}", { title: 'Study laravel', list_id: list.id, completed: 'true', duration: '162' }, 'HTTP_X_CSRF_TOKEN' => token

      expect(last_response.status).to eq(401)
    end

    context 'with valid params' do
      it 'success if belongs to user' do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)

        put "/tasks/#{task.id}", {
          title: 'Study laravel',
          list_id: task.list.id,
          completed: 'true',
          duration: '162'
        }, 'HTTP_X_CSRF_TOKEN' => token

        follow_redirect!

        task.reload

        expect(last_response.body).to include('Study laravel')
        expect(task.list).to eq(list)
        expect(task.completed_at).not_to be_nil
        expect(task.duration).to eq(162)

        put "/tasks/#{task.id}", {
          title: 'Study laravel',
          list_id: task.list.id,
          completed: 'false'
        }, 'HTTP_X_CSRF_TOKEN' => token

        follow_redirect!

        task.reload

        expect(task.completed_at).to be_nil

        put "/tasks/#{task.id}", { title: 'Study laravel', list_id: list.id, completed: 'wtf' }, 'HTTP_X_CSRF_TOKEN' => token

        follow_redirect!

        task.reload

        expect(task.completed_at).to be_nil
      end
    end

    context 'with invalid params' do
      it 'fails' do
        user_two = create(:user_with_lists)

        task = user.lists.first.tasks.last
        list = user_two.lists.last

        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)

        put "/tasks/#{task.id}", { title: 'Study laravel', list_id: list.id }, 'HTTP_X_CSRF_TOKEN' => token

        expect(last_response).not_to be_ok
        expect(last_response.status).to eq(404)

        put "/tasks/#{task.id}", { title: '' }, 'HTTP_X_CSRF_TOKEN' => token

        expect(last_response).not_to be_ok
        expect(last_response.status).to eq(400)

        put "/tasks/#{task.id}", { title: 'Study laravel', completed: 'true', duration: 'not_number' }, 'HTTP_X_CSRF_TOKEN' => token

        expect(last_response).not_to be_ok
        expect(last_response.status).to eq(400)
      end
    end
  end

  describe "Deleting a task " do
    let(:token) { "Mi65Gq3AdKNU74OOsaOgWKdXdBq2RvCoHHcc6cVPpBo=" }

    it "halts an error for non logged in users" do
      task = create(:task, title: "Build an image gallery in ruby")

      delete "/tasks/#{task.id}", {}, 'HTTP_X_CSRF_TOKEN' => token

      expect(last_response.status).to eq(401)
    end

    context "when user is logged in" do
      let(:user) { create(:user_with_lists) }
      let(:task) { user.lists.last.tasks.first }

      it "success if belongs to user" do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)

        delete "/tasks/#{task.id}", {}, 'HTTP_X_CSRF_TOKEN' => token

        follow_redirect!

        expect(last_response.body).not_to include('Build an image gallery in ruby')
      end

      it "fails if it does not belong to user" do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)

        user_two = create(:user_with_lists)

        task_two = user_two.lists.first.tasks.last

        delete "/tasks/#{task_two.id}", {}, 'HTTP_X_CSRF_TOKEN' => token

        expect(last_response).not_to be_ok
        expect(last_response.status).to eq(404)
      end
    end

  end

end
