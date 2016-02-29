<%@ page import="java.sql.*, com.marcomet.environment.UserProfile" %>
<%@ taglib uri="/WEB-INF/tld/taglib.tld" prefix="taglib" %>
<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<html>
<head>
  <title>Offering Selection</title>
  <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
  <link rel="stylesheet" href="<%=(String)session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css">
</head>
<body>
<form method="post" action="/servlet/com.marcomet.admin.catalog.CatalogSelectionServlet">
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td class="minderheaderleft"></td>
      <td class="minderheaderleft">Offering Id</td>
      <td class="minderheaderleft">Job Type</td>
      <td class="minderheaderleft">Service Type</td>
    </tr><%
   int vendorId = 0;
   UserProfile up = (UserProfile) request.getSession().getAttribute("userProfile");
   String query0 = "SELECT id FROM vendors WHERE company_id = " + up.getCompanyId();
   Connection conn = com.marcomet.jdbc.DBConnect.getConnection();
   Statement st = conn.createStatement();
   Statement st2 = conn.createStatement();
   ResultSet rs0 = st.executeQuery(query0);
   if (rs0.next()) {
      vendorId = rs0.getInt("id");
   }
   String query1 = "SELECT DISTINCT o.id, ljt.value as job_type, lst.value as service_type FROM offerings o, offering_sequences os, lu_job_types ljt, lu_service_types lst WHERE o.id = os.offering_id AND ljt.id = os.job_type_id AND lst.id = os.service_type_id ORDER BY ljt.sequence";
   ResultSet rs1 = st2.executeQuery(query1);
   while (rs1.next()) { %>
    <tr>
      <td><input type="checkbox" name="catJobIds" value="<%=rs1.getString("id")%>"></td>
      <td><%=rs1.getString("id")%></td>
      <td><%=rs1.getString("job_type")%></td>
      <td><%=rs1.getString("service_type")%></td>
    </tr>
<% } %>
    <tr><td>&nbsp;</td></tr>
    <tr>
      <td colspan="5"align="center"><input type="image" border="0" src="images/submit.gif"></td>
    </tr>
  </table>
</form>
</body>
</html><%conn.close();%>
