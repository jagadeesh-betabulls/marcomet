<%@ page import="java.util.*,java.sql.*, com.marcomet.catalog.*,com.marcomet.jdbc.*,com.marcomet.environment.*" %>
<%@ taglib uri="/WEB-INF/tld/taglib.tld" prefix="taglib" %>
<%
    Connection conn = DBConnect.getConnection();
	Statement st = conn.createStatement();
	session.setAttribute("reprintJob","true");
	session.setAttribute("priorJobId",request.getParameter("jobId"));
	session.setAttribute("lastRow",request.getParameter("lastRow"));
	session.setAttribute("lastCol",request.getParameter("lastCol"));
	System.out.println("priorJobId is "+session.getAttribute("priorJobId"));
	String sql = "SELECT p.*,os.job_type_id,os.service_type_id from products p left join offerings o on o.id=p.offering_id left join offering_sequences os on os.offering_id=o.id, jobs j where p.id=j.product_id and j.id='"+request.getParameter("jobId")+"'";
	
    ResultSet rs = st.executeQuery(sql);
	if(rs.next()){%>
<html><head>
<script>
	function reprint(){
		document.location.href="/servlet/com.marcomet.catalog.CatalogNavigationServlet?offeringId=<%=rs.getString("offering_id")%>&jobTypeId=<%=rs.getString("job_type_id")%>&serviceTypeId=<%=rs.getString("service_type_id")%>&productId=<%=rs.getString("id")%>&priorJobId=<%=request.getParameter("jobId")%>";
	}
	reprint();<%
	}%>
</script>
</head></html>
<%
st.close();
conn.close();
%>