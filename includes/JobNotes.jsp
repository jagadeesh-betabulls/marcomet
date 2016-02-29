<%@ page import="com.marcomet.users.security.*,java.sql.*" %>
<p />

<table border="0" cellpadding="5" cellspacing="0" width="60%">

  <tr>

    <td class="tableheader" colspan="2">Job/Invoice Description</td>

  </tr>

  <tr>

    <td class="lineitems" align="left"><%
    Connection conn = com.marcomet.jdbc.DBConnect.getConnection();
    Statement st = conn.createStatement();
    java.sql.ResultSet rsJobInfo = st.executeQuery("SELECT j.job_notes 'notes' FROM jobs j WHERE j.id = " + request.getParameter("jobId"));

    if (rsJobInfo.next()) { %>

      <%= rsJobInfo.getString("notes") %><%

    } %>&nbsp;

    </td><%

    if (((RoleResolver)session.getAttribute("roles")).isVendor()) {%>

    <td class="lineitems" align="center" width="1%"><a href="javascript:popw('/popups/QuickChangeForm.jsp?tableName=jobs&columnName=job_notes&valueType=String&question=Edit%20Job%20Description&rows=5&cols=40&primaryKeyValue=<%= request.getParameter("jobId")%>', 500, 200)" class="minderACTION">Edit</a></td><%

    } %>		

  </tr>

</table>