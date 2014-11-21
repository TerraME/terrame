<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
   "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html>
	<head>
	    <%if doc.description.title == "" then%>
			<title><%=doc.description.package%></title>
		<%else%>
	    	<title><%=doc.description.title%></title>
	    <%end%>
	    <link rel="stylesheet" href="<%=luadoc.link('luadoc.css', 'files/examples.lua')%>" type="text/css" />
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
					<%=luadoc.include("menu.lp", { doc=doc, example = true })%>
				</div> <!-- id="navigation" -->

				<div id="content">
					<h1>Examples</h1>
					<%if not options.nofiles and #doc.examples > 0 then%>
						<table class="file_list">
							<!-- <tr><td colspan="2">Examples</td></tr> -->
							<%for _, filepath in ipairs(doc.files) do%>
								<%if doc.files[filepath].type == "example" then%>
								<tr>
									<!-- <td class="name"><a href="<%=luadoc.file_link(filepath)%>"><%=filepath:match("(.-)%.lua")%></a></td> -->
									<td class="name"><a href = "#<%=filepath%>"><%=filepath%></a></td>
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
