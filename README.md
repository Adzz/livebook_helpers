# LivebookHelpers

Some useful helpers that you can use to interact with livebook.

## Generating Livebooks From Module Functions.

The easiest way to use this is to include `LivebookHelpers` as a dev dependency:

```elixir
{:livebook_helpers, "~> 0.0.1", only: :dev}
```

Now you can run the mix task as follows:

```sh
mix CreateLivebookFromModule YourModule "path_to_destination_livebook"
```

You can try it out with like this:

```sh
mix CreateLivebookFromModule LivebookHelpers "livebook_helpers_livebook"
```

### Protocol Implementations

When you implement a protocol a new module is created:

```elixir
defmodule Thing do
  defimpl Enum do
    ...
  end
end
```

This would create a module called `Enum.Thing`. If I were documenting all the functions in `Thing`, it would be great if it included any protocols that were implemented there also, but because a new module is created it's not trivial to do. We would have to find all protocols, then see if our module implemented any of them, then construct the module name and generate the docs for that module. I plan on trying this at some point.

That means currently you will have to generate a livebook for each protocol implementation. You can find the name of the created module by doing this:

```elixir
defmodule Thing do
  defimpl Enum do
    __MODULE__ |> IO.inspect(limit: :infinity, label: "protocol module name")
    ...
  end
end
```

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `livebook_helpers` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:livebook_helpers, "~> 0.0.5", only: :dev}
  ]
end
```

### Contributing

**NB** Set the `MIX_ENV` to `:docs` when publishing the package. This will ensure that modules inside `test/support` won't get their documentation published with the library (as they are included in the :dev env).

```sh
MIX_ENV=docs mix hex.publish
```

You will also have to set that env if you want to run `mix docs`

```sh
MIX_ENV=docs mix docs
```


Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/livebook_helpers>.
