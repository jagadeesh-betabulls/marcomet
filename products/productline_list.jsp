<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<%@ include file="/includes/SessionChecker.jsp" %>
<%@ page import="java.sql.*,com.marcomet.tools.*;" %>
<%@ taglib uri="/WEB-INF/tld/taglib.tld" prefix="taglib" %>
<%
Connection conn = com.marcomet.jdbc.DBConnect.getConnection();
Statement st = conn.createStatement();
String siteHostId=session.getAttribute("siteHostId").toString();%><html>
<head>
<title>Edit Products and Lines</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link rel="stylesheet" href="<%=(String)session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css">
<style type="text/css">
</style>
</head>
<script language="JavaScript" src="/javascripts/mainlib.js"></script>
<%=((com.marcomet.users.security.RoleResolver)session.getAttribute("roles")).roleCheckRedirect("admin","/admin/no_rights.jsp")%>
<body bgcolor="#FFFFFF" background="<%=(String)session.getAttribute("siteHostRoot")%>/images/back.jpg" leftmargin="0" topmargin="1">
<p class="tableheader">Edit Products and Product Lines</p>
<blockquote >
  <p class="contentsTitle">Choose a Top-Level Product Line, or create a new one:
  <hr size=1>
  <table border=0 cellpadding=0 cellspacing=0><tr>
      <td class="yellowButtonBox"> <a href="/products/product_line_form.jsp" class="yellowButton">Add&nbsp;Product&nbsp;Line</a></td>

    </tr></table>
    <%
String sql = "SELECT * FROM product_lines WHERE prod_line_id=0 and company_id=" + session.getAttribute("siteHostCompanyId");
ResultSet rsLines = st.executeQuery(sql);
while (rsLines.next()){
	%>
  </p>
  <ul>
    <ul>
      <li><a href="/products/product_line_form.jsp?productLineId=<%=rsLines.getString("id")%>" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('editprodtop','','/images/buttons/editoverold.gif',1)"><img name="editprodtop" border="0" src="/images/buttons/editold.gif" width="34" height="21" align="absmiddle"></a><a href="/products/productline_summary.jsp?productLineId=<%=rsLines.getString("id")%>&editFlag=true" class="prodPageProductLine">&nbsp;&nbsp;<%=rsLines.getString("prod_line_name")%></a></li>
    </ul>
  </ul>
  <p>
    <%
}
%>
  </p>
</blockquote>
</body>
</html><%st.close();conn.close();%>
