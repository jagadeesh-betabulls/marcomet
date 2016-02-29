<%@ page import="java.sql.*;"%>
<%@ taglib uri="/WEB-INF/tld/iterationTagLib.tld" prefix="iterate" %>
<jsp:useBean id="connection" class="com.marcomet.jdbc.ConnectionBean" scope="session" />
<jsp:useBean id="formatter" class="com.marcomet.tools.FormaterTool" scope="page" />
<% double totCost = 0;
   double totMu = 0;
   double totFee = 0;
   double totPrice = 0;
   ResultSet shippingRS = st1.executeQuery("SELECT DATE_FORMAT(date,'%m/%d/%y') 'date', reference,cost,mu,fee,price FROM shipping_data WHERE job_id = " + request.getParameter("jobId")); %>
<table border="0" width="100%">
  <tr>
    <td class="tableheader">Date</td>
    <td class="tableheader">Ref Tracking Number</td><%
      if (((RoleResolver)session.getAttribute("roles")).isVendor()) { %>
    <td class="tableheader">Est. Cost</td>
    <td class="tableheader">Seller MU</td>
    <td class="tableheader">MC Fee</td><%
      } %>
    <td class="tableheader">Total</td>
  </tr>
  <iterate:dbiterate name="shippingRS" id="i"><%
    totCost += rs1.getDouble("cost");
    totMu += rs1.getDouble("mu");
    totFee += rs1.getDouble("fee");
    totPrice += rs1.getDouble("price"); %>
  <tr>
    <td class="body"><$ date $></td>
    <td class="body"><$ reference $></td>
    <td class="body" align="right"><%
      if (((RoleResolver)session.getAttribute("roles")).isVendor()) { %>
      <%=formater.getCurrency(rs1.getDouble("cost"))%>
    </td>
    <td class="body" align="right">formater.getCurrency(rs1.getDouble("mu")));</td>
    <td class="body" align="right">formater.getCurrency(rs1.getDouble("fee")));</td>
    <td class="body" align="right"><%
      } %>
      <%=formater.getCurrency(rs1.getDouble("price"))%>
    </td>
  </tr>		
  </iterate:dbiterate>
  <tr>
    <td class="label" align="right" colspan="2">Job Total</td>
    <td class="Topborderlable" align="right"><%
      if (((RoleResolver)session.getAttribute("roles")).isVendor()) { %>
      <%=formater.getCurrency(totCost)%>
    </td>
    <td class="Topborderlable" align="right">formater.getCurrency(totMu));</td>
    <td class="Topborderlable" align="right">formater.getCurrency(totFee));</td>
    <td class="Topborderlable" align="right"><%
    } %>
      <%=formater.getCurrency(totPrice)%>
    </td>
  </tr>	
</table>