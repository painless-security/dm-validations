# -*- encoding: utf-8 -*-

require 'data_mapper/validations/rule'

module DataMapper
  module Validations
    class Rule

      class Method < Rule

        EQUALIZE_ON = superclass::EQUALIZE_ON.dup << :method

        equalize *EQUALIZE_ON

        attr_reader :method

        def initialize(attribute_name, options={})
          @method = options.fetch(:method, attribute_name)

          super
        end

        def validate(resource)
          result, error_message = resource.__send__(method)

          if result
            nil
          else
            Violation.new(resource, error_message, self)
          end
        end

        def call(resource)
          result, error_message = resource.__send__(method)
          add_error(resource, error_message, attribute_name) unless result
          result
        end

      end # class Method

    end # class Rule
  end # module Validations
end # module DataMapper
