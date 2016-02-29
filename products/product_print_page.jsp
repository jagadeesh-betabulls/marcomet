<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<%@ include file="/includes/SessionChecker.jsp" %>
<%@ taglib uri="/WEB-INF/tld/taglib.tld" prefix="taglib" %>
<%@ page import="java.sql.*,com.marcomet.tools.*;" %>
<jsp:useBean id="pB" class="com.marcomet.products.ProductBean" scope="page" />
<%
Connection conn = com.marcomet.jdbc.DBConnect.getConnection();
Statement st = conn.createStatement();
Statement st2 = conn.createStatement();
String header="";
String footer="";
String productId = ((request.getParameter("productId")==null)?"":(String)request.getParameter("productId")); 
pB.setProductId(productId);
String sql = "SELECT * FROM product_line_headers_footers where prod_line_id="+pB.getProdLineId();
ResultSet rs = st.executeQuery(sql);
if (rs.next()){
	header=((rs.getString("header")==null)?"":rs.getString("header"));
	footer=((rs.getString("footer")==null)?"":rs.getString("footer"));	
}else{
	sql = "SELECT * FROM product_line_headers_footers where prod_line_id=0 and company_id="+session.getAttribute("siteHostCompanyId").toString();
	rs = st2.executeQuery(sql);
	if (rs.next()){
		header=((rs.getString("header")==null)?"":rs.getString("header"));
		footer=((rs.getString("footer")==null)?"":rs.getString("footer"));
	}	
}
%><html>
<head>
<title>Product Spec Sheet</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link rel="stylesheet" href="<%=(String)session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css">
<style type="text/css">
<!--
-->
</style>
</head>

<body bgcolor="white" leftmargin="0" topmargin="1">
<table width="100%"  height="100%" border="0" cellspacing="0" cellpadding="0">
  <tr><td height="1">
<table width="100%" border="0" cellspacing="1" cellpadding="1">
<tr><td colspan=5 class="header"><%=header%></td></tr>
<tr><td width="37%" colspan=5 height="41" class="prodPageProductName" align="center"><%=pB.getProductName()%></td></tr>
<tr><td class="prodPageProductLine" colspan=5 height="24" align="center"><a href="/products/productline_summary.jsp?productLineId=<%=pB.getProdLineId()%>" target="main" class="prodPageProductLine"><%=pB.getProductLineName()%></a></td> </tr>
<tr align="left" valign="top"> 
<td colspan="5" class="prodPageSummary"><%=pB.getProductSummary()%></td>
</tr>
<tr><td align="left" valign="top" ><img src="<%=(String)session.getAttribute("siteHostRoot")%>/fileuploads/product_images/<%=pB.getProductFullPicurl()%>"></td>
           <td width="34%" height="142" class="body">
            <blockquote>
              <p><%=pB.getProductFeatures()%> </p>
            </blockquote>
          </td>
 </tr>
  <tr align="left" valign="top"> 
    <td colspan="2" height="142" class="body"><%=pB.getProductDescription()%></td>
  </tr>
  <tr> 
          <td colspan="5" class="tableheader" bgcolor="#000099" height="21"><%=pB.getProductName()%> Product 
            Specifications</td>
  </tr>
  </table>
<tr><td height="1" colspan=5>  
<table width=100% border="0">
<%=pB.getSpecsTable()%>
  </table>
  </td></tr>
  <tr>
    <td valign="bottom"> 
      <table width=100% border=0 cellpadding=0 cellspacing=0>
</table>
</td></tr>
<tr><td class="footer"><%=footer%>
</td></tr>
</table>
</body>
</html><%st2.close();st.close();conn.close();%>