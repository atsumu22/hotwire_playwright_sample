FactoryBot.define do
  factory :task do
    title { "Task" }
    association :project
  end
end