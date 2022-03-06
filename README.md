# Grumble

`Grumble` is a DSL for generating GraphQL queries

## Status: beta

We use this in our tests at work to generate all the queries (because
we outgrew string concatenation). I'm not sure I'd want to depend on
it in production yet because it's hard to feel like it's had a proper
stress testing.

* Needs (better) tests and documentation.
* Missing support for some things we don't use.

## Usage

Add to your deps:

```elixir
{:grumble, "~> 0.1.0"}
```

Simple example:

```elixir
import Grumble
alias Grumble.PP

IO.puts(PP.to_string(
  query(
    params: [community_id: type!(:string)],
    fields: [
      field(
        :community,
        args: [community_id: var(:community_id)],
        fields: [:id, :name]
      )
    ]
  )
))
```

Output:

```
query($communityId: String!) {
  community(communityId: $communityId) {
    name
    id
  }
}
```

## Guide

Most of the useful functions are in the `Grumble` module. From there
you can read which arguments are understood by the relevant `new`
function. We apologise for the poor documentation, please feel free to
contribute better docs!

## Contributing

Contributions are welcome, even just doc fixes or suggestions.

This project has adopted a [Code of Conduct](CONDUCT.md) based on the
Contributor Covenant. Please be nice when interacting with the community.

## Copyright and License

Copyright (c) 2020 Grumble contributors.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
