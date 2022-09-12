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
defmodule Grumble do
  alias Grumble.{
    Arg,
    Field,
    FragmentSpread,
    ObjectSpread,
    Query,
    Param,
    Type,
    Var
  }

  @type name :: :atom | :binary

  @spec arg(name :: name, value :: term) :: Arg.t()
  def arg(name, value), do: Arg.new(name, value)

  @spec field(name :: name) :: Field.t()
  @spec field(name :: name, set :: list) :: Field.t()
  def field(name, set \\ []), do: Field.new(name, set)

  @spec fragment_spread(name :: name) :: FragmentSpread.t()
  def fragment_spread(name), do: FragmentSpread.new(name)

  @spec mutation() :: Query.t()
  @spec mutation(set :: list) :: Query.t()
  def mutation(set \\ []), do: Query.new(:mutation, set)

  @spec object_spread(name :: name) :: ObjectSpread.t()
  @spec object_spread(name :: name, set :: list) :: ObjectSpread.t()
  def object_spread(name, set \\ []), do: ObjectSpread.new(name, set)

  @spec param(name :: name, type :: Type.t()) :: Param.t()
  def param(name, type), do: Param.new(name, type)

  @spec query() :: Query.t()
  @spec query(set :: list) :: Query.t()
  def query(set \\ []), do: Query.new(:query, set)

  @spec subscription() :: Query.t()
  @spec subscription(set :: list) :: Query.t()
  def subscription(set \\ []), do: Query.new(:subscription, set)

  @spec list_type(name :: name) :: Type.t()
  @spec list_type(name :: name, set :: list) :: Type.t()
  def list_type(name, set \\ []), do: Type.new(name, set)

  @spec type(name :: name) :: Type.t()
  @spec type(name :: name, set :: list) :: Type.t()
  def type(name, set \\ []), do: Type.new(name, set)

  @spec type!(name :: name) :: Type.t()
  @spec type!(name :: name, set :: list) :: Type.t()
  def type!(name, set \\ []), do: Type.new(name, [{:required, true} | set])

  @spec var(name :: name) :: Var.t()
  def var(name), do: Var.new(name)
end

# defmodule Grumble.FragmentDef do
#   @enforce_keys [:name, :type]
#   defstruct [directives: [], fields: [], @enforce_keys]
# end

# defmodule Grumble.InlineFragment do
#   defstruct [:type, directives: [], fields: []]
# end

# defmodule Grumble.Directive do
#   defstruct [:name, :value]
#
#   import Grumble.Helpers, only: [name?: 1, value?: 1, validate: 3]
#   alias Grumble.{Arg, Directive, Helpers, Var}
#
#   def new(name, value)
#     validate(&name?/1, name, :invalid_name)
#     validate(&value?/1, value, :invalid_value)
#     %Arg{name: name, value: value}
#   end
#
# end
