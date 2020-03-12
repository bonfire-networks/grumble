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
defmodule Gruff.Query do
  @enforce_keys [:operation]
  # directives: []
  defstruct [:operation, name: nil, params: [], fields: []]

  import Gruff.Helpers, only: [name?: 1, operation?: 1, validate: 3]
  alias Gruff.{Field, FragmentSpread, ObjectSpread, Param, Query}

  @type name :: atom | binary

  @type operation :: :query | :mutation | :subscription

  @type t :: %Query{
          operation: operation,
          name: name | nil,
          params: [Param.t()],
          fields: [Field.t()]
          # directives: [Directive.t],
        }

  @spec new(operation :: operation) :: t
  @spec new(operation :: operation, set :: list) :: t
  def new(operation, set \\ [])

  def new(operation, set) do
    validate(&operation?/1, operation, :invalid_operation)
    set(%Query{operation: operation}, set)
  end

  @spec set(query :: t, set :: list) :: t
  def set(%Query{} = query, []), do: query
  def set(%Query{} = query, [{k, v} | set]), do: set(set(query, k, v), set)

  def set(%Query{} = query, :name, name) do
    %{query | name: validate(&name?/1, name, :invalid_name)}
  end

  def set(%Query{params: params} = query, :param, %Param{} = param) do
    %{query | params: [param | params]}
  end

  def set(%Query{params: params} = query, :param, {name, type}) do
    %{query | params: [Param.new(name, type) | params]}
  end

  def set(%Query{} = query, :params, params) when is_list(params) do
    Enum.reduce(params, query, &set(&2, :param, &1))
  end

  def set(%Query{fields: fields} = query, :field, %Field{} = field) do
    %{query | fields: [field | fields]}
  end

  def set(%Query{fields: fields} = query, :field, %FragmentSpread{} = field) do
    %{query | fields: [field | fields]}
  end

  def set(%Query{fields: fields} = query, :field, %ObjectSpread{} = field) do
    %{query | fields: [field | fields]}
  end

  def set(%Query{fields: fields} = query, :field, {name, subfields}) do
    %{query | fields: [Field.new(name, fields: subfields) | fields]}
  end

  def set(%Query{fields: fields} = query, :field, field) do
    %{query | fields: [Field.new(field) | fields]}
  end

  def set(%Query{} = query, :fields, fields) when is_list(fields) do
    Enum.reduce(fields, query, &set(&2, :field, &1))
  end
end
