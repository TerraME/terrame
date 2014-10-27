version = "2.0"
date = "17 October 2014"
package = "TerraME"
url = "http://www.terrame.org"
authors = "TerraLAB/UFOP and INPE"
contact = "pedro.andrade@inpe.br, tiago@iceb.ufop.br"
content = [[This document presents a detailed description of each type and function of TerraME, ordered alphabetically by its types. TerraME adopts <i>American English</i> (e.g., neighbor instead of neighbo<b>u</b>r), with the following syntax convention:
<ul>
<li>Names of types have the <b>upper</b> <a href="http://en.wikipedia.org/wiki/CamelCase">CamelCase</a> style, starting with a capital letter, followed by other words starting with capitalized letters (e.g., Agent, Trajectory, CellularSpace).</li>
<li>Functions and parameters names have the lower CamelCase style, with names starting with lowercase letters, followed by other words starting with capitalized letters (e.g., load, database, forEachCell, dbType).<br/><br/>
There are two signatures for functions in TerraME. The first one uses the structure "function(v1, v2, ...)", where v1 is the 1st argument, v2 is the 2nd, and so forth. The arguments of a call to a function that has this signature must follow the specified order. It is possible to use fewer arguments than the function signature, with missing arguments taking their default values. Parameters of functions following this format are described as 1st, 2nd, etc. in this document. Every parameter that
does not have a default value is compulsory.<br/>The second signature is "function{arg1 = v1, arg2 = v2, ...}", where v1 is the value of named argument arg1, v2 is the value of named argument arg2, and so on. These arguments can be used in any order, but the function call needs to use braces. Every type constructor of TerraME and some of its functions have this kind of signature. In this document, such arguments are described with their names.
</li>
</ul>]]
