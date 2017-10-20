describe List, type: :model do
  it { should validate_presence_of(:title) }
  it { should have_many(:tasks) }
end

describe Task, type: :model do
  it { should validate_presence_of(:title) }
  it { should validate_presence_of(:list) }
  it { should validate_numericality_of(:duration).only_integer }
  it { should belong_to(:list) }
end

describe User, type: :model do
  it { should validate_presence_of(:email) }
  it { should validate_presence_of(:password) }
  it { should validate_uniqueness_of(:email) }
  it { should have_secure_password }

  it 'transforms email to downcase' do
    user = create(:user, email: 'EMAIL@EXAMPLE.COM', password: 'qwert')
    expect(user.email).to eq('email@example.com')
  end

  it 'validates email format' do
    user = build(:user, email: 'EMAIL_at_EXAMPLE.COM', password: 'qwert')
    expect(user.save).to be_falsy
  end
end
