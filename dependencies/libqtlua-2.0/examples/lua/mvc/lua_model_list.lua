#!/usr/bin/env qtlua

function create_model(array)

   -- fetch some constant values
   local display_role          = qt.meta.QtLua__LuaModel.DisplayRole;
   local background_color_role = qt.meta.QtLua__LuaModel.BackgroundColorRole;
   local QColor_type           = qt.meta_type("QColor")

   return qt.mvc.new_lua_model(

      function(role, item_id, child_row, child_col)     -- get

	 -- return item child count and choose an item_id for each item
	 if (role == nil) then

	    -- model root ?
	    if (item_id == 0) then
	       -- reuse row index as our item_id
	       return #array, 1, child_row
	    else
	       -- no children item
	       return 0, 0, 0;
	    end

	 -- get item data
	 elseif (role == display_role) then
	    -- return a lua number or string value, let QtLua handle the conversion
	    return array[item_id]

	 -- use alternating item background colors
	 elseif (role == background_color_role) then
	    if (item_id % 2 == 0) then
	       -- we need to tell QtLua how to convert this table value
	       return { 200, 200, 255 }, QColor_type
	    else
	       return { 200, 255, 200 }, QColor_type
	    end
	 end
      end,

      function(role, item_id, value)                   -- set
	 array[item_id] = value;
	 return true;
      end,

      function(check, parent_id, pos, count)           -- insert rows
	 if (check) then
	    return true;
	 end
	 for i = 1, count do
	    table.insert(array, pos, "new_entry");
	 end
      end,

      function(check, parent_id, pos, count)           -- remove rows
	 if (check) then
	    return true;
	 end
	 for i = 1, count do
	    table.remove(array, pos);
	 end
      end,

      nil,                 -- insert column

      nil);                -- remove column

end

data = { "a", "b", "c", "d", "e", "f" };

model = create_model(data)

view = qt.new_qobject(qt.meta.QListView);

qt.mvc.set_model(model, view);

view:show()

