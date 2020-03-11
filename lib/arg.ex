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
defmodule Gruff.Arg do
  @enforce_keys [:name, :value]
  defstruct @enforce_keys

  import Gruff.Helpers, only: [name?: 1, value?: 1, validate: 3]
  alias Gruff.Arg

  @type name :: atom | binary

  @type t :: %Arg{name: name, value: term}

  @spec new(name :: name, value :: term) :: t
  def new(name, value) do
    validate(&name?/1, name, :invalid_name)
    validate(&value?/1, value, :invalid_value)
    %Arg{name: name, value: value}
  end
end
