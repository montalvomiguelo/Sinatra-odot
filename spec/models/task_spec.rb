describe Task, type: :model do
  it { should validate_presence_of(:title) }
  it { should validate_presence_of(:list) }
  it { should validate_numericality_of(:duration).only_integer }
  it { should belong_to(:list) }
end
