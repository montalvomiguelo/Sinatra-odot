describe Todo do
  it "assigns all todo_lists as @todo_list" do
    get '/'
    expect(last_response).to be_ok
    expect(last_response.body).to include('Todo lists')
  end
end
