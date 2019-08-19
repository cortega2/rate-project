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
    Time.new(2000, 1, 1, hour, min, 0, tz).utc
  end

  def self.replace_all(rates)
    Rate.delete_all
    rates.each { | r | r.save }
  end

  def self.by_times(start_time, end_time)
    day_keys = ["sun", "mon", "tues", "wed", "thurs", "fri", "sat"]
    day_key = start_time ? day_keys[start_time.wday] : end_time ? day_keys[end_time.wday] : nil

    # because of the way we are storing the time (2000 1 1) we need to
    # account for day light savings
    start_offset = start_time ? (start_time.dst? == true ? 1 : 0) : nil
    end_offset = end_time ? (end_time.dst? == true ? 1 : 0) : nil

    adj_start_time = start_time ? Time.new(2000, 1, 1, start_time.hour + start_offset, start_time.min, 0, start_time.utc_offset).utc : nil
    adj_end_time = end_time ? Time.new(2000, 1, 1, end_time.hour + end_offset, end_time.min, 0, end_time.utc_offset).utc : nil

    if adj_start_time && adj_end_time
      return Rate.order(:price, :start, :end, :timezone).where(["start <= ? AND end >= ? AND day_key = ?", adj_start_time, adj_end_time, day_key]).to_a
    elsif adj_start_time
      return Rate.order(:price, :start, :end, :timezone).where(["start <= ? AND day_key = ?", adj_start_time, day_key]).to_a
    elsif adj_end_time
      return Rate.order(:price, :start, :end, :timezone).where(["end >= ? AND day_key = ?", adj_end_time, day_key]).to_a
    else
      return Rate.order(:price, :start, :end, :timezone).to_a
    end
  end


  def valid_day_key
    day_keys = ["mon", "tues", "wed", "thurs", "fri", "sat", "sun"]
    if !day_keys.include?(self.day_key)
      errors.add(:day_key, "has to be a valid key")
    end
  end
end
