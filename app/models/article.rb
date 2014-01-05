class Article < ActiveRecord::Base

  belongs_to :author, class_name: 'Account', inverse_of: :articles
  has_and_belongs_to_many :topics

  include Sluggable
  self.generate_slugs_from_column = :title

  validates :title, :author_id, presence: true

  scope :visible, -> {
    where(visible: true).order('published_at DESC')
  }

  def published?
    !!published_at
  end

  PARAGRAPH_DIVIDER = "\r\n\r\n"  # What the <textarea> tag uses.

  def synopsis
    body.split(PARAGRAPH_DIVIDER).first
  end

  def synopsis_covers_everything?
    body.split(PARAGRAPH_DIVIDER).count == 1
  end
end
