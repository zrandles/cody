require "rails_helper"

RSpec.describe SessionsController, type: :controller do
  describe "GET :create" do
    before do
      mock_auth(
        :github,
        {
          uid: uid,
          info: {
            nickname: login,
            email: email,
            name: name
          }
        }
      )
      request.env["omniauth.auth"] = OmniAuth.config.mock_auth[:github]
    end

    let(:uid) { 1234 }
    let(:login) { "aergonaut" }
    let(:email) { "omgwtf@bbq.org" }
    let(:name) { "Joe Blow" }

    it "redirects to the Pull Requests page" do
      get :create
      expect(response).to redirect_to(root_path)
    end

    context "when the user has never logged in before" do
      it "makes a new User" do
        expect {
          get :create
        }.to change {
          User.count
        }.by(1)
      end
    end

    context "when the user has logged in before" do
      before do
        FactoryGirl.create :user, uid: uid, login: login, email: email, name: name
      end

      it "does not make a new User" do
        expect {
          get :create
        }.to_not change { User.count }
      end
    end
  end
end
