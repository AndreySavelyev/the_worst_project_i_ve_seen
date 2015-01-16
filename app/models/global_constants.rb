module GlobalConstants
  COMMISSIONS = {personal_green: 1.9, personal_biz: 3}
  ACCOUNT_TYPE = {personal: 0, green: 1, biz: 2, partner: 4, pale: 5, system: 100}
  MOOD_TYPES = {bad: 0, melancholic: 1, neutral: 2, ginger: 3, high: 4, joyful: 5}
  OPERATION_CODES = {cashin: 3, payment: 1, hold: 2, commission: 4, payout: 5}
  REQUEST_TYPES = {pay: 2, charge: 3, friendship:0, ad: 20}
  SERVICE_EMAILS = {support: 'support@onlinepay.com'}
  DOMAIN_NAME = {production: 'https://api.onlinepay.com', test: 'http://test.chargebutton.com', development: 'http://localhost:3000'}
  CONTENT_STATE = {new: 0, published: 1, deleted: 2 }
  DEFAULT_CURRENCY = 'EUR'

  #result codes
  RESULT_CODES = {no_money: {result: 101, message: 'not enough money', code: 403},
                  not_verified: {result: 102, message: 'not verified', code: 200},
                  verified: {result: 103, message: 'verified', code: 200},
                  not_match: {result: 104, message: 'value does not match', code: 403},
                  hold_complete: {result: 105, message: '', code: 200},
                  limit_reached: {result:106, message:'limit has been reached', code: 403},
                  limit_notfound: {result:107, message:'limit not found', code: 404}
  }
end