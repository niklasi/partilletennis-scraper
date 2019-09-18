require 'sinatra'
require 'sinatra/reloader' if development?
require './scraperTeamSeries'
require './scraperExcerciseSeries'

set :port, 8080
set :haml, :format => :html5
set :public_folder, File.dirname(__FILE__) + '/static'

get '/lagserien/:series' do
  haml :index, :locals => team_series(params[:series])
end

get '/motionserier/:series' do
  haml :index, :locals => excercise_series(params[:series])
end

