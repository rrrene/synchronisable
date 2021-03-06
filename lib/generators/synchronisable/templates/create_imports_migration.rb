class CreateImports < ActiveRecord::Migration
  def self.up
    create_table :imports do |t|
      t.string  :synchronisable_type, null: false
      t.integer :synchronisable_id, null: false
      t.text    :attrs
      t.string  :remote_id, null: false

      t.timestamps
    end

    add_index :imports, :remote_id
    add_index :imports, [:synchronisable_type, :synchronisable_id]
  end

  def self.down
    remove_index :imports, :remote_id
    remove_index :imports, [:synchronisable_type, :synchronisable_id]
    drop_table :imports
  end
end
