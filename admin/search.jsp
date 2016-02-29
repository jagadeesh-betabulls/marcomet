<%@ include file="/includes/SessionChecker.jsp" %>
<%@ page import="java.sql.*,com.marcomet.tools.*;" %>
<%@ taglib uri="/WEB-INF/tld/taglib.tld" prefix="taglib" %>
<jsp:useBean id="connection" class="com.marcomet.jdbc.ConnectionBean" scope="session" />
<html>
<head>
<title>Search</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link rel="stylesheet" href="<%=(String)session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css">
</head>

<body bgcolor="#FFFFFF" background="<%=(String)session.getAttribute("siteHostRoot")%>/images/back.jpg" leftmargin="0"  class='body' topmargin="0" marginwidth="0" marginheight="0">
<%String lineStyle="first";
if (request.getParameter("searchString") !=null ){
	%><br><table width=100% cellpadding=6 cellspacing=0>
  <tr> 
    <td class="maintitle" colspan=3 height="25">Search Results for "<%=request.getParameter("searchString")%>"</td>
  </tr>
    <tr > 
    <td colspan=3 height="5">&nbsp;</td>
  </tr>
    <tr>
      <td class="tableheader" width="4%">&nbsp;</td>
      <td class="tableheader" width="19%">Product Name</td>
      <td class="tableheader" width="77%">Summary</td>
    </tr>	
  <%String sql = "Select * from products where company_id="+session.getAttribute("siteHostCompanyId").toString()+" and prod_name like '%"+request.getParameter("searchString")+"%' or summary like '%"+request.getParameter("searchString")+"%' or detailed_description like '%"+request.getParameter("searchString")+"%'";
  Connection conn = com.marcomet.jdbc.DBConnect.getConnection();
  Statement st = conn.createStatement();
  ResultSet rsPL = st.executeQuery(sql);
	while (rsPL.next()){
		lineStyle=((lineStyle.equals("prodLineHPLine") || lineStyle.equals("first"))?"prodLineHPAltLine":"prodLineHPLine");%>
  	<tr>
      <td  width="4%" class="<%=lineStyle%>">&nbsp;</td>
		
      <td class="<%=lineStyle%>" width="19%" ><a href="/products/product_page.jsp?productId=<%=rsPL.getString("id")%>"><%=rsPL.getString("prod_name")%></a> </td>
		
      <td class="<%=lineStyle%>" width="77%" ><%=rsPL.getString("summary")%></td></tr>

  <%}%>  </table>
  <br>
  <br>
  <input type=button value="Continue" onClick="window.history.back()">
<%}else{%>
<br>
<form method="post" action="/admin/search.jsp">
  <table width=100% cellpadding=4 align="center">
    <tr>
      <td class='maintitle'>Site Search</td>
    </tr>
	</table>
  <table width=95% cellpadding=4 align="center">	
  <tr>
    <td class="body">Please enter your search string below. This will search through 
      the product pages for your request.</td>
  </tr>
  <tr class="body"><td>
    <input type="text" name="searchString" size="80"></td></tr>
  <tr class="body"><td>
  <input type=submit value="Search" name="Submit"></td></tr>
</table>  </form><%}%>
</body>
</html><%conn.close();%>
