defmodule DoctestSpansLines do
  @moduledoc """
  of said module:

      iex> users = [
      ...>   %{name: "Ellis", birthday: ~D[1943-05-11]},
      ...>   %{name: "Lovelace", birthday: ~D[1815-12-10]},
      ...>   %{name: "Turing", birthday: ~D[1912-06-23]}
      ...> ]
      iex> Enum.min_max_by(users, &(&1.birthday), Date)
      {
        %{name: "Lovelace", birthday: ~D[1815-12-10]},
        %{name: "Ellis", birthday: ~D[1943-05-11]}
      }

  Finally, if you don't want to raise on empty enumerables, you can pass
  the empty fallback:

      iex> Enum.min_max_by([], &String.length/1, fn -> nil end)
      nil

  """
end
