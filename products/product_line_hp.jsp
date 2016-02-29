<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<%@ include file="/includes/SessionChecker.jsp" %>
<%@ page import="java.sql.*,com.marcomet.tools.*;" %>
<%@ taglib uri="/WEB-INF/tld/taglib.tld" prefix="taglib" %>
<jsp:useBean id="fmt" class="com.marcomet.tools.FormaterTool" scope="session" />
<jsp:useBean id="str" class="com.marcomet.tools.StringTool" scope="page" />
<%
Connection conn = com.marcomet.jdbc.DBConnect.getConnection();
Statement st = conn.createStatement();
Statement st2 = conn.createStatement();
String siteHostId=session.getAttribute("siteHostId").toString();
String editFlag=((request.getParameter("editFlag")==null)?"":request.getParameter("editFlag"));
String prodLineId=((request.getParameter("prodLineId")==null)?"":request.getParameter("prodLineId"));
String sql = "SELECT * FROM product_lines where id="+prodLineId;
ResultSet rsProdLine = st.executeQuery(sql);
if(rsProdLine.next()){
%><html>
<head>
<title><%=rsProdLine.getString("prod_line_name")%> Home Page</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link rel="stylesheet" href="<%=(String)session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css">
<style type="text/css">
</style>
</head>
<script language="JavaScript" src="/javascripts/mainlib.js"></script>
<%if (rsProdLine.getString("homepage_html")==null){%>
<body bgcolor="#FFFFFF" background="<%=(String)session.getAttribute("siteHostRoot")%>/images/back.jpg" leftmargin="0" topmargin="1" onLoad="MM_preloadImages('/images/buttons/editoverold.gif')">
<br>
<table border=0 cellpadding=0 cellspacing=0 width=98% align="center">
  <tr>
		
    <td class="ProductLinetitle" width="86%"><%=rsProdLine.getString("prod_line_name")%><br>
      <br>
    </td>
		
    <td rowspan=2 width="14%"> 
<!--	<table cellspacing=0 cellpadding=0 width=100%>
	<tr>
	<td>
	<%=((rsProdLine.getString("full_picurl")==null || rsProdLine.getString("full_picurl").equals(""))?"":"<img src='"+(String)session.getAttribute("siteHostRoot")+"/fileuploads/product_images/"+ str.replaceSubstring(rsProdLine.getString("full_picurl")," ","%20") +"'>")%>
	</td>
	</tr><tr><td class="yellowButtonBox"> <a href="/products/productline_summary.jsp?productLineId=<%=prodLineId%>" class="yellowButton"><%=str.replaceSubstring(rsProdLine.getString("prod_line_name")," ","&nbsp;")%>&nbsp;Selector</a></td><tr>
	</tr></table>-->
    <tr>
    	<td class="body" width="86%"> <%=((rsProdLine.getString("homepage_html")==null)?rsProdLine.getString("summary"):rsProdLine.getString("homepage_html"))%>
	</td>
      </tr>
</table>
<br><br><br><%
	String lineStyle="first";
	sql = "SELECT * FROM press_releases where status_id=2 and  pr_type=2 and prod_line_id="+prodLineId;
	ResultSet rsPR = st2.executeQuery(sql);		
	while (rsPR.next()){
		if (lineStyle.equals("first")){
	%>
<table border=0 cellpadding=0 cellspacing=0 width=98% align="center">
  <tr>
    <td class="subProductLineTitle" colspan=2>&nbsp;Product Spotlight</td>
  </tr><%}
	lineStyle=((lineStyle.equals("prodLineHPLine") || lineStyle.equals("first"))?"prodLineHPAltLine":"prodLineHPLine");%>	
		<tr>
		<td width=5% class=<%=lineStyle%>><%=((rsPR.getString("small_picurl")==null || rsPR.getString("small_picurl").equals(""))?"":"<img src='"+(String)session.getAttribute("siteHostRoot")+"/fileuploads/page_images/"+ str.replaceSubstring(rsPR.getString("small_picurl")," ","%20") +"'>")%></td>
		
    <td  class=<%=lineStyle%> valign="top"><a class="prodLineHPNews" href="/press_releases/pressrelease_page.jsp?prId=<%=rsPR.getString("id")%>"><b><%=rsPR.getString("title")%></b>-<%=rsPR.getString("summary")%></a></td>
		</tr>
	<%}%>
		<%if (!lineStyle.equals("first") ){%><tr>
    <td colspan=2>&nbsp;</td>
  </tr><%}%>
</table>
<br><%
	lineStyle="first";
	sql = "SELECT * FROM press_releases where status_id=2 and not(pr_type=2) and prod_line_id="+prodLineId;
	rsPR = st2.executeQuery(sql);		
	while (rsPR.next()){
		if (lineStyle.equals("first")){	
			%>
<table border=0 cellpadding=0 cellspacing=0 width=98% align="center">
  <tr> 
    <td colspan="2" class="subProductLineTitle" height="23">&nbsp;Product News and Announcements</td>
  </tr>
  <%}
	lineStyle=((lineStyle.equals("prodLineHPLine") || lineStyle.equals("first"))?"prodLineHPAltLine":"prodLineHPLine");%>
  <tr> 

    <td class="<%=lineStyle%>" valign="top"><a  class="prodLineHPNews"  href="/press_releases/pressrelease_page.jsp?prId=<%=rsPR.getString("id")%>"><b><%=rsPR.getString("title")%></b>-<%=rsPR.getString("summary")%></a></td>
  </tr>
  <%}%>
  <%if (!lineStyle.equals("first") ){%>
  <tr> 
    <td colspan=2>&nbsp; </td>
  </tr>
  <%}%>
</table>

	
</body>
<%}else{%>
<%=rsProdLine.getString("homepage_html")%>
<%}
}%>
</html><%st2.close();st.close();conn.close();%>