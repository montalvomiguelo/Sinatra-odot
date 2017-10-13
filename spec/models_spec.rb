describe List do
  it "success to create a new list" do
    list = build(:list)
    expect(list.save).to be_truthy
  end
end
