class CreateDomains < ActiveRecord::Migration
  def change
    create_table :domains do |t|
      t.citext :name, null: false
      t.string :verification_token, null: false
      t.integer :status, null: false
      t.belongs_to :account, null: false, index: true, foreign_key: true
      t.timestamps null: false
      t.index :name, unique: true
    end
  end
end
