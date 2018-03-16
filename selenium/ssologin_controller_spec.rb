require 'rails'

describe "SSO Login" do
  before(:all) do
    @user = build(:user, :username=>'test_sso')
    @driver = Driver.new
  end

  after(:all) do
    @driver.quit
  end

  it "logins using omniauth" do
    @driver.login(OpenStruct.new())
    @driver.find_element(:link, "Login using NetID").click
  end
end


