defmodule Tapestry.Program do

  def start(num_nodes, num_requests) do
    node_ids = Tapestry.Utils.generate_node_guids(num_nodes)
    create_nodes(node_ids)
    get_max_hops(num_nodes, num_requests, node_ids)
  end

  def create_nodes(node_ids) do
    for current_node_id <- node_ids ,do:
      Tapestry.Node.start_link(current_node_id, node_ids)
  end

  def get_max_hops(_num_nodes, _num_requests, all_node_ids) do
    source_node = Enum.at(all_node_ids, 0)
    dest_node = Enum.at(all_node_ids, 1)

    Tapestry.Node.get_hops(source_node, dest_node, 5)
  end
end
