# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'sinatra/content_for'
require 'tilt/erubis'
require 'pry'

configure do
  enable :sessions
  set :session_secret, 'secret'
end

before do
  session[:lists] ||= []
end

helpers do
  # Validates list name length and uniqueness
  def valid_list?(name)
    unless (1..100).cover?(name.size)
      return { valid: false,
               error: MESSAGES[:list_length_error] }
    end
    return { valid: false, error: MESSAGES[:list_duplicate_name] }\
      if session[:lists].any? { |list| list[:name] == name }

    { valid: true }
  end
end

# Hash of potential flash messages
MESSAGES = {
  new_list_success: 'The list has been created.',
  list_length_error: 'List name must be between 1-100 characters.',
  list_duplicate_name: 'List name already exists. Please choose a unique name.',
  list_edit_success: 'The list name has been changed.'
}.freeze

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

# Creates a new list
post '/lists/new' do
  list_name = params[:list_name].strip || ''
  name_status = valid_list?(list_name)
  if name_status[:valid]
    session[:lists] << { name: list_name, todos: [] }
    session[:success] = MESSAGES[:new_list_success]
    redirect '/lists'
  else
    session[:error] = name_status[:error]
    erb :new_list, layout: :layout
  end
end

# View list
get '/lists/:id' do
  @list = session[:lists][params[:id].to_i]
  erb :list, layout: :layout
end

# Render page to edit list name
get '/lists/:id/edit' do
  erb :list_edit, layout: :layout
end

# Submit list name changes with validation
post '/lists/:id/edit' do
  @list_id = params[:id].to_i
  list_name = params[:list_name].strip || ''
  name_status = valid_list?(list_name)
  if name_status[:valid]
    session[:lists][@list_id][:name] = list_name
    session[:success] = MESSAGES[:list_edit_success]
    redirect '/lists'
  else
    session[:error] = name_status[:error]
    erb :list_edit, layout: :layout
  end
end
