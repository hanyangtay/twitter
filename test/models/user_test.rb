require 'test_helper'

class UserTest < ActiveSupport::TestCase
  
  def setup
    @user = User.new(name: "Han", email: "han@han.com",
    password: "hanhanhanH1!", password_confirmation: "hanhanhanH1!")
  end
  
  test "isValid" do
    assert @user.valid?
  end
  
  test "absentName" do
    @user.name = "   "
    assert_not @user.valid?
  end
  
  test "absentEmail" do
    @user.email = "   "
    assert_not @user.valid?
  end
    
  test "longName" do
    @user.name = "a" * 51
    assert_not @user.valid?
  end
  
  test "longEmail" do
    @user.email = "a" * 244 + "@example.com"
    assert_not @user.valid?
  end
  
  test "validEmail" do
    valid_addresses = %w[user@example.com USER@foo.COM A_US-ER@foo.bar.org
                         first.last@foo.jp alice+bob@baz.cn]
    valid_addresses.each do |valid_address|
      @user.email = valid_address
      assert @user.valid?, "#{valid_address.inspect} should be valid."
    end
  end

# invalidEmails are checked by live validation by HTML 5 forms.
  
  test "uniqueEmail" do
    duplicate_user = @user.dup
    duplicate_user.email = @user.email.upcase
    @user.save
    assert_not duplicate_user.valid?
  end
  
  test "emailSaveAsLowerCase" do
    mixed_case_email = "HaN@hAn.CoM"
    @user.email = mixed_case_email
    @user.save
    assert_equal mixed_case_email.downcase, @user.reload.email
  end
  
#Michael Hartl, listing 9.17
  test "authenticated? should return false for a user with nil digest" do
    assert_not @user.authenticated?(:remember, '')
  end
  
  test "associated status posts should be destroyed" do
    @user.save
    @user.status_posts.create!(content: "Lorem ipsum")
    assert_difference 'StatusPost.count', -1 do
      @user.destroy
    end
  end
  
end
