
module Loquacious

  #
  #
  class Help

    # :stopdoc:
    class Error < StandardError; end
    # :startdoc:

    def initialize( config )
      @config = config
      @iterator = Iterator.new config
    end

    attr_reader :config, :iterator

    def describe( var = nil )
      var = case var
        when String, nil; var
        when Array;  var.join('.')
        else raise 'what again?' end
      h = Hash.new

      iterator.each(var) {|n| h[n.name] = n.desc}
      return h
    end

    private

    def describe_node( cfg, var )
      h = Hash.new

      name = var.join('.')
      n = node_for(cfg, var)
      h[name] = n.desc

      if n.config?
        h.merge! describe_all(n.obj, name)
      end

      return h
    rescue Error
      raise Error, "unknown configuration attribute '#{name}'"
    end

    def describe_all( cfg, pre = nil )
      h = Hash.new

      cfg.__desc.keys.each do |key|
        n = Node.new key, cfg[key], cfg
        name = [pre, key].compact.join('.')
        h[name] = n.desc

        if n.config?
          h.merge! describe_all(n.obj, name)
        end
      end

      return h
    end

    def node_for( cfg, ary )
      ary = ary.dup
      key = ary.pop
      cfg = ary.inject(cfg) do |c,k|
        raise Error unless c.__desc.has_key? k
        c.__send__(k)
      end
      raise Error unless cfg.__desc.has_key? key

      Node.new key, cfg[key], cfg
    end

    Node = Struct.new( :key, :desc, :cfg ) {
      def obj() @obj ||= cfg.__send__(key); end
      def config?() obj.kind_of? Configuration; end
    }

  end  # class Help
end  # module Loquacious

# EOF
