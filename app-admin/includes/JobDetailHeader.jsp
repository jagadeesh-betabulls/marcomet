<%@ page import="java.sql.*;" %>
<%@ taglib uri="/WEB-INF/tld/iterationTagLib.tld" prefix="iterate" %>
<jsp:useBean id="connection" class="com.marcomet.jdbc.ConnectionBean" scope="session" />
<%
String headerQuery = "SELECT j.id AS job_id, ljt.value AS job_type, lst.value AS service_type, j.project_id, p.order_id AS order_id, com1.company_name AS vendor_name, com2.company_name AS customer_name, com2.id AS customer_id, DATE_FORMAT(o.date_created,'%m/%d/%y') AS order_date FROM jobs j, projects p, orders o, companies com1, companies com2, lu_service_types lst, lu_job_types ljt, vendors v WHERE j.project_id = p.id AND p.order_id = o.id AND v.id = j.vendor_id AND com1.id = v.company_id AND com2.id = o.buyer_company_id AND j.service_type_id = lst.id AND j.job_type_id = ljt.id AND j.id = " + request.getParameter("jobId");

Connection conn = com.marcomet.jdbc.DBConnect.getConnection();
Statement st = conn.createStatement();

ResultSet headerRS = st.executeQuery(headerQuery); 
request.setAttribute("headerRS", headerRS); %>
<table border="0" cellpadding="5" cellspacing="0" width="100%">
  <tr>
    <td class="tableheader">Customer</td>
    <td class="tableheader">Vendor</td>
    <td class="tableheader">Order #</td>
    <td class="tableheader">Order Date</td>
    <td class="tableheader">Project ID</td>
    <td class="tableheader">Job #</td>
    <td class="tableheader">Job Type</td>
    <td class="tableheader">Service Type</td>
  </tr>
  <iterate:dbiterate name="headerRS" id="i">
  <tr>
    <td class="lineitems" align="center"><$ customer_name $></td>
    <td class="lineitems" align="center"><$ vendor_name $></td>
    <td class="lineitems" align="center"><$ order_id $></td>
    <td class="lineitems" align="center"><$ order_date $></td>
    <td class="lineitems" align="center"><$ project_id $></td>
    <td class="lineitems" align="center"><$ job_id $></td>
    <td class="lineitems" align="center"><$ job_type $></td>
    <td class="lineitems" align="center"><$ service_type $></td>
  </tr>
  </iterate:dbiterate>
</table><%conn.close();%>