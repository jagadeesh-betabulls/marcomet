<%@ page import="java.sql.*"%>
<p /><table border="0" cellpadding="5" cellspacing="0"><tr><td class="tableheader" colspan=2>Customer Service / Vendor Rep</td></tr><tr><td class="lineitems" align="center" width=90%><%		
Connection conn = com.marcomet.jdbc.DBConnect.getConnection();
Statement st = conn.createStatement();
boolean print=((request.getParameter("print")==null || request.getParameter("print").equals("false"))?false:true);
      java.sql.ResultSet rs = st.executeQuery("SELECT co.company_name,j.vendor_company_id 'company_id', j.vendor_contact_id 'vendor_rep', c.firstname 'firstname', c.lastname 'lastname' FROM jobs j, contacts c,companies co WHERE c.companyid=co.id and j.vendor_contact_id = c.id AND j.id = " + request.getParameter("jobId"));
      if (rs.next()) { 
	%><%= rs.getString("firstname") %>&nbsp;<%= rs.getString("lastname") %> / <%= rs.getString("co.company_name") %><%
      } 
//Add Vendor Rep company to display
%>&nbsp;</td><%if(!print){%><td class="lineitems" align="center" width=10%><a href="javascript:popw('/popups/QuickChangeFormDropDown.jsp?repId=<%=rs.getString("vendor_rep")%>&companyId=<%=rs.getString("company_id")%>&tableName=jobs&columnName=vendor_contact_id&valueType=String&question=Edit%20Vendor%20Rep&rows=1&cols=30&primaryKeyValue=<%= request.getParameter("jobId")%>', '350', '200')" class="minderACTION">Edit</a></td><%}%></tr></table>
