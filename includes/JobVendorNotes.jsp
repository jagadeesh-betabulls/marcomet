<%@ page import="com.marcomet.users.security.*,java.sql.*" %>
<p /><table border="0" cellpadding="5" cellspacing="0" width="60%">
  <tr><td class="tableheader" colspan="2">Vendor/Subvendor Notes</td></tr><tr><td class="lineitems" align="left"><%
boolean print=((request.getParameter("print")==null || request.getParameter("print").equals("false"))?false:true);
  Connection conn = com.marcomet.jdbc.DBConnect.getConnection();
  Statement st = conn.createStatement();
    java.sql.ResultSet rsJobInfo = st.executeQuery("SELECT j.vendor_notes 'vnotes' FROM jobs j WHERE j.id = " + request.getParameter("jobId"));

    if (rsJobInfo.next()) { %><%= rsJobInfo.getString("vnotes") %><%
    } %>&nbsp;</td><%
    if (((RoleResolver)session.getAttribute("roles")).isVendor() && !print) {
	%><td class="lineitems" align="center" width="1%"><a href="javascript:popw('/popups/QuickChangeAppendForm.jsp?tableName=jobs&columnName=vendor_notes&valueType=String&question=Edit%20Vendor%20Notes&rows=5&cols=40&primaryKeyValue=<%= request.getParameter("jobId")%>', 500, 500)" class="minderACTION">Edit</a></td><%
    } %></tr></table>