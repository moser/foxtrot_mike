class PdfsController < ApplicationController
  def show
    pdf_name = File.join(RAILS_ROOT, 'tmp', "#{params[:id]}.pdf")
    send_file pdf_name, :filename => "#{(params[:name] || 'document')}.pdf",  :type => 'application/pdf'
    FileUtils.rm pdf_name
  end

  def create
    name = rand(999999999).to_s
    html_name = File.join(RAILS_ROOT, 'tmp', "#{name}.html")
    pdf_name = File.join(RAILS_ROOT, 'tmp', "#{name}.pdf")
    html = File.new(html_name, 'w')
    html.write(params[:html])
    html.close
    `prince --baseurl="http://#{request.host_with_port}" #{html_name} -o #{pdf_name}`
    FileUtils.rm html_name
    render :text => pdf_path(name)
  end
end
