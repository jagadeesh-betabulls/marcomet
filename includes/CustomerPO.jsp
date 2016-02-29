<%@ page import="java.sql.*;" %>
<p /><table border="0" cellpadding="5" cellspacing="0"><tr><td class="tableheader" colspan=2>Customer Reference/Purchase Order Number</td></tr><tr><td class="lineitems" align="center" width=90%><%
Connection conn = com.marcomet.jdbc.DBConnect.getConnection();
Statement st = conn.createStatement();
String orderId="";
boolean print=((request.getParameter("print")==null || request.getParameter("print").equals("false"))?false:true);
      java.sql.ResultSet rs = st.executeQuery("Select o.id as 'orderId',customer_po from jobs j left join projects p on j.project_id=p.id left join orders o on p.order_id=o.id where j.id=" + request.getParameter("jobId"));
      if (rs.next()) {
      	orderId=((rs.getString("orderId")==null)?"":rs.getString("orderId"));
      %><%= ((rs.getString("customer_po")==null)?"":rs.getString("customer_po")) %><%
      } %>&nbsp;</td><%if (!print){%><td class="lineitems" align="center" width=10%><a href="javascript:popw('/popups/QuickChangeForm.jsp?tableName=orders&columnName=customer_po&valueType=String&question=Edit%20Customer%20Reference&rows=1&cols=30&primaryKeyValue=<%= orderId%>', '350', '120')" class="minderACTION">Edit</a></td><%}%></tr></table> 