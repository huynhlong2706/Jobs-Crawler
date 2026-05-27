class Job < ApplicationRecord
   
  validates :title, presence: true
  validates :company_name, presence: true
  validates :job_url, presence: true, uniqueness: true

  searchkick synonyms: [["ror", "ruby on rails", "ruby"]]

  def search_data
    {
      title: title,
      location: location,
      posted_at: posted_at
    }
  end
end
