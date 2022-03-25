class UserA
  attr_accessor :first_name, :last_name
  include Resultify
  optionify :get_full_name

  def initialize(fname, lname)
    @first_name = fname
    @last_name = lname
  end

  def get_full_name
    first_name + last_name
  end
end

class UserB
  attr_accessor :first_name, :last_name
  include Resultify
  resultify :get_full_name

  def initialize(fname, lname)
    @first_name = fname
    @last_name = lname
  end

  def get_full_name
    @first_name + @last_name
  end
end

RSpec.describe Resultify do
  it "has a version number" do
    expect(Resultify::VERSION).not_to be nil
  end

  it "raise error if blank_handler is not defined" do
    u = UserA.new("", "")
    result = u.get_full_name
    expect { result.value_handler = proc { |v| v } }.to raise_error("Define blank_handler")
  end
end
