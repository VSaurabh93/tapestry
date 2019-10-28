defmodule Tapestry.MainApp do
  use Application

  def start(_type, _args) do
    args = System.argv()
    {num_nodes, num_requests, num_failure} = process_args(args)
    Tapestry.Program.start(num_nodes, num_requests,num_failure)
    {:ok, self()}
  end

  @spec process_args(any) :: {any, any, any}
  def process_args(args) do
    num_nodes = String.to_integer(Enum.at(args, 0))
    num_requests = String.to_integer(Enum.at(args, 1))
    num_failure =0
    if Enum.at(args,2)==nil do
    IO.inspect("num_nodes : #{num_nodes}, num_requests : #{num_requests}")
    {num_nodes, num_requests, num_failure}
    else
      num_failure = String.to_integer(Enum.at(args,2))
      IO.inspect("num_nodes : #{num_nodes}, num_requests : #{num_requests}, num_failure : #{num_failure}")

      {num_nodes,num_requests,num_failure}
    end
  end
end
