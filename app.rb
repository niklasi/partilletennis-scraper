require 'sinatra'
require 'sinatra/reloader' if development?
require './scraper'

set :port, 8080
set :haml, :format => :html5

get '/foretagstennis/:series' do
  haml :index, :locals => foretagstennis(params[:series])
end

