class Task < ActiveRecord::Base
  validates :title, presence: true
  validates :list, presence: true

  belongs_to :list
end
