<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<%@ page import="javax.servlet.*,javax.servlet.http.*,java.sql.*,java.util.*,com.marcomet.users.security.*, com.marcomet.jdbc.*, com.marcomet.environment.*;" %>
<%@ taglib uri="/WEB-INF/tld/taglib.tld" prefix="taglib" %>
<jsp:useBean id="str" class="com.marcomet.tools.StringTool" scope="session" /><%
boolean editor= ((((RoleResolver)session.getAttribute("roles")).roleCheck("editor")) );

String pageId=((request.getParameter("pageId")==null)?"":request.getParameter("pageId"));
String pageName=((request.getParameter("pageName")==null)?"":request.getParameter("pageName"));
Connection conn = DBConnect.getConnection();
Statement stB = conn.createStatement();
String queryStr=((pageName.equals(""))?"select * from pages where id='"+pageId+"'":"select * from pages where page_name='"+pageName+"'");
ResultSet rs = stB.executeQuery(queryStr);
if (rs.next()){
	pageId=rs.getString("id");
		%><html>
	<head>
		<title><%=((rs.getString("title")==null || rs.getString("title").equals(""))?"":rs.getString("title"))%></title>
		<link rel="stylesheet" href="<%=(String)session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css">
		<script language="javascript" src="/javascripts/mainlib.js"></script>
	</head>
	<body><%if (editor){%><hr size=1 color=red><a href='javascript:popw("/popups/QuickChangeForm.jsp?cols=60&rows=1&question=Change%20Title&primaryKeyValue=<%=pageId%>&columnName=title&tableName=pages&valueType=string",500,150)'class='greybutton'>&raquo;&nbsp;EDIT TITLE&nbsp;</a>&nbsp;<a href='javascript:popw("/popups/QuickChangeHTMLForm.jsp?cols=60&rows=20&question=Change%20Body&primaryKeyValue=<%=pageId%>&columnName=html&tableName=pages&valueType=string",600,600)' class='greybutton'>&raquo;&nbsp;EDIT PAGE</a>&nbsp;<hr size=1 color=red><%}%>
	<div class=title><%=((rs.getString("title")==null || rs.getString("title").equals(""))?"":rs.getString("title"))%></div><%=((rs.getString("html")==null || rs.getString("html").equals(""))?"":rs.getString("html"))%>
	<br /><div align="center"><a href="javascript:window.close();" class="menuLINK">CLOSE</a></div></body>	</html><%
}else{
%><html>
	<head>
		<title>Page Not Found</title>
		<link rel="stylesheet" href="<%=(String)session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css">
		<script language="javascript" src="/javascripts/mainlib.js"></script>
	</head>
	<body><br><blockquote><div class=title>Page Not Found</div>
	<p>This is an invalid page reference, or this page has expired. </p><div align='center'><a href="javascript:window.close()" class='greybutton'>CLOSE</a></div></blockquote></body>
	</html><%
}
	stB.close();
	conn.close();
	%>
