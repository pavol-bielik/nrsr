class CreateVotes < ActiveRecord::Migration
  def self.up
    options = "ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=utf8 COLLATE=utf8_slovak_ci"
    create_table(:votes, :options => options) do |t|
      t.integer :id
      t.integer :voting_id
      t.integer :deputy_id
      t.string :vote, :limit => "10"
      t.string :party, :limit => "100"
    end
    add_index :votes, [:id], :unique => true
    add_index :votes, [:voting_id]
    add_index :votes, [:deputy_id]
  end

  def self.down
    drop_table :votes
  end
end
