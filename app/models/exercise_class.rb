class ExerciseClass < ApplicationRecord
  belongs_to :studio
  belongs_to :category
  has_many :ratings

  validates :studio, presence: true
  validates :category, presence: true
  validates :name, presence: true, uniqueness: { scope: [:studio] }

  update_index('exercise_classes') { self }

  def self.search(term: "")
    if term.present?
      query = {
        query: [
          { match: { name: term } }
        ],
        sort: {
          average_score: { order: 'desc' }
        }
      }
    else
      query = {
        query: [
          { match_all: {} }
        ],
        sort: {
          average_score: { order: 'desc' }
        }
      }
    end

    # returns an `ExerciseClassIndex::Query` object
    results = ExerciseClassesIndex.query(query)
    # pull out the class attributes
    class_attributes = results.to_a.map(&:attributes)
    # fetch the classes with the right IDs from the database
    class_ids = class_attributes.map { |attrs| attrs['id'] }
    find(class_ids)
  end

  def average_score
    ratings.sum(:score).to_f / ratings.count
  end
end
