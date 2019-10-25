defmodule Tapestry.Utils do
  def generate_node_guids(node_count) do
    _guid_list =
      for n <- 1..node_count,
          do: :crypto.hash(:sha, Integer.to_string(n)) |> Base.encode16() |> String.slice(0..7)
  end
end
