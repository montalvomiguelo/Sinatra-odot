describe User, type: :model do
  it { should validate_presence_of(:email) }
  it { should validate_presence_of(:password) }
  it { should validate_uniqueness_of(:email) }
  it { should have_secure_password }

  it 'saves email in downcase' do
    user = create(:user, email: 'EMAIL@EXAMPLE.COM', password: 'qwert')
    expect(user.email).to eq('email@example.com')
  end

  it 'validates email format' do
    user = build(:user, email: 'EMAIL_at_EXAMPLE.COM', password: 'qwert')
    expect(user.save).to be_falsy
  end
end
