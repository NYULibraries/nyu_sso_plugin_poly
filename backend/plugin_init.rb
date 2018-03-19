require 'sinatra/base'
require 'omniauth-oauth2'
require_relative 'lib/ssoauth_helper'
require "yaml"

include SsoauthHelper


sso_url="archivesspace-stage.library.nyu.edu"
sso_frontend_port="8480"
sso_login_url="https://dev.login.library.nyu.edu"
AppConfig[:ap_id]="3cc3e7e396c1d431424fce3469f282058d2fbc035d5961eead87992a96eee90e"
AppConfig[:auth_key]="key"

env_list=['development','stage','production']
env_list.each do |env_list|

   file_path = "/etc/puppetlabs/code/environments/#{env_list}/data/aspace_plugins.yaml"

   if File.exists?(file_path)

     heira_hash=YAML::load_file(file_path)

     heira_hash.each do |key,value|    
      sso_url= value if key.include? "poly_plugins::sso_url"
      sso_frontend_port= value if key.include? "poly_plugins::frontend_port"
      sso_login_url=value if key.include? "poly_plugins::sso_login_url"
      AppConfig[:ap_id]= value if key.include? "poly_plugins::ap_id"
      AppConfig[:auth_key]= value if key.include? "poly_plugins::auth_key"
     end
   end
end

AppConfig[:sso_login_url]= "https://#{sso_login_url}"

AppConfig[:frontend_sso_url]= "https://#{sso_url}"

class ArchivesSpaceService < Sinatra::Base
  use Rack::Session::Cookie, :key => 'rack.session',
      :expire_after => 2592000, # In seconds
      :secret => 'archivesspace remote SSO session'

  use OmniAuth::Builder do
    provider :nyulibraries, AppConfig[:ap_id], AppConfig[:auth_key],
    client_options: {
            site: AppConfig[:sso_login_url],
            authorize_path: '/oauth/authorize'
    }
  end

end

