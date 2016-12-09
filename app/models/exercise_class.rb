class ExerciseClass < ApplicationRecord
  belongs_to :studio
  belongs_to :category

  validates :studio, presence: true
  validates :category, presence: true
  validates :name, presence: true, uniqueness: { scope: [:studio] }
end
