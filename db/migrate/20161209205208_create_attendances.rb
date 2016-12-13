class CreateAttendances < ActiveRecord::Migration[5.0]
  def change
    create_table :attendances do |t|
      t.references :exercise_class, foreign_key: true
      t.references :user, foreign_key: true
      t.datetime :date

      t.timestamps
    end
  end
end
