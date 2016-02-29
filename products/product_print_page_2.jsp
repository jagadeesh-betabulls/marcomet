<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<%@ include file="/includes/SessionChecker.jsp" %>
<%@ taglib uri="/WEB-INF/tld/taglib.tld" prefix="taglib" %>
<%@ page import="java.sql.*,com.marcomet.tools.*;" %>
<jsp:useBean id="pB" class="com.marcomet.commonprocesses.ProcessProduct" scope="page" />
<jsp:useBean id="str" class="com.marcomet.tools.StringTool" scope="page" />
<%
Connection conn = com.marcomet.jdbc.DBConnect.getConnection();
Statement st = conn.createStatement();
Statement st2 = conn.createStatement();
String header="";
String footer="";
String productId = ((request.getParameter("productId")==null)?"":(String)request.getParameter("productId")); 
pB.select(productId);
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
</head>
<body bgcolor="white" leftmargin="0" topmargin="1">
<table width="80%" border="0" cellspacing="1" cellpadding="1">
<tr><td colspan=5 class="header"><%=header%></td></tr>
</table>
<table width="80%"  border="0" cellspacing="0" cellpadding="0">
    <tr><td class="prodPageProductName" align="center" colspan=3><%=pB.getProdName()%></td>
	</tr><tr>
		<td class="prodPageProductLine"  align="center" colspan=3><a href="/products/productline_summary.jsp?productLineId=<%=pB.getProdLineId()%>" target="main" class="prodPageProductLine"><%=pB.getProdLineName()%></a></td>
	</tr>
	<tr>
		
    <td width="50%" class="prodPageSummary" colspan=3 height="36">
<div align="center"><%=pB.getSummary()%></div></td>
	</tr>
  <tr> 
		<td colspan=3>
			<table width=100%><tr>
		  		
          <td width="47%" class="body" valign="top"><%=pB.getProdFeatures()%></td>
          <td width="6%" class="body" valign="top">&nbsp;</td>			
          <td width="47%" class="body" valign="top"><%=pB.getApplication()%></td>
        </tr>
			</table>
		</td>
  </tr>
  <tr> 
    <td align="left" valign="top" width="10%" ><%=((pB.getProdFullPicURL()==null || pB.getProdFullPicURL().equals(""))?"":"<img src='"+(String)session.getAttribute("siteHostRoot")+"/fileuploads/product_images/"+ str.replaceSubstring(pB.getProdFullPicURL()," ","%20")+"'>")%></td>
    <td width=10>&nbsp;</td>
	<td width="90%"  class="body">
					<table width=100% border="1">
				<tr> <td colspan="2" class="lineitems" height="21"><%=pB.getProdName()%> Product 
						Specifications</td></tr>
						<%=pB.getSpecsTable()%>
					</table>
          </td>
  </tr>
  <tr align="left" valign="top"> 
    <td colspan="3"class="body"><%=pB.getDescription()%><br><%=pB.getProdSpecDiagramPicURL()%></td>
  </tr>
  </table>
<table width=100%>
<tr><td class="footer"><%=footer%></td></tr>
</table>
</body>
</html><%st2.close();st.close();conn.close();%>