<%@ page import="java.sql.*;"%>
<%@ taglib uri="/WEB-INF/tld/iterationTagLib.tld" prefix="iterate" %>
<jsp:useBean id="formatter" class="com.marcomet.tools.FormaterTool" scope="page" />
<% Connection conn = com.marcomet.jdbc.DBConnect.getConnection();
Statement st = conn.createStatement();
ResultSet siteHostRS = st.executeQuery("SELECT payable_to_site_host, paid_to_site_host, site_host_job_share, balance_to_site_host FROM jobs WHERE id = " + request.getParameter("jobId"));
   request.setAttribute("siteHostRS", siteHostRS); %>
<hr size="1">
<table width=100% class="body">
  <tr> 
    <td class="subtitle1">Due to SiteHost:</td>
  </tr>
</table>
<table border="0" width="100%">
  <tr>
    <td class="tableheader">Site Host Share of Job Total</td>
    <td class="tableheader">Amount Payable to Site Host from Escrow Released</td>
    <td class="tableheader">Amount Paid to Site Host</td>
    <td class="tableheader">Balance Due to Site Host</td>
  </tr>
  <iterate:dbiterate name="siteHostRS" id="i">
  <tr>
    <td class="body" align="right"><%=formatter.getCurrency(siteHostRS.getDouble("site_host_job_share"))%></td>
    <td class="body" align="right"><%=formatter.getCurrency(siteHostRS.getDouble("payable_to_site_host"))%></td>
    <td class="body" align="right"><%=formatter.getCurrency(siteHostRS.getDouble("paid_to_site_host"))%></td>
    <td class="body" align="right"><%=formatter.getCurrency(siteHostRS.getDouble("balance_to_site_host"))%></td>
  </tr>
  </iterate:dbiterate>
</table>