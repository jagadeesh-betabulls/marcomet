<%@ page import="java.sql.*;"%>
<%@ taglib uri="/WEB-INF/tld/iterationTagLib.tld" prefix="iterate" %>
<jsp:useBean id="formatter" class="com.marcomet.tools.FormaterTool" scope="page" />
<% Connection conn = com.marcomet.jdbc.DBConnect.getConnection();
Statement st = conn.createStatement();
ResultSet vendorRS = st.executeQuery("SELECT payable_to_vendor, paid_to_vendor, vendor_job_share, balance_to_vendor FROM jobs WHERE id = " + request.getParameter("jobId"));
   request.setAttribute("vendorRS", vendorRS); %>
<hr size="1">
<table width=100% class="body">
  <tr> 
    <td class="subtitle1">Due to Vendor:</td>
  </tr>
</table>
<table border="0" width="100%">
  <tr>
    <td class="tableheader">Vendor Share of Job Total</td>
    <td class="tableheader">Amount Payable to Vendor from Escrow Released</td>
    <td class="tableheader">Amount Paid to Vendor</td>
    <td class="tableheader">Balance Due to Vendor</td>
  </tr>
  <iterate:dbiterate name="vendorRS" id="i">
  <tr>
    <td class="body" align="right"><%=formatter.getCurrency(vendorRS.getDouble("vendor_job_share"))%></td>
    <td class="body" align="right"><%=formatter.getCurrency(vendorRS.getDouble("payable_to_vendor"))%></td>
    <td class="body" align="right"><%=formatter.getCurrency(vendorRS.getDouble("paid_to_vendor"))%></td>
    <td class="body" align="right"><%=formatter.getCurrency(vendorRS.getDouble("balance_to_vendor"))%></td>
  </tr>
  </iterate:dbiterate>
</table>