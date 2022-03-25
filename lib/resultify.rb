# require "resultify/version"

module Resultify
  class Result
    private
    attr_accessor :value, :err

    public
    attr_reader :error_handler
    attr_reader :value_handler

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

    def value_handler=(f)
      raise "Define error_handler = proc { |err| } before calling value_handler" if !@error_handler.is_a?(Proc)
      @result_handler = f
      if @err == nil
        f.call(@value)
      end
    end
  end

  class Option
    private
    attr_accessor :value

    public
    attr_reader :blank_handler
    attr_reader :value_handler

    def initialize(ret_val)
      @value = ret_val
    end

    def blank_handler=(f)
      @blank_handler = f
      if @value == nil || @value == ""
        f.call
      end
    end

    def value_handler=(f)
      raise "Define blank_handler = proc { } before calling value_handler" if !@blank_handler.is_a?(Proc)
      if @value != nil && @value != ""
        f.call(@value)
      end
    end
  end

  module ClassMethods
    def overwrite_method_for_result(name)
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

    def overwrite_method_for_option(name)
      @@overwriting_method = true
      alias_method "old_#{name}".to_sym, name.to_sym
      define_method name do |*args, &block|
        old_method = self.class.instance_method("old_#{name}")
        ret_val = old_method.bind(self).call(*args, &block)
        if ret_val == nil || ret_val == ""
          return Option.new(ret_val)
        else
          return Option.new(nil)
        end
      end
      @@overwriting_method = false
    end

    def resultify(*method_names)
      @@resultify_method_names = method_names
      self.instance_methods(false).each do |mname|
        self.overwrite_method_for_result(mname) if @@resultify_method_names.include?(mname)
      end
      @@overwriting_method = false
    end

    def optionify(*method_names)
      @@optionify_method_names = method_names
      self.instance_methods(false).each do |mname|
        self.overwrite_method_for_option(mname) if @@optionify_method_names.include?(mname)
      end
      @@overwriting_method = false
    end

    def method_added(name)
      return if defined?(@@overwriting_method) && @@overwriting_method
      if defined?(@@resultify_method_names) && @@resultify_method_names.include?(name)
        self.overwrite_method_for_result(name)
      end
      if defined?(@@optionify_method_names) && @@optionify_method_names.include?(name)
        self.overwrite_method_for_option(name)
      end
    end
  end

  def self.included(base)
    base.extend(ClassMethods)
  end
end
