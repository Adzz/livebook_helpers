defmodule FunctionDocParser do
  import NimbleParsec

  def doctest do
    # This is going to be the start of a code section
    "\n    iex>"
    # or this
    "iex>"
  end
end

defmodule LivebookHelpers do
  @moduledoc """
  Documentation for `LivebookHelpers`.
  """

  @doc """
  This function will take a module and turn the module doc found there into a livebook.
  This make it really easy to create one set of information and have it be represented
  in different formats. For example you can write a README, use the readme as the
  moduledoc then run this function to spit out a livebook with all the same info.

  This will turn the doctests into elixir sections in a livebook.
  """
  def livebook_from_module(module) do
    {:docs_v1, _, :elixir, _, %{"en" => module_doc}, _, function_docs} = Code.fetch_docs(module)

    # function_docs |> IO.inspect(limit: :infinity, label: "FDs")

    Enum.reduce(function_docs |> IO.inspect(limit: :infinity, label: "DOCS"), "", fn
      {{:function, function_name, _arity}, _, [_], %{"en" => doc}, _meta}, acc ->
        acc <> "## #{function_name}\n\n" <> parse_doc(doc)
    end)
    |> IO.inspect(limit: :infinity, label: "result")

    # The doc tests will begin with iex> but where do they end?
    # We can assume they will end either at the end of the string or at the
    # after 1 blank newline? Can the result span multiple lines?
    # Well we don't actually need to put in the response which is easy.
    # We can just save the setup etc.

    # Code examples can also be 4 spaces in I think....

    # We could also summarise all function docs into a livebook perhaps.
  end

  def parse_doc(doc) do
    doc
  end
end
