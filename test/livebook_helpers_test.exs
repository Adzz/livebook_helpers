defmodule LivebookHelpersTest do
  use ExUnit.Case
  doctest LivebookHelpers

  test "Can turn a simple docttest into a livebook" do
    # LivebookHelpers.livebook_from_module(Mod, "./livebook_test")
  end

  describe "livebook_string/1" do
    test "existing elixir cells stay as elixir cells" do
      assert LivebookHelpers.livebook_string(Thing) ==
               "<!-- vim: syntax=markdown -->\n\n# Thing\n\n\n```elixir\n# field {:content, \"text\", &cast_string/1}\n#       ^          ^                ^\n# struct field     |                |\n#     path to data in the source    |\n#                            casting function\n```\n\n\nThis says in the source data there will be a field called `:text`. When creating a struct we should get the data under that field and pass it too `cast_string/1`. The result of that function will be put in the resultant struct under the key `:content`.\n\nThere are 5 kinds of struct fields we could want:\n\n1. `field`     - The value will be a casted value from the source data.\n2. `list_of`   - The value will be a list of casted values created from the source data.\n3. `has_one`   - The value will be created from a nested data schema (so will be a struct)\n4. `has_many`  - The value will be created by casting a list of values into a data schema.\n(You end up with a list of structs defined by the provided schema). Similar to has_many in ecto\n5. `aggregate` - The value will be a casted value formed from multiple bits of data in the source.\n\nAvailable options are:\n\n* `:optional?` - specifies whether or not the field in the struct should be included in\nthe `@enforce_keys` for the struct. By default all fields are required but you can mark\nthem as optional by setting this to `true`. This will also be checked when creating a\nstruct with `DataSchema.to_struct/2` returning an error if the required field is null.\n\nFor example:\n\n```elixir\ndefmodule Sandwich do\n  require DataSchema\n\n  DataSchema.data_schema(field: {:type, \"the_type\", &{:ok, String.upcase(&1)}, optional?: true})\nend\n```\nTo see this better let's look at a very simple example. Assume our input data looks like this:\n\n```elixir\nsource_data = %{\n  \"content\" => \"This is a blog post\",\n  \"comments\" => [%{\"text\" => \"This is a comment\"}, %{\"text\" => \"This is another comment\"}],\n  \"draft\" => %{\"content\" => \"This is a draft blog post\"},\n  \"date\" => \"2021-11-11\",\n  \"time\" => \"14:00:00\",\n  \"metadata\" => %{\"rating\" => 0}\n}\n```\n\n\n"
    end

    test "non elixir triple backticks are kept as is" do
      assert LivebookHelpers.livebook_string(NonElixirBackticks) ==
               "<!-- vim: syntax=markdown -->\n\n# NonElixirBackticks\n\n```xml\n<Thing />\n```\n\n"
    end

    test "doctests in doctests are not allowed" do
      message = "Parsing error - You can't have a doctest inside a doctest"

      assert_raise(RuntimeError, message, fn ->
        LivebookHelpers.livebook_string(DoctestInDoctest)
      end)
    end

    test "blank line in doctest is not allowed" do
      message = "Parsing error - doctest can't have blank lines in them"

      assert_raise(RuntimeError, message, fn ->
        LivebookHelpers.livebook_string(BlankLineDoctest)
      end)
    end

    test "macros fns with no docs" do
      assert LivebookHelpers.livebook_string(MacroWithNoDoc) ==
               "<!-- vim: syntax=markdown -->\n\n# MacroWithNoDoc\n\nA wild doc appeared!\n\n"
    end

    test "macros fns work" do
      assert LivebookHelpers.livebook_string(MacroWithDoc) ==
               "<!-- vim: syntax=markdown -->\n\n# MacroWithDoc\n\n## with_a_doc/0\n\nReturns 1 probably.\n\n```elixir\n1 + 1\n```\n\n"
    end

    test "fns work" do
      assert LivebookHelpers.livebook_string(FnsForAll) ==
               "<!-- vim: syntax=markdown -->\n\n# FnsForAll\n\n## one/0\n\nThis is a doc\n\n## two/0\n\nThere are many like it, but this one is mine.\n\n```xml\n<text>\n```\n\n```elixir\n\"some elixir code example\"\n```\n"
    end

    test "fns with no docs work" do
      assert LivebookHelpers.livebook_string(FnsForNone) ==
               "<!-- vim: syntax=markdown -->\n\n# FnsForNone\n\n"
    end

    test "four space indentations are code blocks" do
      assert LivebookHelpers.livebook_string(IndentedCodeAreElixirCells) ==
               "<!-- vim: syntax=markdown -->\n\n# IndentedCodeAreElixirCells\n\n\n```elixir\n\"This is elixir\" <> \"And should be a cell\"\n```\n"
    end

    test "four space indentations are formatted" do
      message =
        "nofile:4:11: syntax error before: invalid\n    |\n  4 | \"this is\" invalid elixir\n    |           ^"

      assert_raise(SyntaxError, message, fn ->
        LivebookHelpers.livebook_string(IndentedInvalidElixir)
      end)
    end

    test "when @moduledoc false is used" do
      assert LivebookHelpers.livebook_string(ModuleDocFalse) ==
               "<!-- vim: syntax=markdown -->\n\n# ModuleDocFalse\n\n"
    end

    test "typedocs" do
      assert LivebookHelpers.livebook_string(TypeDocs) ==
               "<!-- vim: syntax=markdown -->\n\n# TypeDocs\n\n## fun_time/1\n\ndoc AND a spec?!\n\n## other_thing\n\nThis is a type\n## final\n\nThis is a type lower down the module, can it have elixir cells in it?\n\n```elixir\n1 + 1\n```\n\nThis probably wont test?\n\n```elixir\n\"example elixir though\"\n```\n"
    end

    test "protocols" do
      assert LivebookHelpers.livebook_string(Proto) ==
               "<!-- vim: syntax=markdown -->\n\n# Proto\n\nJust a normal mod doc I assume\n\n## thing/1\n\nAnything special here?\n\n"
    end

    test "protocol implementations" do
      assert LivebookHelpers.livebook_string(ImplementedProto) ==
               "<!-- vim: syntax=markdown -->\n\n# ImplementedProto\n\nJust a normal mod doc I assume\n\n## thing/1\n\nAnything special here?\n\n"

      assert LivebookHelpers.livebook_string(Implementation) ==
               "<!-- vim: syntax=markdown -->\n\n# Implementation\n\nThis is the actual moduledoc\n\n"

      # RIGHT now if we get the actual module for the implementation then it works.
      assert LivebookHelpers.livebook_string(ImplementedProto.Implementation) ==
               "<!-- vim: syntax=markdown -->\n\n# ImplementedProto.Implementation\n\nDoc for implementation.\nnot sure you should do this but it probably works.\n\n## thing/1\n\nthis is a doc\n"

      # BUT the problem is if the implementation is in the module you don't want to have to
      # like manually find the module name for the implementation. It would be great to do
      # it for them for protocols, but that requires:
      # 1. find all protocols
      # 2. Get the implementations for it
      # 3. Generate the implementation that's relevant for the module we are in

      # None of that is trivial, so for now I will create an issue and put something in the
      # README.
    end

    test "behaviours docs" do
      assert LivebookHelpers.livebook_string(Behave) == "<!-- vim: syntax=markdown -->\n\n# Behave\n\n## thing/1\n\nThis is a doc for a callback, dope right?\n"
    end

    test "nested modules" do
      # Should we be able to extract all nested modules too?
    end
  end

  describe "parse_elixir_cells/2" do
    test "" do
    end
  end
end
