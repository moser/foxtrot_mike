class DateTime
  def to_i
    u = self.utc
    Time.utc(u.year, u.month, u.day, u.hour, u.min, u.sec, 0).to_i
  end
end

class Date
  def week
    cweek
  end
  
  def prev_week
    self - 7.days
  end
  
  def prev_day
    self - 1.days
  end
end

class String
  # Calculates the Levenshtein distance of two strings
  # http://www.dcs.shef.ac.uk/~sam/stringmetrics.html#Levenshtein
  # The calculation is not case sensitive.
  def distance(str2)
    str1 = self.downcase
    str2 = str2.downcase
    if $KCODE =~ /^U/i
      unpack_rule = 'U*'
    else
      unpack_rule = 'C*'
    end
    s = str1.unpack(unpack_rule)
    t = str2.unpack(unpack_rule)
    n = s.length
    m = t.length
    return m if (0 == n)
    return n if (0 == m)
  
    d = (0..m).to_a
    x = nil

    (0...n).each do |i|
      e = i+1
      (0...m).each do |j|
        cost = (s[i] == t[j]) ? 0 : 1
        x = [
          d[j+1] + 1, # insertion
          e + 1,      # deletion
          d[j] + cost # substitution
        ].min
        d[j] = e
        e = x
      end
      d[m] = x
    end

    return x
  end
end

class ActiveRecord::Base
  def self.l(sym = nil)
    if sym.nil?
      model_name.human
    else
      human_attribute_name(sym)
    end
  end
end

class Array
  # Returns a Hash. The given block is called with any element, the returns are used as 
  # the keys in the hash.
  #  a = Date.parse("2010-09-01")
  #  b = Date.parse("2010-10-01")
  #  [a, b].group_by(&:year) # => {2010 => [a, b]}
  #  [a, b].group_by { |d| d.month } # => {9 => [a], 10 => [b]}
  def group_by(&block)
    keys = self.map(&block).flatten.uniq #.reject(&:'nil?')
    Hash[
      keys.map do |k|
        [k, self.select { |e| v = block.call(e); v.is_a?(Array) ? v.include?(k) : v == k }]
      end
    ]
  end
end
