<%@ page import="java.sql.*;" %>
<p /><table border="0" cellpadding="5" cellspacing="0"><tr><td class="tableheader" colspan=2>Subvendor Reference</td></tr><tr><td class="lineitems" align="center" width=90%><%
Connection conn = com.marcomet.jdbc.DBConnect.getConnection();
Statement st = conn.createStatement();
boolean print=((request.getParameter("print")==null || request.getParameter("print").equals("false"))?false:true);
      java.sql.ResultSet rs = st.executeQuery("SELECT j.subvendor_reference_data 'subvendor_reference_data' FROM jobs j WHERE j.id = " + request.getParameter("jobId"));
      if (rs.next()) {
      %><%= rs.getString("subvendor_reference_data") %><%
      } %>&nbsp;</td><%if (!print){%><td class="lineitems" align="center" width=10%><a href="javascript:popw('/popups/QuickChangeForm.jsp?tableName=jobs&columnName=subvendor_reference_data&valueType=String&question=Edit%20Subvendor%20Reference&rows=1&cols=30&primaryKeyValue=<%= request.getParameter("jobId")%>', '350', '120')" class="minderACTION">Edit</a></td><%}%></tr></table> 