defmodule LivebookHelpers do
  # We should try generating livebooks for the Elixir modules.
  # This would mean we could also get a bit meta and use a livebook
  # to append to itself the docs for the module. Or replace itself
  # entirely!

  @moduledoc """
  Documentation for `LivebookHelpers`.
  """

  @doc """
  Takes a module and a path to a file, creates a livebook from the moduledocs in the given
  module. The `.livemd` extension is automatically added. The provided deps are put into a
  `Mix.install` section at the start of the livebook, so the deps should be in the format
  that `Mix.install` allows.

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
  mix create_livebook_from_module LivebookHelpers "my_livebook" "[livebook_helpers: \">= 0.0.0\"]"
  ```
  """
  def livebook_from_module(module, livebook_path, deps) do
    created_file = Path.expand(livebook_path <> ".livemd")
    File.write!(created_file, livebook_string(module, deps))
    created_file
  end

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
  def livebook_from_module(module, livebook_path) do
    created_file = Path.expand(livebook_path <> ".livemd")
    File.write!(created_file, livebook_string(module))
    created_file
  end

  @doc """
  Returns the text that can be used to create a livebook using the docs in the supplied
  module.
  """
  def livebook_string(module, deps) do
    # Check out the docs for fetch_docs to understand the expected return value.
    # https://hexdocs.pm/elixir/Code.html#fetch_docs/1
    case Code.fetch_docs(Module.safe_concat([module])) do
      # Tuple is {:docs_v1, _annotation, _beam_lang, _format, doc, _metadata, function_docs}
      {:docs_v1, _, _, _, doc, _, function_docs} when doc in [:hidden, :none] ->
        livebook = """
        <!-- vim: syntax=markdown -->

        # #{inspect(module)}

        ## Dependencies

        ```elixir
        #{Code.format_string!("Mix.install(#{deps})")}
        ```
        """

        process_function_docs(function_docs, livebook)

      {:docs_v1, _, _, _, %{"en" => module_doc}, _, function_docs} ->
        livebook = """
        <!-- vim: syntax=markdown -->

        # #{inspect(module)}

        ## Dependencies

        ```elixir
        #{Code.format_string!("Mix.install(#{deps})")}
        ```

        #{parse_module_doc(module_doc)}\
        """

        process_function_docs(function_docs, livebook)
    end
  end

  def livebook_string(module) do
    # We need to first check if a module implements any protocols. If it does they will
    # effectively be extra modules that we need to fold into our livebook. If we don't
    # do this the user might be surprised that their nested modules aren't actually
    # documented in the livebook.

    # We could see if the module is a protocol and then try to get all the implementations
    # for it, but that doesn't feel like it would be great docs. Makes more sense to
    # document the implementation of a protocol where it is used...
    case Code.fetch_docs(Module.safe_concat([module])) do
      {:docs_v1, _, _, _, doc, _, function_docs} when doc in [:hidden, :none] ->
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

  # I'm not actually sure if there is a reliable order to the list of docs. Visually it
  # looks like all type docs are grouped together but not sure if that is guaranteed.
  # So we could perhaps put all the typedocs into one Section, but for now they each get
  # their own section.
  def process_function_docs(function_docs, livebook) do
    Enum.reduce(function_docs, livebook, fn
      # We get this for protocols.
      {{:type, _fn_name, _arity}, _, _, :none, _}, acc ->
        acc

      # We get this for protocols.
      {{:callback, _fn_name, _arity}, _, _, doc, _}, acc when doc in [:hidden, :none] ->
        acc

      {{:callback, fn_name, arity}, _, _, %{"en" => doc}, _}, acc ->
        acc <> "## #{fn_name}/#{arity}\n\n" <> elixir_cells(doc)

      {{:type, type_name, _}, _line_number, _, %{"en" => type_doc}, _meta}, acc ->
        acc <> "## Type #{type_name}\n\n" <> elixir_cells(type_doc)

      {{:macro, macro_name, arity}, _, _spec, %{"en" => doc}, _meta}, acc ->
        acc <> "## Macro #{macro_name}/#{arity}\n\n" <> elixir_cells(doc)

      # When there is no function doc we just skip it for now.
      {{:macro, _macro_name, _arity}, _, _spec, :none, _meta}, acc ->
        acc

      {{:macro, _, _}, _, [_], doc, _}, acc when doc in [:hidden, :none] ->
        acc

      {{:macro, _macro_name, _arity}, _, _spec, map, _meta}, acc when map_size(map) == 0 ->
        acc

      {{:function, _, _}, _, [_], doc, _}, acc when doc in [:hidden, :none] ->
        acc

      {{:function, function_name, arity}, _, _spec, %{"en" => doc}, _meta}, acc ->
        acc <> "## Function #{function_name}/#{arity}\n\n" <> elixir_cells(doc)

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
  # we should leave it as an elixir cell. There should be no chars after "elixir" but
  # there may be spaces I guess.
  def parse_elixir_cells(["```elixir" <> _ | rest], livebook) do
    {remaining_lines, elixir_cell} = parse_existing_elixir_cell(rest, "")
    parse_elixir_cells(remaining_lines, livebook <> elixir_cell)
  end

  def parse_elixir_cells(["```elixir" | rest], livebook) do
    {remaining_lines, elixir_cell} = parse_existing_elixir_cell(rest, "")
    parse_elixir_cells(remaining_lines, livebook <> elixir_cell)
  end

  def parse_elixir_cells(["    iex>" <> code_sample | rest], livebook) do
    {remaining_lines, elixir_cell} = parse_doctest(rest, code_sample <> "\n")
    parse_elixir_cells(remaining_lines, livebook <> elixir_cell)
  end

  def parse_elixir_cells(["    ...>" <> _code_sample | _rest], _acc) do
    raise "Parsing error - missing the beginning iex> of the doc test"
  end

  # Seems like one space is also allowed??? See Enum.slide docs as an example.
  def parse_elixir_cells([" *" <> bullet_point | rest], livebook) do
    {remaining_lines, bullets} = parse_bullet_point(rest, 1, "  *" <> bullet_point)
    parse_elixir_cells(remaining_lines, livebook <> bullets)
  end

  def parse_elixir_cells(["  *" <> bullet_point | rest], livebook) do
    # The 2 is the current level of indentation. It's needed to know about
    {remaining_lines, bullets} = parse_bullet_point(rest, 2, "  *" <> bullet_point)
    parse_elixir_cells(remaining_lines, livebook <> bullets)
  end

  # These need to come after the "   ...>" and "    iex>" for obvious reasons.
  # The idea here is that we have reached the expected return value, but the wrinkle is
  # that it can span multiple lines it seems. Which means there must always be at least
  # one new line after the return of a doctest. Not sure if the community know this but
  # this would allow us to generate an Enum livebook for example.
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

  # Turns out this is valid. In Enum for example there are doctests that prepend multiple
  # lines for the same doctest with an `iex>`
  def parse_doctest(["    iex>" <> code_sample | rest], elixir_cell) do
    parse_doctest(rest, elixir_cell <> code_sample <> "\n")
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
  # and save it. The wrinkle is that this might span multiple lines, so we need to keep
  # ignoring until we find a new line with no spaces I think...
  def parse_doctest(["    " <> _line | rest], elixir_cell) do
    parse_doctest_assertion(rest, elixir_cell)
  end

  # This means we have reached a new line so the assertion is over.
  def parse_doctest_assertion(["" | rest], elixir_cell) do
    elixir_cell = """
    ```elixir
    #{Code.format_string!(elixir_cell)}
    ```
    """

    {rest, elixir_cell}
  end

  # Bit weird but an iex after an assertion seems to want to use the previous elixir cells
  # data. See this example:

  # ```
  # ## Examples

  #     iex> chunk_fun = fn element, acc ->
  #     ...>   if rem(element, 2) == 0 do
  #     ...>     {:cont, Enum.reverse([element | acc]), []}
  #     ...>   else
  #     ...>     {:cont, [element | acc]}
  #     ...>   end
  #     ...> end
  #     iex> after_fun = fn
  #     ...>   [] -> {:cont, []}
  #     ...>   acc -> {:cont, Enum.reverse(acc), []}
  #     ...> end
  #     iex> Enum.chunk_while(1..10, [], chunk_fun, after_fun)
  #     [[1, 2], [3, 4], [5, 6], [7, 8], [9, 10]]
  #     iex> Enum.chunk_while([1, 2, 3, 5, 7], [], chunk_fun, after_fun)
  #     [[1, 2], [3, 5, 7]]
  #
  # ```
  def parse_doctest_assertion(["    iex>" <> line | rest], elixir_cell) do
    formatted = """
    ```elixir
    #{Code.format_string!(elixir_cell)}
    ```
    """
    {remaining_lines, elixir_cell} = parse_doctest(["    iex>" <> line | rest], "\n")
    {remaining_lines, formatted <> elixir_cell}
  end

  # If we start with at least 4 spaces then we know we are still asserting.
  def parse_doctest_assertion(["    " <> _line | rest], elixir_cell) do
    parse_doctest_assertion(rest, elixir_cell)
  end

  def parse_bullet_point(["" | rest], indentation, livebook) do
    parse_bullet_point(rest, indentation, livebook <> "\n")
  end

  def parse_bullet_point([line | rest], indentation, livebook) when indentation <= 0 do
    {rest, livebook <> "\n" <> line}
  end

  # We want to allow line wraps in bullet points, meaning you may have a 4 space indent
  # which should not be a code block, eg:
  # ```
  #   * This is a bullet
  #     point still.
  #       * nested bullet point too.
  # ```
  # this means we have to enforce that a bullet point be "done" when there is at least
  # one empty line after OR if there is a new bullet point AT THE SAME LEVEL OF INDENTATION.

  # SO, if we hit a two space bullet point we are onto the next line. We put this first
  # as it's most likely.

  # If we are not the next bullet point we can possibly a line wrap OR a nested bullet
  # point. But to know that we need to know the level of indentation we are working with
  # and that makes simply binary pattern matching not possible.
  def parse_bullet_point([line | rest], indentation, livebook) do
    prefix = String.duplicate(" ", indentation)

    if String.starts_with?(line, prefix <> "*") do
      # if we are here line is the next bullet point.
      parse_bullet_point(rest, indentation, livebook <> "\n" <> line)
    else
      nested_bullet_prefix = String.duplicate(" ", indentation + 2)

      if String.starts_with?(line, nested_bullet_prefix <> "*") do
        # Here we know we are a nested bullet point, so we recur increasing indentation.
        parse_bullet_point(rest, indentation + 2, livebook <> "\n" <> line)
      else
        if String.starts_with?(line, nested_bullet_prefix) do
          # If we are here it means we are line wrapping. I think.
          parse_bullet_point(rest, indentation, livebook <> "\n" <> line)
        else
          # IF we are here then I think the bullet points are done for this level of
          # indentation.
          parse_bullet_point([line | rest], indentation - 2, livebook)
        end
      end
    end
  end
end
