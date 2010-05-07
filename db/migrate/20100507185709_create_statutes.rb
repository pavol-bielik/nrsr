class CreateStatutes < ActiveRecord::Migration
  def self.up
    options = "ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=utf8 COLLATE=utf8_slovak_ci"
    create_table(:statutes, :options => options) do |t|
      t.integer :id
      t.integer :parent_id
      t.string :type
      t.string :state
      t.string :result
      t.text :subject, :limit => "1000"
      t.date :date
    end
  end

  def self.down
    drop_table :statutes
  end
end