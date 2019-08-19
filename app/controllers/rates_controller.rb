require 'structure_validator'

class RatesController < ApplicationController
  include ActionController::MimeResponds

  before_action :check_query, only: :index
  # GET /rates
  def index
    @rates = Rate.by_times(@start_time, @end_time)

    groups = []
    group_idx = -1
    start_time = nil
    end_time = nil
    price = nil
    timezone = nil
    # seperate by price start and end
    @rates.each do | rate |
      if rate.start == start_time && rate.end == end_time && rate.price == price && rate.timezone == timezone
        groups[group_idx] << rate
      else
        group_idx += 1
        groups << [rate]
        start_time = rate.start
        end_time = rate.end
        price = rate.price
        timezone = rate.timezone
      end
    end

    respond_to do |format|
      format.json { render json: json_response(groups) }
      format.all { render plain: text_response(groups) }
    end
  end

  # POST /rates
  def create
    rates = JSON.parse(request.body.read).symbolize_keys[:rates]

    status = :created
    error = nil

    rates_to_save = []
    rates.each do | group |
      group.symbolize_keys!
      # basic error checking
      if !StructureValidator::all_valid?(group)
        status = :unprocessable_entity
        error = "The structure is incorrect"
        break
      end

      created_results = Rate.new_from_group(group)
      if created_results[:error]
        status = :unprocessable_entity
        error = "One or more fields are not valid"
        break
      else
        rates_to_save = rates_to_save + created_results[:rates]
      end
    end

    if !error
      Rate.replace_all(rates_to_save)
    end

    render json: {error: error}, status: status
  end

  private
  def check_query
    @start_time = params[:start]
    @end_time = params[:end]

    @range = false

    if @start_time
      @start_time = Time.parse(@start_time)
    end

    if @end_time
      @end_time = Time.parse(@end_time)
    end

    if @start_time && @end_time
     @range = true
    end

    if @range && !(@start_time.to_date === @end_time.to_date)
      error = "Range cannot spand more than a day"
      status =  :unprocessable_entity

      respond_to do |format|
        format.json { render json: {error: error}, status: status}
        format.all { render plain: error, status: status }
      end
    end
  end

  def text_response(data)
    # the documentation didnt make it clear
    # if a rates can overlap, so this check makes sure that
    # if this does happen we simply return nothing
    if @range && data.length > 1
      return "Unavaliable"
    end

    prices = []
    data.each do | group |
      prices << group[0][:price]
    end

    return prices.length == 0 ? "Unavailable" : prices.join(",")
  end

  def json_response(data)
    # the documentation didnt make it clear
    # if a rates can overlap, so this check makes sure that
    # if this does happen we simply return nothing
    if @range && data.length > 1
      return { rates: [] }
    end

    formatted_groups = []
    data.each do | group |
      formatted_groups << StructureValidator.restructure(group)
    end

    return { rates: formatted_groups }
  end
end
