class ExerciseClassesIndex < Chewy::Index
  define_type ExerciseClass do
    # primary and foreign keys
    field :id, type: 'integer'
    field :studio_id, type: 'integer'
    field :category_id, type: 'integer'

    # other attributes
    field :name, type: 'string'
    field :description, type: 'string'
    field :created_at, type: 'date', index: 'not_analyzed'
    field :updated_at, type: 'date', index: 'not_analyzed'
  end
end
