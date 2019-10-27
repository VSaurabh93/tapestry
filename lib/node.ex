defmodule Tapestry.Node do
 use GenServer

 def start_link(current_node_id, peer_node_ids) do
  routing_table = Tapestry.RoutingTable.create_table(current_node_id, peer_node_ids)
  GenServer.start_link(__MODULE__, {current_node_id, routing_table},
    name: String.to_atom(current_node_id)
  )
end

def init({current_node_id, routing_table}) do
  #IO.inspect("Started Worker Node: " <> current_node_id)
  #IO.puts("Routing Table:")
  #IO.inspect(routing_table)
  {:ok, {current_node_id, routing_table}}
end


def get_hops(source_node, dest_node, hop_count) do
  node_name = String.to_atom(source_node)
  GenServer.cast(node_name, {:getHops,{source_node, dest_node, hop_count}})
end

def handle_cast({:getHops, {source_node, dest_node, hop_count}}, {current_node_id, routing_table}) do
  closest_node = Tapestry.RoutingTable.query_closest_node_in_table(dest_node, routing_table, current_node_id)
  if closest_node == dest_node do
    # update some global service about hops
    #IO.puts("reached " <> dest_node <> " in " <> Integer.to_string(hop_count) <> " hops ")
    #send(:global.whereis_name(:mainproc), {:globalMaxHops, hop_count})
    GenServer.cast(:global_counter, {:dec_counter,hop_count})
    {:noreply, {current_node_id, routing_table}}
  else
    #IO.inspect(source_node <> Integer.to_string(hop_count) <> " hops ")
    # IO.inspect(["Hopping from ",current_node_id, " to ", closest_node,
    #           " current hops: ", Integer.to_string(hop_count + 1)])
    get_hops(closest_node, dest_node , hop_count + 1)
    {:noreply, {current_node_id, routing_table}}
  end
end

def handle_cast({:joinNode, new_node}, {current_node_id, routing_table}) do
  routing_table = Joiner.start(current_node_id,routing_table,new_node)
  {:noreply, {current_node_id, routing_table}}
end
end
