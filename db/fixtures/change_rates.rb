ChangeRate.delete_all
IsoCurrency.delete_all

IsoCurrency.seed do |s|
  #RUSSIAN FEDERATION
  s.Alpha3Code="RUB"
  s.Numeric3Code=643
  s.IsoName="Russian Ruble"
  s.Precision=2
end

IsoCurrency.seed do |s|
  #MALAYSIA
  s.Alpha3Code="MYR"
  s.Numeric3Code=458
  s.IsoName="Malaysian Ringgit"
  s.Precision=2
end

IsoCurrency.seed do |s|
  #Euro
  s.Alpha3Code="EUR"
  s.Numeric3Code=978
  s.IsoName="Euro"
  s.Precision=2
end

IsoCurrency.seed do |s|
  #UNITED STATES
  s.Alpha3Code="USD"
  s.Numeric3Code=840
  s.IsoName="US Dollar"
  s.Precision=2
end

ChangeRate.seed do |s|
  s.CurrencyFrom = IsoCurrency.find_by_Alpha3Code("RUB").id
  s.CurrencyTo = IsoCurrency.find_by_Alpha3Code("USD").id
  s.Rate = 100
  s.SetUpDate = "21.09.2013 01:00"
end