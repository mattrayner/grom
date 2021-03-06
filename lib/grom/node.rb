module Grom
  class Node
    attr_reader :statements

    def initialize(statements)
      @statements = statements

      populate
    end

    def method_missing(method, *params, &block)
      instance_variable_get("@#{method}".to_sym) || super
    end

    def respond_to_missing?(method, include_private = false)
      instance_variable_get("@#{method}".to_sym) || super
    end

    private

    def populate
      @statements.each do |statement|
        attribute_name = Grom::Helper.get_id(statement.predicate)
        attribute_value = statement.object.to_s
        instance_variable_set("@#{attribute_name}".to_sym, attribute_value)
      end
    end
  end
end
