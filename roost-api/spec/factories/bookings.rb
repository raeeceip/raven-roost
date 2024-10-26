FactoryBot.define do
  factory :booking do
    user { nil }
    space { nil }
    start_time { "2024-10-26 19:10:46" }
    end_time { "2024-10-26 19:10:46" }
    status { "MyString" }
  end
end
