# Grumble - a DSL for building GraphQL queries as data structures.
#
# Copyright (c) 2020 James Laver
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
defmodule Grumble.MixProject do
  use Mix.Project

  def project do
    [
      app: :grumble,
      version: "0.1.3",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      package: [
        description: "A DSL for building GraphQL queries as data structures.",
        licenses: ["Apache 2"],
        links: %{
          "Repository" => "https://github.com/bonfire-networks/grumble",
          "Hexdocs" => "https://hexdocs.pm/grumble"
        }
      ],
      docs: [
        name: "Grumble",
        main: "readme",
        source_url: "https://github.com/bonfire-networks/grumble",
        extras: [
          "README.md",
          "CONDUCT.md"
        ]
      ],
      deps: [
        {:recase, "~> 0.8"},
        {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
      ]
    ]
  end
end
