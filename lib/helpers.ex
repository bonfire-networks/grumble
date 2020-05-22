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
defmodule Grumble.Helpers do
  # Directive, FragmentDef, FragmentSpread, FragmentItem
  alias Grumble.{Arg, Field, Query, Param, Type, Var}

  @type predicate :: (term -> boolean)

  @spec field_case(atom | binary) :: binary
  def field_case(name) when is_atom(name), do: field_case(Atom.to_string(name))
  def field_case(name) when is_binary(name), do: Recase.to_camel(name)

  @spec type_case(atom | binary) :: binary
  def type_case(name) when is_atom(name), do: type_case(Atom.to_string(name))
  def type_case("id"), do: "ID"
  def type_case(name) when is_binary(name), do: Recase.to_pascal(name)

  @spec string_literal(binary) :: iolist
  def string_literal(string), do: ["\"", escape_string(string, []), "\""]

  @spec validate(test :: predicate, subject :: term, error_tag :: term) :: term
  def validate(pred, val, error)
      when is_function(pred) do
    if pred.(val),
      do: val,
      else: throw({error, val})
  end

  @spec operation?(term) :: boolean
  def operation?(:query), do: true
  def operation?(:mutation), do: true
  def operation?(:subscription), do: true
  def operation?(_), do: false

  @spec name?(term) :: boolean
  def name?(""), do: false
  def name?(name) when is_atom(name), do: name?(Atom.to_string(name))

  def name?(<<start::utf8, rest::binary>>),
    do: name_start?(start) and every?(&name_continue?/1, rest)

  def name?(_), do: false

  @spec value?(term) :: boolean
  def value?(nil), do: true
  def value?(x) when is_number(x) or is_boolean(x) or is_binary(x), do: true
  def value?(x) when is_list(x), do: Enum.all?(x, &value?/1)
  def value?(%{__struct__: Var}), do: true
  def value?(%{__struct__: Arg}), do: false
  # def value?(%{__struct__: Directive}), do: false
  def value?(%{__struct__: Field}), do: false
  # def value?(%{__struct__: FragmentDef}), do: false
  # def value?(%{__struct__: FragmentSpread}), do: false
  # def value?(%{__struct__: InlineFragment}), do: false
  def value?(%{__struct__: Query}), do: false
  def value?(%{__struct__: Param}), do: false
  def value?(%{__struct__: Type}), do: false

  def value?(%{} = fields),
    do: Enum.all?(Map.delete(fields, :__struct__), fn {k, v} -> name?(k) and value?(v) end)

  def value?(_), do: false

  @spec const_value?(term) :: boolean
  def const_value?(nil), do: true
  def const_value?(x) when is_number(x) or is_boolean(x) or is_binary(x), do: true
  def const_value?(x) when is_list(x), do: Enum.all?(x, &const_value?/1)
  def const_value?(%{__struct__: Arg}), do: false
  # def const_value?(%{__struct__: Directive}), do: false
  def const_value?(%{__struct__: Field}), do: false
  # def const_value?(%{__struct__: FragmentDef}), do: false
  # def const_value?(%{__struct__: FragmentSpread}), do: false
  # def const_value?(%{__struct__: InlineFragment}), do: false
  def const_value?(%{__struct__: Query}), do: false
  def const_value?(%{__struct__: Param}), do: false
  def const_value?(%{__struct__: Var}), do: false
  def const_value?(%{__struct__: Type}), do: false

  def const_value?(%{} = x),
    do: Enum.all?(Map.delete(x, :__struct__), fn {k, v} -> name?(k) and const_value?(v) end)

  def const_value?(_), do: false

  @spec fragment_name?(term) :: boolean
  def fragment_name?(:on), do: false
  def fragment_name?("on"), do: false
  def fragment_name?(name), do: name?(name)

  ## impl: basic parsers

  # does every char in a binary match a predicate?
  defp every?(_pred, ""), do: true
  defp every?(pred, <<char::utf8, rest::binary>>), do: pred.(char) and every?(pred, rest)

  # find the first character that matches a predicate, get it and its byte offset and size
  defp first(str, pred), do: first(str, pred, 0)

  defp first("", _pred, _idx), do: :error

  defp first(<<ch::utf8, rest::binary>> = all, pred, idx) do
    # jesus
    size = byte_size(all) - byte_size(rest)

    if pred.(ch) do
      {:ok, idx, ch, size}
    else
      first(rest, pred, idx + size)
    end
  end

  ### impl: character tests

  # defp source_character?(x) when x in [9,10,13] or (x >= 20 and x <= 65535)

  defp name_start?(x), do: x == ?_ or letter?(x)

  defp name_continue?(x), do: name_start?(x) or digit?(x)

  defp lower_case_letter?(x), do: x >= ?a and x <= ?z

  defp upper_case_letter?(x), do: x >= ?A and x <= ?Z

  defp letter?(x), do: lower_case_letter?(x) or upper_case_letter?(x)

  defp digit?(x), do: x >= ?0 and x <= ?9

  ### impl: string escaping

  # fast path for no items
  defp escape_string("", []), do: ""
  # fast path for one item
  defp escape_string("", [acc]), do: acc
  defp escape_string("", acc), do: acc

  defp escape_string(str, acc) do
    case first(str, &escape_char?/1) do
      :error ->
        [acc, str]

      {:ok, 0, ch, size} ->
        ch = escape_char(ch)
        escape_string(:binary.part(str, size, byte_size(str) - size), [acc, ch])

      {:ok, index, ch, size} ->
        pre = :binary.part(str, 0, index)
        ch = escape_char(ch)
        escape_string(:binary.part(str, size, byte_size(str) - (size + index)), [acc, pre, ch])
    end
  end

  # defp source_character?(x) when x in [9,10,13] or (x >= 20 and x <= 65535)

  # should we escape this character in a string literal?
  defp escape_char?(x), do: x <= 31 or x >= 127 or x in [?", ?\\]

  ## escape translation

  # special common cases
  # double quote
  defp escape_char(?"), do: "\\\""
  # backslash
  defp escape_char(?\\), do: "\\\\"
  # bell
  defp escape_char(?\b), do: "\\b"
  # form feed
  defp escape_char(?\f), do: "\\f"
  # line feed
  defp escape_char(?\n), do: "\\n"
  # carriage return
  defp escape_char(?\r), do: "\\r"
  # horizontal tab
  defp escape_char(?\t), do: "\\t"
  # printable, narrowly avoiding ascii del
  defp escape_char(ch) when ch >= 31 and ch <= 126, do: ch
  # by digits
  # 1 digit
  defp escape_char(ch) when ch <= 15, do: ["\\u000", Integer.to_string(ch, 16)]
  # 2 digits
  defp escape_char(ch) when ch <= 255, do: ["\\u00", Integer.to_string(ch, 16)]
  # 3 digits
  defp escape_char(ch) when ch <= 4095, do: ["\\u0", Integer.to_string(ch, 16)]
  # 4 byte
  defp escape_char(ch) when ch <= 65535, do: ["\\u", Integer.to_string(ch, 16)]
  defp escape_char(ch) when ch > 65535, do: throw({:char_out_of_range, ch})
end
