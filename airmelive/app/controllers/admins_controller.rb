=begin
	creates an event.
	autopublishes the event creation into facebook.
	edits the event.
	lists the whole events.
=end

class AdminsController < ApplicationController	

=begin
	input : nil
	output : @event
	creates a new object of Event.
=end	

	def index
		@event = Event.new
	end

=begin
	input : @event
	output : nil
	creates an event and autopublishes into facebook.
=end

	def create
		@event = Event.new(event_params)
		event_save = @event.save
		if event_save
			loc = @event.avatar.url
			location = loc.partition("?")
			
			#connecting with AWS cloud
			connection = Fog::Storage.new({
 		    :provider                 => 'AWS',
    		:aws_access_key_id        => 'AKIAIS7NMF5PS3DYZRJQ',
    		:aws_secret_access_key    => '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',
			})
			directory = connection.directories.create(
    			:key    => "airmelive",
    			:public => true
			)
			p connection.directories
			@file = directory.files.create(
				:key    =>  @event.avatar_file_name,
				:body   => File.open(Rails.root.to_s+ "/public"+location[0]),
				:public => true
			)
			p @file.public_url
			logger.info @file.public_url
			
			#autopublishing into facebook
			owner = FbGraph::User.me("CAADLVlmd6d4BAJ8EZBrZC9lcxQvf945umxZCIocJuHXTMO3HZB37WPdogBeWhoeUBnqE8297z32f6Dbkx3DakntN6qdTMP96Uqob67WkdKRkxF6RN7CQiYvVmGxP6akkZAoaiDhuyWnExa91HEQ8ZA3eZAUZCYafEpFeLRntT1ospyDdg7G4gBjjbCcGpZCJv2RUZD")
    	pages = owner.accounts
	    page = pages.detect do |page|
	      page.identifier == "271138649706896"
	   	end
	   	page.feed!(
	    	:message => 'AirMeLive',
		  	:picture => @file.public_url,
		  	:link => 'http://10.6.0.64:4567/upcomingevents/'+ @event.id.to_s+'/show',
		  	:name => params[:event][:eventname],
		  	:description => params[:event][:description]
			)
		else
			err_msg = @event.errors.full_messages
		end
		redirect_to admins_path, :notice => err_msg
	end

=begin 
	input : nil
	output : @upcoming_events, @ongoing_events
	finds the upcoming and ongoing events.
=end	

	def show
		@event_list = Event.all
		@date_today = Date.today
		@upcoming_events = Event.where('registrationopen <= ? and registrationclose > ?',@date_today,@date_today)
		@ongoing_events = Event.where('eventopen <= ? and eventclose > ?',@date_today,@date_today)
	end

=begin
	input : nil
	output : @event_edit
	edits the event.
=end

	def edit
    	@event_edit = Event.find(params[:id])
  	end

=begin
	input : nil
	output : nil
	updates edited event details in the database.
=end    

	def update
    	x = Event.find(params[:id])
    	if x.update_attributes(event_params)
      		redirect_to show_path
    	else
      		render ('edit')
    	end
  	end
    
private
    def event_params
      params.require(:event).permit(:eventname, :category, :registrationopen, :registrationclose, :auditionopen, :auditionclose, :eventopen, :eventclose, :description, :rules,:avatar)
    end
end
