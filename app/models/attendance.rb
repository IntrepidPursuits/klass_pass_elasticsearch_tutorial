class Attendance < ApplicationRecord
  belongs_to :exercise_class
  belongs_to :user

  validates :exercise_class, presence: true
  validates :user, presence: true, uniqueness: { scope: :exercise_class_id }
end
