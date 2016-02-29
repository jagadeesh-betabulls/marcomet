<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<%@ page import="java.sql.*,com.marcomet.jdbc.*,com.marcomet.users.security.*;"%>
<%@ taglib uri="/WEB-INF/tld/iterationTagLib.tld" prefix="iterate" %>
<jsp:useBean id="formatter" class="com.marcomet.tools.FormaterTool" scope="page" />
<% double totCost = 0;
   double totMu = 0;
   double totFee = 0;
   double totPrice = 0;
   Connection conn2 = null;//com.marcomet.jdbc.DBConnect.getConnection();
   Statement st1a = null;//conn2.createStatement();
   try{
      	conn2 = com.marcomet.jdbc.DBConnect.getConnection();
   		st1a = conn2.createStatement();
   ResultSet shippingRS = st1a.executeQuery("SELECT DATE_FORMAT(date,'%m/%d/%y') 'date', reference,cost,mu,fee,price FROM shipping_data WHERE job_id = " + request.getParameter("jobId")); 
   request.setAttribute("shippingRS", shippingRS); 
   %>
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
    totCost += shippingRS.getDouble("cost");
    totMu += shippingRS.getDouble("mu");
    totFee += shippingRS.getDouble("fee");
    totPrice += shippingRS.getDouble("price"); %>
  <tr>
    <td class="body"><$ date $></td>
    <td class="body"><$ reference $></td>
    <td class="body" align="right"><%
      if (((RoleResolver)session.getAttribute("roles")).isVendor()) { %>
      <%=formatter.getCurrency(shippingRS.getDouble("cost"))%>
    </td>
    <td class="body" align="right">formatter.getCurrency(shippingRS.getDouble("mu")));</td>
    <td class="body" align="right">formatter.getCurrency(shippingRS.getDouble("fee")));</td>
    <td class="body" align="right"><%
      } %>
      <%=formatter.getCurrency(shippingRS.getDouble("price"))%>
    </td>
  </tr>		
  </iterate:dbiterate>
  <tr>
    <td class="label" align="right" colspan="2">Job Total</td>
    <td class="Topborderlable" align="right"><%
      if (((RoleResolver)session.getAttribute("roles")).isVendor()) { %>
      <%=formatter.getCurrency(totCost)%>
    </td>
    <td class="Topborderlable" align="right">formatter.getCurrency(totMu));</td>
    <td class="Topborderlable" align="right">formatter.getCurrency(totFee));</td>
    <td class="Topborderlable" align="right"><%
    } %>
      <%=formatter.getCurrency(totPrice)%>
    </td>
  </tr>	
</table><%
}catch(Exception e){
%>Error: <%=e%><%
}finally{
	try{st1a.close();conn2.close();}catch(Exception e){ st1a=null;conn2=null;}
}%>