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
					<a href="<%="http://www.terrame.org"%>">
					<img src='<%="../img/terrame.png"%>'/><br/></div></a>
				<div id="product_name"><big><b></b></big></div>
				<div id="product_description"></div>
			</div> <!-- id="product" -->

			<div id="main">
				<div id="navigation">
					<%=luadoc.include("menu.lp", { doc = doc, mfont = true })%>
				</div> <!-- id="navigation" -->

				<div id="content">
					<h1><code>Font</code></h1>
					<%if not options.nofiles and doc.mfont then%>
						<table class="file_list">
							<%for _, data in ipairs(doc.mfont) do%>
								<tr>
									<td class="name"><a href = "#<%=data.file%>"><%=data.file%></a></td>
									<td class="summary"><%= data.shortsummary or "" %></td>
								</tr>
							<%end%>
						</table>
					<%end%>

					<dl class="function">
					<%for fpos, data in ipairs(doc.mfont) do%>
						<dt><h2><%=data.file%><a name="<%=data.file%>"></h2></dt>
						<dd>
						<br><b>Name: </b>
						<%if data.name then%>
							<%=data.name%>
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
				<p><a href="http://validator.w3.org/check?uri=referer"><img src="http://www.w3.org/Icons/valid-xhtml10" alt="Valid XHTML 1.0!" height="31" width="88" /></a></p>
			</div> <!-- id="about" -->

		</div> <!-- id="container" -->	
	</body>
</html>

