defmodule Tapestry.Program do

  def start(num_nodes, _num_requests) do
    node_ids = Tapestry.Utils.generate_node_guids(num_nodes)
    create_nodes(node_ids)
  end

  defp create_nodes(node_ids) do

    for current_node_id <- node_ids ,do:
      Tapestry.Node.start_link(current_node_id, node_ids)
  end

end
