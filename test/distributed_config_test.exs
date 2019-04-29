defmodule DistributedConfigTest do
  use ExUnit.Case
  doctest DistributedConfig

  test 'write' do
    {:ok, result } = DistributedConfig.write("a.b.c", 1)
    {:ok, foundValue } = Map.fetch(result, "a.b.c")
    assert foundValue == 1
  end
end
