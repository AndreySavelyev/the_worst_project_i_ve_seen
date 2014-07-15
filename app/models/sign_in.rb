class SignIn <  EmailValidator
include ActiveModel::Validations
include ActiveModel::Conversion
extend ActiveModel::Naming

attr_accessor :email;
attr_accessor :password;
attr_accessor :fb_token;
attr_accessor :phone;

validates :email, presence: true, email: true

def initialize(attributes = {})
  attributes.each do |name, value|
    send("#{name}=", value)
  end
end

def persisted?
  false
end

end