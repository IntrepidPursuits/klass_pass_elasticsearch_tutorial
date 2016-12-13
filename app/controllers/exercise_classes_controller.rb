class ExerciseClassesController < ApplicationController
  def  index
    exercise_classes = ExerciseClass.search(term: params[:query])
    render json: exercise_classes
  end
end
