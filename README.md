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
