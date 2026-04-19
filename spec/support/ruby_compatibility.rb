# Ruby 3.4+ renders hashes with symbol keys using label syntax: {key: value}
LABEL_HASH_SYNTAX = Gem::Version.new(RUBY_VERSION) >= "3.4"
