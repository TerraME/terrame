<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
   "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<%
if module_doc then
	from = "modules/"..module_doc.name
elseif file_doc then
	from = "files/.."..file_doc.name
else
	from = ""
end
%>
<% if file_doc.name:match("(.-)%.lua") ~= func.name then %>
<dt><h2><%=func.private and "local " or ""%><a name="<%=func.name%>">
<%if func.deprecated and func.deprecated[1] then%>
	<%if func.deprecated[2] then%>
		<%local href = luadoc.symbol_link(func.deprecated[2], doc, module_doc, file_doc, from, doc_report)
		local _,_,filename, funcname = string.find(func.deprecated[2], "^(.-)[%.%:]?([^%.%:]*)$")
		local text
		if filename ~= "" and filename ~= string.gsub(file_doc.name, "%.lua$", "") then 
		  	text = funcname.." ("..filename..")"
		else
		  	text = funcname
		end%>

		</a><font color="gray"><%=func.name%> <i>(deprecated, use
			<%if href ~= "unresolved" then %>	
				<a href="<%=href%>"><%=text%></a> 
			<%else%> 
				<%=func.deprecated[2]%> 
			<%end%>
		instead)</i></font>&nbsp;
	<%else%>
		</a><font color="gray"><%=func.name%><i> (deprecated) </font></i>&nbsp;
	<%end%>
<%else%>
	</a><strong><%=func.name%></strong>&nbsp;
<%end%>
</h2></dt>
<dd>
<%end %>
<%if func.deprecated then%><font color="gray"><%end%>
<span class="description"><%=
luadoc.link_description(func.description or "", doc, module_doc, file_doc, from, true, doc_report)%></span>

<%if type(func.tabular) == "table" and #func.tabular > 0 then %>
	<%for i = 1, #func.tabular do 
		if not func.arg[func.tabular[i]] then
			local tab = func.tabular[func.tabular[i]] %> 
			<table class="arg_tab">
			<% for j, line in ipairs(tab) do %>
				<tr>
					<% local td
					if j == 1 then td = "th" else td = "td"  end 
						for _, data in ipairs(line) do %>
							<<%=td%>>
							<%= data %>
							</<%=td%>>
						<%end 
					end%>
				</tr>    
			</table>
		<%end
	end
end %>

<% if type(func.arg) == "table" and #func.arg > 0 then %>
<!-- Function arguments -->
  <h3>Arguments</h3>
<ul><span class="arg">
<%for i = 1, #func.arg do
	local arg_desc = func.arg[func.arg[i]] or ""
	local arg_name
	if func.arg.named then
		arg_name = func.arg[i]
	else
		local sufix
		if i == 1 then
			sufix = "st"
		elseif i == 2 then
			sufix = "nd"
		elseif i == 3 then
			sufix = "rd"
		else
			sufix = "th"
		end
		arg_name = i .. sufix
	end %>
    <li>
	  <strong><%=arg_name%></strong>: <%= luadoc.link_description(arg_desc or "", doc, module_doc, file_doc, from, nil, doc_report) %>
    </li> 
    <% if type(func.tabular) == "table" and func.tabular[func.arg[i]] then %>
      </span>
      <!-- Strategy of the argument -->
      <% local tab = func.tabular[func.arg[i]]
      for i = 1, #func.tabular do
        if func.tabular[func.tabular[i]] == tab then
          table.remove(func.tabular, i)
          break
        end
      end
       %> 
      <table class="arg_tab">
	  <%util.parse_tab(tab, func, file_doc.name, doc_report)%>
      <% for j, line in ipairs(tab) do %>
        <tr>
        <% for _, data in ipairs(line) do %>
          <% local td
          if j == 1 then td = "th" else td = "td"  end %>
            <<%=td%>>
            <%= luadoc.link_description(data or "", doc, module_doc, file_doc, from, nil, doc_report) %>
            </<%=td%>>
          <% end %>
        <% end %>
        </tr>    
      </table>
      <span class="arg">
    <% end %>
  <%end%>
  </span></ul>
<%end%>

<%if type(func.output) == "table" and #func.output > 0 then%>
<!-- Outputs of the function -->
<p>Attributes of <%=file_doc.name:match("(.-)%.lua")%> that can be used as <b>read-only</b> by the modeler:</p>
<ul>
<span class="output">
	<%for p = 1, #func.output do%>
	<li>
	  <strong><%=func.output[p]%></strong>: <%=
	  luadoc.link_description(func.output[func.output[p]] or "", doc, module_doc, file_doc, from, nil, doc_report)%>
	</li>
	<%end%>
</span>
</ul>
<%end%>

<%if type(func.ret) == "string" then%>
<h3>Return value:</h3>
<ol>
<%=func.ret%>
</ol>
<%elseif type(func.ret) == "table" then%>
<h3>Return values:</h3>
<ol>
	<%for _, ret in ipairs(func.ret) do%>
	<li><%= ret %>
	<%end%>
</ol>
<%end%>

<%if type(func.usage) == "string" then%>
<h3>Usage</h3>
<pre class="example"><code><%=hl.parse(func.usage)%></code></pre>
<%elseif type(func.usage) == "table" then%>
<h3>Usage</h3>
<pre class="example"><code><ul>
	<%for _, usage in ipairs(func.usage) do%>
	<li><%= usage %>
	<%end%>
</ul></code></pre>
<%end%>
<%if func.deprecated then%></font><%end%>

<%if type(func.see) == "string" then %>
<h3>See also</h3>
	<a href="<%=func.see%>"><%=func.see%></a>
<%elseif type(func.see) == "table" and #func.see > 0 then %>
<h3>See also</h3>
<ul>
	<%for i = 1, #func.see do %>
	<li>
		<%local href = luadoc.symbol_link(func.see[i], doc, module_doc, file_doc, from, doc_report)
		local _,_,filename, funcname = string.find(func.see[i], "^(.-)[%.%:]?([^%.%:]*)$")
		local text
		if filename ~= "" and filename ~= string.gsub(file_doc.name, "%.lua$", "") then
		  	text = funcname.." ("..filename..")"
		else
		  	text = funcname
		end%>

		<%if href ~= "unresolved" then %>	<a href="<%=href%>"><%=text%>	</a>
		<%else%>	<font color="red"><b><%="Unresolved link to function "..func.see[i]%></b></font>
		<%end%>
	</li>
	<%end%>
</ul>
<%end%>
</dd>

