defmodule LivebookHelpersTest do
  use ExUnit.Case
  doctest LivebookHelpers

  test "Can turn a simple docttest into a livebook" do
    LivebookHelpers.livebook_from_module(Mod)
  end
end
