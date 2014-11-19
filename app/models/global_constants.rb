module GlobalConstants
  COMMISSIONS = {personal_green: 1.9, personal_biz: 3}
  ACCOUNT_TYPES = {personal: 1, green: 2, biz: 3, system: 100}
  MOOD_TYPES = {bad: 0, melancholic: 1, neutral: 2, ginger: 3, high: 4, joyful: 5}
  OPERATION_CODES = {cashin: 3, payment: 1, hold: 2, commission: 4, payout: 5}
  REQUEST_TYPES = {pay: 2, charge: 3, friendship:0, ad: 20}
  SERVICE_EMAILS = {support: 'vk@onlinepay.com'}
  DOMAIN_NAME = {production: 'https://api.onlinepay.com', test: 'http://test.chargebutton.com', development: 'http://localhost:3000'}
end