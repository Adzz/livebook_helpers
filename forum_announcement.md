I made a simple mix task that will create a livebook from a module's documentation.
It will turn the doctests to elixir cells and will turn 4-space indented code blocks into elixir cells.
It's available on mix to play around with.

https://github.com/Adzz/livebook_helpers

This could be useful for ensuring a single source of truth for all your documentation in a library, so rather than writing a README, then a moduledoc, then creating a livebook, you could do this:

1. Demark the moduledoc in the README and use moduledoc syntax there:

```md
# My Readme

This is my module doc

### Examples

    1 + 1 = 2

    iex> 1 + 1
   2

<!-- MODULEDOC END -->

### Installation

....
```

Then in your module:

```elixir
defmodule MyModule do
  @moduledoc File.read!(Path.expand("./README.md"))
             |> String.split("<!-- MODULEDOC END -->")
             |> List.first()
end
```

==================================================================================================

Announcing https://github.com/Adzz/livebook_helpers

This is a library that generates a livebook from a module. It turns the module and function docs into a livebook, turning any doctests and elixir snippets into elixir cells.

This is really helpful for creating


add it to docs alias. Link to blog when it's out.

It adds the magic github command that ensures the livebook renders as markdown on github (giving nice syntax highlighting) and
