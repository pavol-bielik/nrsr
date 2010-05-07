class CreateVotings < ActiveRecord::Migration
  def self.up
    options = "ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=utf8 COLLATE=utf8_slovak_ci"
    create_table(:votings, :options => options) do |t|
      t.integer :id
      t.integer :statute_id
      t.decimal :period             , :precision => 2, :scale => 0
      t.text :subject, :limit => "1000"
      t.integer :meeting_no
      t.integer :number_no
      t.datetime :happened_at
      t.decimal :attending_count    , :precision => 3, :scale => 0
      t.decimal :voting_count       , :precision => 3, :scale => 0
      t.decimal :pro_count          , :precision => 3, :scale => 0
      t.decimal :against_count      , :precision => 3, :scale => 0
      t.decimal :hold_count         , :precision => 3, :scale => 0
      t.decimal :not_voting_count   , :precision => 3, :scale => 0
      t.decimal :not_attending_count, :precision => 3, :scale => 0
      t.integer :popularity
    end

    add_index :votings, :statute_id
    add_index :votings, :popularity
  end

  def self.down
    drop_table :votings
  end
end
