require 'json'

module Tempest
  class Function
    include Tempest

    class Call
      def initialize(name, args)
        @name = name
        @args = args
      end

      def to_s
        JSON.generate(self.fragment_ref)
      end

      def fragment_ref
        { @name => Util.compile(@args) }
      end
    end

    def initialize(name, arity)
      @name  = name
      @arity = arity
    end

    def call(*args)
      if args.size != @arity
        raise "Function #{@name} expects #{@arity} arguments"
      end

      if @arity == 1
        Call.new(@name, args.first)
      else
        Call.new(@name, args)
      end
    end
  end

  If        = Function.new('Fn::If',        3)
  Join      = Function.new('Fn::Join',      2)
  Equals    = Function.new('Fn::Equals',    2)
  Base64    = Function.new('Fn::Base64',    1)
  FindInMap = Function.new('Fn::FindInMap', 3)
end
