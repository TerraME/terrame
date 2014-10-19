<%
if module_doc then
	from = "modules/"..module_doc.name
elseif file_doc then
	from = "files/.."..file_doc.name
else
	from = ""
end
%>

<h1><%=doc.description.package%></h1>
<ul>
	<%if not module_doc and not file_doc then%>
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


<!-- Types list -->
<%if not options.nofiles and #doc.files > 0 then%>
<h1>Types</h1>
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
<h1>Files</h1>
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