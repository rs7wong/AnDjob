class Job < ApplicationRecord

  has_many :resumes

  belongs_to :user
  has_many :job_relationships
  has_many :members, through: :job_relationships, source: :user

  has_many :job_favorites
  has_many :collectors, through: :job_favorites, source: :user

  validates :title, presence: true
  validates :wage_upper_bound, presence: true
  validates :wage_lower_bound, presence: true
  validates :wage_lower_bound, numericality: { greater_than: 0}

  scope :published, -> { where(is_hidden: false ) }
  scope :recent, -> { order('created_at DESC') }
  scope :published, -> { where(is_hidden: false) }
  scope :recent, -> { order("created_at DESC") }


  def publish!
    self.is_hidden = false
    self.save
  end

  def hide!
    self.is_hidden = true
    self.save
  end
end
