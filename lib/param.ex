# Gruff - a DSL for building GraphQL queries as data structures.
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
defmodule Gruff.Param do
  @enforce_keys [:name, :type]
  defstruct @enforce_keys

  import Gruff.Helpers, only: [name?: 1, validate: 3]
  alias Gruff.{Param, Type}

  @type name :: atom | binary

  @type t :: %Param{name: name, type: name | Type.t()}

  @spec new(name :: name, type :: name | Type.t()) :: t
  def new(name, %Type{} = type) do
    validate(&name?/1, name, :invalid_name)
    %Param{name: name, type: type}
  end

  def new(name, type) do
    %Param{name: name, type: Type.new(type)}
  end
end
