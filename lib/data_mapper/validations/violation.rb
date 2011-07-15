require 'forwardable'

module DataMapper
  module Validations

    class Violation

      attr_reader :resource
      attr_reader :custom_message
      attr_reader :rule
      attr_writer :attribute_name

      def initialize(resource, message = nil, rule = nil, attribute_name = nil)
        unless message || rule
          raise ArgumentError, "expected +message+ or +rule+"
        end

        @resource       = resource
        @rule           = rule
        @attribute_name = attribute_name
        @custom_message = evaluate_message(message)
      end

      # @api public
      def message(transformer = Undefined)
        return @custom_message if @custom_message

        transformer = Undefined == transformer ? self.transformer : transformer

        transformer.transform(self)
      end

      # @api public
      alias_method :to_s, :message

      # @api public
      def attribute_name
        if @attribute_name
          @attribute_name
        elsif rule
          rule.attribute_name
        end
      end

      # @api public
      def violation_type
        rule ? rule.violation_type(resource) : nil
      end

      # @api public
      def violation_data
        rule ? rule.violation_data(resource) : nil
      end

      def transformer
        if resource.respond_to?(:model) && transformer = resource.model.validators.transformer
          transformer
        else
          ValidationErrors.default_transformer
        end
      end

      def evaluate_message(message)
        if message.respond_to?(:call)
          if resource.respond_to?(:model) && resource.model.respond_to?(:properties)
            property = resource.model.properties[attribute_name]
            message.call(resource, property)
          else
            message.call(resource)
          end
        else
          message
        end
      end

      # In general we want Equalizer-type equality/equivalence,
      # but this allows direct equivalency test against Strings, which is handy
      def ==(other)
        if other.respond_to?(:to_str)
          self.to_s == other.to_str
        else
          super
        end
      end

      module Equalization
        extend Equalizer

        EQUALIZE_ON = [:resource, :rule, :custom_message, :attribute_name]

        equalize *EQUALIZE_ON

        def inspect
          out = "#<#{self.class.name}"
          self.class::Equalization::EQUALIZE_ON.each do |ivar|
            value = send(ivar)
            out << " @#{ivar}=#{value.inspect}"
          end
          out << ">"
        end
      end
      include Equalization

    end # class Violation

  end # module Validations
end # module DataMapper
