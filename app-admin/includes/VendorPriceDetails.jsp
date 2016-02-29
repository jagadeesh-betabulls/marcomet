<%@ taglib uri="/WEB-INF/tld/taglib.tld" prefix="taglib" %>
<hr size="1">
<table width=100% class="body">
  <tr> 
    <td class="subtitle1">Job Price Details:</td>
  </tr>
</table>
<taglib:JobPriceDetailVendorTag tableWidth="100%" jobId="<%= request.getParameter(\"jobId\")%>"/>