class CreateDeputyRelations < ActiveRecord::Migration
  def self.up
    options = "ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=utf8 COLLATE=utf8_slovak_ci"
    create_table(:deputy_relations, :options => options) do |t|
      t.integer :id
      t.integer :deputy1_id
      t.integer :deputy2_id
      t.integer :relation, :default => 0
      t.integer :votes, :default => 0
    end
    add_index :deputy_relations, [:id], :unique => true
    add_index :deputy_relations, [:deputy1_id, :deputy2_id], :unique => true
  end

  def self.down
    drop_table :deputy_relations
  end
end
