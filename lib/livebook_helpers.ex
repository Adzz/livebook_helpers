defmodule LivebookHelpers do
  @moduledoc """
  Documentation for `LivebookHelpers`.
  """

  @doc """
  Takes a module and a path to a file, creates a livebook from the moduledocs in the given
  module. The `.livemd` extension is automatically added. Returns the file path for the
  created livebook.

  This function will take a module and turn the module doc found there into a livebook.
  This make it really easy to create one set of information and have it be represented
  in different formats. For example you can write a README, use it as the moduledoc then
  run this function to spit out a livebook with all the same info.

  Below is a summary of what we do to create the Livebook:

  * The module is used as the title for the Livebook.
  * Each function's @doc is put under a section with the function's name and arity.
  * doctests become (formatted) elixir cells
  * The magic line to make github render livebooks as markdown is added.

  ### Examples

  ```sh
  mix create_livebook_from_module LivebookHelpers "my_livebook"
  ```
  """
  def livebook_from_module(module, livebook_path, deps) do
    created_file = Path.expand(livebook_path <> ".livemd")
    File.write!(created_file, livebook_string(module, deps))
    created_file
  end
  def livebook_from_module(module, livebook_path) do
    created_file = Path.expand(livebook_path <> ".livemd")
    File.write!(created_file, livebook_string(module))
    created_file
  end

  @doc """
  Returns the text that can be used to create a livebook using the docs in the supplied module.
  """
  def livebook_string(module, deps) do
    case Code.fetch_docs(Module.safe_concat([module])) do
      {:docs_v1, _, _, _, :hidden, _, function_docs} ->
        livebook = """
        <!-- vim: syntax=markdown -->

        # #{inspect(module)}

        ## Dependencies

        ```elixir
        Mix.install(#{deps})
        ```
        """

        process_function_docs(function_docs, livebook)

      {:docs_v1, _, _, _, %{"en" => module_doc}, _, function_docs} ->
        livebook = """
        <!-- vim: syntax=markdown -->

        # #{inspect(module)}

        ## Dependencies

        ```elixir
        Mix.install(#{deps})
        ```

        #{parse_module_doc(module_doc)}\
        """

        process_function_docs(function_docs, livebook)
    end
  end

  def livebook_string(module) do
    case Code.fetch_docs(Module.safe_concat([module])) do
      {:docs_v1, _, _, _, :hidden, _, function_docs} ->
        livebook = """
        <!-- vim: syntax=markdown -->

        # #{inspect(module)}

        """

        process_function_docs(function_docs, livebook)

      {:docs_v1, _, _, _, %{"en" => module_doc}, _, function_docs} ->
        livebook = """
        <!-- vim: syntax=markdown -->

        # #{inspect(module)}

        #{parse_module_doc(module_doc)}\
        """

        process_function_docs(function_docs, livebook)
    end
  end

  def process_function_docs(function_docs, livebook) do
    Enum.reduce(function_docs, livebook, fn
      {{:macro, macro_name, arity}, _, [_spec], %{"en" => doc}, _meta}, acc ->
        acc <> "## #{macro_name}/#{arity}\n\n" <> elixir_cells(doc)

      # When there is no function doc we just skip it for now.
      {{:macro, _macro_name, _arity}, _, [_spec], :none, _meta}, acc ->
        acc

      {{:macro, _, _}, _, [_], :hidden, _}, acc ->
        acc

      {{:macro, _macro_name, _arity}, _, [_spec], map, _meta}, acc when map_size(map) == 0 ->
        acc

      {{:function, _, _}, _, [_], :hidden, _}, acc ->
        acc

      {{:function, _function_name, _arity}, _line_number, [_spec], :none, _}, acc ->
        acc

      {{:function, function_name, arity}, _, [_spec], %{"en" => doc}, _meta}, acc ->
        acc <> "## #{function_name}/#{arity}\n\n" <> elixir_cells(doc)

      {{:function, _, _}, _, [_], map, _}, acc when map_size(map) == 0 ->
        acc
    end)
  end

  def parse_module_doc(module_doc) do
    livebook = ""

    module_doc
    |> String.split("\n")
    |> parse_elixir_cells(livebook)
  end

  def elixir_cells(doc) do
    livebook = ""

    doc
    |> String.split("\n")
    |> parse_elixir_cells(livebook)
  end

  def parse_elixir_cells([], livebook), do: livebook

  # A "" means it was a line of just a \n.
  def parse_elixir_cells(["" | rest], livebook) do
    parse_elixir_cells(rest, livebook <> "\n")
  end

  # Sometime there will be a ``` section already, if there is and it's marked as elixir
  # we should leave it as an elixir cell. There should be no chars after "elixir"
  def parse_elixir_cells(["```elixir" <> _ | rest], livebook) do
    {remaining_lines, elixir_cell} = parse_existing_elixir_cell(rest, "")
    parse_elixir_cells(remaining_lines, livebook <> elixir_cell)
  end

  def parse_elixir_cells(["    iex>" <> code_sample | rest], livebook) do
    {remaining_lines, elixir_cell} = parse_doctest(rest, code_sample <> "\n")
    parse_elixir_cells(remaining_lines, livebook <> elixir_cell)
  end

  def parse_elixir_cells(["    ...>" <> _code_sample | _rest], {_acc, "", ""}) do
    raise "Parsing error - missing the beginning iex> of the doc test"
  end

  # These need to come after the "   ...>" and "    iex>" for obvious reasons.
  def parse_elixir_cells(["    " <> code_sample | rest], livebook) do
    {remaining_lines, elixir_cell} = parse_four_space_code_blocks(rest, code_sample <> "\n")
    parse_elixir_cells(remaining_lines, livebook <> elixir_cell)
  end

  def parse_elixir_cells([line | rest], livebook) do
    parse_elixir_cells(rest, livebook <> line <> "\n")
  end

  # Existing cells =======================================================================

  defp parse_existing_elixir_cell(["" | rest], code_contents) do
    parse_existing_elixir_cell(rest, code_contents <> "\n")
  end

  defp parse_existing_elixir_cell(["```" <> _ | rest], code_contents) do
    elixir_cell = """
    ```elixir
    #{Code.format_string!(code_contents)}
    ```

    """

    {rest, elixir_cell}
  end

  defp parse_existing_elixir_cell([code_line | rest], code_contents) do
    parse_existing_elixir_cell(rest, code_contents <> code_line <> "\n")
  end

  def parse_four_space_code_blocks(["    iex>" <> line | rest], four_space_elixir_block) do
    elixir_cell = """
    ```elixir
    #{Code.format_string!(four_space_elixir_block)}
    ```

    """

    {["    iex>" <> line | rest], elixir_cell}
  end

  def parse_four_space_code_blocks(["    ...>" <> line | rest], four_space_elixir_block) do
    elixir_cell = """
    ```elixir
    #{Code.format_string!(four_space_elixir_block)}
    ```
    """

    {["    ...>" <> line | rest], elixir_cell}
  end

  def parse_four_space_code_blocks(["    " <> code_sample | rest], elixir_cell) do
    parse_four_space_code_blocks(rest, elixir_cell <> code_sample <> "\n")
  end

  def parse_four_space_code_blocks(["" | remaining_lines], four_space_elixir_block) do
    parse_four_space_code_blocks(remaining_lines, four_space_elixir_block <> "\n")
  end

  # If the next line is anything else (ie not a 4 space indented line or new line) we are done.
  def parse_four_space_code_blocks(remaining_lines, four_space_elixir_block) do
    elixir_cell = """
    ```elixir
    #{Code.format_string!(four_space_elixir_block)}
    ```
    """

    {remaining_lines, elixir_cell}
  end

  def parse_doctest(["    iex>" <> _code_sample | _rest], _acc) do
    raise "Parsing error - You can't have a doctest inside a doctest"
  end

  def parse_doctest(["    ...>" <> code_sample | rest], elixir_cell) do
    parse_doctest(rest, elixir_cell <> code_sample <> "\n")
  end

  # There is possibly a case to handle when brackets are involved, but for now we assume
  # if you have a new line in a doctest then something is wrong.
  def parse_doctest(["" | _], _elixir_cell) do
    raise "Parsing error - doctest can't have blank lines in them"
  end

  # Here we are one line after the ...> which means we are on the last line of a doctest.
  # This is the output and so can be ignored because Livebook will output it when you run
  # the cell. But it means we have collected all of the lines and so can format the cell
  # and save it.
  def parse_doctest([_line | rest], elixir_cell) do
    elixir_cell = """
    ```elixir
    #{Code.format_string!(elixir_cell)}
    ```
    """

    {rest, elixir_cell}
  end
end
