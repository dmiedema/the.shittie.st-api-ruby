require 'sinatra'

set :env, :production
disable :run

require_relative 'base'

run Sinatra::Application
