class CreateDefaultAssignItem < ActiveRecord::Migration
  def self.up
    create_table :default_assign_items do |t|
      t.column :project_id, :integer
      t.column :issue_category_id, :integer
      t.column :tracker_id, :integer
      t.column :assigned_to_id, :integer, :null => false
    end
  end

  def self.down
    drop_table :default_assign_items
  end
end
