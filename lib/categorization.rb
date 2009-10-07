# TODO: when the sequel move is complete, this join model is probably useless.
class Categorization < Sequel::Model
  many_to_one :category
  many_to_one :racer
end
