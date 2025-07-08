class ChangeColumnToTask < ActiveRecord::Migration[8.0]
  def change
    remove_column :tasks, :status
    add_column :tasks, :status, :boolean, default: false
  end
end
