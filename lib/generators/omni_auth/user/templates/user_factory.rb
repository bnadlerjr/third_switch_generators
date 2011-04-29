# Read about factories at http://github.com/thoughtbot/factory_girl

Factory.define :user do |f|
  f.name     "John Doe"
  f.provider "thirty_seven_signals"
  f.uid      35821
end
