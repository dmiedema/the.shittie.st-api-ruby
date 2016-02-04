require 'sinatra'
require 'sinatra/contrib'
require 'base64'
require 'digest'
require 'json'
require 'sqlite3'
require 'sinatra/reloader' if development?

get '/' do
  responseMessage(request, "the boats are nervous. The wind comes so they hide")
end

get '/api' do
  responseMessage(request, 'shit')
end

namespace '/api' do
  get '/'  do
    responseMessage(request, 'shit')
  end

  get '/shit' do
    responseMessage(request, "shit")
  end

  get '/shit/:count' do
    count = params['count'].to_i
    count = count < 5000 ? count : 5000
    responseMessage(request, "shit " * count)
  end

  get '/shit/:name' do
    responseMessage(request, "#{params['name']} is shit")
  end

  get '/shit/:name/fuck' do
    responseMessage(request, "#{params['name']} is fucking shit")
  end

  get '/shittiest' do
    responseMessage(request, "this is the shittiest")
  end

  get '/shittiest/:name' do
    responseMessage(request, "#{params['name']} is the shittiest person")
  end

  get '/fuck' do
    responseMessage(request, "fucking shit")
  end

  get '/you' do
    responseMessage(request, 'you are shit')
  end

  get '/this' do
    responseMessage(request, 'this is shit')
  end

  get '/everything' do
    responseMessage(request, 'everything is shit')
  end
end

# DB Configuration
db_name = development? ? 'test.db' : 'shortened_urls.db'
db = SQLite3::Database.new db_name

# Create our Table
db.execute <<-SQL
  CREATE TABLE IF NOT EXISTS URLs (
    Key TEXT PRIMARY KEY,
    URL TEXT NON NULL
    );
SQL

get '/url' do
  responseMessage(request, 'URL shortener. Do a `POST` with JSON ```{"url":"some://url"}```')
end

get '/url/:id' do
  row = db.execute(" SELECT URL from URLs WHERE Key = ?", params['id']).first
  puts row.class
  if row.empty?
    halt 404, 'nope nope nope'
  else
    redirect (Base64.urlsafe_decode64(row.first)), 301
  end
end

post '/url' do
  request.body.rewind # just in case
  data = JSON.parse(request.body.read)
  if data.nil?
    halt 400, 'no data...'
  end
  url = Base64.urlsafe_encode64(data['url'])
  key = Digest::SHA256.hexdigest(url)[0..8] # Take first 8 characters
  db.execute(" INSERT OR IGNORE INTO URLs ( Key, URL ) VALUES ( ?, ? )", key, url)
  if env['HTTP_ACCEPT'].nil?
    env['HTTP_ACCEPT'] = 'application/json'
  end
  responseMessage(request, {"key" => key, "url" => "https://the.shittie.st/url/#{key}"})
end

private
def responseMessage(req, obj)
  if env['HTTP_ACCEPT'].include? 'application/json'
    return json :message => obj
  else
    return obj
  end
end
