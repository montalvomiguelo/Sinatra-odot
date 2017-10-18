FactoryGirl.define do
  factory :list do
    title "List title"

    factory :list_with_tasks do
      transient do
        tasks_count 5
      end

      after(:create) do |list, evaluator|
        create_list(:task, evaluator.tasks_count, list: list)
      end
    end
  end

  factory :task do
    title "Task title"
    list
  end

  factory :user do
    email "test@example.com"
  end
end
