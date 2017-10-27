FactoryGirl.define do
  factory :list do
    sequence :title do |n|
      "List title #{n}"
    end
    user

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
    sequence :title do |n|
      "Task title #{n}"
    end
    list
  end

  factory :user do
    sequence(:email, 1000) { |n| "person#{n}@example.com" }
    password "123456"

    factory :user_with_lists do
      transient do
        lists_count 2
      end

      after(:create) do |user, evaluator|
        create_list(:list_with_tasks, evaluator.lists_count, user: user)
      end
    end
  end
end
