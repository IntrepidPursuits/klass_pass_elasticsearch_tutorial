class ExerciseClassesIndex < Chewy::Index
  define_type ExerciseClass.includes(:ratings) do
    # primary and foreign keys
    field :id, type: 'integer'
    field :studio_id, type: 'integer'
    field :category_id, type: 'integer'

    # other attributes
    field :name, type: 'string'
    field :description, type: 'string'
    field :created_at, type: 'date', index: 'not_analyzed'
    field :updated_at, type: 'date', index: 'not_analyzed'

    # computed
    field :average_score, type: 'number', value: ->(exercise_class) do
      ratings = exercise_class.ratings
      ratings.sum(:score) / ratings.count
    end
  end
end
