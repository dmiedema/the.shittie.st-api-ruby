require 'sinatra'

set :env, :production
disable :run

require 'base'

run Sinatra::Application
