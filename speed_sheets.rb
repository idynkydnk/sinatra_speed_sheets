require 'sinatra'
require 'data_mapper'
require 'google_drive'
require 'json'

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
  @title = 'All Games'
  erb :home
end

get '/locations' do
  file = File.read('data/locations.json')  
  puts file
  return file
end

get '/winners' do
  file = File.read('data/winners.json')
  return file
end

get '/losers' do
  file = File.read('data/losers.json')
  return file
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
  if n.location != "" && n.winner1 != "" && n.winner2 != "" && n.loser1 != "" && n.loser2 != "" 
    n.save
    add_game_to_google_sheets(n)
  end
  redirect '/'
end

get '/:id' do
  @game = Game.get params[:id]
  @title = "Edit game ##{params[:id]}"
  erb :edit
end

put '/:id' do
  n = Game.get params[:id]
  n.location = params[:location]
  n.complete = params[:complete] ? 1 : 0
  n.updated_at = Time.now
  n.save
  redirect '/'
end

get '/:id/delete' do
  @game = game.get params[:id]
  @title = "Confirm deletion of game ##{params[:id]}"
  erb :delete
end

delete '/:id' do
  n = game.get params[:id]
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
  sheet = session.spreadsheet_by_key("1lI5GMwYa1ruXugvAERMJVJO4pX5RY69DCJxR4b0zDuI").worksheets[0]
  next_empty_row = sheet.num_rows + 1
  time_format = game.created_at.strftime("%m/%d/%y")
  sheet[next_empty_row, 1] = time_format
  sheet[next_empty_row, 2] = game.location
  sheet[next_empty_row, 3] = game.winner1
  sheet[next_empty_row, 4] = game.winner2
  sheet[next_empty_row, 5] = game.loser1
  sheet[next_empty_row, 6] = game.loser2
  sheet.save
end
