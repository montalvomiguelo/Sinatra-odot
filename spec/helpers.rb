module Helpers
  def sign_in(user)
    allow_any_instance_of(App).to receive(:current_user).and_return(user)
  end
end
