<jsp:useBean id="connection" class="com.marcomet.jdbc.ConnectionBean" scope="session" />
<p />
<table border="0" cellpadding="5" cellspacing="0">
  <tr>
    <td class="tableheader">Reference Data</td>
	<td class="tableheader">&nbsp;</td>
  </tr>
  <tr>
    <td class="lineitems" align="center"><%		
    Connection conn = com.marcomet.jdbc.DBConnect.getConnection();
    Statement st = conn.createStatement();
      java.sql.ResultSet rs = st.executeQuery("SELECT j.buyer_internal_reference_data 'internal_reference' FROM jobs j WHERE j.id = " + request.getParameter("jobId"));
      if (rs.next()) { %>
      <%= rs.getString("internal_reference") %><%
      } %>&nbsp;
    </td>
	<td class="lineitems" align="center">
      <a href="javascript:popw('/popups/QuickChangeForm.jsp?tableName=jobs&columnName=buyer_internal_reference_data&valueType=String&question=Edit%20Job%20Reference%20value&rows=1&cols=30&primaryKeyValue=<%= request.getParameter("jobId")%>', 350, 200)" class="minderACTION">Edit</a>
    </td>
  </tr>
</table><%conn.close();%>