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
     expected <ComplexMessage: date: <DateMessage: month: 1>, numbers: [], messages: []> to have attributes {date: {month: 2}} but had attributes {date: <DateMessage: month: 1>}
     Diff:
     @@ -1 +1 @@
     -:date => {month: 2},
     +:date => <DateMessage: month: 1>,
```

After
```ruby
Failure/Error: is_expected.to be_a_protobuf(date: { month: 2 })
     Diff:
     @@ -1 +1 @@
     -:date => {month: 2},
     +:date => {month: 1},
```

----
## Installation

```ruby
# Gemfile
gem "rspec-protobuf"
```

or

```
gem install rspec-protobuf
```
