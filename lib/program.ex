defmodule Tapestry.Program do

  def start(num_nodes, num_requests) do
    node_ids = Tapestry.Utils.generate_node_guids(num_nodes)

    [first_node | remaining_nodes] = node_ids
    create_nodes(remaining_nodes)
    join_node(remaining_nodes, first_node)

    Tapestry.Counter.start_link(num_nodes*num_requests)
    #hops_task = Task.async(fn -> update_global_max_hops(0, 0, num_nodes*num_requests ) end)
    #:global.register_name(:mainproc, hops_task.pid)
    #start_time = System.system_time(:millisecond)
    get_max_hops(num_requests, node_ids)
    #Task.await(hops_task, :infinity)
    #time_diff = System.system_time(:millisecond) - start_time
    #IO.puts("Time taken for hops: #{time_diff} milliseconds")
    #System.halt(0)
  end

  def create_nodes(node_ids) do
    for current_node_id <- node_ids ,do:
      Tapestry.Node.start_link(current_node_id, node_ids)

  end

  def join_node(node_ids, joining_node)do
    IO.inspect(joining_node)
    Tapestry.Node.start_link(joining_node, node_ids)
    for current_node_id <- node_ids ,do:
    GenServer.cast(String.to_atom(current_node_id), {:joinNode, joining_node})

  end

  def get_max_hops(num_requests, all_node_ids) do
    Enum.each(all_node_ids, fn source_node ->
      get_hops_for_node(source_node, all_node_ids, num_requests)
    end)
  end

  def get_hops_for_node(source_node, all_node_ids, num_requests) do
    destinations = Enum.take_random(all_node_ids, num_requests + 1)
    |> Enum.filter(fn x -> x !=source_node end)
    |> Enum.take(num_requests)

    init_hop_count = 0
    Enum.each(destinations, fn destination_node ->
      Tapestry.Node.get_hops(source_node, destination_node, init_hop_count)
    end)
  end

  def update_global_max_hops(current_max_hops, hops_completed, total_hops) do
    # Receive convergence messages
    if(hops_completed <= total_hops) do
      receive do
        {:globalMaxHops, max_hops} ->
          IO.inspect([hops_completed + 1, total_hops], charlists: false)
          if (hops_completed  == (total_hops - 1)) do
            IO.inspect("Completed: " <> current_max_hops)
          else
            if max_hops > current_max_hops do
            update_global_max_hops(max_hops ,hops_completed + 1, total_hops)
            else
            update_global_max_hops(current_max_hops, hops_completed + 1, total_hops)
            end
          end
      end
    else
      IO.inspect("Completed: " <> current_max_hops)
    end
  end
end
