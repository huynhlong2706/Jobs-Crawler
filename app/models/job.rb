class Job < ApplicationRecord
   
  validates :title, presence: true
  validates :company_name, presence: true
  validates :job_url, presence: true, uniqueness: true

  scope :search_by_title,    ->(q)   { where("title LIKE ?", "%#{q}%") if q.present? }
  scope :filter_by_location, ->(loc) { where("location LIKE ?", "%#{loc}%") if loc.present? }
  scope :newest,             ->      { order(posted_at: :desc) }
end
