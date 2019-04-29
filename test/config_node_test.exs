defmodule ConfigNodeTest do
  use ExUnit.Case
  doctest DistributedConfig

  describe "read/2" do
    test 'read simple value' do
      {:ok, root_node , new_node } = ConfigNode.write(%ConfigNode{name: 'root'}, "a", 1)
      value = ConfigNode.read(root_node, "a")
      assert value == 1
    end

    test 'read nested value' do
      {:ok, root_node , new_node } = ConfigNode.write(%ConfigNode{name: 'root'}, "a.b", 1)
      value = ConfigNode.read(root_node, "a")
      assert value == nil 
      value = ConfigNode.read(root_node, "a.b")
      assert value == 1
    end

    test 'read fanned out values' do
      {:ok, root_node , new_node } = ConfigNode.write(%ConfigNode{name: 'root'}, "a", 1)
      {:ok, root_node , new_node } = ConfigNode.write(root_node, "b", 2)
      value = ConfigNode.read(root_node, "a")
      assert value == 1
      value = ConfigNode.read(root_node, "b")
      assert value == 2
    end

    test 'read fanned out and nested values' do
      {:ok, root_node , new_node } = ConfigNode.write(%ConfigNode{name: 'root'}, "a", 1)
      {:ok, root_node , new_node } = ConfigNode.write(root_node, "b", 2)
      {:ok, root_node , new_node } = ConfigNode.write(root_node, "b.c", 3)
      value = ConfigNode.read(root_node, "a")
      assert value == 1
      value = ConfigNode.read(root_node, "b")
      assert value == 2
      value = ConfigNode.read(root_node, "b.c")
      assert value == 3
    end
  end

  describe "write/3" do
    test 'write node' do
      {:ok, original_node, new_node } = ConfigNode.write(%ConfigNode{name: 'root'}, "a", 1)
      assert new_node.name == "a"
      assert MapSet.size(original_node.children) == 1
      assert MapSet.member?(original_node.children, new_node) == true
      assert new_node.value == 1
    end

    test 'multiple nodes' do
      root_node = %ConfigNode{name: 'root'}
      {:ok, root_node, new_node_a } = ConfigNode.write(root_node, "a", 1)
      {:ok, root_node, new_node_b } = ConfigNode.write(root_node, "b", 2)

      assert new_node_a.name == "a"
      assert new_node_b.name == "b"

      assert new_node_a.value == 1
      assert new_node_b.value  == 2

      assert MapSet.size(root_node.children) == 2
      assert MapSet.member?(root_node.children, new_node_a) == true
      assert MapSet.member?(root_node.children, new_node_b) == true
    end

    test 'nested multiple nodes' do
      root_node = %ConfigNode{name: 'root'}
      {:ok, root_node, new_node_a } = ConfigNode.write(root_node, "a", 1)
      assert new_node_a.name == "a"
      assert new_node_a.value == 1
      {:ok, root_node , new_node_b } = ConfigNode.write(root_node, "a.b", 2)
      assert new_node_b.name == "b"
      assert new_node_b.value  == 2

      assert MapSet.size(root_node.children) == 1
      assert MapSet.size(Enum.at(root_node.children, 0).children) == 1
    end

    test 'nested multiple nodes in reverse' do
      root_node = %ConfigNode{name: 'root'}
      {:ok, root_node , new_node_b } = ConfigNode.write(root_node, "a.b", 2)
      assert new_node_b.value  == 2

      {:ok, root_node, new_node_a } = ConfigNode.write(root_node, "a", 1)
      assert new_node_b.name == "b"
      assert new_node_a.name == "a"
      assert new_node_a.value == 1

      assert MapSet.size(root_node.children) == 1
      assert MapSet.size(Enum.at(root_node.children, 0).children) == 1
    end
  end
end
