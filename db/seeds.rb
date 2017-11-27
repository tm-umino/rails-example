# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
10.times do |i|
  News.create(title: "タイトル#{i}", writer: "ジロー", memberOnly: i % 2, contents: "この文章はダミーです。文字の大きさ、量、字間、行間等を確認するために入れています。")
end
