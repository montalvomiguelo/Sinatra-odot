class Task < ActiveRecord::Base
  validates :title, presence: true
  validates :list, presence: true
  validates :duration, numericality: { only_integer: true }

  belongs_to :list
end
