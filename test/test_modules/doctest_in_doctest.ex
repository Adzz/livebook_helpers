defmodule DoctestInDoctest do
  @moduledoc """
  This is not allowed:

      iex> 1 * 1
      iex> 2
      2

  This is:

      iex> 1 * 1
      ...> 2
      2

  And this:

      iex> 1 * 1
      1

      iex> 2
      2
  """
end
