defmodule MacroWithNoDoc do
  @moduledoc """
  A wild doc appeared!
  """
  defmacro no_doc() do
    quote do
      1
    end
  end
end
