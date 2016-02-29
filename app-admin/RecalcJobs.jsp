<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<%@ page import="java.sql.*,java.util.*,com.marcomet.users.security.*, com.marcomet.jdbc.*, com.marcomet.environment.*,com.marcomet.workflow.actions.*;" %>
<%@ taglib uri="/WEB-INF/tld/taglib.tld" prefix="taglib" %>
<%@ include file="/includes/SessionChecker.jsp" %>
<html><head><title>Recalc Job Costs</title>
<link rel="stylesheet" href="/htdocs/commerce/styles/marcomet.css" type="text/css"></head><body><p class='Title'>Recalculating Job Costs for flagged jobs.</p><%
//String query = "update tmp_shipping_data t, shipping_data s set s.reference=t.reference,s.method=t.method,s.vendor_ship_reference=t.vendor_ship_reference  where s.job_id=t.job_id and s.cost=t.cost and s.reference<>t.reference and s.reference='see warehouse'";

CalculateJobCosts cjc = new CalculateJobCosts();
Connection conn = DBConnect.getConnection();
Statement st = conn.createStatement();
ResultSet rs = null;

String query=((request.getParameter("jobId")==null || request.getParameter("jobId").equals("") )?"Select * from jobs where recalc_flag=1":"Select * from jobs where id="+request.getParameter("jobId"));

int x=0;
rs = st.executeQuery(query);
while (rs.next()) {
	cjc.calculate(rs.getString("id"));
	x++;
	%>Job <%=x%> Updated:<%=rs.getString("id")%><br><%
}
st.close();
conn.close();
%><hr><%=x%> Job records updated.</body></html>