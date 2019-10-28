defmodule Tapestry.Program do

  def start(num_nodes, num_requests, num_failure) do
    node_ids = Tapestry.Utils.generate_node_guids(num_nodes)

    [first_node | remaining_nodes] = node_ids
    create_nodes(remaining_nodes)
    join_node(remaining_nodes, first_node)

    Tapestry.Counter.start_link(num_nodes*num_requests)
    #hops_task = Task.async(fn -> update_global_max_hops(0, 0, num_nodes*num_requests ) end)
    #:global.register_name(:mainproc, hops_task.pid)
    #start_time = System.system_time(:millisecond)

    if num_failure !=0 do
      failnodes(num_failure,node_ids,num_requests)
      get_max_hops(num_requests, node_ids)

    else
      get_max_hops(num_requests, node_ids)
    end


    # get_max_hops(num_requests, node_ids)
    #Task.await(hops_task, :infinity)
    #time_diff = System.system_time(:millisecond) - start_time
    #IO.puts("Time taken for hops: #{time_diff} milliseconds")
    #System.halt(0)
  end

  def create_nodes(node_ids) do
    for current_node_id <- node_ids ,do:
      Tapestry.Node.start_link(current_node_id, node_ids)

  end

  # def killsomerandom(node_count, kill_nodes_no) do
  #   list = 1..node_count

  #   Enum.each(1..kill_nodes_no, fn _x ->
  #     random_number = Enum.random(list)
  #     random_worker_name = "worker_node_" <> to_string(random_number)
  #     IO.puts("Killed Node: #{random_number}")

  #     if GenServer.whereis(String.to_atom(random_worker_name)) != nil do
  #       Process.exit(GenServer.whereis(String.to_atom(random_worker_name)), :kill)
  #     end
  #   end)
  # end

  def failnodes(num_failure,node_ids,num_request) do
    counter_no=0
    Enum.each(1..num_failure,fn _x ->
      random_node=GenServer.whereis(String.to_atom(Enum.random(node_ids)))
      if random_node != nil do
        Process.exit(random_node,:kill)
        GenServer.cast(:global_counter,:kill_count)
      end
    end)
    counter_no=GenServer.call(:global_counter,:get_killednodes)
    IO.inspect(counter_no)
    GenServer.cast(:global_counter,{:dec_by,counter_no*num_request*2})

  end

  def join_node(node_ids, joining_node)do
    #IO.inspect(joining_node)
    Tapestry.Node.start_link(joining_node, node_ids)
    for current_node_id <- node_ids ,do:
    GenServer.cast(GenServer.whereis(String.to_atom(current_node_id)), {:joinNode, joining_node})

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
