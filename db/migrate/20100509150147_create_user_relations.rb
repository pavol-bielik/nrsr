class CreateUserRelations < ActiveRecord::Migration
  def self.up
    options = "ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=utf8 COLLATE=utf8_slovak_ci"
    create_table(:user_relations, :options => options) do |t|
      t.integer :id
      t.integer :user_id
      t.integer :deputy_id
      t.integer :relation, :default => 0
      t.integer :votes, :default => 0
    end
    add_index :user_relations, [:id], :unique => true
    add_index :user_relations, [:user_id, :deputy_id], :unique => true
  end

  def self.down
    drop_table :user_relations
  end
end
