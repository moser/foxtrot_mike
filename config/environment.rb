# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Server::Application.initialize!

Mime::Type.register "text/plain", :txt
Mime::Type.register "text/dtaus", :dtaus
