class CreateQuestions < ActiveRecord::Migration[5.0]
  def change
    create_table :questions do |t|
      t.string :title
      t.text :body

      #this will create two timestamp fields: created_at and updated_at
      t.timestamps
    end
  end
end
