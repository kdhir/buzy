class StaticPagesController < ApplicationController
  include ApplicationHelper
  
  def home
  	update_scores
    file = File.open(File.join(Rails.root, 'app', 'assets', 'json', 'locations.json')).read
    json = JSON.parse(file)
    @center_coords = json.find{|p| p['name'] == 'CENTER'}['location'].gsub(" ","").split(",")
    if params[:search]
      @places = Place.search(params[:search])
      @search_term = params[:search]
    else
      @places = Place.ordered_by_popularity
    end
  end

  def map
  	update_scores
  	file = File.open(File.join(Rails.root, 'app', 'assets', 'json', 'locations.json')).read
  	json = JSON.parse(file)
  	@center_coords = json.find{|p| p['name'] == 'CENTER'}['location'].gsub(" ","").split(",")
  	selection = Place.where.not(location: nil).select{|p| p.location != ""} # find all the actual places
  	@addresses = selection.map{|p| p.location.gsub(" ","").split(",")} # 2d array of [lat,long]
  	@scores = selection.map{|p| p.prediction}
  	@names = selection.map{|p| p.name}
  	render 'map'
  end

  def contact
  end

end
