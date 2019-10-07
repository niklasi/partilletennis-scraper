require 'sinatra'
require 'sinatra/reloader' if development?
require './scraperTeamSeries'
require './scraperExcerciseSeries'

set :port, 8080
set :haml, :format => :html5
set :public_folder, File.dirname(__FILE__) + '/static'

get '/' do
  haml :index
end

get '/lagserien/:series' do
  series = TeamSeries.load(params[:series])
  haml :index, :locals => series 
end

post '/lagserien/:series' do
  haml :index
end

get '/motionserier/:series' do
  series = ExcerciseSeries.load(params[:series])
  haml :index, :locals => series
end

post '/motionserier/:series' do
  # params.each do |p, v|
  #   puts p + " " + v
  # end
  haml :index
end
