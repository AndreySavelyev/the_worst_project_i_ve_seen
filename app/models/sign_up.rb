class SignUp <  EmailValidator
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_accessor :email;
  attr_accessor :password1;
  attr_accessor :password2;
#  attr_accessor :fid;
#  attr_accessor :user_token;

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
