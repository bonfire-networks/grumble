# Gruff - a library for generating GraphQL queries
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
defmodule Gruff.MixProject do
  use Mix.Project

  def project do
    [
      app: :gruff,
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      elixirc_paths: elixirc_paths(Mix.env()),
      package: [
        licenses: ["Apache 2"],
        links: %{
          "Repository" => "https://github.com/irresponsible/gruff.ex",
          "Hexdocs" => "https://hexdocs.pm/gruff"
        }
      ],
      docs: [
        name: "Gruff",
        main: "readme",
        source_url: "https://github.com/irresponsible/gruff.ex",
        extras: [
          "README.md",
          "CONDUCT.md"
        ]
      ]
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:recase, "~> 0.5"}
    ]
  end
end
