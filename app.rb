require 'sinatra'
require 'sinatra/reloader' if development?
require './scraper'

set :port, 8080
set :haml, :format => :html5
set :public_folder, File.dirname(__FILE__) + '/static'

get '/foretagstennis/:series' do
  haml :index, :locals => foretagstennis(params[:series])
end

