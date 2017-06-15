module QueryToFilterQuery
  extend self
    # { "amount.$gte": 100 }
    # to
    # { :amount.gte => 100 }

    # { age: 28, name: "" }
    # to
    # { age: 28 }

  def run(query = {})
    filter_query = {}
    query.each do |key, value|
      new_key = to_mongoid_criteria_queryable_key(key)
      filter_query[new_key] = value
    end
    filter_query = filter_query.select{ |key,value| value != "" }
  end

  def to_mongoid_criteria_queryable_key(hash_key = "")
    if custom_filter?(hash_key)
      name, operator = hash_key.to_s.split(operator_prefix)
      name.to_sym.send(operator)
    else
      hash_key
    end
  end

  def custom_filter?(hash_key)
    if hash_key.is_a?(String) || hash_key.is_a?(Symbol)
      mongoid_filter_operators.any?{ |operator| hash_key.to_s.include?("#{operator_prefix}#{operator}") }
    else
      false
    end
  end

  def operator_prefix
    "__"
  end

  def mongoid_filter_operators
    %W[ gte lte in with_size ]
  end

end

class Hash
  def to_filter_query
    QueryToFilterQuery.run(self)
  end
end

module Mongoid
  module Filters
    extend ActiveSupport::Concern

    module ClassMethods
      def filter(query = {})
        filter_query = QueryToFilterQuery.run(query)
        where(filter_query)
      end
    end

  end
end