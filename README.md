rspec-protobuf
======
![Gem](https://img.shields.io/gem/dt/rspec-protobuf?style=plastic)
[![codecov](https://codecov.io/gh/dpep/rspec-protobuf/branch/main/graph/badge.svg)](https://codecov.io/gh/dpep/rspec-protobuf)

RSpec matchers for Protobuf.


```ruby
require "rspec/protobuf"

subject { MyProtoMessage.new(msg: "hi") }

it { is_expected.to be_a_protobuf }

# check type
it { is_expected.to be_a_protobuf(MyProtoMessage) }

# check field values
it { is_expected.to be_a_protobuf(msg: "hi") }
it { is_expected.to be_a_protobuf(msg: /^h/) }

# composite matching
it { expect(result).to include(data: a_protobuf(MyProtoMessage, msg: starting_with("h"))) }
```


### Improved RSpec Errors
Before
```ruby
Failure/Error: is_expected.to have_attributes(date: { month: 2 })
     expected <ComplexMessage: complex: false, date: <DateMessage: type: :DATE_DEFAULT, month: 1, day: 0, year: 0>> to have attributes {:date => {:month => 2}} but had attributes {:date => <DateMessage: type: :DATE_DEFAULT, month: 1, day: 0, year: 0>}
     Diff:
     @@ -1 +1 @@
     -:date => {:month=>2},
     +:date => <DateMessage: type: :DATE_DEFAULT, month: 1, day: 0, year: 0>,
```

After
```ruby
Failure/Error: is_expected.to be_a_protobuf(date: { month: 2 })
     Diff:
     @@ -1 +1 @@
     -:date => {:month=>2},
     +:date => {:month=>1},
```

----
## Contributing

Yes please  :)

1. Fork it
1. Create your feature branch (`git checkout -b my-feature`)
1. Ensure the tests pass (`bundle exec rspec`)
1. Commit your changes (`git commit -am 'awesome new feature'`)
1. Push your branch (`git push origin my-feature`)
1. Create a Pull Request
