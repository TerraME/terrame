<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
   "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<h2><dt><a name="<%=tab.name%>"></a><strong><%=tab.name%></strong></dt></h2>
<dd><%=tab.description%>

<%if type(tab.field) == "table" and #tab.field > 0 then%>
<em>Fields</em>
<ul>
	<%for p = 1, #tab.field do%>
	<li>
	  <%=tab.field[p]%>: <%=tab.field[tab.field[p]] or ""%>
	</li>
	<%end%>
</ul>
<%end%>

</dd>
