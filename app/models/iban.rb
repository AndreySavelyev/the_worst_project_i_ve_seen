class Iban < ActiveRecord::Base
  belongs_to :profile
  def self.create_iban(profile, iban_num)
    iban = Iban.new;
    iban.profile_id = profile.id;
    iban.iban_num = iban_num;
    iban.verified = false;

    coder=rand(9).to_s + rand(9).to_s + rand(9).to_s + rand(9).to_s;

    iban.code = 1234;
    iban.save!
    return iban;
  end

  def self.get_iban(profile, iban_num)
    i = Iban.where("iban_num = :iban and profile_id = :id",
                   {:iban => iban_num, :id => profile.id}).first;
    if (i == nil)
      i = create_iban(profile, iban_num)
    end
    return i;
  end
end
