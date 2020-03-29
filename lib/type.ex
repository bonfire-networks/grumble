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
defmodule Grumble.Type do
  @enforce_keys [:name]
  defstruct [:name, param: nil, required: false]

  import Grumble.Helpers, only: [name?: 1, validate: 3]
  alias Grumble.Type

  @type name :: atom | binary

  @type t :: %Type{name: name | [], param: t | nil, required: boolean}

  @spec new(name :: name | []) :: t
  @spec new(name :: name | [], set :: list) :: t
  def new(name, set \\ [])
  def new([], set), do: set(%Type{name: [], required: false}, set)

  def new(name, set) do
    validate(&name?/1, name, :invalid_name)
    set(%Type{name: name, required: false}, set)
  end

  @spec set(type :: t, set :: list) :: t
  def set(%Type{} = type, []), do: type
  def set(%Type{} = type, [{k, v} | set]), do: set(set(type, k, v), set)

  def set(%Type{} = type, :param, %Type{} = param), do: %{type | param: param}
  def set(%Type{} = type, :param, param), do: %{new(type) | param: param}

  def set(%Type{} = type, :required, required) do
    %{type | required: validate(&is_boolean/1, required, :invalid_required)}
  end
end
