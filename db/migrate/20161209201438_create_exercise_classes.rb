class CreateExerciseClasses < ActiveRecord::Migration[5.0]
  def change
    create_table :exercise_classes do |t|
      t.references :studio, foreign_key: true
      t.references :category, foreign_key: true
      t.string :name
      t.string :description

      t.timestamps
    end
  end
end
