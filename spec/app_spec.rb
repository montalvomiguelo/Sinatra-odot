require_relative '../app'

describe App do
  include Rack::Test::Methods

  def app
    App
  end

  it "retreives all lists" do
    list = create(:list)

    get '/lists'

    expect(last_response).to be_ok
    expect(last_response.body).to include('Lists')

    expect(List.all.size).to eq(1)
    expect(last_response.body).to include('List title')
  end

  it "shows a form to create a new todo list" do
    get '/lists/new'

    expect(last_response).to be_ok
    expect(last_response.body).to include('New list')
  end

  describe "creating a list" do
    context 'with valid params' do
      it 'success' do
        post '/lists', { title: 'Clean the car' }

        follow_redirect!

        expect(last_response.body).to include('Clean the car')
      end
    end

    context 'with invalid params' do
      it 'fails' do
        post '/lists', { title: '' }

        expect(last_response.status).to eq(500)
      end
    end
  end

  it "shows a single list" do
    list = create(:list_with_tasks, title: "Groceries list")

    get "/lists/#{list.id}"

    expect(last_response).to be_ok
    expect(last_response.body).to include('Groceries list')

    expect(list.tasks.size).to eq(5)
    expect(last_response.body).to include('Task title')
  end

  it "shows a form to edit a list" do
    list = create(:list, title: "Groceries list")

    get "/lists/#{list.id}/edit"

    expect(last_response).to be_ok
    expect(last_response.body).to include('Edit list')
    expect(last_response.body).to include("lists/#{list.id}")
    expect(last_response.body).to include('value="Groceries list"')
  end

  describe 'updating a list' do
    let (:list) { create(:list, title: "Groceries list") }

    context 'with valid params' do
      it 'success' do
        put "/lists/#{list.id}", { title: 'Title updated' }

        follow_redirect!

        expect(last_response).to be_ok
        expect(last_response.body).to include('Title updated')
      end
    end

    context 'with invalid params' do
      it 'fails' do
        put "/lists/#{list.id}", { title: '' }

        expect(last_response.status).to eq(500)
      end
    end
  end

  it "deletes a list and its related tasks" do
    list = create(:list_with_tasks, title: "Groceries list")

    delete "/lists/#{list.id}"

    follow_redirect!

    expect(last_response.body).not_to include('Groceries list')
    expect(Task.all.size).to eq(0)
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

  it "returns an HTML form for creating a new user" do
    get "/users/new"

    expect(last_response).to be_ok
    expect(last_response.body).to include('New user')
  end

  context "creating a new user" do
    describe "with valid params" do
      it "success" do
        post "/users", {
          first_name: 'John',
          last_name: 'Doe',
          email: 'johndoe@example.com',
          password: '123456'
        }

        expect(User.all.size).to eq(1)
        expect(User.first.first_name).to eq('John')
        expect(User.first.last_name).to eq('Doe')
        expect(User.first.email).to eq('johndoe@example.com')
        expect(last_request.env['rack.session']['id']).to eq(User.first.id)
      end
    end

    describe "with invalid params" do
      it "fails" do
        post "/users", {
          email: 'email',
          password: 'password'
        }

        expect(last_response.status).to eq(500)
      end
    end
  end

  it "has a login page" do
    get "/sessions/login"

    expect(last_response).to be_ok
    expect(last_response.body).to include('Login')
  end

  describe "logging in a user" do
    context "with valid credentials" do
      let!(:user) { create(:user, email: 'johndoe@example.com', password: '123456') }

      it "stores user's ID in the session hash" do
        post '/sessions', { email: 'johndoe@example.com', password: '123456' }

        expect(last_request.env['rack.session']['id']).to eq(user.id)
      end

      it "redirects to lists page" do
        post '/sessions', { email: 'johndoe@example.com', password: '123456' }

        follow_redirect!
        expect(last_response.body).to include('Lists')
      end
    end

    context "with invalid credentials" do
      it "redirects to login page" do
        post '/sessions', { email: '', password: '' }

        follow_redirect!
        expect(last_response.body).to include('Login')
      end
    end
  end

end
