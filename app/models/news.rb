class News < ApplicationRecord
  validates :title, presence:true
  validates :contents, presence: true


  def self.getNews(isMember = false)
    if (isMember)
      News.all
    else
      News.where(memberOnly: false)
    end
  end

end
