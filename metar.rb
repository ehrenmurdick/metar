require 'rubygems'
require 'sinatra'

configure do
  require 'mechanize'
  require 'memcached'

  CACHE = Memcached.new
end


get "/:airport" do
  break unless params[:airport] != ""

  content_type "text/plain"

  begin
    CACHE.get(params[:airport])
  rescue Memcached::NotFound
    addy = "http://aviationweather.gov/adds/metars/"

    mech = ::Mechanize.new { |agent| agent.user_agent_alias = 'Mac Safari' }
    result = nil
    mech.get(addy) do |page|
      result = page.form_with(:action => "/adds/metars/index.php") do |form|
        form.station_ids = params[:airport]
      end.submit
    end
    metar = result.parser.css('font').map {|f| f.text }.join("\n\n")
    CACHE.set(params[:airport], metar, 3600)
    metar
  end
end

