require 'sinatra'
require 'sinatra/reloader' if development?
# require 'json'
# require './scraperTeamSeries'
# require './scraperExcerciseSeries'

set :port, 8080

get '/scraper/lagserien/:series', :provides => 'json' do
  # series = TeamSeries.load(params[:series])
  # series.to_json
  File.read(params[:series] + '.json')
end

get '/scraper/motionserier/:series', :provides => 'json' do
  # series = ExcerciseSeries.load(params[:series])
  # series.to_json
  File.read(params[:series] + '.json')
end
