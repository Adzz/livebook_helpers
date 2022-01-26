defmodule LivebookHelpers do
  @moduledoc """
  Documentation for `LivebookHelpers`.
  """

  @doc """
  Takes a module and a path to a file, creates a livebook from the moduledocs in the given
  module. The `.livemd` extension is automatically added.

  This function will take a module and turn the module doc found there into a livebook.
  This make it really easy to create one set of information and have it be represented
  in different formats. For example you can write a README, use it as the moduledoc then
  run this function to spit out a livebook with all the same info.

  Below is a summary of what we do to create the Livebook:

  * The module is used as the title for the Livebook.
  * Each function's @doc is put under a section with the function's name and arity.
  * doctests become (formatted) elixir cells
  * The magic line to make github render livebooks as markdown is added.
  """
  def livebook_from_module(module, livebook_path) do
    File.write(Path.expand(livebook_path <> ".livemd"), livebook_string(module))
  end

  def livebook_string(module) do
    {:docs_v1, _, :elixir, _, %{"en" => module_doc}, _, function_docs} = Code.fetch_docs(module)

    start_of_page = """
    <!-- vim: syntax=markdown -->

    # #{inspect(module)}

    #{parse_module_doc(module_doc)}\
    """

    Enum.reduce(function_docs, start_of_page, fn
      {{:macro, macro_name, arity}, _, [_spec], %{"en" => doc}, _meta}, acc ->
        acc <> "## #{macro_name}/#{arity}\n\n" <> elixir_cells(doc)

      # When there is no function doc we just skip it for now.
      {{:macro, _macro_name, _arity}, _, [_spec], :none, _meta}, acc ->
        acc

      {{:function, _function_name, _arity}, _line_number, [_spec], :none, _}, acc ->
        acc

      {{:function, function_name, arity}, _, [_spec], %{"en" => doc}, _meta}, acc ->
        acc <> "## #{function_name}/#{arity}\n\n" <> elixir_cells(doc)
    end)
  end

  def parse_module_doc(module_doc) do
    livebook = ""
    doctest = ""
    four_space_code_block = ""

    module_doc
    |> String.split("\n")
    |> parse_elixir_cells({livebook, doctest, four_space_code_block})
  end

  def elixir_cells(doc) do
    livebook = ""
    doctest = ""
    four_space_code_block = ""

    doc
    |> String.split("\n")
    |> parse_elixir_cells({livebook, doctest, four_space_code_block})
  end

  def parse_elixir_cells([], {acc, _, _}), do: acc

  # A new line will always be "" because of how we split.
  def parse_elixir_cells(["" | rest], {acc, "", ""}) do
    parse_elixir_cells(rest, {acc <> "\n", "", ""})
  end

  def parse_elixir_cells(["" | rest], {acc, "", four_space_elixir_block}) do
    parse_elixir_cells(rest, {acc, "", four_space_elixir_block <> "\n"})
  end

  # There is possibly a case to handle when brackets are involved, but for now we assume
  # if you have a new line in a doctest then something is wrong.
  def parse_elixir_cells(["" | _rest], {_acc, _, ""}) do
    raise "Parsing error - doctest needs each line prepended with ...>"
  end

  def parse_elixir_cells(["    " <> code_sample | rest], {acc, "", ""}) do
    parse_elixir_cells(rest, {acc, "", code_sample})
  end

  def parse_elixir_cells(["    " <> code_sample | rest], {acc, "", current_elixir_cell}) do
    parse_elixir_cells(rest, {acc, "", current_elixir_cell <> code_sample})
  end

  def parse_elixir_cells(["    " <> _code_sample | _rest], {_, _, ""}) do
    raise "Parsing error - doctest is wrong, line needs to start with ...>"
  end

  def parse_elixir_cells(["    iex>" <> code_sample | rest], {acc, "", ""}) do
    parse_elixir_cells(rest, {acc, code_sample, ""})
  end

  def parse_elixir_cells(["    iex>" <> _code_sample | _rest], {_acc, _, ""}) do
    raise "Parsing error - You can't have a doctest inside a doctest"
  end

  def parse_elixir_cells(["    ...>" <> _code_sample | _rest], {_acc, "", ""}) do
    raise "Parsing error - missing the begining iex> of the doc test"
  end

  def parse_elixir_cells(["    ...>" <> _code_sample | _rest], {_acc, "", _}) do
    raise "Parsing error - code block indented by 4 spaces can't contain a doctest."
  end

  def parse_elixir_cells(["    ...>" <> code_sample | rest], {acc, current_elixir_cell, ""}) do
    parse_elixir_cells(rest, {acc, current_elixir_cell <> code_sample, ""})
  end

  def parse_elixir_cells([line | rest], {acc, "", ""}) do
    parse_elixir_cells(rest, {acc <> line, "", ""})
  end

  # Here we have reached the end of the 4 space elixir code block (because if it still had
  # 4 spaces previous clauses would catch it). So we can format the code and put it into an
  # elixir block.
  def parse_elixir_cells([line | rest], {acc, "", four_space_elixir_block}) do
    elixir_cell = """

    ```elixir
    #{Code.format_string!(four_space_elixir_block)}
    ```

    """

    parse_elixir_cells(rest, {acc <> elixir_cell <> line, "", ""})
  end

  # Here we are one line after the ...> which means we are on the last line of a doctest.
  # This is the output and so can be ignored because Livebook will output it when you run
  # the cell. But it means we have collected all of the lines and so can format the cell
  # and save it.
  def parse_elixir_cells([_line | rest], {acc, iex_elixir_block, ""}) do
    elixir_cell = """

    ```elixir
    #{Code.format_string!(iex_elixir_block)}
    ```

    """

    parse_elixir_cells(rest, {acc <> elixir_cell, "", ""})
  end
end
