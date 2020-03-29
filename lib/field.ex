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
defmodule Grumble.Field do
  @enforce_keys [:name]
  # directives: []
  defstruct [:name, alias: nil, args: [], fields: []]

  import Grumble.Helpers, only: [name?: 1, validate: 3]
  alias Grumble.{Arg, Field, FragmentSpread, ObjectSpread}

  @type name :: atom | binary

  @type t :: %Field{
          name: name,
          alias: name | nil,
          args: [Arg.t()],
          fields: [t]
          # directives: [Directive.t],
        }

  def new(name, set \\ []) do
    validate(&name?/1, name, :invalid_name)
    set(%Field{name: name}, set)
  end

  def set(%Field{} = field, []), do: field
  def set(%Field{} = field, [{k, v} | set]), do: set(set(field, k, v), set)

  def set(%Field{} = field, :alias, alia) do
    validate(&name?/1, alia, :alias)
    %{field | alias: alia}
  end

  def set(%Field{args: args} = field, :arg, %Arg{} = arg) do
    %{field | args: [arg | args]}
  end

  def set(%Field{args: args} = field, :arg, {name, value}) do
    %{field | args: [Arg.new(name, value) | args]}
  end

  def set(%Field{} = field, :args, args) do
    Enum.reduce(args, field, &set(&2, :arg, &1))
  end

  def set(%Field{fields: fields} = field, :field, %Field{} = new) do
    %{field | fields: [new | fields]}
  end

  def set(%Field{fields: fields} = field, :field, %FragmentSpread{} = new) do
    %{field | fields: [new | fields]}
  end

  def set(%Field{fields: fields} = field, :field, %ObjectSpread{} = new) do
    %{field | fields: [new | fields]}
  end

  def set(%Field{fields: fields} = field, :field, {name, subfields}) do
    %{field | fields: [Field.new(name, fields: subfields) | fields]}
  end

  def set(%Field{fields: fields} = field, :field, new) do
    %{field | fields: [Field.new(new) | fields]}
  end

  def set(%Field{} = field, :fields, fields) do
    Enum.reduce(fields, field, &set(&2, :field, &1))
  end

  # def set(%Field{directives: dirs}=field, :directive, %Directive{}=dir) do
  #   %{ field | directives: [dir | dirs] }
  # end
end
