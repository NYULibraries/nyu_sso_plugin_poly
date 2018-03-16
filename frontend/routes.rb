ArchivesSpace::Application.routes.draw do

  match 'login_sso' => "ssologin#login_sso", :via => :get
  match 'error' => "ssologin#error", :via => :get
  match 'logoutsso' => "ssologin#logout", :via => :get

end