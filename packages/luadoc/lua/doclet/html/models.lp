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
					<%=luadoc.include("menu.lp", { doc = doc, model = true })%>
				</div> <!-- id="navigation" -->

				<div id="content">
					<h1>Models</h1>
					<table class="file_list">
						<!-- <tr><td colspan="2">Examples</td></tr> -->
						<%for _, filepath in ipairs(doc.files) do%>
							<%if doc.files[filepath].type == "model" then%>
							<tr>
								<td class="name"><a href = "#<%=doc.files[filepath].doc[1].name%>"><%=doc.files[filepath].doc[1].name%></a></td>
								<td class="summary"><%= doc.files[filepath].doc[1].summary or "" %></td>
							</tr>
							<%end%>
						<%end%>
					</table>
					<dl class="function">
						<%for _, filepath in ipairs(doc.files) do%>
							<%if doc.files[filepath].type == "model" then%>
								<dt><h2><a name="<%=doc.files[filepath].doc[1].name%>" href= <%="../../lua/"..doc.files[filepath].doc[1].name..".lua"%>><%=doc.files[filepath].doc[1].name%></a></h2></dt>
									<%func = doc.files[filepath].doc[1]%>
									<% if func.image then %>
										<% loc = "../../images/"..func.image %>
										<center><img src=<% =loc %> ></center><br><br>
									<%end%>
									<%= httpLink(doc.files[filepath].doc[1].description)%>
									<% if func.arg then %>
										<h3>Arguments</h3>
										<ul><span class="arg">
										<%for i = 1, #func.arg do
											local arg_desc = func.arg[func.arg[i]] or ""
											local arg_name
											arg_name = func.arg[i]%>
										    <li><strong><%=arg_name%></strong>: <%= arg_desc%></li> 
										<%end%>
										</ul>
									<%end%>
							<%end%>
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

