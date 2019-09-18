require 'sinatra'
require 'sinatra/reloader' if development?
require './scraperTeamSeries'
require './scraperExcerciseSeries'

set :port, 8080
set :haml, :format => :html5
set :public_folder, File.dirname(__FILE__) + '/static'

get '/lagserien/:series' do
  series = TeamSeries.load(params[:series])
  haml :index, :locals => series 
end

get '/motionserier/:series' do
  haml :index, :locals => ExcerciseSeries.load(params[:series])
end

