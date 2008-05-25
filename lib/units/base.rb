class UnitsError < StandardError #:nodoc:
end

module Units
  attr_reader :unit, :kind
  alias :units :unit
  
  # The heart of unit conversion, it will handle methods like: to_seconds and cast the number accordingly.
  def method_missing(symbol, *args)
    symbol = symbol.to_s.sub(/^to_/,'').intern if symbol.to_s =~ /^to_.+/
    
    to_kind, to_unit = lookup_unit(symbol)
    
    # If there is a kind and this is conversion and the aliases include the provided symbol, convert
    if to_kind && to_unit && self.class.all_unit_aliases(to_kind).include?(symbol)
      from_unit = (@unit || to_unit)
      from_kind = lookup_unit(from_unit).first

      if from_kind != to_kind
        raise UnitsError, "invalid conversion, cannot convert #{from_unit} (a #{from_kind}) to #{to_unit} (a #{to_kind})"

      else
        # The reason these numbers have to be floats instead of integers is that all similar integers are the same ones
        # in memory, so that @kind and @unit couldn't be different for different numbers
        case self.class.unit_conversions[to_kind]
          when Hash
            result = Float( self * self.class.unit_conversions[from_kind][from_unit] / self.class.unit_conversions[to_kind][to_unit] )
          when Symbol
            result = Float( self * send(self.class.unit_conversions[to_kind], from_unit, to_unit) )
        end        
      end
      
      result.instance_eval do
        @unit = to_unit
        @kind = to_kind
      end

      return result
    else
      super
    end
  end
  
  private
  
  # lookup a kind and base unit (like [:volume, :liters]) when you input :liter
  def lookup_unit(symbol)
    self.class.unit_conversions.keys.each do |kind|
      if Symbol === self.class.unit_conversions[kind]
        return kind, symbol if send(:"#{ self.class.unit_conversions[kind] }_include?", symbol)
      else
        if self.class.unit_conversions[kind].include? symbol
          return kind, symbol
        else
          s = self.class.unit_aliases[kind].find { |k,v| v.include? symbol }
          return kind, s[0] if s
        end
      end
    end
    return nil, nil
  end

  module ClassMethods #:nodoc:
    def unit_conversions()            @@unit_conversions            end
    def unit_aliases()                @@unit_aliases                end
    def add_unit_conversions(hash={}) unit_conversions.update(hash) end
    def add_unit_aliases(hash={})     unit_aliases.update(hash)     end

    def init_units
      @@unit_conversions = Hash.new
      @@unit_aliases = Hash.new
    end

    def all_unit_aliases(kind)
      results = Array.new
      results += @@unit_conversions[kind].keys rescue nil
      results += @@unit_aliases[kind].to_a.flatten rescue nil

      return results.uniq
    end
  end

  def self.append_features(base) #:nodoc:
    super
    base.extend ClassMethods
    base.init_units
  end
end

class Numeric
  include Units
end

class Float
  alias :add :+
  # Add only numbers that both have units or both don't have units
  def +(other)
    if Float === other && kind && other.kind
      add_with_units( unit == other.unit ? other : other.send(unit) )

    elsif Numeric === other && (kind || other.kind) && (kind.nil? || other.kind.nil?)
      raise UnitsError, "cannot add a number without units to one with units"

    else
      add other
    end
  end
  def add_with_units(other)
    add(other).send(unit)
  end
  
  alias :multiply :*
  # CURRENTLY: Scalar multiplication (a number with a unit to a number without a unit)
  # TO COME: Non-scalar multiplication
  # This will require keeping track of the exponents, like:
  #   meters is [:meters, 1], square inches is [:inches, 2], cubic mililiters is [:milileters, 3]
  # And then we can get rid of the silly :m3's in the volume conversion as well
  # as add new units like:
  #   :joules => [[:kilograms, 1], [:meters, 1], [:seconds, -2]]
  def *(other)
    if Numeric === other && kind && other.kind
      raise UnitsError, "currently cannot mutiply two numers with units, try scalar multiplication instead"

    elsif Numeric === other && kind.nil? && other.kind.nil?
      multiply other

    else
      multiply_with_units other
    end
  end
  def multiply_with_units(other)
    multiply(other).send(unit || other.unit)
  end
end

class Fixnum
  alias :add :+
  # Raise an error if the other number has a unit
  def +(other)
    if Numeric === other && other.kind
      raise UnitsError, "cannot add a number without units to one with units"

    else
      add other
    end
  end

  alias :multiply :*
  # Allow for scalar multiplication
  def *(other)
    if Numeric === other && other.kind
      multiply_with_units other

    else
      multiply other
    end
  end
  def multiply_with_units(other)
    multiply(other).send(unit || other.unit)
  end
end

class String
  alias :multiply :*
  # Cannot multiply a String by anything Numeric with units
  def *(other)
    if Numeric === other && other.kind
      raise UnitsError, "cannot multiply a String by anything Numeric with units"
    else
      multiply other
    end
  end
end