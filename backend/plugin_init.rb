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
env_list.each do

   file_path = "/etc/puppetlabs/code/environments/#{env_value}/data/aspace_plugins.yaml"

   if File.exists?(file_path)

     heira_hash=YAML::load_file(AppConfig[:heira_path])

     heira_hash.each do |key,value|    
      sso_url= value if key.include? "sso_url"
      sso_frontend_port= value if key.include? "frontend_port"
      sso_login_url=value if key.include? "sso_login_url"
      AppConfig[:ap_id]= value if key.include? "archivesspace::ap_id:"
      AppConfig[:auth_key]= value if key.include? "archivesspace::auth_key:"
     end
   end
end

sso_frontend_port.empty? ? AppConfig[:frontend_sso_url]= "https://#{sso_url}":AppConfig[:frontend_sso_url]= "https://#{sso_url}:#{sso_frontend_port}"

class ArchivesSpaceService < Sinatra::Base
  use Rack::Session::Cookie, :key => 'rack.session',
      :expire_after => 2592000, # In seconds
      :secret => 'archivesspace remote SSO session'

  use OmniAuth::Builder do
    provider :nyulibraries, AppConfig[:ap_id], AppConfig[:auth_key],
    client_options: {
            site: '"#{sso_login_url}"',
            authorize_path: '/oauth/authorize'
    }
  end

end

