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
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td class="minderheaderleft">&nbsp;&nbsp;</td>
      <td class="minderheaderleft">Cat Job Id</td>
      <td class="minderheaderleft">Job Type</td>
      <td class="minderheaderleft">Service Type</td>
      <td class="minderheaderleft">Notes</td>
    </tr><%
   UserProfile up = (UserProfile)session.getAttribute("userProfile");
   String query0 = "SELECT cj.id, ljt.value as job_type, lst.value as service_type, notes FROM vendor_catalogs vc, catalog_jobs cj, vendors v, lu_job_types ljt, lu_service_types lst WHERE cj.job_type_id = ljt.id AND cj.service_type_id = lst.id AND vc.cat_job_id = cj.id AND v.id = vc.vendor_id AND company_id = " + up.getCompanyId() + " ORDER BY cj.id";
   Connection conn = com.marcomet.jdbc.DBConnect.getConnection();
   Statement st = conn.createStatement();
   ResultSet rs0 = st.executeQuery(query0);
   while (rs0.next()) { %>
    <tr>
      <td>&nbsp;&nbsp;</td>
      <td><%=rs0.getString("id")%></td>
      <td><%=rs0.getString("job_type")%></td>
      <td><%=rs0.getString("service_type")%></td>
      <td><%=rs0.getString("notes")%></td>
    </tr>
<% } %>
    <tr><td>&nbsp;</td></tr>
    <tr>
      <td colspan="5"align="center"><a href="AddCatalogs.jsp">Add Catalog(s)</a></td>
    </tr>
  </table>
</body>
</html><%conn.close();%>
