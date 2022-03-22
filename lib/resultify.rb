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
    def resultify(*method_names)
      method_names.each do |method|
        alias_method "old_#{method}".to_sym, method.to_sym

        define_method(method) do |*args, &block|
          begin
            ret_val = self.send("old_#{method}", *args)
            return Result.new(ret_val, nil)
          rescue Exception => e
            return Result.new(nil, e)
          end
        end
      end
    end
  end

  def self.included(base)
    base.extend(ClassMethods)
  end
end
