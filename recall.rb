require 'rubygems'
require 'sinatra'
require 'data_mapper'
require 'builder'
require 'sinatra/flash'
require 'sinatra/redirect_with_flash'

SITE_TITLE = "Todo"

enable :sessions

DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/recall.db")

class Note
	include DataMapper::Resource
	property :id, Serial
	property :content, Text, :required => true
	property :complete, Boolean, :required => true, :default => false
	property :created_at, DateTime
	property :updated_at, DateTime
end

DataMapper.finalize.auto_upgrade!

helpers do
	include Rack::Utils
	alias_method :h, :escape_html
end

get '/rss.xml' do
	@notes = Note.all :order => :id.desc
	builder :rss
end

get '/' do
	@notes = Note.all :order => :id.desc
	@title = 'All Notes'
	if @notes.empty?
		flash[:error] = 'No notes found. Add your first note below.'
	end
	erb :home
end

post '/' do
	note = Note.new
	note.content = params[:content]
	note.created_at = Time.now
	note.updated_at = Time.now
	if note.save
		redirect '/', flash[:notice] = 'Note created successfully.'
	else
		redirect '/', flash[:error] = 'Failed to save your note.'
	end
end

get '/:id' do
	@note = Note.get params[:id]
	@title = "Edit note ##{params[:id]}"
	if @note
		erb :edit
	else	
		redirect '/', flash[:error] = "Can't find that note."
	end
end

put '/:id' do
	note = Note.get params[:id]
	unless note
		redirect '/', flash[:error] = "Can't find that note."
	end
	note.content = params[:content]
	note.complete = params[:complete] ? 1 : 0
	note.updated_at = Time.now
	if note.save
		redirect '/', flash[:notice] = 'Note updated successfully.'
	else
		redirect '/', flash[:error] = 'Error updating your note.'
	end
end

get '/:id/delete' do
	@note = Note.get params[:id]
	@title = "Confirm deletion of note ##{params[:id]}"
	if @note
		erb :delete
	else 
		redirect '/', flash[:error] = "Can't find that note."
	end
end

delete '/:id' do
	note = Note.get params[:id]
	if note.destroy
		redirect '/', flash[:notice] = 'Note deleted successfully.'
	else
		redirect '/', flash[:error] = 'Error deleting your note.'
	end
end

get '/:id/complete' do
	note = Note.get params[:id]
	unless note
		redirect '/', flash[:error] = "Can't find that note."
	end
	note.complete = note.complete ? 0 : 1
	note.updated_at = Time.now
	if note.save
		redirect '/', flash[:notice] = 'Note marked as complete.'
	else
		redirect '/', flash[:error] = 'Error marking your note as complete.'
	end
end
