class List < ActiveRecord::Base
  validates :title, presence: true

  has_many :tasks, inverse_of: :list, dependent: :destroy
end
