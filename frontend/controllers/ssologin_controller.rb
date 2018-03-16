class SsologinController < ApplicationController


  set_access_control  :public => [:login_sso, :error, :logout]

  def login_sso
    error= params[:error]

    if !error.nil?
      redirect_to :controller => :ssologin, :action => :error
      return
    end

    backend_session = SsologinController.verify_session(params[:user], params[:session])

    if backend_session
      User.establish_session(self, backend_session, params[:user])

      load_repository_list

      redirect_to :controller => :welcome, :action => :index
    else
      redirect_to :controller => :ssologin, :action => :error
    end
  end


  def self.verify_session(username, session)

    uri = JSONModel(:user).uri_for("#{username}/#{session}/verify")

    response = JSONModel::HTTP.post_form(uri)

    if response.code == '200'
      ASUtils.json_parse(response.body)
    else
      nil
    end
  end

  def logout()
    reset_session
    redirect_to "#{AppConfig[:ssologout_url]}"
  end

  end