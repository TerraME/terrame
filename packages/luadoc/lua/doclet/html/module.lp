<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
   "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8">

	<%if doc.description.title == "" then%>
		<title><%=doc.description.package%></title>
	<%else%>
    	<title><%=doc.description.title%></title>
    <%end%>
    <link rel="stylesheet" href="<%=luadoc.doclet.html.link('luadoc.css', 'modules/'..module_doc.name)%>" type="text/css" />
	<!--meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/-->
</head>

<body>
<div id="container">

<div id="product">
	<div id="product_logo"><img src='../img/logo.png'/><br/></div>
	<div id="product_name"><big><b></b></big></div>
	<div id="product_description"></div>
</div> <!-- id="product" -->

<div id="main">

<div id="navigation">
<%=luadoc.doclet.html.include("menu.lp", { doc=doc, module_doc=module_doc })%>

</div><!-- id="navigation" -->

<div id="content">

<h1>Module <code><%=module_doc.name%></code></h1>

<p><%=module_doc.description%></p>
<%if module_doc.author then%>
<p><b><%= #module_doc.author>1 and "Authors" or "Author" %>:</b>
<table class="authors_list">
<%for _, author in ipairs(module_doc.author) do%>
	<tr><td class="name"><%= author %></td></tr>
<%end%>
</table>
</p>
<%end%>
<%if module_doc.copyright then%>
<p>Copyright&copy; <%=module_doc.copyright%></p>
<%end%>
<%if module_doc.release then%>
<p><small><b>Release:</b> <%=module_doc.release%></small></p>
<%end%>

<%if #module_doc.functions > 0 then%>
<h2>Functions</h2>
<table class="function_list">
<%for _, func_name in ipairs(module_doc.functions) do
  local func_data = module_doc.functions[func_name]
  local allParams = func_data["arg"]
  local selectedParams = {}
  for i=1,#allParams do
    local pos = string.find(allParams[i],"%.")
    if not (i==1 and allParams[i]=="self") and not pos then
       table.insert(selectedParams,allParams[i])
    end
  end
%>
	<tr>
	<td class="name" nowrap><%=func_data.private and "local " or ""%><a href="#<%=func_name%>"><%=func_name%></a>&nbsp;(<%=table.concat(selectedParams, ", ")%>)</td>
	<td class="summary"><%=module_doc.functions[func_name].summary%></td>
	</tr>
<%end%>
</table>
<%end%>


<%if #module_doc.tables > 0 then%>
<h2>Tables</h2>
<table class="table_list">
<%for _, tab_name in ipairs(module_doc.tables) do%>
	<tr>
	<td class="name" nowrap><a href="#<%=tab_name%>"><%=tab_name%></a></td>
	<td class="summary"><%=module_doc.tables[tab_name].summary%></td>
	</tr>
<%end%>
</table>
<%end%>


<br/>
<br/>


<%if #module_doc.functions > 0 then%>
<h2><a name="functions"></a>Functions</h2>
<dl class="function">
<%for _, func_name in ipairs(module_doc.functions) do%>
<%=luadoc.doclet.html.include("function.lp", { doc=doc, module_doc=module_doc, func=module_doc.functions[func_name], doc_report = doc_report })%>
<%end%>
</dl>
<%end%>


<%if #module_doc.tables > 0 then%>
<h2><a name="tables"></a>Tables</h2>
<dl class="table">
<%for _, tab_name in ipairs(module_doc.tables) do%>
<%=luadoc.doclet.html.include("table.lp", { doc=doc, module_doc=module_doc, tab=module_doc.tables[tab_name] })%>
<%end%>
</dl>
<%end%>


</div> <!-- id="content" -->

</div> <!-- id="main" -->

<div id="about">
	<p>This webpage was automatically created using <a target="_blank" href="http://www.terrame.org">TerraME</a>.</p>
</div> <!-- id="about" -->

</div> <!-- id="container" -->	
</body>
</html>
