class CreateDeputies < ActiveRecord::Migration
  def self.up
    options = "ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=utf8 COLLATE=utf8_slovak_ci"
    create_table(:deputies, :options => options) do |t|
      t.integer :id
      t.string :degree
      t.string :lastname
      t.string :firstname
      t.string :party
      t.date :born
      t.string :nationality
      t.string :domicile
      t.string :region
      t.string :email
      t.string :contact_person
      t.string :photo
    end
    add_index :deputies, [:id], :unique => true

  end

  def self.down
    drop_table :deputies
  end
end

