require 'rubygems'
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
  property :date, DateTime
  property :updated_at, DateTime
end
 
DataMapper.finalize.auto_upgrade!

get '/' do
  @games = Game.all :order => :id.desc
  @todays_games = todays_games
  @todays_players = todays_players
  get_todays_stats
  @title = 'All Games'
  erb :home
end

post '/' do
  n = Game.new
  n.location = params[:location]
  n.winner1 = params[:winner1]
  n.winner2 = params[:winner2]
  n.loser1 = params[:loser1]
  n.loser2 = params[:loser2]
  n.date = Time.now
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
  n.winner1 = params[:winner1]
  n.winner2 = params[:winner2]
  n.loser1 = params[:loser1]
  n.loser2 = params[:loser2]
  n.updated_at = Time.now
  if n.location != "" && n.winner1 != "" && n.winner2 != "" && n.loser1 != "" && n.loser2 != "" 
    n.save
  end
  redirect '/'
end

get '/:id/delete' do
  @game = Game.get params[:id]
  @title = "Confirm deletion of game ##{params[:id]}"
  erb :delete
end

delete '/:id' do
  n = Game.get params[:id]
  n.destroy
  redirect '/'
end

def add_game_to_google_sheets(game)
  puts "adding a game!"
  session = GoogleDrive::Session.from_config("config.json")
  sheet = session.spreadsheet_by_key("1lI5GMwYa1ruXugvAERMJVJO4pX5RY69DCJxR4b0zDuI").worksheets[0]
  next_empty_row = sheet.num_rows + 1
  formatted_time = game.date.strftime("%m/%d/%y")
  sheet[next_empty_row, 1] = formatted_time
  sheet[next_empty_row, 2] = game.location
  sheet[next_empty_row, 3] = game.winner1
  sheet[next_empty_row, 4] = game.winner2
  sheet[next_empty_row, 5] = game.loser1
  sheet[next_empty_row, 6] = game.loser2
  sheet.save
end

def reload_database
  session = GoogleDrive::Session.from_config("config.json")
  sheet = session.spreadsheet_by_key("1lI5GMwYa1ruXugvAERMJVJO4pX5RY69DCJxR4b0zDuI").worksheets[0]
  (1..sheet.num_rows).each do |row|
    x = Game.new
    date = sheet[row, 1].to_s
    new_date = Time.new(date[6..9], date[0..1], date[3..4])
    x.date = new_date
    x.location = sheet[row, 2] 
    x.winner1 = sheet[row, 3]
    x.winner2 = sheet[row, 4]
    x.loser1 = sheet[row, 5]
    x.loser2 = sheet[row, 6]
    x.save
  end 
end

def delete_database
  Game.destroy
end

def get_todays_stats
  name_and_stats = []
  @todays_players.each do |player|
  wins, losses = 0, 0
    @todays_games.each do |game|
      if player == game.winner1 || player == game.winner2
        wins += 1
      elsif player == game.loser1 || player == game.loser2
        losses += 1
      end
    end
      puts player + " " + wins.to_s + " " + losses.to_s
  end
end

def todays_games
  games = []
  @games.each do |game|
    if game.date.strftime("%m/%d/%y") == Time.now.strftime("%m/%d/%y")
      games << game 
    end
  end
  return games
end

def todays_players
  players = []
  @todays_games.each do |game|
    players << game.winner1 unless players.include?(game.winner1)
    players << game.winner2 unless players.include?(game.winner2)
    players << game.loser1 unless players.include?(game.loser1)
    players << game.loser2 unless players.include?(game.loser2)
  end
  return players
end


#
#get '/:id' do
#  @game = Game.get params[:id]
#  @title = "Edit game ##{params[:id]}"
#  erb :edit
#end
#
#put '/:id' do
#  n = Game.get params[:id]
#  n.location = params[:location]
#  n.complete = params[:complete] ? 1 : 0
#  n.updated_at = Time.now
#  n.save
#  redirect '/'
#end
#
#get '/:id/delete' do
#  @game = game.get params[:id]
#  @title = "Confirm deletion of game ##{params[:id]}"
#  erb :delete
#end
#
#delete '/:id' do
#  n = game.get params[:id]
#  n.destroy
#  redirect '/'
#end
#
#get '/:id/complete' do
#  n = Game.get params[:id]
#  n.complete = n.complete ? 0 : 1 # flip it
#  n.updated_at = Time.now
#  n.save
#  redirect '/'
#end
#
