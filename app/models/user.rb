class User < ApplicationRecord
    
    has_many :status_posts, dependent: :destroy
    attr_accessor :remember_token, :activation_token, :reset_token
    mount_uploader :avatar, AvatarUploader



    before_save :downcase_email
    before_create :create_activation_digest
    
    NAME_REGEX = /\A[a-zA-Z0-9\s]{2,}/
    
    validates :name, presence: true, length: { maximum: 50},
            format: { with: NAME_REGEX }
    
    
    validates :email, presence: true, length: { maximum: 255 }, 
        uniqueness: { case_sensitive: false}
        
    STRONG_PASSWORD_REGEX = /\A(?=.*[a-z])(?=.*[0-9])(?=.*[\-\_\/:;,\?'\"\.!@#\$%\^&\*\(\)\+\=])(?=^.{8,})/
    
    has_secure_password
        
    validates :password, presence: true, length: { minimum: 8 },
        format: { with: STRONG_PASSWORD_REGEX}, allow_nil: true
    
    def User.digest(string)
        cost = ActiveModel::SecurePassword.min_cost ? 
        BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
        BCrypt::Password.create(string, cost: cost)
    end
    
    def User.new_token
        SecureRandom.urlsafe_base64
    end
    
    def remember
        self.remember_token = User.new_token
        update_attribute(:remember_digest, User.digest(remember_token))
    end
    
    def authenticated?(attribute, token)
        digest = send("#{attribute}_digest")
        return false if digest.nil?
        BCrypt::Password.new(digest).is_password?(token)
    end
    
    def forget
        update_attribute(:remember_digest, nil)
    end
    
    def activate
        update_columns(activated: true, activated_at: Time.zone.now)
    end
    
    def send_activation_email
        UserMailer.account_activation(self).deliver_now
    end
    
    def create_reset_digest
        self.reset_token = User.new_token
        update_columns(reset_digest: User.digest(reset_token), 
                        reset_sent_at: Time.zone.now)
    end
    
    def send_password_reset_email
        UserMailer.password_reset(self).deliver_now
    end
    
    def password_reset_expired?
        reset_sent_at < 2.hours.ago
    end
    
    def feed
         # StatusPost.where("user_id = ?", id)
         status_posts
    end
    
    private
        
        def downcase_email
            self.email = email.downcase
        end
        
        def create_activation_digest
            self.activation_token = User.new_token
            self.activation_digest = User.digest(activation_token)
        end

end
