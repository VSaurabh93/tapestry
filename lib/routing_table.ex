defmodule Tapestry.RoutingTable do

  @base 16
  @levels 7
  @digits ["0","1","2","3","4","5","6","7","8","9","A", "B", "C", "D", "E", "F"]

  def create_table(current_node_id, peer_node_ids) do

    #node_ids = Tapestry.Utils.generate_node_guids(1000)
    #[current_node_id | peer_node_ids] = node_ids

    #debug
    # current_node_id = "42AD"
    # peer_node_ids = ["400F", "5230", "4227",
    #                  "4629","42A2", "AC78",
    #                  "42E0", "4211", "42A9",
    #                  "42AD", "4112", "42A7"
    #                 ]

    #debug end

    #IO.puts("current node: #{current_node_id}")
    #IO.puts("peer nodes prefix matches:")
    #IO.inspect(peer_node_ids)

    table = create_empty_table()
    prefix_matches = generate_prefix_matches(current_node_id, peer_node_ids) #|> IO.inspect
    populate_table(table, current_node_id, prefix_matches)

  end


  def create_empty_table() do
    _table = for level <- 0..(@levels), into: %{}, do: {level, (for digit <- @digits, into: %{}, do: {digit, nil})}
  end


  def match_nth_digit(current_node_id, other_node_id, n) do
    if String.at(current_node_id, n) == String.at(other_node_id, n), do: true, else: false
  end


  def get_prefix_match(_current_node_id, other_node_id, @levels), do: {@levels, other_node_id}
  def get_prefix_match(current_node_id, other_node_id, n) do
    if match_nth_digit(current_node_id, other_node_id, n) do
      get_prefix_match(current_node_id, other_node_id, n + 1)
  else
    {n, other_node_id}
    end
  end
  def get_prefix_match(current_node_id, other_node_id) do
    get_prefix_match(current_node_id, other_node_id, 0)
 end



  def generate_prefix_matches(current_node_id, peer_node_ids) do
    stored_prefix_matches = for n <- 0..@levels, into: %{}, do: {n, []}
    add_to_stored_matches = fn {n, node_id}, matches -> Map.put(matches, n, matches[n] ++ [node_id]) end

    Enum.reduce(peer_node_ids, stored_prefix_matches,
    fn peer_node, matches ->
      get_prefix_match(current_node_id, peer_node)
      |> add_to_stored_matches.(matches) end)

  end


  def get_closest_node(current_node_id, peer_node_ids) do
     #TODO : current id first or other node id first?
     if length(peer_node_ids) !=0 do
      Enum.min_by(peer_node_ids, fn node_id ->
      (Integer.parse(current_node_id, @base) |> elem(0)) - (Integer.parse(node_id, @base) |> elem(0) |> abs)
      end)
    else
      nil
    end
  end

  def update_table(table, row_key, col_key, node_id) do
    row = table[row_key]
    row = Map.put(row, col_key, node_id)
    _table = Map.put(table, row_key, row)
  end

  def populate_table(table, current_node_id, prefix_matches) do
    Enum.reduce(0..@levels,table, fn level, table_i ->
      level_matches = prefix_matches[level]
      Enum.reduce(@digits,table_i, fn digit, table_i_j ->
          col_nodes = Enum.filter(level_matches, fn node_id ->
              (node_id != current_node_id) and
              (String.at(node_id, level) == digit)
            end)
          selected_node = get_closest_node(current_node_id, col_nodes)
          row_key = level
          col_key = digit
          update_table(table_i_j, row_key, col_key, selected_node)
      end)
    end)
  end

  def query_closest_node_in_table(query_node, table, table_owner_node) do
    match_level = get_prefix_match(table_owner_node, query_node) |> elem(0)
    columns = table[match_level]
    col_key = String.at(query_node, match_level)

    value = table[match_level][col_key]
    cond  do
      value == query_node ->
        #IO.inspect("Match level " <> Integer.to_string(match_level))
        value
      value == nil ->
        IO.inspect("Bug in routing table")
      true ->
        #IO.inspect([query_node, value])
        #column_nodes = Map.values(columns)
        #get_closest_node(query_node, column_nodes)
        value
    end
  end

end
