require_relative '../../controllers/tasks_controller'

describe TasksController do
  include Rack::Test::Methods

  def app
    TasksController
  end

  it 'retreives all tasks' do
    task = create(:task, title: "Study ruby")

    get '/tasks'

    expect(last_response).to be_ok
    expect(last_response.body).to include('Study ruby')
    expect(Task.all).to eq([task])
  end

  it 'shows a form to create a new task' do
    list = create(:list)

    get '/tasks/new'

    expect(last_response).to be_ok
    expect(last_response.body).to include('New task')
    expect(last_response.body).to include('List title')
  end

  describe 'creating a task' do
    context 'with valid params' do
      it 'success' do
        list = create(:list, title: "Tuts list")

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
        post '/tasks', { title: '' }

        expect(last_response.body).to include('Error')
        expect(last_response.status).to eq(500)

        post '/tasks', { title: 'Task with no list', list_id: '' }

        expect(last_response.body).to include('Error')
        expect(last_response.status).to eq(500)
      end
    end
  end

  describe 'showing a single task' do
    context 'with valid id' do
      it 'success' do
        task = create(:task, title: "Study ruby")

        get "/tasks/#{task.id}"

        expect(last_response).to be_ok
        expect(last_response.body).to include('Study ruby')
      end
    end

    context 'with invalid id' do
      it 'fails' do
        get '/tasks/23'

        expect(last_response).not_to be_ok
      end
    end
  end

  it 'shows a form to edit a task' do
    list = create(:list, title: "Tuts list")
    task = create(:task, title: "Study ruby")

    get "/tasks/#{task.id}/edit"

    expect(last_response).to be_ok
    expect(last_response.body).to include('Tuts list')
    expect(last_response.body).to include('Study ruby')
    expect(last_response.body).to include('Complete')
  end

  describe 'updating a task' do
    let (:list) { create(:list, title: "Tuts list") }
    let (:task) { create(:task, title: "Study ruby") }

    context 'with valid params' do
      it 'success' do
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

  it "deletes a task " do
    task = create(:task, title: "Build an image gallery in ruby")

    delete "/tasks/#{task.id}"

    follow_redirect!

    expect(last_response.body).not_to include('Build an image gallery in ruby')
  end

end
