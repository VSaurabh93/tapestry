defmodule Tapestry.Counter do
  use GenServer

  def start_link(counter) do
    GenServer.start_link(__MODULE__, {counter, 0},
      name: :global_counter
    )
  end

  def init( {counter, max_count}) do
    {:ok, {counter, max_count}}
  end

  # def update_count() do
  #   GenServer.cast(:global_counter, {:dec_counter,hop_count})
  # end

  def handle_cast({:dec_counter, hop_count}, {counter, max_count}) do
    if counter==1 do
      IO.inspect("Max hops: " <> Integer.to_string(max_count))
      System.halt(0)
      {:noreply, {counter,hop_count}}
    else
      if hop_count>max_count do
       {:noreply, {counter - 1,hop_count}}
      else

       {:noreply, {counter - 1,max_count}}
      end

    end
  end

end
