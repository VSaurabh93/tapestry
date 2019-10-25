defmodule Tapestry.MainApp do
  use Application

  def start(_type, _args) do
    args = System.argv()
    {num_nodes, num_requests} = process_args(args)
    Tapestry.Program.start(num_nodes, num_requests)
    {:ok, self()}
  end

  def process_args(args) do
    num_nodes = String.to_integer(Enum.at(args, 0))
    num_requests = String.to_integer(Enum.at(args, 1))
    IO.inspect("num_nodes : #{num_nodes}, num_requests : #{num_requests}")
    {num_nodes, num_requests}
  end
end
