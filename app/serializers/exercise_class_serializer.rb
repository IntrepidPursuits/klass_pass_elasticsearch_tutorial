class ExerciseClassSerializer < ActiveModel::Serializer
  has_one :studio
  has_many :ratings

  attributes :id, :name, :average_score
end
