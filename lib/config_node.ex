defmodule ConfigNode do
  defstruct name: nil, children: MapSet.new(), value: nil

  def read(root_node, path) do
    [ head | tail ] = String.split(path, ".")
    existing_node = root_node.children
                |> Enum.filter( fn n -> n.name == head  end )
                |> Enum.at(0)
    if existing_node do
      if Enum.count(tail) == 0 do
        existing_node.value
      else
        read(existing_node, Enum.join(tail, "."))
      end
    else
      nil
    end
  end 

  @doc """
  [IMMUTABLE]

  writes the intended value to the correct node that is
  contained in the corresponding children attribute to the ConfigNode module

  This function treats nodes as immutable. See the return declaration here to
  understand more.

  params:
  - root_node - the node to start parsing the path to write the value to
  - path - a "." delimited string indicating the name of the nodes to traverse
    in order to place the value at the last token of the path
  - value - the value to place at the resulting node

  Returns - { :ok, new_root, new_node }
  - new_root - the updated root after adding n nodes underneath the original
  node to create a path to the intended node
  - new_node the final node that was created that contains the value originally passed
  """
  def write(root_node, path, value) do
    [ head | tail ] = String.split(path, ".")
    existing_node = root_node.children
                |> Enum.filter( fn n -> n.name == head  end )
                |> Enum.at(0)
    if existing_node do
      if Enum.count(tail) == 0 do
        new_node = %ConfigNode{ existing_node | value: value }
        new_children = root_node.children
                       |> MapSet.delete(existing_node)
                       |> MapSet.put(new_node)

        new_root = %ConfigNode{ root_node | children: new_children }
        { :ok,  new_root, new_node }
      else
        { :ok, returned_root, new_node } = write(existing_node, Enum.join(tail, "."), value)
        new_children = root_node.children
                       |> MapSet.delete(existing_node)
                       |> MapSet.put(returned_root)
        new_root = %ConfigNode{ root_node | children: new_children }
        { :ok,  new_root, new_node }
      end
    else
      if Enum.count(tail) == 0 do
        new_node = %ConfigNode{ name: head, value: value }
        new_root = %ConfigNode{ root_node | children: MapSet.put(root_node.children, new_node) }
        { :ok,  new_root, new_node }
      else
        new_node = %ConfigNode{ name: head, value: nil }
        { :ok, new_root, created } = write(new_node, Enum.join(tail, "."), value)
        new_root = %ConfigNode{ root_node | children: MapSet.put(root_node.children, new_root) }
        { :ok, new_root, created } 
      end
    end
  end
end
