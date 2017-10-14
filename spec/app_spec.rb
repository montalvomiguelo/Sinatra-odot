require_relative '../app'  # <-- your sinatra app

describe App do
  include Rack::Test::Methods

  def app
    App
  end

  it "retrieves all lists" do
    list = create(:list)

    get '/lists'

    expect(last_response).to be_ok
    expect(last_response.body).to include('Lists')

    expect(List.all.size).to eq(1)
    expect(last_response.body).to include('List title')
  end

  it "allows to create a new todo list" do
    get '/lists/new'

    expect(last_response).to be_ok
    expect(last_response.body).to include('New list')
  end

  it "creates a list" do
    post '/lists', { title: 'Clean the car' }
    follow_redirect!

    expect(last_response.body).to include('Clean the car')

    post '/lists', { title: '' }
    expect(last_response.status).to eq(500)
  end

  it "shows a single list" do
    list = create(:list, title: "Groceries list")

    get "/lists/#{list.id}"

    expect(last_response).to be_ok
    expect(last_response.body).to include('Groceries list')
  end

  it "shows a form to edit the list" do
    list = create(:list, title: "Groceries list")

    get "/lists/#{list.id}/edit"

    expect(last_response).to be_ok
    expect(last_response.body).to include('Edit Groceries list')
    expect(last_response.body).to include("lists/#{list.id}")
    expect(last_response.body).to include('value="Groceries list"')
  end

  it "updates an existing list" do
    list = create(:list, title: "Groceries list")

    put "/lists/#{list.id}", { title: 'Title updated' }
    follow_redirect!

    expect(last_response).to be_ok

    list = List.find(list.id)

    expect(list.title).to include('Title updated')

    put "/lists/#{list.id}", { title: '' }

    expect(last_response.status).to eq(500)
  end

  it "removes a list " do
    list = create(:list, title: "Groceries list")

    delete "/lists/#{list.id}"
    follow_redirect!

    expect(last_response.body).not_to include('Groceries list')
  end

  it 'retrieves all tasks' do
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

  it 'creates a new task' do
    list = create(:list, title: "Tuts list")

    post '/tasks', { title: 'Learn ruby core', list_id: list.id }
    follow_redirect!

    expect(last_response.body).to include('Learn ruby core')
    expect(last_response.body).to include('Tuts list')
    expect(List.find(list.id).tasks.size).to eq(1)
    expect(List.find(list.id).tasks.first.title).to eq('Learn ruby core')

    post '/tasks', { title: '' }

    expect(last_response.body).to include('Error')
    expect(last_response.status).to eq(500)

    post '/tasks', { title: 'Javascript fundamentals' }
    follow_redirect!

    expect(last_response.body).to include('Javascript fundamentals')
    expect(Task.last.list).to eq(nil)
  end

end
