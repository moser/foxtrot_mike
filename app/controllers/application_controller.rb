# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  #protect_from_forgery # See ActionController::RequestForgeryProtection for details
  include AuthenticatedSystem
  before_filter :parse_after
  before_filter :parse_json

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password
  def verify_authenticity_token
    #TODO ...
    logged_in_basic? || verified_request? || raise(ActionController::InvalidAuthenticityToken)
  end
  
  def parse_after
    @after = Time.at(params[:after].to_i).utc rescue nil if params.has_key? :after
  end
  
  def parse_json
    if params[:json]
      params.each do |k, v|
        if m = k.to_s.match(/(.*)_json/)
          params[m[1].to_sym] = parse_json_dates(JSON.parse(v))
        end
      end
    end
  end
  
  def parse_json_dates(obj)
   if obj.is_a?(Hash)
      obj.keys.each do |k|
        obj[k] = parse_json_dates(obj[k])
      end
      obj
    elsif obj.is_a?(Array)
      obj.map { |e| parse_json_dates(e) }
    elsif obj.is_a?(String) && obj =~ /^\d{4}\/\d{2}\/\d{2} \d{2}:\d{2}:\d{2} \+\d{4}$/
      DateTime.strptime(obj, "%Y/%m/%d %H:%M:%S")
    else
      obj
    end
  end
end
