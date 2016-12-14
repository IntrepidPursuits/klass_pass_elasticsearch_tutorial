class ExerciseClass < ApplicationRecord
  belongs_to :studio
  belongs_to :category
  has_many :ratings

  validates :studio, presence: true
  validates :category, presence: true
  validates :name, presence: true, uniqueness: { scope: [:studio] }

  def self.search(term: "")
    # TODO use elasticsearch
    if term.present?
      where("name ILIKE ?", "%#{term}%")
    else
      all
    end
  end
end
