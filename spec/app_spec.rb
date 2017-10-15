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
    list = create(:list, title: "Groceries list")

    get "/lists/#{list.id}"

    expect(last_response).to be_ok
    expect(last_response.body).to include('Groceries list')
  end

  it "shows a form to edit a list" do
    list = create(:list, title: "Groceries list")

    get "/lists/#{list.id}/edit"

    expect(last_response).to be_ok
    expect(last_response.body).to include('Edit Groceries list')
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

  it "removes a list " do
    list = create(:list, title: "Groceries list")

    delete "/lists/#{list.id}"

    follow_redirect!

    expect(last_response.body).not_to include('Groceries list')
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
        expect(List.find(list.id).tasks.size).to eq(1)
        expect(List.find(list.id).tasks.first.title).to eq('Learn ruby core')

        post '/tasks', { title: 'Javascript fundamentals' }

        follow_redirect!

        expect(last_response.body).to include('Javascript fundamentals')
        expect(Task.last.list).to eq(nil)
      end
    end

    context 'with invalid params' do
      it 'fails' do
        post '/tasks', { title: '' }

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

end
