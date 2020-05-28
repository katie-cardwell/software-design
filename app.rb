# Set up for the application and database. DO NOT CHANGE. #############################
require "sinatra"                                                                     #
require "sinatra/reloader" if development?                                            #
require "sequel"                                                                      #
require "logger"                                                                      #
connection_string = ENV['DATABASE_URL'] || "sqlite://#{Dir.pwd}/development.sqlite3"  #
DB ||= Sequel.connect(connection_string)                                              #
DB.loggers << Logger.new($stdout) unless DB.loggers.size > 0                          #
def view(template); erb template.to_sym; end                                          #
use Rack::Session::Cookie, key: 'rack.session', path: '/', secret: 'secret'           #
before { puts "Parameters: #{params}" }                                               #
after { puts; }                                                                       #
#######################################################################################

events_table = DB.from(:events)
rsvps_table = DB.from(:rsvps)

get "/" do
  @events = events_table.all
  # taking this events table and assigning it to a variable called events (events_table.all is the ruby code for SELECT * FROM events and returning to us as an array of hashes)
  puts @events.inspect
  # this is then showing me what lives inside of the events variable .. it's an array of hashes (brackets tell you) each reps a row 
  view "events"
end

# creating the individual event urls
get "/events:id" do
    # SELECT * FROM events WHERE id=:id is what we really want to do, to grab that url and get the relevant info out of the database. type as:
    @event = events_table.where(:id => params["id"]).to_a[0]
    # above gets you to return the events with the id that matches the id typed into the url by user (ie params hash)
    @rsvps = rsvps_table.where(:event_id => params["id"]).to_a
        # above, we want all of the values because there could be multiple rsvps for one event and we want all of those, vs. event with [0
        # we need to include the zero after the event definition because it expects event to be a hash, not an array, so we want to just pick out the first
        # so if your variable name is singular, include the zero at the end. if plural, don't
    # To get the total rsvps count.  In SQL we would do: SELECT COUNT(*) FROM rsvps WHERE event_id=:id AND going=1
    @count = rsvps_table.where(:event_id => params["id"], :going => true).count
    
    puts @event.inspect
    puts @rsvps.inspect
    # above will report back what the actual event id, report back the dynamic part of the url
    view "event"
end

get "events/:id/rsvps/new" do
    @event = events_table.where(:id => params["id"]).to_a[0]
    # need to have the code for @event again because it's a new url vs. above.  only runs the code under this url
    puts @event.inspect
    view "new_rsvp"
    # new_rsvp contains the bootstrap form
end

get "/events/:id/rsvps/create" do
    # have to do something to actually create those rsvps in the database here
    # first step, params inspect returns the info they filled out in the form into the area below for inspection. now how to insert into database
    # same way we inserted into events table, but look at createdb and see what fields are in rsvp table
    puts params.inspect
    rsvps_table.insert(:event_id => params["id"],
                      :going => params["going"],
                      :name => params["name"],
                      :email => params["email"],
                      :comments => params["comments"])
    view "create_rsvp"
end


# get "/tacos" do
#    view "tacos"
# end

