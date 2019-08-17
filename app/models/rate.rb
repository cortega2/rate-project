require 'tzinfo'
class Rate < ApplicationRecord
  validates_presence_of :day_key, :price, :start, :end, :timezone
  validates :price, numericality: { greater_than: 0 }
  validate :valid_day_key

  def self.new_from_group(rate_group)
    price = rate_group[:price]
    start_time = create_time(rate_group[:times].split("-")[0], rate_group[:tz])
    end_time = create_time(rate_group[:times].split("-")[1], rate_group[:tz])
    timezone = rate_group[:tz]

    rates = []
    rate_group[:days] = rate_group[:days].split(",")
    rate_group[:days].each do | day_key |
      day_key.strip!
      params = { day_key: day_key, price: price, start: start_time, end: end_time, timezone: timezone }
      rate = Rate.new(params)

      if rate.valid?
        rates << rate
      else
        return {rates: rates, error: true}
      end
    end

    return {rates: rates, error: false}
  end

  # Since we only care about the time field
  # we can use any date in this case it is Jan 1 2000
  def self.create_time(time_string, timezone)
    tz = TZInfo::Timezone.get(timezone)
    hour = time_string[0...2].to_i
    min = time_string[2..4].to_i
    Time.new(2000, 1, 1, hour, min, 0, tz)
  end

  def self.replace_all(rates)
    Rate.delete_all
    rates.each { | r | r.save }
  end


  def valid_day_key
    day_keys = ["mon", "tues", "wed", "thurs", "fri", "sat", "sun"]
    if !day_keys.include?(self.day_key)
      errors.add(:day_key, "has to be a valid key")
    end
  end
end
