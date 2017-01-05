require 'sinatra'
require 'data_mapper'
require 'google_drive'

DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/recall.db")
 
class Game
  include DataMapper::Resource
  property :id, Serial
  property :location, Text, :required => true
  property :winner1, Text, :required => true
  property :winner2, Text, :required => true
  property :loser1, Text, :required => true
  property :loser2, Text, :required => true
  property :complete, Boolean, :required => true, :default => false
  property :created_at, DateTime
  property :updated_at, DateTime
end
 
DataMapper.finalize.auto_upgrade!

get '/' do
  @games = Game.all :order => :id.desc
  @title = 'All Notes'
  erb :home
end

post '/' do
  n = Game.new
  n.location = params[:location]
  n.winner1 = params[:winner1]
  n.winner2 = params[:winner2]
  n.loser1 = params[:loser1]
  n.loser2 = params[:loser2]
  n.created_at = Time.now
  n.updated_at = Time.now
  n.save
  add_game_to_google_sheets(n)
  redirect '/'
end

get '/:id' do
  @note = Game.get params[:id]
  @title = "Edit note ##{params[:id]}"
  erb :edit
end

put '/:id' do
  n = Game.get params[:id]
  n.content = params[:content]
  n.complete = params[:complete] ? 1 : 0
  n.updated_at = Time.now
  n.save
  redirect '/'
end

get '/:id/delete' do
  @note = Note.get params[:id]
  @title = "Confirm deletion of note ##{params[:id]}"
  erb :delete
end

delete '/:id' do
  n = Note.get params[:id]
  n.destroy
  redirect '/'
end

get '/:id/complete' do
  n = Game.get params[:id]
  n.complete = n.complete ? 0 : 1 # flip it
  n.updated_at = Time.now
  n.save
  redirect '/'
end

def add_game_to_google_sheets(game)
  puts "started the google sheets method!"
  session = GoogleDrive::Session.from_config("config.json")
  sheet = session.spreadsheet_by_key("1gvdN0KvpSOz7hV_OKoJKBerwynMKboBnQvHRsbcc4sQ").worksheets[8]
  next_empty_row = sheet.num_rows + 1
  new_time = game.created_at.strftime("%m/%d/%y")

  sheet[next_empty_row, 1] = new_time
  sheet[next_empty_row, 2] = game.location
  sheet[next_empty_row, 3] = game.winner1
  sheet[next_empty_row, 4] = game.winner2
  sheet[next_empty_row, 5] = game.loser1
  sheet[next_empty_row, 6] = game.loser2
  sheet.save
end
