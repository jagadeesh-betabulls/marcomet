<%@ page import="com.marcomet.users.security.*, java.util.*,java.sql.*" %>

<table border="0" cellpadding="5" cellspacing="0"><tr><td class="tableheader" colspan=2>Job Name</td></tr><tr>
<td class="lineitems" align="center" width=90%><%
boolean print=((request.getParameter("print")==null || request.getParameter("print").equals("false"))?false:true);		
boolean editor= (((RoleResolver)session.getAttribute("roles")).roleCheck("editor") && !print);
Connection conn = com.marcomet.jdbc.DBConnect.getConnection();
Statement st = conn.createStatement();
      java.sql.ResultSet rs = st.executeQuery("SELECT j.job_name 'job_name' FROM jobs j WHERE j.id = " + request.getParameter("jobId"));

      if (rs.next()) { %>
      <%= rs.getString("job_name") %><%
      } %>&nbsp;</td><%if (editor){%><td class="lineitems" align="center" width=10%><a href="javascript:popw('/popups/QuickChangeForm.jsp?tableName=jobs&columnName=job_name&valueType=String&question=Edit%20Job%20Name%20value&rows=1&cols=30&primaryKeyValue=<%= request.getParameter("jobId")%>', '350', '150')" class="minderACTION">Edit</a></td><%}%></tr></table>  