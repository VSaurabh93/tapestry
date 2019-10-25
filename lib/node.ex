defmodule Tapestry.Node do
 use GenServer

 def start_link(current_node_id, peer_node_ids) do
  routing_table = Tapestry.RoutingTable.create_table(current_node_id, peer_node_ids)
  GenServer.start_link(__MODULE__, {current_node_id, routing_table},
    name: String.to_atom(current_node_id)
  )
end

def init({current_node_id, routing_table}) do
  IO.inspect("Started Worker Node: " <> current_node_id)
  IO.puts("Routing Table:")
  IO.inspect(routing_table)
  {:ok, {current_node_id, routing_table}}
end

end
