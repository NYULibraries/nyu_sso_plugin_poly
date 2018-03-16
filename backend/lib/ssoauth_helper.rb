 module SsoauthHelper
   include BCrypt
   include JSONModel

    def create_user_from_omniauth(username,last_name,first_name,email)
      user_json=JSONModel(:user).from_hash(:username => username,
                                           :name => "#{last_name} #{first_name}",
                                           :last_name=>"#{last_name}",
                                           :first_name=>"#{first_name}",
                                           :email=>"#{email}"
      )
      User.create_from_json(user_json,{})
    end

   def add_user_to_auth_db(username, auth_token)

     pwhash = Password.create(auth_token)

     DB.open do |db|
       DB.attempt {
         db[:auth_db].insert(:username => username,
                             :pwhash => pwhash,
                             :create_time => Time.now,
                             :system_mtime => Time.now)
       }.and_if_constraint_fails {
         db[:auth_db].
             filter(:username => username).
             update(:username => username,
                    :pwhash => pwhash,
                    :system_mtime => Time.now)
       }
     end

   end
 end

 module AuthHelpers

   def create_session_for(username, expiring_session)
     session = Session.new
     session[:user] = username
     session[:login_time] = Time.now
     session[:expirable] = expiring_session
     session.save

     session
   end

 end



