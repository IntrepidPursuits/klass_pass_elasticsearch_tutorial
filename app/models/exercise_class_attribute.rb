class ExerciseClassAttribute < ApplicationRecord
  validates :name, presence: true, uniqueness: true
end
