require_relative '../../../controllers/api/application_controller'
require_relative '../../../controllers/api/tasks_controller'

describe Api::TasksController do
  include Rack::Test::Methods

  def app
    Api::TasksController
  end

  it "Retrieving all tasks" do
    get '/tasks'
    expect(last_response).to be_ok
  end

  describe "Retrieving a single task" do
    let(:user_one) { create(:user_with_lists) }
    let(:task) { user_one.lists.first.tasks.last }

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
  end

  describe "Updating a single task" do
    let(:user_one) { create(:user_with_lists) }
    let(:task) { user_one.lists.first.tasks.last }

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
      it "responds 422 error" do
        put "tasks/#{task.id}", {title: '', list_id: ''}
        expect(last_response.status).to eq(422)
        expect(last_response.body).to include('title')
      end
    end

    context "with invalid id" do
      it "responds 404 error" do
        put "tasks/9999", {title: '', list_id: ''}
        expect(last_response.status).to eq(404)
        expect(last_response.body).to eq('Not found')
      end
    end
  end

  describe "Creating a new task" do
    let(:user_one) { create(:user_with_lists) }
    let(:list) { user_one.lists.first }

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
        post '/tasks', {title: '', list_id: ''}
        expect(last_response.status).to eq(422)
        expect(last_response.body).to include('title')
        expect(last_response.body).to include('list')
      end
    end
  end

  describe "Deleting a task" do
    let(:user_one) { create(:user_with_lists) }
    let(:task) { user_one.lists.first.tasks.last }

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
  end
end
