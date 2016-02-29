<%@ page import="java.sql.*, com.marcomet.environment.UserProfile" %>
<%@ taglib uri="/WEB-INF/tld/taglib.tld" prefix="taglib" %>
<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<html>
<head>
  <title>Catalog Selection</title>
  <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
  <link rel="stylesheet" href="<%=(String)session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css">
</head>
<body>
<form method="post" action="/servlet/com.marcomet.admin.catalog.CatalogSelectionServlet">
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td class="minderheaderleft"></td>
      <td class="minderheaderleft">Cat Job Id</td>
      <td class="minderheaderleft">Job Type</td>
      <td class="minderheaderleft">Service Type</td>
      <td class="minderheaderleft">Notes</td>
    </tr><%
   int vendorId = 0;
   UserProfile up = (UserProfile) request.getSession().getAttribute("userProfile");
   String query0 = "SELECT id FROM vendors WHERE company_id = " + up.getCompanyId();
   Connection conn = com.marcomet.jdbc.DBConnect.getConnection();
Statement st = conn.createStatement();
   ResultSet rs0 = st.executeQuery(query0);
   if (rs0.next()) {
      vendorId = rs0.getInt("id");
   }
   String query1 = "SELECT cj.id, ljt.value AS job_type,lst.value AS service_type, notes FROM catalog_jobs cj, lu_service_types lst, lu_job_types ljt LEFT OUTER JOIN vendor_catalogs vc ON cj.id = vc.cat_job_id AND vendor_id = " + vendorId + " WHERE cj.job_type_id = ljt.id AND cj.service_type_id = lst.id AND vc.cat_job_id IS NULL";
   Connection conn = com.marcomet.jdbc.DBConnect.getConnection();
   Statement st = conn.createStatement();
   ResultSet rs1 = st.executeQuery(query1);
   while (rs1.next()) { 
   %><tr>
      <td><input type="checkbox" name="catJobIds" value="<%=rs1.getString("id")%>"></td>
      <td><%=rs1.getString("id")%></td>
      <td><%=rs1.getString("job_type")%></td>
      <td><%=rs1.getString("service_type")%></td>
      <td><%=rs1.getString("notes")%></td>
    </tr><%
    } 
    %><tr><td>&nbsp;</td></tr>
    <tr>
      <td colspan="5"align="center"><input type="image" border="0" src="images/submit.gif"></td>
    </tr>
  </table>
  <input type="hidden" name="$$Return" value="[/app-admin/CatalogSelection.jsp]">
</form>
</body>
</html><%conn.close();%>
