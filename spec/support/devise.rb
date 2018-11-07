module DeviseRequestHelper
  include Warden::Test::Helpers

  def login_user permissions: nil
    permissions ||= Support::Permissions.all_permissions
    organisation = Organisation.where(:code => "first").first_or_create(attributes_for(:organisation))
    @user ||=
      create(:user,
             :organisation => organisation,
             :permissions => permissions)

    login_as @user, :scope => :user
    # post_via_redirect user_session_path, 'user[email]' => @user.email, 'user[password]' => @user.password
  end

  def self.included(base)
    base.class_eval do
      extend ClassMethods
    end
  end

  module ClassMethods

    def login_user permissions: nil
      before(:each) do
        login_user permissions: permissions
      end
      after(:each) do
        Warden.test_reset!
      end
    end

  end

end

module DeviseControllerHelper

  def setup_user permissions: nil
    before do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      permissions ||= Support::Permissions.all_permissions
      organisation = Organisation.where(:code => "first").first_or_create(attributes_for(:organisation))
      @user = create(:user,
                     organisation: organisation,
                     permissions: permissions)
    end
  end

  def login_user permissions: nil
    setup_user permissions: permissions
    before do
      sign_in @user
    end
  end

end

RSpec.configure do |config|
  config.include Devise::Test::ControllerHelpers, :type => :controller
  config.extend DeviseControllerHelper, :type => :controller

  config.include DeviseRequestHelper, :type => :request
  config.include DeviseRequestHelper, :type => :feature
end
