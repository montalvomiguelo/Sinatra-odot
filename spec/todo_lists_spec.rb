describe Todo do
  it "retrieves all todo lists" do
    todo_list = create(:todo_list)
    todo_list = create(:todo_list)
    todo_list = create(:todo_list)

    get '/'

    expect(last_response).to be_ok
    expect(last_response.body).to include('Todo lists')

    expect(TodoList.all.size).to eq(3)
    expect(last_response.body).to include('List title')
  end

  it "allows to create a new todo list" do
    get '/lists/new'

    expect(last_response).to be_ok
    expect(last_response.body).to include('New todo list')
  end

  it "creates a list" do
    post '/lists', { title: 'Clean the car' }
    follow_redirect!

    expect(last_response.body).to include('Clean the car')

    post '/lists'
    expect(last_response.status).to eq(500)
  end
end
