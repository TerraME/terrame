<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
   "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html>
	<head>
	    <%if doc.description.title == "" then%>
			<title><%=doc.description.package%></title>
		<%else%>
	    	<title><%=doc.description.title%></title>
	    <%end%>
	    <link rel="stylesheet" href="<%=luadoc.link('luadoc.css', 'files/data.lua')%>" type="text/css" />
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
					<%=luadoc.include("menu.lp", { doc = doc, mdata = true })%>
				</div> <!-- id="navigation" -->

				<div id="content">
					<h1>Data</h1>
					<%if not options.nofiles and doc.mdata then%>
						<table class="file_list">
							<%for _, data in ipairs(doc.mdata) do%>
								<tr>
									<td class="name"><a href = "#<%=data.file[1]%>"><%=data.file[1]%></a></td>
									<td class="summary"><%= data.shortsummary or "" %></td>
								</tr>
							<%end%>
						</table>
					<%end%>

					<dl class="function">
					<%for _, data in ipairs(doc.mdata) do%>
						<dt><h2><%=data.file[1]%><a name="<%=data.file[1]%>"></h2></dt>

						<% if data.image then %>
							<% loc = "../../images/"..tostring(data.image) %>
							<center><img src=<% =loc %> ></center><br><br>
						<%end%>
						<%if data.summary then%>
							<%=data.summary%>
						<%else%>
							<font color="red"><%="undefined"%></font>
						<%end%>
						<dd>
						<%if #data.file > 1 then%>
							<br><b>Files: </b>
							<%for pos, f in ipairs(data.file) do%>
								<%if pos<#data.file then%>
									<%=f..", "%>
								<%else%>
									<%=f%>
								<%end%>
							<%end%>
						<%end%>
						<br><b>Source: </b>
						<%if data.source then%>
							<%= httpLink(data.source)%>
						<%else%>
							<font color="red"><%="undefined"%></font>
						<%end%>

						<%if data.reference then%>
							<br><b>Reference: </b><%=data.reference%>
						<%end%>

						<%if data.attributes then%>
							<table class="arg_tab">
							<tr><td><b>Attribute</b></td><td><b>Type</b></td><td><b>Description</b></td></tr>
							<%if data.attributes[1] == "_incompatible_" then%>
								<tr>
								<td><font color="red">Incompatible sizes</font></td>
								<td><font color="red">Incompatible sizes</font></td>
								<td><font color="red">Incompatible sizes</font></td>
								</tr>
							<%else%>
								<% for j = 1,#data.attributes do %>
									<tr><td><%=data.attributes[j]%></td><td><%=data.types[j]%></td><td><%=data.description[j]%></td></tr>
								<%end%>
							<%end%> 
							</table>
						<%end%>
						</dd>
					<%end%>
					</dl>
				</div> <!-- id="content" -->
			</div> <!-- id="main" -->

			<div id="about">
				<p><a href="http://validator.w3.org/check?uri=referer"><img src="http://www.w3.org/Icons/valid-xhtml10" alt="Valid XHTML 1.0!" height="31" width="88" /></a></p>
			</div> <!-- id="about" -->

		</div> <!-- id="container" -->	
	</body>
</html>

