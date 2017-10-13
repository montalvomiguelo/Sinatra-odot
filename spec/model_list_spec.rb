describe List do
  it "fails to create an emtpy todo list" do
    list = build(:list)
    expect(list.save).to be_truthy
  end
end
