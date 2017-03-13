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

		<%for pos, data in ipairs(doc.mfont) do%>
			<style>
			@font-face { font-family: MyFont<%=pos%>; src: url('<%=data.file%>'); }
			hrr<%=pos%> {
				font-family: MyFont<%=pos%>
			}
			</style>
		<%end%>

	</head>

	<body>
		<div id="container">
			<div id="product">
				<div id="product_logo">
					<% if doc.description.url ~= "" then %>
						<a target="_blank" href="<%=doc.description.url%>">
					<% end %>
					<img src='<%="../img/logo.png"%>'/><br/></div>
					<% if doc.description.url ~= "" then %>
						</a>
					<% end %>
				<div id="product_name"><big><b></b></big></div>
				<div id="product_description"></div>
			</div> <!-- id="product" -->

			<div id="main">
				<div id="navigation">
					<%=luadoc.include("menu.lp", { doc = doc, mfont = true })%>
				</div> <!-- id="navigation" -->

				<div id="content">
					<h1>Font</h1>
					<%if not options.nofiles and doc.mfont then%>
						<table class="file_list">
							<%for _, data in ipairs(doc.mfont) do%>
								<tr>
									<td class="name"><a href = "#<%=data.name%>"><%=data.name%></a></td>
									<td class="summary"><%= data.shortsummary or "" %></td>
								</tr>
							<%end%>
						</table>
					<%end%>

					<dl class="function">
					<%for fpos, data in ipairs(doc.mfont) do%>
						<dt><a name="<%=data.name%>"><h2><%=data.name%></h2></dt>
						<dd>
						<br><b>File: </b>
						<%if data.name then%>
							<%=data.file%>
						<%else%>
							<font color="red"><%="undefined"%></font>
						<%end%>
						<br><b>Summary: </b>
						<%if data.summary then%>
							<%=data.summary%>
						<%else%>
							<font color="red"><%="undefined"%></font>
						<%end%>
						<br><b>Source: </b>
						<%if data.source then%>
							<%= httpLink(data.source)%>
						<%else%>
							<font color="red"><%="undefined"%></font>
						<%end%>
						<br><b>Symbols: </b>
						<table class="arg_tab">
						<%count = 0%>
						<tr>
						<%forEachOrderedElement(data.symbol, function(pos, f)%>
							<%if count > 4 then%>
								</tr><tr>
								<%count = 0%>
							<%end%>
							<%count = count + 1%>
							<td><%=pos%></td><td><hrr<%=fpos%>><p style="font-size:45px"><%=string.char(f)%></p></hrr<%=fpos%>></td>
						<%end)%>
						</tr></table>
						<%if data.reference then%>
							<br><b>Reference: </b><%=data.reference%>
						<%end%>

						</dd>
					<%end%>
					</dl>
				</div> <!-- id="content" -->
			</div> <!-- id="main" -->

			<div id="about">
				<p>This webpage was automatically created using <a target="_blank" href="http://www.terrame.org">TerraME</a>.</p>
			</div> <!-- id="about" -->

		</div> <!-- id="container" -->	
	</body>
</html>

