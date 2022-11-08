rspec-protobuf
======
![Gem](https://img.shields.io/gem/dt/rspec-protobuf?style=plastic)
[![codecov](https://codecov.io/gh/dpep/rspec-protobuf/branch/main/graph/badge.svg)](https://codecov.io/gh/dpep/rspec-protobuf)

RSpec matchers for Protobuf.


```ruby
require "rspec/protobuf"

subject { MyProtoMessage.new(msg: "hi") }

it { is_expected.to be_a_protobuf }
it { is_expected.to be_a_protobuf(msg: "hi") }
it { is_expected.to be_a_protobuf(msg: /^h/) }
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
