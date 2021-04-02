#encoding: utf-8
require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'

def init_db
	@db = SQLite3::Database.new 'leprosorium.db'
	@db.results_as_hash = true
end

before do
	init_db

end

configure do
	init_db
	@db.execute 'CREATE TABLE IF NOT EXISTS "Posts" 
	("id" INTEGER PRIMARY KEY AUTOINCREMENT, 
	"created_date" DATE, "content" TEXT, "nickname" TEXT)'

	@db.execute 'CREATE TABLE IF NOT EXISTS "Comments" 
	("id" INTEGER PRIMARY KEY AUTOINCREMENT, 
	"created_date" DATE, "content" TEXT, post_id INTEGER, "nickname" TEXT)'

end

get '/' do
	@results = @db.execute 'select * from Posts order by id desc'
	
	erb :index	
end

get '/newpost' do
  erb :new
end

post '/newpost' do
  content = params[:content]
  nickname = params[:nickname]
  if content.length <=0 
  	@error = 'Введите текст поста'
  	return erb :new
  end

   if nickname.length <=0 
  	@error = 'Введите никнейм'
  	return erb :new
  end

  @db.execute 'insert into Posts (content,created_date,nickname) values (?, datetime(), ?)', [content,nickname]

  redirect to '/'
end

get '/details/:post_id' do
	post_id = params[:post_id]

	results = @db.execute 'select * from Posts where id = ?', [post_id]
	@row = results[0]
	@comments = @db.execute 'select * from Comments where post_id = ? order by id', [post_id]

	erb :details
end

post '/details/:post_id' do
	post_id = params[:post_id]
  	content = params[:comment]
  	nickname = params[:nickname]
  		if content.length <=0 
  			@error = 'Введите текст комментария'
  			return erb :details
 		end

 		if nickname.length <=0 
  			@error = 'Введите никнейм'
  			return erb :details
 		end

  @db.execute 'insert into Comments (content,created_date,post_id,nickname) values (?, datetime(), ?, ?)', [content,post_id,nickname]

  redirect to('/details/' + post_id)
end