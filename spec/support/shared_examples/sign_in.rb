shared_examples "requires user sign in" do
  context "user not signed in" do
    it "redirects to sign in page" do
      sign_out :user
      do_request
      expect(response.code).to eq('302')
      expect(response).to redirect_to(new_user_session_path)
    end
  end
end
