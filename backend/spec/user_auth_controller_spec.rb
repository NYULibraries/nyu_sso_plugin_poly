require_relative '../lib/ssoauth_helper'
require_relative 'spec_helper'
include SsoauthHelper
include AuthHelpers


describe 'Authentication callback' do
  let(:user) { create(:user, :username=>'test_sso')}
  before do
    OmniAuth.config.add_mock(:nyulibraries, {"provider"=>:nyulibraries,
                                             "uid"=>"test_sso",
                                             "info"=>
                                                 {"name"=>"test_sso",
                                                  "nickname"=>"name",
                                                  "email"=>"test_sso@site.com",
                                                  "last_name"=>"last_name",
                                                  "first_name"=>"first_name"},
                                             "credentials"=>
                                                 {"token"=>"token",
                                                  "expires_at"=>1111111111,
                                                  "expires"=>true},
                                             "extra"=>
                                                 {"provider"=>:nyulibraries,
                                                  "identities"=>nil}})
    get 'auth/nyulibraries/callback'
  end
  context 'when login was successful' do
    it 'should redirect to the frontend login_sso method after login' do
      expect(last_response.redirect?).to be true
      follow_redirect!
      expect(last_request.path).to eq('/login_sso')
      expect(Session.find(last_request.params['session'])[:user]).to eq('test_sso')
    end
  end
  context 'when user does not exist' do
    before do
      OmniAuth.config.add_mock(:nyulibraries, {"provider"=>:nyulibraries,
                                               "uid"=>"name1",
                                               "info"=>
                                                   {"name"=>"name1",
                                                    "nickname"=>"name",
                                                    "email"=>"test1@site.com",
                                                   "last_name"=>"name1",
                                                   "first_name"=>"name"},
                                               "credentials"=>
                                                   {"token"=>"token",
                                                    "expires_at"=>1111111111,
                                                    "expires"=>true},
                                               "extra"=>
                                                   {"provider"=>:nyulibraries,
                                                    "identities"=>nil}})
      get 'auth/nyulibraries/callback'
    end
    it 'should be created' do
      expect(User.find(:username=>'name1')).not_to be nil
      expect(User.find(:name=>'name1 name')).not_to be nil
      expect(User.find(:last_name=>'name1')).not_to be nil
      expect(User.find(:first_name=>'name')).not_to be nil
      expect(User.find(:email=>'test1@site.com')).not_to be nil
    end
  end
  context 'when user login is invalid' do
    before do
      OmniAuth.config.mock_auth[:nyulibraries] = nil
      get 'auth/nyulibraries/callback'
    end
    it 'should send error message' do
      follow_redirect!
      expect(last_request.params['error']).to eq('failed')
    end
  end
 end

describe 'Authentication failure' do
  before do
    get 'auth/failure'
  end
    it 'should redirect to the frontend error page' do
      follow_redirect!
      expect(last_request.params['error']).to eq('auth')
    end
  end

describe 'Session verification' do
  let(:user) { create(:user, :username=>"test1")}
  let(:username) { user.username }
  let(:another_user) { create(:user, :username=>"test2")}
  before do
     post "/users/#{username}/#{session_id}/verify"
  end
  context 'when session was created for the user in the backend' do
  let(:session) { create_session_for("test1",true) }
  let(:session_id) { session.id }
  it 'should return session_id and user json object'do
    expect(last_response.body).to include("\"session\":\"#{session.id}\"")
    expect(last_response.body).to include("\"username\":\"test1\"")
  end
  end
  context 'when session was created for a different user' do
  let(:session) { create_session_for("test2",true) }
  let(:session_id) { session.id }
  it 'should return login failed' do
    expect(last_response.body).to include("\"error\":\"Login Failed\"")
  end
  end
  context 'when session does not exists' do
  let(:session_id) { 'fake_id' }
  it 'should return login failed' do
    expect(last_response.body).to include("\"error\":\"Login Failed\"")
  end
  end
  context 'when user does not exists' do
  let(:session) { create_session_for("test1",true) }
  let(:session_id) { session.id }
  let(:username) { "fake_user" }
  it 'should return login failed' do
    expect(last_response.body).to include("\"error\":\"Login Failed\"")
  end
  end
end

