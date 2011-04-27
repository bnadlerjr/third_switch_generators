class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :provider
      t.string :uid
      t.string :name

      t.timestamps
    end

    add_index :users, :provider
    add_index :users, :uid
    add_index :users, :name
  end

  def self.down
    remove_index :users, :name
    remove_index :users, :uid
    remove_index :users, :provider

    drop_table :users
  end
end
