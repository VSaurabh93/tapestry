defmodule Joiner do
    def start(current_node_id,table,new_node) do


     #Get Level where the new node belongs which will be your row_no
     {level,new_node}=Tapestry.RoutingTable.get_prefix_match(current_node_id, new_node)
     row_no=level

     #getting column_no from the new_nodes name
     column_no=String.at(new_node, level)

     #get current value which is in the table
     val=table[row_no][column_no]

     #update the value
   #  IO.inspect("Your old val:"<>val)
     if val==nil do
    #   IO.inspect("replace with: "<>new_node)
      Tapestry.RoutingTable.update_table(table, row_no, column_no, new_node)
     else
      replacement=Tapestry.RoutingTable.get_closest_node(current_node_id, [val,new_node])
    #   IO.inspect("replace with:"<>replacement)
      Tapestry.RoutingTable.update_table(table, row_no, column_no, replacement)
     end

    end
end
