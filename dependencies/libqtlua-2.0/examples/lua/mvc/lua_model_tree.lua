#!/usr/bin/env qtlua

function create_model(array)

   -- fetch some constant values
   local display_role          = qt.meta.QtLua__LuaModel.DisplayRole;
   local edit_role             = qt.meta.QtLua__LuaModel.EditRole;

   -- internal index of the model
   local ids = {
      [0] = {
	 value = array,     -- cached item value
	 row_1_id = 1,      -- id of first row item
	 parent_id = 0,     -- id of parent
--	 keys = {}          -- table value keys, filled by get function
      }
   };

   -- next available internal item id
   local next_id = 1;

   return qt.mvc.new_lua_model(

      function(role, item_id, child_row, child_col)     -- get

	 if (role == nil) then       -- layout query
	    local i = ids[item_id]
	    local rows = 0
	    local cols = 0
	    local child_id = 0
	    local parent_id = i.parent_id
	    local item_row = item_id - ids[i.parent_id].row_1_id

	    if (type(i.value) == "table") then
	       local k = i.keys

	       if (k == nil) then    -- create an index for this table value
		  k = {}
		  i.keys = k

		  local row = 1;
		  for key, v in each(i.value) do
		     k[row] = key
		     row = row + 1
		     j = { value = v, parent_id = item_id }
		     ids[next_id + row - 1] = j
		  end

		  i.row_1_id = next_id
		  next_id = next_id + row + 1
	       end

	       rows = #k
	       cols = 1
	       child_id = i.row_1_id + child_row
	    end

	    return rows, cols, child_id, parent_id, item_row, 1

	 elseif (role == display_role) then     -- data query
	    return tostring(ids[item_id].value)
	 end
      end,

      function(role, item_id, value)                   -- set
	 if (role == edit_role) then     -- data query
	    local i = ids[item_id]
	    i.value = value              -- update lua table

	    local p = ids[i.parent_id]
	    local k = p.keys[item_id - p.row_1_id]
	    p.value[k] = value           -- update model cache

	    return true;
	 else
	    return false;
	 end
      end
);

end

data = { { "a", "b" }, {"c", "d"}, "e", "f" };

model = create_model(data)

view = qt.new_qobject(qt.meta.QTreeView);

qt.mvc.set_model(model, view);

view:show()

