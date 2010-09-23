module Enumerable
  def second
    self[1]
  end

  def third
    self[2]
  end

  def fourth
    self[3]
  end
end

class Array
  alias :shift_without_args :shift

  def shift(number_of_items = nil)
    if number_of_items
      collection = []
      number_of_items.times do |i|
        collection << shift_without_args
      end
      collection
    else
      shift_without_args
    end
  end
end

class Numeric
  def to_minutes_seconds_string
    [self/60 % 60, self % 60].map{|t| t.to_s.rjust(2,'0')}.join(':')
  end
end

module Subclasses
  # return a list of the subclasses of a class
  def subclasses(direct = false)
    classes = []
    if direct
      ObjectSpace.each_object(Class) do |c|
        next unless c.superclass == self
        classes << c
      end
    else
      ObjectSpace.each_object(Class) do |c|
        next unless c.ancestors.include?(self) and (c != self)
        classes << c
      end
    end
    classes
  end
end

Object.send(:include, Subclasses)

class Integer
  def ordinal
    to_s + ([[nil, 'st','nd','rd'],[]][self / 10 == 1 && 1 || 0][self % 10] || 'th')
  end
end
