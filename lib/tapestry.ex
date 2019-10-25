defmodule Tapestry.MainApp do
  use Application

  def start(_type, _args) do
    args = System.argv()
    {_num_nodes, _num_requests} = process_args(args)
  end

  def process_args(args) do
    num_nodes = String.to_integer(Enum.at(args, 0))
    num_requests = String.to_integer(Enum.at(args, 1))
    # Base.encode16(:crypto.strong_rand_bytes(4))
    # max hops : 3 or 4 for 1000 nodes

    # check_args(node_count, topology_type, algorithm_type)

    IO.inspect("num_nodes : #{num_nodes}, num_requests : #{num_requests}")

    {num_nodes, num_requests}
  end
end
