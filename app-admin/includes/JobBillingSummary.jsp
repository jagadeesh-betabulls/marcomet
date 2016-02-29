<%@ taglib uri="/WEB-INF/tld/taglib.tld" prefix="taglib" %>
<hr size="1">
<table width=100% class="body">
  <tr> 
    <td class="subtitle1">Job Billing Detail:</td>
  </tr>
</table>
<taglib:JobInvoiceTableTag tableWidth="60%" jobId="<%= request.getParameter(\"jobId\")%>"/>