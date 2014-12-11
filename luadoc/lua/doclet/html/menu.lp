<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
   "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<%
	if module_doc then
		from = "modules/"..module_doc.name
	elseif file_doc then
		from = "files/.."..file_doc.name
	elseif #doc.examples > 0 and not index then
		from = "files/..".."examples.html"
	else
		from = ""
	end
%>

<h1><%=doc.description.package%></h1>
<ul>
	<%if not module_doc and not file_doc and not example and not mdata and not model then%>
		<li><strong>Index</strong></li>
	<%else%>
		<li><a href="<%=luadoc.link("index.html", from)%>">Index</a></li>
	<%end%>
</ul>

<!-- Module list -->
<%if not options.nomodules and #doc.modules > 0 then%>
	<h1>Modules</h1>
	<ul>
		<%for _, modulename in ipairs(doc.modules) do
			if module_doc and module_doc.name == modulename then%>
				<li><strong><%=modulename%></strong></li>
			<%else%>
				<li>
					<a href="<%=luadoc.module_link(modulename, doc, from)%>"><%=modulename%></a>
				</li>
		<%	end
		end%>
	</ul>
<%end%>

<!-- Models list -->
<%if not options.nofiles and #doc.files > 0 then%>
	<%local count_models = 0%>
	<%for _, filepath in ipairs(doc.files) do%>
		<%if doc.files[filepath].type == "model" then%>
			<%count_models = count_models + 1%>
		<%end%>
	<%end%>

	<%if count_models > 0 then%>
		<%if not model then%>
			<h1><a href="<%=luadoc.link("files/models.html", from)%>">Models</a></h1>
		<%else%>
			<h1>Models</h1>
		<%end%>
	<%end%>
<%end%>

<!-- Types list -->
<%if not options.nofiles and #doc.files > 0 then%>
	<%local count_types = 0%>
	<%for _, filepath in ipairs(doc.files) do%>
		<%if doc.files[filepath].type == "type" then%>
			<%count_types = count_types + 1%>
		<%end%>
	<%end%>

	<%if count_types > 0 then%>
		<h1>Types</h1>
	<%end%>

	<ul>
		<%for _, filepath in ipairs(doc.files) do
			if doc.files[filepath].type == "type" then
				if file_doc and file_doc.name == filepath then%>
					<li><strong><%=filepath:match("(.-)%.lua")%></strong></li>
				<%else%>
					<li>
						<a href="<%=luadoc.file_link(filepath, from)%>"><%=filepath:match("(.-)%.lua")%></a>
					</li>
				<%end%>
			<%end%>
		<%end%>
	</ul>
<%end%>

<!-- Files list -->
<%if not options.nofiles and #doc.files > 0 then%>
	<%local count_functions = 0%>
	<%for _, filepath in ipairs(doc.files) do%>
		<%if doc.files[filepath].type == "file" then%>
			<%count_functions = count_functions + 1%>
		<%end%>
	<%end%>

	<%if count_functions > 0 then%>
		<h1>Functions</h1>
	<%end%>

	<ul>
		<%for _, filepath in ipairs(doc.files) do
			if doc.files[filepath].type == "file" then
				if file_doc and file_doc.name == filepath then%>
					<li><strong><%=filepath:match("(.-)%.lua")%></strong></li>
				<%else%>
					<li>
						<a href="<%=luadoc.file_link(filepath, from)%>"><%=filepath:match("(.-)%.lua")%></a>
					</li>
				<%end%>
			<%end%>
		<%end%>
	</ul>
<%end%>

<!-- Examples -->
<%if not options.nofiles and #doc.examples > 0 then%>
	<%if not example then%>
		<h1><a href="<%=luadoc.link("files/examples.html", from)%>">Examples</a></h1>
	<%else%>
		<h1>Examples</h1>
	<%end%>

<%end%>

<!-- Data -->
<%if not options.nofiles and #doc.mdata > 0 then%>
	<%if not mdata then%>
		<h1><a href="<%=luadoc.link("files/data.html", from)%>">Data</a></h1>
	<%else%>
		<h1>Data</h1>
	<%end%>

<%end%>

