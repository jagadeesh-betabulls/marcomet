<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<%@ page import="java.sql.*,com.marcomet.tools.*,com.marcomet.environment.*,com.marcomet.jdbc.*,com.marcomet.users.security.*;" %>
<jsp:useBean id="formatter" class="com.marcomet.tools.FormaterTool" scope="page" />
<jsp:useBean id="str" class="com.marcomet.tools.StringTool" scope="page" />
<html>
	<head>
		<title>Order Product</title>
		<link rel="stylesheet" href="<%=(String)session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css">
	</head>
	<body>
<%
Connection conn = DBConnect.getConnection();
Statement stD = conn.createStatement();
String sitehostId=((SiteHostSettings)session.getAttribute("siteHostSettings")).getSiteHostId();
String prodCode=((request.getParameter("prodCode")==null)?"":request.getParameter("prodCode"));
String orderLink="";
SiteHostSettings shs = (SiteHostSettings)session.getAttribute("siteHostSettings");
String target=((shs.getSiteTarget()==null)?"main":shs.getSiteTarget());
String order="";
if (prodCode.equals("")){
	%><form action=""><div align="center">No product code was entered, please enter code:<input type="text" name="prodCode" size="20"><input type="button" value="Place Order" onclick="document.forms[0].submit();"></div></form><%
	
}else{
	String sql = "SELECT distinct p.id as prodId,p.offering_id as offering_id,os.service_type_id as service_type_id,os.job_type_id as job_type_id FROM products p,offerings o, offering_sequences os where p.offering_id=o.id and o.id=os.offering_id and os.sequence=0 and p.prod_code='"+prodCode+"'";
	ResultSet rsProds = stD.executeQuery(sql);
	if(rsProds.next()){
		orderLink="/frames/InnerFrameset.jsp?contents=/servlet/com.marcomet.catalog.CatalogNavigationServlet?offeringId="+rsProds.getString("offering_id")+"&jobTypeId="+rsProds.getString("job_type_id")+"&serviceTypeId="+rsProds.getString("service_type_id")+"&productId="+rsProds.getString("prodId");
	}
	if(orderLink.equals("")){
		%><form action=""><div align="center">Product Code <b><%=prodCode%></b> was not found in our system, please re-enter code:<input type="text" name="prodCode" size="20"><input type="button" value="Place Order" onclick="document.forms[0].submit();"></div></form><%
	}else{
		%><script>top.window.location.replace("<%=orderLink%>")</script><%
	}
}
%></body></html><%
	stD.close();
	conn.close();
%>