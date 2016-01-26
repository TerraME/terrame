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

	<%local file_doc = {name = "index.lua"}%>

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

						<%if doc.description.depends ~= "" then %><b>Depends: </b><%= doc.description.depends %><br>
						</b></font><br>
						<%end%>

						<%if doc.description.url ~= "" then%>
						<b>URL: </b>
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

					<%if doc.description.content ~= "Undefined content" then%> <%= doc.description.content %>
					<%else%> <font color="red"><b><%= doc.description.content %></b></font>
					<%end%><br>

					<%if not options.nomodules and #doc.modules > 0 then%>
						<h2>Modules</h2>
						<table class="module_list">
							<tr><td colspan="2">Modules</td></tr>
							<%for _, modulename in ipairs(doc.modules) do%>
								<tr>
									<td class="name"><a href="<%=luadoc.module_link(modulename, doc)%>"><%=modulename%></a></td>
									<td class="summary"><%=luadoc.link_description(doc.modules[modulename].summary or "", doc,
										module_doc, file_doc, from, true, "summary", doc_report)%></td>
								</tr>
							<%end%>
						</table>
					<%end%>

					<%if not options.nofiles and #doc.files > 0 then%>
						<%local count_models = 0%>
						<%for _, filepath in ipairs(doc.files) do%>
							<%if doc.files[filepath].type == "model" then%>
								<%count_models = count_models + 1%>
							<%end%>
						<%end%>

						<%if count_models > 0 then%>
							<h2><a href="<%=luadoc.link("files/models.html", from)%>">Models</a></h2>
							<table class="file_list">

							<%for _, filepath in ipairs(doc.files) do%>
								<%if doc.files[filepath].type == "model" then%>
									<tr>
										<td class="name"><%=doc.files[filepath].doc[1].name%></td>
										<td class="summary"><%=luadoc.link_description(doc.files[filepath].doc[1].summary or "", doc,
											module_doc, file_doc, from, true, "summary", doc_report)%></td>
									</tr>
								<%end%>
							<%end%>
							</table>
						<%end%>
					<%end%>

					<%if not options.nofiles and #doc.files> 0 then%>
						<%local count_types = 0%>
						<%for _, filepath in ipairs(doc.files) do%>
							<%if doc.files[filepath].type == "type" then%>
								<%count_types = count_types + 1%>
							<%end%>
						<%end%>

						<%if count_types > 0 then%>
							<h2>Types</h2>
						<%end%>
						<table class="file_list">
							<!--<tr><td colspan="2">Files</td></tr>-->
							<%for _, filepath in ipairs(doc.files) do%>
								<%if doc.files[filepath].type == "type" then%>
								<tr>
									<td class="name"><a href="<%=luadoc.file_link(filepath)%>"><%=filepath:match("(.-)%.lua")%></a></td>
									<td class="summary"><%=luadoc.link_description(doc.files[filepath].summary or "", doc,
										module_doc, file_doc, from, true, "summary", doc_report)%></td>
								</tr>
								<%end%>
							<%end%>
						</table>
					<%end%>

					<%if not options.nofiles and #doc.files > 0 then%>
						<%local count_functions = 0%>
						<%for _, filepath in ipairs(doc.files) do%>
							<%if doc.files[filepath].type == "file" then%>
								<%count_functions = count_functions + 1%>
							<%end%>
						<%end%>

						<%if count_functions > 0 then%>
							<h2>Functions</h2>
						<%end%>
	
						<table class="file_list">
							<!--<tr><td colspan="2">Files</td></tr>-->
							<%for _, filepath in ipairs(doc.files) do%>
								<%if doc.files[filepath].type == "file" then%>
									<tr>
										<td class="name"><a href="<%=luadoc.file_link(filepath)%>"><%=filepath:match("(.-)%.lua")%></a></td>
										<td class="summary"><%=luadoc.link_description(doc.files[filepath].summary or "", doc,
											module_doc, file_doc, from, true, "summary", doc_report)%></td>
									</tr>
								<%end%>
							<%end%>
						</table>
					<%end%>

					<%if not options.nofiles and #doc.examples > 0 then%>
						<h2><a href="<%=luadoc.link("files/examples.html", from)%>">Examples</a></h2>
						<table class="file_list">
							<%for _, filepath in ipairs(doc.files) do%>
								<%if doc.files[filepath].type == "example" then%>
									<tr>
										<!-- <td class="name"><a href="<%=luadoc.file_link(filepath)%>"><%=filepath:match("(.-)%.lua")%></a></td> -->
										<%file = string.sub(filepath, 0, string.len(filepath) - 4)%>
										<%local link = luadoc.link("files/examples.html", from).."#"..file%>
										<td class="name"><a href="<%=link%>"><b><%=file%></b></a></td>
										<td class="summary"><%=luadoc.link_description(doc.files[filepath].summary or "", doc,
											module_doc, file_doc, from, true, "summary", doc_report)%></td>
									</tr>
								<%end%>
							<%end%>
						</table>
					<%end%>

					<%if not options.nofiles and doc.mdata and #doc.mdata > 0 then%>
						<h2><a href="<%=luadoc.link("files/data.html", from)%>">Data</a></h2>
						<table class="file_list">
							<%for _, data in ipairs(doc.mdata) do%>
								<tr>
									<%local link = luadoc.link("files/data.html", from).."#"..data.file[1]%>
									<td class="name"><a href="<%=link%>"><b><%=data.file[1] or ""%></b></a></td>
  
									<td class="summary"><%=luadoc.link_description(data.shortsummary or "", doc, 
										module_doc, file_doc, from, true, "summary", doc_report)%></td>
								</tr>
							<%end%>
						</table>
					<%end%>

					<%if doc.mfont and #doc.mfont > 0 then%>
						<h2><a href="<%=luadoc.link("files/font.html", from)%>">Font</a></h2>
						<table class="file_list">
							<%for _, data in ipairs(doc.mfont) do%>
								<tr>
									<%local link = luadoc.link("files/font.html", from).."#"..data.name%>
									<td class="name"><a href="<%=link%>"><b><%=data.name or ""%></b></a></td>
  
									<td class="summary"><%=luadoc.link_description(data.shortsummary or "", doc,
										module_doc, file_doc, from, true, "summary", doc_report)%></td>
								</tr>
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
