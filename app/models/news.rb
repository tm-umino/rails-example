class News < ApplicationRecord

  def self.getNews(isMember = false)
    if (isMember)
      News.all
    else
      News.where(memberOnly: false)
    end
  end

end
