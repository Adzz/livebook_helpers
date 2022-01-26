defmodule Mod do
  @moduledoc """
  This is a livebook.

      a = 1 + 1
      b = 2 * a
      15

      iex> a = [1, 2,                      4]
      ...> a ++ [5]
      [1,2,3,4,5]

  ### With a bit of stuff in it....

      iex> 1
      1
  """

  @doc """
  This is a thing, with examples.

  ### Examples

      iex> a = 1 + 1
      ...> b = 2 * a
      15
  """
  def dummy_function(x), do: :k
  def dummy_function(1), do: :k

  @doc "ANOTHER ONE"
  def second_function(), do: 2
end
