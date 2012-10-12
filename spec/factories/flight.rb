FactoryGirl.define do
  factory :flight do
    plane
    association :seat1_person, :factory => :person
    association :controller, :factory => :person
    association :from, :factory => :airfield
    association :to, :factory => :airfield
    departure_date Date.today
    departure_i 10
    arrival_i 11

    factory :non_editable_flight do
      after(:create) do |flight|
        flight.accounting_session = FactoryGirl.create(:accounting_session)
        flight.save
        flight.accounting_session.finished_at = 1.day.ago
        flight.accounting_session.save!
      end
    end
  end

  factory :tow_flight do
    plane
    association :seat1_person, :factory => :person
    association :controller, :factory => :person
    association :from, :factory => :airfield
    association :to, :factory => :airfield
    association :abstract_flight, :factory => :flight
    departure_i 10
    arrival_i 11
  end

  factory :abstract_flight do
    departure_date { Date.today }
    departure_i 10
    arrival_i 11
  end
end
