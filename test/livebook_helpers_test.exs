defmodule LivebookHelpersTest do
  use ExUnit.Case
  doctest LivebookHelpers

  test "greets the world" do
    assert LivebookHelpers.hello() == :world
  end
end
