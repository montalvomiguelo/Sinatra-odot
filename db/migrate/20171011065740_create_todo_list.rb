class CreateTodoList < ActiveRecord::Migration
  def change
    create_table :todo_lists do |t|
      t.string :title
      t.timestamps null: false
    end
  end
end
