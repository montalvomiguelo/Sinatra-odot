class AddDurationToTasks < ActiveRecord::Migration
  def change
    add_column :tasks, :duration, :integer, :null => false, :default => 0
  end
end
