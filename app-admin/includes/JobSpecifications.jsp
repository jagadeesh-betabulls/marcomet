<%@ taglib uri="/WEB-INF/tld/taglib.tld" prefix="taglib" %>
<hr size="1">
<table width=100% class="body">
  <tr> 
    <td class="subtitle1">Job Specifications (as originally ordered): </td>
  </tr>
</table>
<taglib:JobSpecsTag tableWidth="80%" jobId="<%= request.getParameter(\"jobId\")%>"/>