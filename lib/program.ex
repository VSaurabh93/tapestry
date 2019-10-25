defmodule Tapestry.Program do

  def start(num_nodes, _num_requests) do
    node_ids = Tapestry.Utils.generate_node_guids(num_nodes)
    [current_node_id | peer_node_ids] = node_ids
    Tapestry.Node.start_link(current_node_id, peer_node_ids)
  end

end
