class CreateExerciseClassAttributes < ActiveRecord::Migration[5.0]
  def change
    create_table :exercise_class_attributes do |t|
      t.string :name

      t.timestamps
    end
  end
end
