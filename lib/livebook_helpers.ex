defmodule LivebookHelpers do
  @moduledoc """
  Documentation for `LivebookHelpers`.
  """

  @doc """
  This function will take a module and turn the module doc found there into a livebook.
  This make it really easy to create one set of information and have it be represented
  in different formats. For example you can write a README, use the readme as the
  moduledoc then run this function to spit out a livebook with all the same info.

  This will turn the doctests into elixir sections in a livebook.
  """
  def livebook_from_module_doc(module) do
  end
end
