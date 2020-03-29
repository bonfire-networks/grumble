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
defmodule GruffTest do
  use ExUnit.Case

  # doctest Gruff

  import Gruff
  alias Gruff.PP

  describe "pretty printing" do
    test "simple data" do
      assert "\"hello\"" == PP.to_string("hello")
      assert "123" == PP.to_string(123)
      assert "123.45" == PP.to_string(123.45)
      assert "true" == PP.to_string(true)
      assert "false" == PP.to_string(false)
      assert "null" == PP.to_string(nil)
    end

    test "lists" do
      assert "[]" == PP.to_string([])
      assert "[1]" == PP.to_string([1])

      assert """
             [
               1,
               2,
               3,
             ]
             """ == PP.to_string([1, 2, 3]) <> "\n"
    end

    test "Arg" do
      assert "hello: 123" ==
               PP.to_string(arg(:hello, 123))

      assert "hello: []" ==
               PP.to_string(arg(:hello, []))

      assert "hello: [123]" ==
               PP.to_string(arg(:hello, [123]))

      assert """
             hello: [
               123,
               456,
             ]
             """ == PP.to_string(arg(:hello, [123, 456])) <> "\n"
    end

    test "Field" do
      assert "hello" ==
               PP.to_string(field(:hello))

      assert "hello(worLd: 123)" ==
               PP.to_string(field(:hello, arg: arg(:wor_ld, 123)))
    end

    test "Param" do
    end

    test "Type" do
    end

    test "Var" do
    end

    test "input object" do
    end

    test "Query" do
    end
  end
end
