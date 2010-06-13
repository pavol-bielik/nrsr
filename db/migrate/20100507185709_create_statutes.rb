class CreateStatutes < ActiveRecord::Migration
  def self.up
    options = "ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=utf8 COLLATE=utf8_slovak_ci"
    create_table(:statutes, :options => options) do |t|
      t.integer :id
      t.integer :parent_id
      t.string :statute_type
      t.string :state
      t.string :result
      t.text :subject, :limit => "1000"
      t.string :short_subject
      t.date :date
      t.string :doc                 #url na dokument o zakone v pripade, ze je dostupny
      t.integer :popularity         #momentalne nepouzite, pripadne pouzitie rovnake ako pri votings
      t.text :info, :limit => "2000"
    end
  end

  def self.down
    drop_table :statutes
  end
end
