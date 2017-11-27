class IndexController < ApplicationController

  def index
    @news = News.getNews(signed_in?)
  end

end
