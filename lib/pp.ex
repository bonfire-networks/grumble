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
defmodule Grumble.PP do
  # Directive, FragmentDef, FragmentSpread, FragmentItem
  alias Grumble.{
    Arg,
    Field,
    FragmentSpread,
    ObjectSpread,
    Param,
    Query,
    Type,
    Var,
  }
  import Grumble.Helpers

  def to_string(thing), do: :erlang.iolist_to_binary(to_iolist(thing))

  def to_iolist(thing, indent \\ [])
  def to_iolist(nil, _indent), do: "null"
  def to_iolist(string, _indent) when is_binary(string), do: string_literal(string)
  def to_iolist(simple, _indent) when is_number(simple) or is_boolean(simple), do: "#{simple}"
  def to_iolist(list, indent) when is_list(list), do: list(list, indent)
  def to_iolist(%Arg{} = arg, indent), do: arg(arg, indent)
  def to_iolist(%Field{} = field, indent), do: field(field, indent)
  def to_iolist(%FragmentSpread{} = field, indent), do: field(field, indent)
  def to_iolist(%ObjectSpread{} = field, indent), do: field(field, indent)
  def to_iolist(%Query{} = query, indent), do: query(query, indent)
  def to_iolist(%Param{} = param, indent), do: param(param, indent)
  def to_iolist(%Type{} = type, indent), do: type(type, indent)
  def to_iolist(%Var{} = var, _), do: var(var)
  # def to_iolist(%Directive{}, indent)
  # def to_iolist(%FragmentDef{}, indent)
  # def to_iolist(%FragmentSpread{}, indent)
  # def to_iolist(%InlineFragment{}, indent)
  # must come last
  def to_iolist(%{} = map, indent), do: input_object(map, indent)

  defp ind(indent), do: ["  ", indent]

  # prefix space
  defp alia(nil), do: []
  defp alia(name), do: [field_case(name), ": "]

  # no surrounding space
  defp arg(%Arg{name: name, value: value}, indent),
    do: [field_case(name), ": ", value(value, indent)]

  # no surrounding spaces
  defp args([], _), do: []
  defp args([arg], indent), do: ["(", arg(arg, indent), ")"]

  defp args([arg | args], indent) do
    ind = ind(indent)
    fst = [arg(arg, ind)]
    rest = Enum.map(args, &[", ", arg(&1, ind)])
    ["(", fst, rest, ")"]
  end

  # no surrounding space
  defp field(name, _) when is_atom(name) or is_binary(name), do: field_name(name)

  defp field(%Field{name: name, alias: alia, args: args, fields: fields}, indent) do
    [alia(alia), field_name(name), args(args, indent), fields(fields, indent)]
  end

  defp field(%FragmentSpread{}=field, indent), do: fragment_spread(field, indent)
  defp field(%ObjectSpread{}=field, indent), do: object_spread(field, indent)

  defp field_name(:__typename), do: "__typename"
  defp field_name(other), do: field_case(other)

  # prefix space
  defp fields([], _), do: []

  # defp fields([field], indent),
  #   do: [ " { ", field(field, ind(indent)), " }" ]

  defp fields(fields, indent) when is_list(fields) do
    ind = ind(indent)
    [" {\n", Enum.map(fields, &[ind, field(&1, ind), "\n"]), indent, "}"]
  end

  # no space
  defp fragment_spread(%FragmentSpread{name: name}, _) do
    ["...", field_case(name)]
  end

  defp object_spread(%ObjectSpread{name: name, fields: fields}, indent) do
    ["... on ", type(name, indent), fields(fields, indent)]
  end

  # no surrounding space
  defp input_object(struct, indent) when is_struct(struct),
    do: input_object(Map.from_struct(struct), indent)

  defp input_object(%{} = thing, indent) do
    if thing == %{} do
      "{}"
    else
      ind = ind(indent)
      ["{\n", Enum.map(thing, &[ind, object_field(ind, &1), ",\n"]), indent, "}"]
    end
  end

  defp object_field(indent, {k, v}),
    do: [field_case(k), ": ", to_iolist(v, indent)]

  # no surrounding space
  defp list([], _indent), do: "[]"
  defp list([thing], indent), do: ["[", to_iolist(thing, indent), "]"]

  defp list(list, indent) when is_list(list) do
    ind = ind(indent)
    ["[\n", Enum.map(list, &[ind, to_iolist(&1, ind), ",\n"]), "]"]
  end

  # no surrounding space
  defp param(%Param{name: name, type: type}, indent),
    do: [var(name), ": ", type(type, indent)]

  # no surrounding spaces
  defp params([], _), do: []
  defp params([param], indent), do: ["(", param(param, indent), ")"]

  defp params([param | params], indent) do
    ind = ind(indent)
    fst = [param(param, ind)]
    rest = Enum.map(params, &[", ", param(&1, ind)])
    ["(", fst, rest, ")"]
  end

  # no surrounding space
  defp query(%Query{operation: op, name: name, params: params, fields: fields}, _) do
    [query_intro(op, name), params(params, []), fields(fields, [])]
  end

  # no surrounding space
  defp query_intro(nil, nil), do: []
  defp query_intro(atom, nil) when is_atom(atom), do: [Atom.to_string(atom)]

  defp query_intro(atom, name) when is_atom(atom),
    do: [Atom.to_string(atom), " ", field_case(name)]

  # no surrounding space
  defp type(atom, _indent) when is_atom(atom), do: type_case(atom)

  defp type(%Type{name: [], param: param, required: true}, indent),
    do: ["[", to_iolist(param, indent), "]!"]

  defp type(%Type{name: [], param: param}, _), do: ["[", to_iolist(param), "]"]
  defp type(%Type{name: name, required: true}, _), do: [type_case(name), "!"]
  defp type(%Type{name: name}, _), do: type_case(name)
  defp type(%Type{} = field, indent), do: to_iolist(field, indent)

  # todo: better
  defp value(v, indent), do: to_iolist(v, indent)

  defp var(%Var{name: name}), do: ["$", field_case(name)]
  defp var(name) when is_atom(name), do: ["$", field_case(name)]
end
