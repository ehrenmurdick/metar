require 'rubygems'

require 'mechanize'

require 'sinatra'


get "/:airport" do
  addy = "http://aviationweather.gov/adds/metars/"
  mech = ::Mechanize.new { |agent| agent.user_agent_alias = 'Mac Safari' }
  result = nil
  mech.get(addy) do |page|
    result = page.form_with(:action => "/adds/metars/index.php") do |form|
      form.station_ids = params[:airport]
    end.submit

  end

  content_type "text/plain"
  result.parser.css('font').map {|f| f.text }.join("\n\n")
end

