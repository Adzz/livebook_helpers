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
    end

    test "four spaces in a doctest is the end of a doctest" do
    end

    test "macros fns with no docs" do
    end

    test "macros fns work" do
    end

    test "fns work" do
    end

    test "fns with no docs work" do
    end

    test "four space indentations are code blocks" do
    end

    test "moduledocs get written in" do
    end

    test "function docs but no module doc" do
    end

    test "when @moduledoc false is used" do
    end

    test "when @doc false is used" do
    end

    test "typedocs" do
    end
  end
end
