<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
   "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html>
	<head>
	    <%if doc.description.title == "" then%>
			<title><%=doc.description.package%></title>
		<%else%>
	    	<title><%=doc.description.title%></title>
	    <%end%>
	    <link rel="stylesheet" href="<%=luadoc.link("luadoc.css")%>" type="text/css" />
		<!--meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/-->
	</head>

	<body>
		<div id="container">
			<div id="product">
				<div id="product_logo">
					<a href="<%="http://www.terrame.org"%>">
					<img src='<%="./img/terrame.png"%>'/><br/></div></a>
				<div id="product_name"><big><b></b></big></div>
				<div id="product_description"></div>
			</div> <!-- id="product" -->

			<div id="main">
				<div id="navigation">
					<%=luadoc.include("menu.lp", {doc = doc, index = true})%>
				</div> <!-- id="navigation" -->

				<div id="content">
					<div id="index-header">
						<center><%if doc.description.title ~= "" then %> <h1><%=doc.description.title%></h1>
						<%else%> <h1><%=doc.description.package%></h1>
						<%end%></center>
						<br>

						<b>Version: </b><%if doc.description.version ~= "Undefined version" then %><%= doc.description.version %><br>
						<%else%> <font color="red"><b><%= doc.description.version %></b></font><br>
						<%end%>

						<b>License: </b><%if doc.description.license ~= "Undefined license" then %><%= doc.description.license %><br>
						<%else%><font color="red"><b><%= doc.description.license %></b></font><br>
						<%end%>

						<b>Release: </b><%if doc.description.date ~= "Undefined date" then %><%= doc.description.date %><br>
						<%else%><font color="red"><b><%= doc.description.date %></b></font><br>
						<%end%>

						<b>Authors: </b><%if doc.description.authors ~= "Undefined authors" then %> <%= doc.description.authors %><br>
						<%else%><font color="red"><b><%= doc.description.authors %></b></font><br>
						<%end%>

						<b>URL: </b><%if doc.description.url ~= "" then%>
							<%= "<a href= \""..doc.description.url.."\">"..string.gsub(doc.description.url, "http:%/%/", "").."</a>" %><br>
						<%end%>

						<b>Contact: </b><% if doc.description.contact ~= "Undefined contact" then %>
							<% local emails = {}
							local email_link = "<a href=\"mailto:%s\"> %s</a>"
							for contact in string.gmatch(doc.description.contact, "[^@%s]+@[^,%s]+") do	
								table.insert(emails, string.format(email_link, contact, contact))
							end %>
							<%= table.concat(emails, ", ") %><br>
						<%else%>
							<font color="red"><b><%= doc.description.contact %></b></font><br>
						<%end%>
						<br>
					</div>

					<p> <%if doc.description.content ~= "Undefined content" then%> <%= doc.description.content %>
						<%else%> <font color="red"><b><%= doc.description.content %></b></font>
						<%end%></p>

					<%if not options.nomodules and #doc.modules > 0 then%>
						<h2>Modules</h2>
						<table class="module_list">
							<tr><td colspan="2">Modules</td></tr>
							<%for _, modulename in ipairs(doc.modules) do%>
								<tr>
									<td class="name"><a href="<%=luadoc.module_link(modulename, doc)%>"><%=modulename%></a></td>
									<td class="summary"><%=doc.modules[modulename].summary%></td>
								</tr>
							<%end%>
						</table>
					<%end%>

					<%if not options.nofiles and #doc.files> 0 then%>
						<h2>Types</h2>
						<table class="file_list">
							<!--<tr><td colspan="2">Files</td></tr>-->
							<%for _, filepath in ipairs(doc.files) do%>
								<%if doc.files[filepath].type == "type" then%>
								<tr>
									<td class="name"><a href="<%=luadoc.file_link(filepath)%>"><%=filepath:match("(.-)%.lua")%></a></td>
									<td class="summary"><%= doc.files[filepath].summary or "" %></td>
								</tr>
								<%end%>
							<%end%>
						</table>
					<%end%>

					<%if not options.nofiles and #doc.files > 0 then%>
						<h2>Functions</h2>
						<table class="file_list">
							<!--<tr><td colspan="2">Files</td></tr>-->
							<%for _, filepath in ipairs(doc.files) do%>
								<%if doc.files[filepath].type == "file" then%>
									<tr>
										<td class="name"><a href="<%=luadoc.file_link(filepath)%>"><%=filepath:match("(.-)%.lua")%></a></td>
										<td class="summary"><%= doc.files[filepath].summary or "" %></td>
									</tr>
								<%end%>
							<%end%>
						</table>
					<%end%>

<!-- TODO PEDRO -->
					<%if not options.nofiles and #doc.examples > 0 then%>
						<h2><a href="<%=luadoc.link("files/examples.html", from)%>">Examples</a></h2>
						<table class="file_list">
							<!--<tr><td colspan="2">Examples</td></tr>-->
							<%for _, filepath in ipairs(doc.files) do%>
								<%if doc.files[filepath].type == "example" then%>
									<tr>
										<!-- <td class="name"><a href="<%=luadoc.file_link(filepath)%>"><%=filepath:match("(.-)%.lua")%></a></td> -->
										<td class="name"><%=filepath%></td>
										<td class="summary"><%= doc.files[filepath].summary or "" %></td>
									</tr>
								<%end%>
							<%end%>
						</table>
					<%end%>
				</div> <!-- id="content" -->
			</div> <!-- id="main" -->

			<div id="about">
				<p><a href="http://validator.w3.org/check?uri=referer"><img src="http://www.w3.org/Icons/valid-xhtml10" alt="Valid XHTML 1.0!" height="31" width="88" /></a></p>
			</div> <!-- id="about" -->
		</div> <!-- id="container" -->	
	</body>
</html>
