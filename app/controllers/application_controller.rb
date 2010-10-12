# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  layout 'application'
  helper :all # include all helpers, all the time
  #protect_from_forgery # See ActionController::RequestForgeryProtection for details
  #include AuthenticatedSystem
  before_filter :parse_after
  before_filter :parse_json
  before_filter :parse_date_time
  before_filter { javascript; stylesheet; true }

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password
  #def verify_authenticity_token
    #TODO ...
  #  logged_in_basic? || verified_request? || raise(ActionController::InvalidAuthenticityToken)
  #end

  helper_method :current_account, :current_path
    
private  
  def current_account_session  
    return @current_account_session if defined?(@current_account_session)  
    @current_account_session = AccountSession.find  
  end  

  def current_account  
    @current_account = current_account_session && current_account_session.record  
  end

  def current_path
    request.path
  end
  
  def parse_after
    @after = Time.at(params[:after].to_i).utc rescue nil if params.has_key? :after
  end

  def parse_date_time
    parse_date_time_rec(params)
  end

  PA = { "datetime" => "%d.%m.%Y %H:%M", "date" => "%d.%m.%Y", "time" => "%H:%M" }
  SE = { "datetime" => {:min => "5i", :hour => "4i", :day => "3i", :month => "2i", :year => "1i"},
         "date" => {:day => "3i", :month => "2i", :year => "1i"},
         "time" => {:min => "5i", :hour => "4i"}}
  
  def parse_date_time_rec(h)
    h.each do |k, v|
      if v.is_a?(Hash)
        parse_date_time_rec(v)
      elsif v.is_a?(String) && m = k.to_s.match(/^(.*)_parse_(datetime|date|time)$/)
        p m
        p PA[m[2]].gsub(/(%d|%m|%H|%M)/, "\\d{2}").gsub(/%Y/, "\\d{4}")
        h.delete(k)
        if v =~ Regexp.new(PA[m[2]].gsub(/(%d|%m|%H|%M)/, "\\d{2}").gsub(/%Y/, "\\d{4}"))
          d = DateTime.strptime(v, PA[m[2]])
          p d
          p SE[m[2]]
          SE[m[2]].each do |k,v|
            h["#{m[1]}(#{v})".to_sym] = d.send(k).to_s
          end
        else
          SE[m[2]].each do |k,v|
            h["#{m[1]}(#{v})".to_sym] = ''
          end
        end
      end
    end
  end
  
  def parse_json
    if params[:json]
      params.each do |k, v|
        if m = k.to_s.match(/(.*)_json/)
          params[m[1].to_sym] = parse_json_dates(ActiveSupport::JSON.decode(v))
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
    elsif obj.is_a?(String) && obj =~ /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(\+\d{2}:\d{2}|Z)$/
      if obj =~ /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\+\d{2}:\d{2}$/
        DateTime.strptime(obj, "%Y-%m-%dT%H:%M:%S%z")
      else
        DateTime.strptime(obj, "%Y-%m-%dT%H:%M:%SZ")
      end
    else
      obj
    end
  end

  def self.javascript(*args)
    @include_javascript_files ||= []
    @include_javascript_files += args.map { |f| f.to_s }
    @include_javascript_files.uniq
  end

  def javascript(*args)
    @include_javascript_files ||= self.class.javascript
    @include_javascript_files += args.map { |f| f.to_s }
    @include_javascript_files.uniq
  end
  
  def self.stylesheet(*args)
    @include_stylesheet_files ||= []
    @include_stylesheet_files += args.map { |f| f.to_s }
    @include_stylesheet_files.uniq
  end

  def stylesheet(*args)
    @include_stylesheet_files ||= self.class.stylesheet
    @include_stylesheet_files += args.map { |f| f.to_s }
    @include_stylesheet_files.uniq
  end
  
  #def user_for_paper_trail
  #  logged_in? ? current_account.id : nil
  #end
  
  def model_by_id    
    eval "@model = @#{model_name.underscore} = #{model_class}.find(params[:id])"
  end
  
  def model_all
    eval "@models = @#{model_name.pluralize.underscore} = #{model_class}.order()"
  end
  
  def model_all_or_after
    if @after.nil?
      model_all
    else
      eval "@models = @#{model_name.pluralize.underscore} = #{model_class}.where(['updated_at > ?', @after])"      
    end
  end
  
  def model_new
    eval "@model = @#{model_name.underscore} = #{model_class}.new(params[:#{model_name.underscore}])"
  end
  
  def model_name
    @model_name = self.class.name.gsub("Controller", "").singularize
  end
  
  def model_class
    model_name.constantize
  end
end
