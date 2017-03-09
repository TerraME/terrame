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
					<img src='<%="../img/logo.png"%>'/><br/></div></a>
				<div id="product_name"><big><b></b></big></div>
				<div id="product_description"></div>
			</div> <!-- id="product" -->

			<div id="main">
				<div id="navigation">
					<%=luadoc.include("menu.lp", { doc = doc, example = true })%>
				</div> <!-- id="navigation" -->

				<%local found = false%>
				<div id="content">
					<h1>Examples</h1>
					<%if not options.nofiles and #doc.examples > 0 then%>
						<table class="file_list">
							<!-- <tr><td colspan="2">Examples</td></tr> -->
							<%for _, filepath in ipairs(doc.files) do%>
								<%if doc.files[filepath].type == "example" then%>
								<tr>
									<!-- <td class="name"><a href="<%=luadoc.file_link(filepath)%>"><%=filepath:match("(.-)%.lua")%></a></td> -->
									<%file = string.sub(filepath, 0, string.len(filepath) - 4)%>
									<%found = true%>
									<td class="name"><a href = "#<%=file%>"><%=file%></a></td>
									<td class="summary"><%= doc.files[filepath].summary or "" %></td>
								</tr>
								<%end%>
							<%end%>
						</table>
					<%end%>
					<%if not found then%>
						<font color="red">The package has examples but none of them is documented.</font>
					<%end%>
					<dl class="function">
						<%for _, filepath in ipairs(doc.files) do%>
							<%if doc.files[filepath].type == "example" then%>
								<%file = string.sub(filepath, 0, string.len(filepath) - 4)%>
								<dt><h2><a name="<%=file%>"><a href = <%="../../examples/"..file..".lua"%> ><%=file%> </a></h2>
									<% if doc.files[filepath].image then %>
										<% loc = "../../images/"..doc.files[filepath].image %>
										<center><img src=<% =loc %> ></center><br><br>
									<%end%>

									<% local description = doc.files[filepath].description
									description = string.gsub(description, "\\[ ]*", "<br><br>").."<br><br>"%>
									<%= httpLink(description) %>
								</dt>
							<%end%>

							<%if doc.files[filepath].argnames and #doc.files[filepath].argnames > 0 then%>
								<h3>Arguments (global variables)</h3>
								<ul><span class="arg">
								<%for pos, name in ipairs(doc.files[filepath].argnames) do%>
									<li><strong><%=name%></strong>: <%=doc.files[filepath].argdescription[pos]%></li> 
								<%end%>
								</ul>
							<%end%>
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

