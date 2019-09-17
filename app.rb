require 'sinatra'

set :port, 8080

get '/foretagstennis/:name/:category' do
  "Hello #{params['name']} #{params['category']}!"
end
