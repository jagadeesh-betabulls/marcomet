<%@ page import="java.util.*,java.sql.*, com.marcomet.catalog.*,com.marcomet.jdbc.*,com.marcomet.environment.*" %>
<%@ taglib uri="/WEB-INF/tld/taglib.tld" prefix="taglib" %>
<%
    Connection conn = DBConnect.getConnection();
	Statement st = conn.createStatement();
	if(request.getParameter("gtc")!=null){
		session.setAttribute("reprintJob","true");
		session.setAttribute("priorJobId",request.getParameter("jobId"));
	}
	System.out.println("priorJobId is "+session.getAttribute("priorJobId"));
	String sql = "SELECT p.*,os.job_type_id,os.service_type_id from products p left join offerings o on o.id=p.offering_id left join offering_sequences os on os.offering_id=o.id, jobs j where p.id=j.product_id and j.id='"+request.getParameter("jobId")+"'";
	
    ResultSet rs = st.executeQuery(sql);
	if(rs.next()){%>
<html><head>
<script>
	function reprint(){
		document.location.href="/servlet/com.marcomet.catalog.CatalogNavigationServlet?offeringId=<%=rs.getString("offering_id")%>&jobTypeId=<%=rs.getString("job_type_id")%>&serviceTypeId=<%=rs.getString("service_type_id")%>&productId=<%=rs.getString("id")%>&priorJobId=<%=request.getParameter("jobId")%>";
	}
	<%if (request.getParameter("gtc")!=null){%>reprint();<%}%>
</script>
  	<link rel="stylesheet" href="/styles/marcomet.css" type="text/css">
  	<link rel="stylesheet" href="<%=(String)session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css">
  		<script language="javascript" src="/javascripts/mainlib.js"></script>
  		<title>Reprint/Edit File</title>
</head><%if (request.getParameter("gtc")==null){%><body style="margin-left:20px;margin-right:20px;margin-top:30px;">
<jsp:include page="/contents/page.jsp" flush="true" >
	<jsp:param name="pageName" value="reprintIntroText" />
	<jsp:param name="partial" value="true" />
</jsp:include>
<br><br>
<div align='center'><a href="javascript:reprint();" class='plainLink'>CONTINUE &raquo;</a></div>
</body><%}%></html>
<%}
st.close();
conn.close();
%>