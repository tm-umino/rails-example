### Rails基盤作成
```
rails new news-example --skip-bundle
```

### Rails基盤作成2
/news-example直下で下記のコマンドを実行
```
bundle install --path /usr/local/src/bundles/news-example
rails g scaffold User name:string email:string password_digest:string created_at:date updated_at:date
rails g scaffold News title:string writer:string contents:text memberOnly:boolean created_at:date updated_at:date
```

### DB操作
/news-example直下で下記のコマンドを実行
```
rake db:migrate
```

### 初期データ投入
/db/seed.rbに下記を記述
```
10.times do |i|
  News.create(title: "タイトル#{i}", writer: "ジロー", memberOnly: i % 2, contents: "この文章はダミーです。文字の大きさ、量、字間、行間等を確認するために入れています。")
end
```
/news-example直下で下記のコマンドを実行
```
rake db:seed
```


### TOPページ作成
/app/views配下にindexフォルダ作成、その中にindex.html.erbを作成し、下記を記述
```
<%= link_to 'News', news_index_path %>
<%= link_to 'User', users_path %>

<table>
  <thead>
    <tr>
      <th>Title</th>
      <th>Writer</th>
      <th colspan="3"></th>
    </tr>
  </thead>

  <tbody>
    <% @news.each do |news| %>
      <tr>
        <td><%= news.title %></td>
        <td><%= news.writer %></td>
        <td><%= link_to 'Show', news %></td>
      </tr>
    <% end %>
  </tbody>
</table>
```

/config/routes.rbに下記を記述
```
root 'index#index'
```

/app/controller配下にindex_controller.rb作成
下記を記述

```
class IndexController < ApplicationController

  def index
    @news = News.all
  end

end
```

### ヘッダー、フッダー作成
/app/views/layouts/application.html.erb 11行目 ```<%= yield %>``` の前後に下記を記述
```
<div class="header" style="border-bottom:solid 1px #ccc; margin-bottom:10px; padding-bottom:10px;">
  <h1>News-example</h1>
</div>
<%= yield %>
<div class="footer" style="border-top:solid 1px #ccc; margin-top:10px; padding-top:10px;">
  <%= link_to 'TOP', root_path %>
</div>
```


### ログイン機能実装
/Gemfileに下記を記述
```
gem 'bcrypt-ruby', '3.1.1.rc1', :require => 'bcrypt'
```
/news-example直下で下記のコマンドを実行
```
bundle install --path /usr/local/src/bundles/news-example
rails g controller Sessions new
```
/config/routes.rbに下記を追加
```
get 'login', to: 'sessions#new'
post 'login', to: 'sessions#create'
delete 'logout', to: 'sessions#destroy'
```

/app/controller配下のsessions_controller.rbを下記に変更
```
class SessionsController < ApplicationController
  before_action :set_user, only: [:create]

  skip_before_action :require_sign_in!, raise: false, only: [:new, :create]

  def new
  end

  def create
    if @user.authenticate(session_params[:password])
      sign_in(@user)
      redirect_to root_path
    else
      flash.now[:danger] = t('.flash.invalid_password')
      render 'new'
    end
  end

  def destroy
    sign_out
    redirect_to login_path
  end

  def require_sign_in!
    require_sign_in!
  end

  private

    def set_user
      @user = User.find_by!(email: session_params[:email])
    rescue
      flash.now[:danger] = t('.flash.invalid_mail')
      render action: 'new'
    end

    # 許可するパラメータ
    def session_params
      params.require(:session).permit(:email, :password)
    end

end
```

/app/views/sessionsにnew.html.slimに下記を追加
```
<%= form_for :session, url: login_path do |f| %>
  <%= f.text_field :email %>
  <%= f.password_field :password %>

  <%= f.submit 'ログイン' %>
<% end %>
```

/app/controllers/application_controller.rbに下記を追記
```
before_action :current_user
helper_method :signed_in?

def current_user
  @current_user ||= User.find_by(id: session[:user_id])
end

def sign_in(user)
  session[:user_id] = user.id
  @current_user = user
end

def sign_out
  @current_user = nil
  reset_session
end

def signed_in?
  @current_user.present?
end

private
  def require_sign_in!
    redirect_to login_path unless signed_in?
  end
```



/app/model/user.rbに下記を追記
```
has_secure_password validations: true
```

rake db:migrate

/app/views/index/index.htmlに下記を追加
```
<% if @current_user %>
  <p><%= @current_user.name %></p><%= link_to 'ログアウト', logout_path, method: :delete %>
<% else %>
  <%= link_to 'ログイン', login_path %>
<% end %>
```

### 会員限定機能
/app/news_controller.rbに下記を追加
```
before_action :require_sign_in!, only: [:new, :create, :edit, :update, :destroy]
before_action :require_sign_in!, only: [:new, :create, :edit, :update, :destroy]
```

/app/model/news.rbに下記を追加
```
def self.getNews(isMember = false)
  if (isMember)
    News.all
  else
    News.where(memberOnly: false)
  end
end
```

/app/controller/news_controller.rbのindexとcreateを下記に置き換え
```
def index
  @news = News.getNews(signed_in?)
end

def create
  @news = News.new(news_params)
  @news.writer = @current_user.name
  respond_to do |format|
    if @news.save
      format.html { redirect_to @news, notice: 'News was successfully created.' }
      format.json { render :show, status: :created, location: @news }
    else
      format.html { render :new }
      format.json { render json: @news.errors, status: :unprocessable_entity }
    end
  end
end
```

/app/views/news/_form.html.erbから以下を削除
```
<div class="field">
  <%= form.label :writer %>
  <%= form.text_field :writer, id: :news_writer %>
</div>

<div class="field">
  <%= form.label :created_at %>
  <%= form.date_select :created_at, id: :news_created_at %>
</div>

<div class="field">
  <%= form.label :updated_at %>
  <%= form.date_select :updated_at, id: :news_updated_at %>
</div>
```

/app/views/news/_form.html.erbから以下を変更
```
<div class="field">
  <%= f.label :password_digest %>
  <%= f.text_field :password_digest %>
</div>

↓

<div class="field">
  <%= f.label :password %>
  <%= f.text_field :password %>
</div>
```
