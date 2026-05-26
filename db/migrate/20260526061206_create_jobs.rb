class CreateJobs < ActiveRecord::Migration[8.1]
  def change
    create_table :jobs do |t|
      t.string :title             , null: false
      t.string :company_name      , null: false
      t.string :salary
      t.string :location
      t.string :job_url           , null: false
      t.datetime :posted_at
      t.text :description
      t.string :source

      t.timestamps
    end
    add_index :jobs, :job_url, unique: true  #Tránh trùng ở dưới DB
    add_index :jobs, :posted_at              # tăng tốc sort newest
    add_index :jobs, :location               # tăng tốc filter location
    add_index :jobs, :title                  # tăng tốc filter title
  end
end
