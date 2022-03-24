# Resultify

Inspired by Result and Option objects in Rust and Maybe Typeclass in Haskell. This gem adds these features to Ruby.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'resultify'
```
## Usage

```ruby
class User
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

u = User.new("John", nil)
result = u.get_full_name
result.error_handler = proc { |err| puts "could not get full name from user" }
result.value_handler = proc { |v| puts "Hello #{v}" }
```
Resultify forces you to define the error_handler function before trying to access the value wrapped inside the Result object.
If you define the value_handler without defining error_handler, you'll get an error.
If `get_full_name` results in an error, the exception will be caught and the proc assigned to `result.error_handler` will be called otherwise `result.value_handler`.

Similarly for handling blank values you can call the `optionify` method.

```ruby
class User
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

u = User.new("", "")
result = u.get_full_name
result.blank_handler = proc { |err| puts "could not get full name from user" }
result.value_handler = proc { |v| puts "Hello #{v}" }
```
If `u.get_full_name` return a blank value i.e `[], nil, ''` then the proc assigned to `result.blank_handler` will be called otherwise `result.value_handler`.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/blackblood/resultify. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Resultify project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/blackblood/resultify/blob/master/CODE_OF_CONDUCT.md).
