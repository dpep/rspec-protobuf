## Unreleased
- Fix map fields: naming one in `be_a_protobuf` raised `TypeError`, and a hash never matched one.
- RSpec matchers on repeated and map fields see plain Ruby values with defaults kept, e.g. `be_a_protobuf(messages: include(a_hash_including(msg: "")))`, the same on google-protobuf 3 and 4.

###  0.4.0  (2026-04-19)
- ruby version / gem upgrades

###  v0.3.1  (2023-03-27)
- bugfix

###  v0.3.0  (2023-03-25)
- match repeated field
- match default values
- test coverage
- type check
- simplify
- symbol matching

###  v0.2.4  (2023-03-15)
- repeated field bug

###  v0.2.3  (2023-03-14)
- repeated fields

###  v0.2.2  (2022-12-15)
- dependabot and lockfile
- simplify dependencies

###  v0.2.1  (2022-11-16)
- fix enum matching

###  v0.2.0  (2022-11-09)
- rspec differ
- failure message and test coverage
- simplify

###  v0.1.0  (2022-11-08)
-

