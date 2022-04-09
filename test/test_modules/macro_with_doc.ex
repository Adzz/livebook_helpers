defmodule MacroWithDoc do
  @doc """
  Returns 1 probably.

      iex> 1 + 1
      2
  """
  defmacro with_a_doc() do
    quote do
      1
    end
  end
end
