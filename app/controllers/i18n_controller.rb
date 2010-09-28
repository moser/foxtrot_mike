class I18nController < ApplicationController
  def index
    @translations = flatn(I18n.backend.instance_values['translations'][I18n.locale])
    respond_to do |format|
      format.js
    end
  end

  def flatn(h, r = nil, scope = '')
    r = {} if r.nil?
    h.each do |k,v|
      k = "#{scope}.#{k}".gsub(/^\./, '')
      if v.is_a?(Hash)
        flatn(v, r, k)
      else
        r[k] = v
      end
    end
    r
  end
end
