<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
   "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html>
	<head>
	    <%if doc.description.title == "" then%>
			<title><%=doc.description.package%></title>
		<%else%>
	    	<title><%=doc.description.title%></title>
	    <%end%>
	    <link rel="stylesheet" href="<%=luadoc.link('luadoc.css', 'files/'..file_doc.name)%>" type="text/css" />
		<!--meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/-->
	</head>

	<body>
		<div id="container">
			<div id="product">
				<div id="product_logo">
					<a href="<%="http://www.terrame.org"%>">
					<img src='<%="../img/terrame.png"%>'/><br/></div></a>
				<div id="product_name"><big><b></b></big></div>
				<div id="product_description"></div>
			</div> <!-- id="product" -->

			<div id="main">
				<div id="navigation">
					<%=luadoc.include("menu.lp", { doc=doc, file_doc=file_doc })%>
				</div> <!-- id="navigation" -->

				<div id="content">
					<h1><code><%=file_doc.name:match("(.-)%.lua")%>
					<% if #file_doc.functions > 0 then
					  local constructor = file_doc.functions[file_doc.functions[1]]
					  if constructor.inherits then%>
					    (inherits <a href="<%=luadoc.symbol_link(constructor.inherits, doc, module_doc, file_doc, "files/.."..file_doc.name, "inherits", doc_report)%>">
					      <%= constructor.inherits %></a>)
					  <% end %>
					<% end %>

					</code></h1>

					<%if file_doc.description then%>
						<span class="description"><%=
							luadoc.link_description(file_doc.description, doc, module_doc, file_doc, "files/.."..file_doc.name, true, doc_report)%></span>
					<%end%>
					<%if file_doc.author then%>
						<p><b><%= #file_doc.author>1 and "Authors" or "Author" %>:</b>
						<table class="authors_list">
						<%for _, author in ipairs(file_doc.author) do%>
							<tr><td class="name"><%= author %></td></tr>
						<%end%>
						</table>
						</p>
					<%end%>
					<%if file_doc.copyright then%>
						<p>Copyright &copy;<%=file_doc.copyright%></p>
					<%end%>
					<%if file_doc.release then%>
						<p><small><b>Release:</b> <%=file_doc.release%></small></p>
					<%end%>

					<%if #file_doc.functions > 0 then%>
						<% if file_doc.functions[1] == file_doc.name:match("(.-)%.lua") then %>
						<%=luadoc.include("function.lp", { doc=doc, file_doc=file_doc, func=file_doc.functions[file_doc.functions[1]], doc_report = doc_report })%>
						<% table.remove(file_doc.functions, 1) %>
						<% end %>

						<%if #file_doc.functions > 0 then%>
							<h2 class="function_list">Functions</h2>
							<table class="function_list">
							<%for _, func_name in ipairs(file_doc.functions) do
								local func_data = file_doc.functions[func_name]%>
								<%if func_data.deprecated then%>
									<tr>
										<td class="name" nowrap><%=func_data.private and "local " or ""%><a href="#<%=func_name%>"><%=func_name%></a>
										<i><font color="gray"> (deprecated)</font></i>&nbsp;
<td class="summary"><%=luadoc.link_description(func_data.summary or "", doc, module_doc, file_doc, from, true, "summary", doc_report)%></td>
									</tr>
								<%else%>
									<tr>
										<td class="name" nowrap><%=func_data.private and "local " or ""%><a href="#<%=func_name%>"><%=func_name%></a>&nbsp;
<td class="summary"><%=luadoc.link_description(func_data.summary or "", doc, module_doc, file_doc, from, true, "summary", doc_report)%></td>
									</tr>
								<%end%>
							<%end%>
						<%end%>
						</table>
					<%end%>

					<%if #file_doc.variables > 0 then%>
					<h2 class="table_list">Variables</h2>
					<table class="table_list">
					<%for _, tab_name in ipairs(file_doc.variables) do%>
						<tr>
						<td class="name" nowrap><a href="#<%=tab_name%>"><%=tab_name%></a></td>
						<td class="summary"><%=file_doc.variables[tab_name].summary%></td>
						</tr>
					<%end%>
					</table>
					<%end%>

					<!--<br/>
					<br/>-->

					<%if #file_doc.functions > 0 then%>
						<%if #file_doc.variables > 0 then%>
							<h2><a name="functions"></a>Functions</h2>
						<%end%>
						<dl class="function">
							<%for i, func_name in ipairs(file_doc.functions) do
						    	if func_name ~= file_doc.name:match("(.-)%.lua") then %>
									<%=luadoc.include("function.lp", { doc=doc, file_doc=file_doc, func=file_doc.functions[func_name], doc_report = doc_report })%>
						    	<%end%>
							<%end%>
						</dl>
					<%end%>

					<%if #file_doc.variables > 0 then%>
						<%if #file_doc.functions > 0 then%>
							<h2><a name="variables"></a>Variables</h2>
						<%end%>
					<dl class="variable">
						<%for _, tab_name in ipairs(file_doc.variables) do%>
							<%=luadoc.include("table.lp", { doc=doc, file_doc=file_doc, tab=file_doc.variables[tab_name] })%>
						<%end%>
					</dl>
					<%end%>

				</div> <!-- id="content" -->
			</div> <!-- id="main" -->

			<div id="about">
				<p><a href="http://validator.w3.org/check?uri=referer"><img src="http://www.w3.org/Icons/valid-xhtml10" alt="Valid XHTML 1.0!" height="31" width="88" /></a></p>
			</div> <!-- id="about" -->

		</div> <!-- id="container" -->	
	</body>
</html>

