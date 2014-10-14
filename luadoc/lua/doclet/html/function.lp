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
</a><strong><%=func.name%></strong>&nbsp;
</h2></dt>
<dd>
<%end %>
<span class="description"><%=
luadoc.doclet.html.link_description(func.description or "", doc, module_doc, file_doc, from, true)%></span>

<%if type(func.tab) == "table" and #func.tab > 0 then %>
	<%for i = 1, #func.tab do 
		if not func.param[func.tab[i]] then
			local tab = func.tab[func.tab[i]] %> 
			<table class="param_tab">
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

<% if type(func.param) == "table" and #func.param > 0 then %>
<!-- Function parameters -->
  <h3>Parameters</h3>
<ul><span class="param">
<%for i = 1, #func.param do
	local param_desc = func.param[func.param[i]] or ""
	local param_name
	if func.param.named then
		param_name = func.param[i]
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
		param_name = i .. sufix
	end %>
    <li>
	  <strong><%=param_name%></strong>: <%= luadoc.doclet.html.link_description(param_desc or "", doc, module_doc, file_doc, from) %>
    </li> 
    <% if type(func.tab) == "table" and func.tab[func.param[i]] then %>
      </span>
      <!-- Strategy of the parameter -->
      <% local tab = func.tab[func.param[i]]
      for i = 1, #func.tab do
        if func.tab[func.tab[i]] == tab then
          table.remove(func.tab, i)
          break
        end
      end
       %> 
      <table class="param_tab">
	  <%util.parse_tab(tab, func, file_doc.name)%>
      <% for j, line in ipairs(tab) do %>
        <tr>
        <% for _, data in ipairs(line) do %>
          <% local td
          if j == 1 then td = "th" else td = "td"  end %>
            <<%=td%>>
            <%= luadoc.doclet.html.link_description(data or "", doc, module_doc, file_doc, from) %>
            </<%=td%>>
          <% end %>
        <% end %>
        </tr>    
      </table>
      <span class="param">
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
	  luadoc.doclet.html.link_description(func.output[func.output[p]] or "", doc, module_doc, file_doc, from)%>
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

<%if type(func.see) == "string" then %>
<h3>See also</h3>
	<a href="<%=func.see%>"><%=func.see%></a>
<%elseif type(func.see) == "table" and #func.see > 0 then %>
<h3>See also</h3>
<ul>
	<%for i = 1, #func.see do %>
	<li>
		<%local href = luadoc.doclet.html.symbol_link(func.see[i], doc, module_doc, file_doc, from)%>
		<%if href ~= "" then %>	<a href="<%=href%>"><%=func.see[i]%>	</a>
		<%else%>	<%=func.see[i]%>
		<%end%>
	</li>
	<%end%>
</ul>
<%end%>
</dd>
