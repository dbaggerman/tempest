module Tempest
  class Condition
    class Ref
      include Tempest::BaseRef
      RefClass = Tempest::Condition
      RefType  = 'parameter'
      RefKey   = 'parameters'

      def compile_reference
        raise Tempest::Error.new("Cannot reference a Condition directly. Use #if")
      end

      def compile_definition
        raise ref_missing if @ref.nil?
        @ref.fragment_declare
      end
      alias :compile_declaration :compile_definition

      def equals(x, y)
        create(Function::Equals.call(x, y))
      end

      def if(t, f)
        @referenced = true
        Function::If.call(@name, t, f)
      end
    end

    def initialize(tmpl, name, body)
      @tmpl = tmpl
      @name = name
      @body = body
    end

    def fragment_declare
      Tempest::Util.compile(@body)
    end

    def fragment_ref
      raise Tempest::Error.new("Cannot reference condition directly. Use #if")
    end

    def if(t, f)
      Function::If.call(@name, t, f)
    end
  end
end
