defmodule DistributedConfig do
  defstruct root: %ConfigNode{name: 'root'}
  @moduledoc """
  Documentation for DistributedConfig.
  """

  @doc """
  Hello world.

  ## Examples

      iex> DistributedConfig.hello
      :world

  """
  def hello do
    :world
  end

  def write(path, value) do
    {:ok, %{ path => value } }
  end
end
