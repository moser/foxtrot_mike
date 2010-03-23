# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  include AuthenticatedSystem
  before_filter :parse_after

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password
  def verify_authenticity_token
    logged_in_basic? || verified_request? || raise(ActionController::InvalidAuthenticityToken)
  end
  
  def parse_after
    @after = Time.at(params[:after].to_i).utc rescue nil if params.has_key? :after
  end
end
