<%@ page import="java.sql.*" %>
<%@ taglib uri="/WEB-INF/tld/taglib.tld" prefix="taglib" %>
<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<html>
<head>
  <title>Offering Selection</title>
  <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
  <link rel="stylesheet" href="<%=(String)session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css">
</head>

<body>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td class="minderheaderleft">&nbsp;&nbsp;</td>
      <td class="minderheaderleft">Offering Id</td>
      <td class="minderheaderleft">Offering Title</td>
      <td class="minderheaderleft">Display Title</td>
    </tr><%
   String query0 = "SELECT offering_id, o.title AS offering_title, sho.title AS display_title FROM site_host_offering_choices shoc, site_host_offerings sho, offerings o WHERE shoc.offering_id = o.id AND shoc.site_host_offering_id = sho.id AND shoc.sequence = 0 AND site_host_id = " + ((com.marcomet.environment.SiteHostSettings)session.getAttribute("siteHostSettings")).getSiteHostId();
    Connection conn = com.marcomet.jdbc.DBConnect.getConnection();
    Statement st = conn.createStatement();
    ResultSet rs0 = st.executeQuery(query0);
   while (rs0.next()) { 
   %><tr>
      <td>&nbsp;&nbsp;</td>
      <td><%=rs0.getString("offering_id")%></td>
      <td><%=rs0.getString("offering_title")%></td>
      <td><%=rs0.getString("display_title")%></td>
    </tr>
<% } %>
    <tr><td>&nbsp;</td></tr>
    <tr>
      <td colspan="5"align="center"><a href="AddOfferings.jsp">Add Offering(s)</a></td>
    </tr>
  </table>
</body>
</html><%conn.close(); %>
