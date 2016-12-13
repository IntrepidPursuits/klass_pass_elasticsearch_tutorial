class Rating < ApplicationRecord
  belongs_to :user
  belongs_to :exercise_class
  belongs_to :exercise_class_attribute

  validates :user, presence: true
  validates :exercise_class, presence: true
  validates :exercise_class_attribute,
    presence: true,
    uniqueness: { scope: [:user_id, :exercise_class_id] }

  delegate :name, to: :exercise_class_attribute, prefix: true
  delegate :name, to: :user, prefix: true
end
