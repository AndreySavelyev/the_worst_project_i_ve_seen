class UpdateProfile <  EmailValidator
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_accessor :user_token;
  attr_accessor :fb_token;
  attr_accessor :pic_url;
  attr_accessor :name;
  attr_accessor :surname;
  attr_accessor :phone;
  attr_accessor :iban;
  attr_accessor :reg_num;
  attr_accessor :birthday;
  attr_accessor :company_name;
  attr_accessor :email;
  attr_accessor :password;
  attr_accessor :password1;
  attr_accessor :password2;
  attr_accessor :salt;
  attr_accessor :created_at;
  attr_accessor :updated_at;

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