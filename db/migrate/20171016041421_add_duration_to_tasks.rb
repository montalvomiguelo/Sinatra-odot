class AddDurationToTasks < ActiveRecord::Migration
  def change
    add_column :tasks, :duration, :integer, :default => 0
  end
end
