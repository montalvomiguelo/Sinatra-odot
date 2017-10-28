describe User, type: :model do
  it { should validate_presence_of(:email) }
  it { should validate_uniqueness_of(:email) }
  it { should have_secure_password }
  it { should have_many(:lists) }

  it 'saves email in downcase' do
    user = create(:user, email: 'EMAIL@EXAMPLE.COM', password: 'qwert')
    expect(user.email).to eq('email@example.com')
  end

  it 'validates email format' do
    user = build(:user, email: 'EMAIL_at_EXAMPLE.COM', password: 'qwert')
    expect(user.save).to be_falsy
  end

  describe "#generate_password_reset_token!" do
    let(:user) { create(:user) }

    it "changes the password_reset_token attribute" do
      expect{ user.generate_password_reset_token! }.to change{ user.password_reset_token }
    end

    it "calls SecureRandom.urlsafe_base64 to generate the password_reset_totken" do
      expect(SecureRandom).to receive(:urlsafe_base64)
      user.generate_password_reset_token!
    end
  end

end
