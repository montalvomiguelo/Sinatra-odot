describe Todo do
  it "says the app is running" do
    get '/test'
    expect(last_response).to be_ok
    expect(last_response.body).to eq('The application is running')
  end
end
