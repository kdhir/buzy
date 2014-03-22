class PlacesController < ApplicationController

  def busyness_color(score)
    case score
      when 0..33
        @color = '#66CC00'
      when 34..66
        @color = '#FF9933'
      else
        @color = '#FF0000'
    end
    @color
  end

  def votes_to_count(time_ago)
    @place.votes.select {|vote| ((time_ago/60).round.hour.ago) < vote[:created_at] }
  end

  def score(votes) #unless a time_ago in minutes is passed, scores all votes

    now = Time.new
  
    total_time_ago = 0 
    votes.each do |vote| #total times ago
      total_time_ago += now - vote.created_at
    end
    
    @total = 0
    votes.each do |vote| #calc weighted average
      time_ago = (now-vote.created_at)
      @total += (vote.score*(time_ago/total_time_ago)).round
    end
    @total 
  end

  def new
  	@place = Place.new
  end

  def graphable_votes(votes)
    votes.map { |x| [x.created_at, x.score]}
  end

  def show
  	@place = Place.find(params[:id])
    @time_ago = params[:time_ago] ? params[:time_ago].to_i : 30
    unless @place.votes.blank?
      votes = @time_ago!=0 ? votes_to_count(@time_ago) : @places.votes
      @score = score(votes)
      @color = busyness_color(@score)
      @graphable  = graphable_votes(votes)
    end
  end

  def create

    if Place.where(:name => place_params[:name]).blank? #check if a place with that name exists
      @place = Place.new(place_params)
      if @place.save
        redirect_to @place
      else
        render 'new'
      end
    else
      @name = place_params[:name]
      render 'place_exists_with_name'
    end

  end

  def index
    @places = Place.all
  end

  private

    def place_params
      params.require(:place).permit(:name)
    end

end

