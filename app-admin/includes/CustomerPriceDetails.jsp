<%@ taglib uri="/WEB-INF/tld/taglib.tld" prefix="taglib" %>
<hr size="1">
<table width=100% class="body">
  <tr> 
    <td class="subtitle1">Job Price Details:</td>
  </tr>
</table>
<taglib:JobPriceDetailCustomerTag tableWidth="40%" jobId="<%= request.getParameter(\"jobId\")%>"/>