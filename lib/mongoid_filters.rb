module QueryToFilterQuery
  extend self
    # { "amount__gte": 100 }
    # to
    # { :amount.gte => 100 }

    # { "amount": 100, "name": "" }
    # to
    # { amount: 100 }

    # { "categories_ids": [""], amount: 28 }
    # to
    # { amount: 100 }

  def run(query = {})
    query ||= {}
    filter_query = {}
    query.each do |key, value|
      new_key, new_value = to_mongoid_criteria_queryable(key, value)
      filter_query[new_key] = new_value
    end
    filter_query = filter_query.select{ |key, value| !empty_value?(value) }
  end

  def to_mongoid_criteria_queryable(hash_key = "", value)
    if custom_filter?(hash_key, mongoid_filter_operators)
      name, operator = hash_key.to_s.split(operator_prefix)
      [name.to_sym.send(operator), value]
    elsif custom_filter?(hash_key, custom_filter_operators)
      name, operator = hash_key.to_s.split(operator_prefix)
      set_custom_filters(name, value, operator)
    else
      [hash_key, value]
    end
  end

  def custom_filter?(hash_key, opterators)
    if hash_key.is_a?(String) || hash_key.is_a?(Symbol)
      opterators.any?{ |operator| hash_key.to_s.include?("#{operator_prefix}#{operator}") }
    else
      false
    end
  end

  def set_custom_filters(key, value, operator)
    value = /#{build_regexp_accents(value)}/i if operator == "regexp" && !empty_value?(value)
    [key, value]
  end

  def operator_prefix
    "__"
  end

  def mongoid_filter_operators
    %W[ gte lte in with_size nin ]
  end

  def custom_filter_operators
    %W[ regexp ]
  end

  def build_regexp_accents(q = "")
    q ||= ""
    q.gsub(/(a|á)/i, "(a|á)")
     .gsub(/(e|é)/i, "(e|é)")
     .gsub(/(i|í)/i, "(i|í)")
     .gsub(/(o|ó)/i, "(o|ó)")
     .gsub(/(u|ú)/i, "(u|ú)")
  end

  def empty_value?(value)
    if value.is_a?(Array)
      value.reject{|v| v == ""}.blank?
    else
      value == ""
    end
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
