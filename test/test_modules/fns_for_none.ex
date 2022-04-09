defmodule FnsForNone do
  def one, do: 1
  @doc false
  def two, do: three() - one()

  defp three, do: 3

  @doc "actually returns 3" && false
  def four, do: 3
end
