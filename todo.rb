# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'tilt/erubis'
require 'pry'

configure do
  enable :sessions
  set :session_secret, 'secret'
end

before do
  session[:lists] ||= []
end

get '/' do
  redirect '/lists'
end

# View of all lists
get '/lists' do
  @lists = session[:lists]
  erb :lists, layout: :layout
end

# Renders the new list form
get '/lists/new' do
  erb :new_list, layout: :layout
end

# Hash of potential flash messages
MESSAGES = {
  new_list_success: 'The list has been created'
}.freeze

# Creates a new list
post '/lists/new' do
  session[:lists] << { name: params[:list_name], todos: [] }
  session[:message] = MESSAGES[:new_list_success]

  redirect '/lists'
end
