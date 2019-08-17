require 'tzinfo'
require 'hash_validator'

module StructureValidator
  def self.all_valid?(group)
    self.structure?(group) && self.timezone?(group[:tz]) && self.times?(group[:times]) && self.has_days?(group[:days])
  end

  def self.structure?(group)
    validations = {
      days: 'string',
      times: 'string',
      tz: 'string',
      price: 'numeric'
    }

    HashValidator.validate(group, validations).valid?
  end

  def self.timezone?(tz)
    TZInfo::Timezone.all_identifiers.include?(tz)
  end

  def self.times?(times)
    times.match(/^\d{4}-\d{4}\z/) != nil
  end

  def self.has_days?(days)
    days.length > 0
  end

  # given an array of rates that have the same price, times, and time zone, restructure them
  def self.restructure(rates)
    start_time = rates[0][:start].in_time_zone(rates[0][:timezone])
    end_time = rates[0][:end].in_time_zone(rates[0][:timezone])
    formatted = {
      days: [],
      times: start_time.strftime("%H%M") + "-" + end_time.strftime("%H%M"),
      tz: rates[0][:timezone],
      price: rates[0][:price]
    }

    rates.each do | rate |
      formatted[:days] << rate[:day_key]
    end

    formatted[:days] = formatted[:days].join(',')

    return formatted
  end
end
