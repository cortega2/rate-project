require 'structure_validator'

class RatesController < ApplicationController
  # GET /rates
  def index
    @rates = Rate.order(:price, :start, :end, :timezone).to_a

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

    formatted_groups = []
    groups.each do | group |
      formatted_groups << StructureValidator.restructure(group)
    end

    render json: {rates: formatted_groups}
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

end
