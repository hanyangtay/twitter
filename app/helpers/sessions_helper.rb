module SessionsHelper
    attr_reader :current_user_1
    
    def log_in(user)
        cookies.signed[:session_user_id] = user.id
    end
    
    def remember(user)
        user.remember
        cookies.permanent.signed[:user_id] = user.id
        cookies.permanent[:remember_token] = user.remember_token
    end
    
    def forget(user)
        user.forget
        cookies.delete(:user_id)
        cookies.delete(:remember_token)
    end

    def current_user
        if (user_id = cookies.signed[:session_user_id])
            @current_user ||= User.find_by(id: user_id)
        elsif (user_id = cookies.signed[:user_id])
            user = User.find_by(id: user_id)
            if user && user.authenticated?(:remember, cookies[:remember_token])
                log_in user
                @current_user = user
            end
        end
    end
    
    
    def logged_in?
        !current_user.nil?
    end
    
    def current_user?(user)
        current_user == user
    end
    
    def log_out
        forget(current_user)
        cookies.delete(:session_user_id)
        @current_user = nil
    end
    
    def redirect_back_or(default)
        redirect_to(session[:fowarding_url] || default)
        session.delete(:fowarding_url)
    end

    def store_location
        session[:fowarding_url] = request.original_url if request.get?
    end
end
