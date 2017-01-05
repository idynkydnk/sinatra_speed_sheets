require 'sinatra'

get '/form' do
  erb :form
end

post '/form' do
  "You said '#{params[:message]}'"
end
