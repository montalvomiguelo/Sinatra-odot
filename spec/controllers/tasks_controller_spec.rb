require_relative '../../controllers/application_controller'
require_relative '../../controllers/tasks_controller'

describe TasksController do
  include Rack::Test::Methods

  def app
    TasksController
  end

  describe "Listing tasks" do

    context "when user is not logged in " do
      it "halts an error" do
        get '/tasks'

        expect(last_response.status).to eq(401)
      end
    end

    it "shows up all tasks" do
      task = create(:task, title: "Study ruby")
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(create(:user))

      get '/tasks'

      expect(last_response).to be_ok
      expect(last_response.body).to include('Study ruby')
      expect(Task.all).to eq([task])
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
      list = create(:list)

      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(create(:user))

      get '/tasks/new'

      expect(last_response).to be_ok
      expect(last_response.body).to include('New task')
      expect(last_response.body).to include('List title')
    end
  end

  describe 'Creating a task' do
    it "halts an error for non logged in users" do
      list = create(:list, title: "Tuts list")

      post '/tasks', { title: 'Learn ruby core', list_id: list.id }

      expect(last_response.status).to eq(401)
    end

    context 'with valid params' do
      it 'success' do
        list = create(:list, title: "Tuts list")
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(create(:user))

        post '/tasks', { title: 'Learn ruby core', list_id: list.id }

        follow_redirect!

        expect(last_response.body).to include('Learn ruby core')
        expect(last_response.body).to include('Tuts list')
        expect(List.first.tasks.size).to eq(1)
        expect(Task.first.title).to eq('Learn ruby core')
      end
    end

    context 'with invalid params' do
      it 'fails' do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(create(:user))

        post '/tasks', { title: '' }

        expect(last_response.body).to include('Error')
        expect(last_response.status).to eq(500)

        post '/tasks', { title: 'Task with no list', list_id: '' }

        expect(last_response.body).to include('Error')
        expect(last_response.status).to eq(500)
      end
    end
  end

  describe 'Showing a single task' do
    it "halts an error for non logged in users" do
      task = create(:task, title: "Study ruby")

      get "/tasks/#{task.id}"

      expect(last_response.status).to eq(401)
    end

    context 'with valid id' do
      it 'success' do
        task = create(:task, title: "Study ruby")
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(create(:user))

        get "/tasks/#{task.id}"

        expect(last_response).to be_ok
        expect(last_response.body).to include('Study ruby')
      end
    end

    context 'with invalid id' do
      it 'fails' do
        get '/tasks/23'
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(create(:user))

        expect(last_response).not_to be_ok
      end
    end
  end

  describe 'Showing a form to edit a task' do
    it "halts an error for non logged in users" do
      list = create(:list, title: "Tuts list")
      task = create(:task, title: "Study ruby")

      get "/tasks/#{task.id}/edit"

      expect(last_response.status).to eq(401)
    end

    it "is allowed for logged in users" do
      list = create(:list, title: "Tuts list")
      task = create(:task, title: "Study ruby")
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(create(:user))

      get "/tasks/#{task.id}/edit"

      expect(last_response).to be_ok
      expect(last_response.body).to include('Tuts list')
      expect(last_response.body).to include('Study ruby')
      expect(last_response.body).to include('Complete')
    end
  end

  describe 'Updating a task' do
    let (:list) { create(:list, title: "Tuts list") }
    let (:task) { create(:task, title: "Study ruby") }

    it "halts an error for non logged in users" do
      put "/tasks/#{task.id}", { title: 'Study laravel', list_id: list.id, completed: 'true', duration: '162' }

      expect(last_response.status).to eq(401)
    end

    context 'with valid params' do
      it 'success' do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(create(:user))
        put "/tasks/#{task.id}", { title: 'Study laravel', list_id: list.id, completed: 'true', duration: '162' }

        follow_redirect!

        task.reload

        expect(last_response.body).to include('Study laravel')
        expect(task.list).to eq(list)
        expect(task.completed_at).not_to be_nil
        expect(task.duration).to eq(162)

        put "/tasks/#{task.id}", { title: 'Study laravel', list_id: list.id, completed: 'false' }

        follow_redirect!

        task.reload

        expect(task.completed_at).to be_nil

        put "/tasks/#{task.id}", { title: 'Study laravel', list_id: list.id, completed: 'wtf' }

        follow_redirect!

        task.reload

        expect(task.completed_at).to be_nil
      end
    end

    context 'with invalid params' do
      it 'fails' do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(create(:user))
        put "/tasks/#{task.id}", { title: 'Study laravel', list_id: 23 }

        expect(last_response).not_to be_ok
        expect(last_response.status).to eq(500)

        put "/tasks/#{task.id}", { title: '', list_id: list.id }

        expect(last_response).not_to be_ok
        expect(last_response.status).to eq(500)

        put "/tasks/#{task.id}", { title: 'Study laravel', list_id: list.id, completed: 'true', duration: 'not_number' }

        expect(last_response).not_to be_ok
        expect(last_response.status).to eq(500)
      end
    end
  end

  describe "Deleting a task " do
    it "halts an error for non logged in users" do
      task = create(:task, title: "Build an image gallery in ruby")

      delete "/tasks/#{task.id}"

      expect(last_response.status).to eq(401)
    end

    it "redirects to /lists on success" do
      task = create(:task, title: "Build an image gallery in ruby")
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(create(:user))

      delete "/tasks/#{task.id}"

      follow_redirect!

      expect(last_response.body).not_to include('Build an image gallery in ruby')
    end
  end

end
