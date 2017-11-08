require_relative '../../../controllers/api/application_controller'
require_relative '../../../controllers/api/tasks_controller'

describe Api::TasksController do
  include Rack::Test::Methods

  def app
    Api::TasksController
  end

  describe "Retrieving all tasks" do
    let(:user) { create(:user_with_lists) }
    let (:user_two) { create(:user_with_lists) }
    let(:task) { user.lists.first.tasks.last }

    context "with authenticated user" do
      before do
        basic_authorize(user.email, user.password)
      end

      it "responds 200 ok" do
        get '/tasks'
        expect(last_response).to be_ok
      end

      it "responds with task data" do
        get '/tasks'
        expect(last_response.body).to include(task.title)
      end

      it "responds with tasks that belongs tu current user only" do
        task_two = user_two.lists.first.tasks.create(title: 'Keep the momentum')
        get '/tasks'
        expect(last_response.body).not_to include(task_two.title)
      end
    end

    context "with no authenticated user" do
      it "responds 401 error" do
        get '/tasks'
        expect(last_response.status).to eq(401)
        expect(last_response.body).to include('Not authorized')
      end
    end
  end

  describe "Retrieving a single task" do
    let(:user_one) { create(:user_with_lists) }
    let(:task) { user_one.lists.first.tasks.last }

    before do
      basic_authorize(user_one.email, user_one.password)
    end

    context "with valid id" do
      it "finds the task" do
        expect_any_instance_of(Api::TasksController).to receive(:find_task).with(task.id.to_s).and_return(task)
        get "/tasks/#{task.id}"
      end

      it "responds 200 ok" do
        get "/tasks/#{task.id}"
        expect(last_response.status).to eq(200)
      end

      it "shows the resource" do
        get "/tasks/#{task.id}"
        expect(last_response.body).to include(task.title)
      end
    end

    context "with invalid id" do
      it "responds 404 error" do
        get '/tasks/9999999'
        expect(last_response.status).to eq(404)
        expect(last_response.body).to eq('Not found')
      end
    end

    context "when task does not belong to current user·" do
      let (:user_two) { create(:user_with_lists) }

      it "halts 404 error" do
        task_two = user_two.lists.first.tasks.create(title: 'Keep the momentum')
        get "/tasks/#{task_two.id}"
        expect(last_response.status).to eq(404)
        expect(last_response.body).to eq('Not found')
      end
    end
  end

  describe "Updating a single task" do
    let(:user_one) { create(:user_with_lists) }
    let(:task) { user_one.lists.first.tasks.last }

    before do
      basic_authorize(user_one.email, user_one.password)
    end

    context "with valid params" do
      it "finds the task" do
        expect_any_instance_of(Api::TasksController).to receive(:find_task).with(task.id.to_s).and_return(task)
        put "tasks/#{task.id}", {title: 'Sanctuary Ship', completed: 'true'}
      end

      it "responds 200 ok" do
        put "tasks/#{task.id}", {title: 'Sanctuary Ship', completed: 'true'}
        expect(last_response.status).to eq(200)
      end

      it "saves the new data" do
        expect_any_instance_of(Task).to receive(:save)
        put "tasks/#{task.id}", {title: 'Sanctuary Ship', completed: 'true'}
      end

      it "shows the just updated task" do
        put "tasks/#{task.id}", {title: 'Sanctuary Ship', completed: 'true'}
        expect(last_response.body).to include('Sanctuary Ship')
        expect(last_response.body).to include('completed')
      end
    end

    context "with invalid params" do
      let (:user_two) { create(:user_with_lists) }

      it "responds 422 error" do
        put "tasks/#{task.id}", {title: ''}
        expect(last_response.status).to eq(422)
        expect(last_response.body).to include('title')
      end
    end

    context "when list does not belong to current user" do
      let (:user_two) { create(:user_with_lists) }

      it "halts 404 error" do
        list_two = user_two.lists.first

        put "tasks/#{task.id}", {title: 'Keep up the momentum', list_id: list_two.id }
        expect(last_response.status).to eq(404)
        expect(last_response.body).to include('Not found')
      end
    end

    context "with invalid id" do
      it "responds 404 error" do
        put "tasks/9999", {title: '', list_id: ''}
        expect(last_response.status).to eq(404)
        expect(last_response.body).to eq('Not found')
      end
    end

    context "when task does not belong to current user" do
      let (:user_two) { create(:user_with_lists) }

      it "halts 404 error" do
        task_two = user_two.lists.first.tasks.create(title: 'Keep the momentum')

        put "tasks/#{task_two.id}", {title: 'Keep up the momentum'}
        expect(last_response.status).to eq(404)
        expect(last_response.body).to eq('Not found')
      end
    end
  end

  describe "Creating a new task" do
    let(:user_one) { create(:user_with_lists) }
    let(:list) { user_one.lists.first }

    before do
      basic_authorize(user_one.email, user_one.password)
    end

    context "with valid params" do
      it "saves the data" do
        expect_any_instance_of(Task).to receive(:save)
        post '/tasks', {title: 'A new task', list_id: list.id }
      end

      it "responds 200 ok" do
        post '/tasks', {title: 'A new task', list_id: list.id }
        expect(last_response.status).to eq(200)
      end

      it "shows the resource just created" do
        post '/tasks', {title: 'A new task', list_id: list.id }
        expect(last_response.body).to include('A new task')
      end
    end

    context "with invalid params" do
      it "responds 422 error" do
        post '/tasks', {title: '', list_id: list.id}
        expect(last_response.status).to eq(422)
        expect(last_response.body).to include('title')
      end
    end

    context "when the list does not belong to current user" do
      let (:user_two) { create(:user_with_lists) }

      it "halts 404 error" do
        list_two = user_two.lists.first

        post '/tasks', {title: 'Cool', list_id: list_two.id}
        expect(last_response.status).to eq(404)
        expect(last_response.body).to include('Not found')
      end
    end
  end

  describe "Deleting a task" do
    let(:user_one) { create(:user_with_lists) }
    let(:task) { user_one.lists.first.tasks.last }

    before do
      basic_authorize(user_one.email, user_one.password)
    end

    context "with valid id" do
      it "finds the task" do
        expect_any_instance_of(Api::TasksController).to receive(:find_task).with(task.id.to_s).and_return(task)
        delete "/tasks/#{task.id}"
      end
      it "destroys the task" do
        expect_any_instance_of(Task).to receive(:destroy)
        delete "/tasks/#{task.id}"
      end
      it "responds 200 ok" do
        delete "/tasks/#{task.id}"
        expect(last_response.status).to eq(200)
        expect(last_response.body).to eq('Task deleted successfully')
      end
    end

    context "with invalid id" do
      it "responds 404 error" do
        delete "/tasks/12345678"
        expect(last_response.status).to eq(404)
      end
    end

    context "when task does not belong to user" do
      let (:user_two) { create(:user_with_lists) }

      it" halts 404 error" do
        task_two = user_two.lists.first.tasks.create(title: 'Keep the momentum')

        delete "/tasks/#{task_two.id}"
        expect(last_response.status).to eq(404)
      end
    end
  end
end
