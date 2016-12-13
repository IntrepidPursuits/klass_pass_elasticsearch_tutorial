class RatingSerializer < ActiveModel::Serializer
  attributes :id, :exercise_class_attribute_name, :user_name, :score
end
