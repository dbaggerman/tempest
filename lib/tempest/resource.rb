module Tempest
  class Resource
    include Tempest

    class Ref
      include Tempest::BaseRef

      RefClass = Tempest::Resource
      RefType  = 'resource'
      RefKey   = 'resources'

      def att(*key)
        key = key.map {|k| Util.mk_id(k) }.join('.')
        Function.new('Fn::GetAtt', @name, key)
      end
    end

    attr_accessor :name, :type, :tmpl

    def initialize(tmpl, name, type, properties)
      @name       = name
      @tmpl       = tmpl
      @type       = type
      @properties = properties
      @depends_on = []
    end

    def compile
      hash = { 'Type' => @type }
      unless @depends_on.empty?
        hash['DependsOn'] = Tempest::Util.compile(@depends_on.uniq)
      end
      unless @properties.empty?
        hash['Properties'] = Tempest::Util.compile(@properties)
      end
      hash
    end
  end
end
