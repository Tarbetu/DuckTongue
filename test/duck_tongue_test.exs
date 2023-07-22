defmodule DuckTongueTest do
  use ExUnit.Case
  doctest DuckTongue

  test "greets the world" do
    assert DuckTongue.hello() == :world
  end
end
