require 'sinatra'

set :env, :production
disable :run

require './base.rb'

run Sinatra::Application
