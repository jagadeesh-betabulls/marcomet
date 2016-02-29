<p />
<table border="0" cellpadding="5" cellspacing="0">
  <tr>
    <td class="tableheader">Job Name</td>
	<td class="tableheader">&nbsp;</td>
  </tr>
  <tr>
    <td class="lineitems" align="center"><%		
    Connection conn = com.marcomet.jdbc.DBConnect.getConnection();
    Statement st = conn.createStatement();
      java.sql.ResultSet rs = st.executeQuery("SELECT j.job_name 'job_name' FROM jobs j WHERE j.id = " + request.getParameter("jobId"));
      if (rs.next()) { %>
      <%= rs.getString("job_name") %><%
      } %>&nbsp;
    </td>
	<td class="lineitems" align="center">
      <a href="javascript:pop('/popups/QuickChangeForm.jsp?tableName=jobs&columnName=job_name&valueType=String&question=Edit%20Job%20Name%20value&rows=1&cols=30&primaryKeyValue=<%= request.getParameter("jobId")%>', '350', '200')" class="minderACTION">Edit</a>
    </td>
  </tr>
</table>  