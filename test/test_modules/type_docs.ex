defmodule TypeDocs do
  @typedoc "This is a private type"
  @typep thing :: String.t()
  @typedoc "This is a type"
  @type other_thing :: String.t()

  @spec fun_time(String.t()) :: integer()
  @doc """
  doc AND a spec?!
  """
  def fun_time(_s), do: 1

  @typedoc """
  This is a type lower down the module, can it have elixir cells in it?

      iex>1 + 1
      2

  This probably wont test?

      "example elixir though"
  """
  @type final :: String.t()
  @spec thing(final) :: integer()
  def thing(_), do: 2
end
