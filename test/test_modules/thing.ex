defmodule Thing do
  @moduledoc """

  ```elixir
  # field {:content, "text", &cast_string/1}
  #       ^          ^                ^
  # struct field     |                |
  #     path to data in the source    |
  #                            casting function
  ```

  This says in the source data there will be a field called `:text`. When creating a struct we should get the data under that field and pass it too `cast_string/1`. The result of that function will be put in the resultant struct under the key `:content`.

  There are 5 kinds of struct fields we could want:

  1. `field`     - The value will be a casted value from the source data.
  2. `list_of`   - The value will be a list of casted values created from the source data.
  3. `has_one`   - The value will be created from a nested data schema (so will be a struct)
  4. `has_many`  - The value will be created by casting a list of values into a data schema.
  (You end up with a list of structs defined by the provided schema). Similar to has_many in ecto
  5. `aggregate` - The value will be a casted value formed from multiple bits of data in the source.

  Available options are:

  * `:optional?` - specifies whether or not the field in the struct should be included in
  the `@enforce_keys` for the struct. By default all fields are required but you can mark
  them as optional by setting this to `true`. This will also be checked when creating a
  struct with `DataSchema.to_struct/2` returning an error if the required field is null.

  For example:

      defmodule Sandwich do
        require DataSchema

        DataSchema.data_schema([
          field: {:type, \"the_type\", &{:ok, String.upcase(&1)}, optional?: true},
        ])
      end

  To see this better let's look at a very simple example. Assume our input data looks like this:

  ```elixir
  source_data = %{
    \"content\" => \"This is a blog post\",
    \"comments\" => [%{\"text\" => \"This is a comment\"},%{\"text\" => \"This is another comment\"}],
    \"draft\" => %{\"content\" => \"This is a draft blog post\"},
    \"date\" => \"2021-11-11\",
    \"time\" => \"14:00:00\",
    \"metadata\" => %{ \"rating\" => 0}
  }
  ```
  """
end
