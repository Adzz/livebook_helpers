defmodule Mix.Tasks.CreateLivebookFromModule do
  @moduledoc """
  Takes a module and a path to a file creates a livebook from the moduledocs in the given
  module. The `.livemd` extension is automatically added. If any deps are provided then
  a section at the start will be created that will `Mix.install` all deps.

  This function will take a module and turn the module doc found there into a livebook.
  This make it really easy to create one set of information and have it be represented
  in different formats. For example you can write a README, use it as the moduledoc then
  run this function to spit out a livebook with all the same info.

  Below is a summary of what we do to create the Livebook:

  * The module is used as the title for the Livebook.
  * Each function's @doc is put under a section with the function's name and arity.
  * doctests become (formatted) elixir cells
  * The magic line to make github render livebooks as markdown is added.
  * A section is placed at the start that will call `Mix.install` with any supplied deps.

  ### Examples

      mix create_livebook_from_module LivebookHelpers "my_livebook"

  With deps:

      mix create_livebook_from_module LivebookHelpers "my_livebook" "[:livebook_helpers]"

      mix create_livebook_from_module LivebookHelpers "my_livebook" "[livebook_helpers: \">= 0.0.0\"]"

  """
  use Mix.Task

  @shortdoc "Creates a livebook from the docs in the given module."
  @impl Mix.Task
  def run([module, file_path, deps]) do
    Mix.Task.run("app.start")

    path =
      LivebookHelpers.livebook_from_module(
        Module.safe_concat([module]),
        file_path,
        deps
      )

    IO.puts("")
    IO.puts("Success!")
    IO.puts("Livebook created from " <> module <> " here: " <> path)
  end

  def run([module, file_path]) do
    Mix.Task.run("app.start")

    path = LivebookHelpers.livebook_from_module(Module.safe_concat([module]), file_path)
    IO.puts("")
    IO.puts("Success!")
    IO.puts("Livebook created from " <> module <> " here: " <> path)
  end
end
