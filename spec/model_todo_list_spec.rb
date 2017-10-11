describe TodoList do
  it "fails to create an emtpy todo list" do
    todo_list = build(:todo_list)
    expect(todo_list.save).to be_falsy
  end
end
