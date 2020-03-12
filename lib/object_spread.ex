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
defmodule Gruff.ObjectSpread do

  @enforce_keys [:name]
  defstruct [:name, fields: []]

  import Gruff.Helpers, only: [name?: 1, validate: 3]
  alias Gruff.{Field, FragmentSpread, ObjectSpread}

  @type name :: atom | binary

  @type t :: %ObjectSpread{name: name}

  @spec new(name :: name) :: t
  @spec new(name :: name, set :: list) :: t
  def new(name, set \\ []) do
    validate(&name?/1, name, :invalid_name)
    set(%ObjectSpread{name: name}, set)
  end

  @spec set(query :: t, set :: list) :: t
  def set(%ObjectSpread{} = self, []), do: self
  def set(%ObjectSpread{} = self, [{k, v} | set]) do
    set(set(self, k, v), set)
  end

  def set(%ObjectSpread{} = self, :name, name) do
    %{self | name: validate(&name?/1, name, :invalid_name)}
  end

  def set(%ObjectSpread{fields: fields} = self, :field, %Field{} = field) do
    %{self | fields: [field | fields]}
  end

  def set(%ObjectSpread{fields: fields} = self, :field, %FragmentSpread{} = field) do
    %{self | fields: [field | fields]}
  end

  def set(%ObjectSpread{fields: fields} = self, :field, %ObjectSpread{} = field) do
    %{self | fields: [field | fields]}
  end

  def set(%ObjectSpread{fields: fields} = self, :field, {name, subfields}) do
    %{self | fields: [Field.new(name, fields: subfields) | fields]}
  end

  def set(%ObjectSpread{fields: fields} = self, :field, field) do
    %{self | fields: [Field.new(field) | fields]}
  end

end
