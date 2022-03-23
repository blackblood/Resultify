require "resultify/version"

module Resultify
  class Result
    attr_accessor :value, :err
    attr_reader :error_handler

    def initialize(ret_val, err)
      @value = ret_val
      @err = err
    end

    def error_handler=(f)
      @error_handler = f
      if @err != nil
        f.call(@err)
      end
    end

    def value
      if self.error_handler.is_a?(Proc)
        @value
      else
        raise "Define the error handler on this result object first"
      end
    end
  end

  module ClassMethods
    def overwrite_method(name)
      @@overwriting_method = true
      alias_method "old_#{name}".to_sym, name.to_sym
      define_method name do |*args, &block|
        begin
          old_method = self.class.instance_method("old_#{name}")
          ret_val = old_method.bind(self).call(*args, &block)
          return Result.new(ret_val, nil)
        rescue Exception => e
          return Result.new(nil, e)
        end
      end
      @@overwriting_method = false
    end

    def resultify(*method_names)
      @@method_names = method_names
      self.instance_methods(false).each do |mname|
        self.overwrite_method(mname) if @@method_names.include?(mname)
      end
      @@overwriting_method = false
    end

    def method_added(name)
      if defined?(@@method_names) && @@method_names.include?(name)
        return if defined?(@@overwriting_method) && @@overwriting_method
        self.overwrite_method(name)
      end
    end
  end

  def self.included(base)
    base.extend(ClassMethods)
  end
end
