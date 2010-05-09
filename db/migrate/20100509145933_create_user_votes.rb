class CreateUserVotes < ActiveRecord::Migration
  def self.up
    options = "ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=utf8 COLLATE=utf8_slovak_ci"
    create_table(:user_votes, :options => options) do |t|
      t.integer :id
      t.integer :voting_id
      t.integer :user_id
      t.string :vote, :limit => "10"
    end
    add_index :user_votes, [:id], :unique => true
    add_index :user_votes, [:voting_id]
    add_index :user_votes, [:user_id]
  end

  def self.down
    drop_table :user_votes
  end
end
