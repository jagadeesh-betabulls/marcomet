<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<%@ page import="javax.servlet.*,javax.servlet.http.*,java.sql.*,java.util.*,com.marcomet.users.security.*, com.marcomet.jdbc.*, com.marcomet.environment.*;" %>
<%@ taglib uri="/WEB-INF/tld/taglib.tld" prefix="taglib" %>
<jsp:useBean id="str" class="com.marcomet.tools.StringTool" scope="session" /><%
boolean editor= ((((RoleResolver)session.getAttribute("roles")).roleCheck("editor")) );

String pageId=((request.getParameter("id")==null)?"":request.getParameter("id"));
Connection conn = DBConnect.getConnection();
Statement stB = conn.createStatement();
String queryStr="select * from v_promo_prods where sale_id='"+pageId+"'";
ResultSet rs = stB.executeQuery(queryStr);
if (rs.next()){
		%><html>
	<head>
		<title><%=((rs.getString("promo_title")==null || rs.getString("promo_title").equals(""))?"":rs.getString("promo_title"))%></title>
		<link rel="stylesheet" href="<%=(String)session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css">
		<script language="javascript" src="/javascripts/mainlib.js"></script>
	</head>
	<body><%if (editor){%><hr size=1 color=red>&nbsp;<a href='javascript:popw("/popups/QuickChangeHTMLForm.jsp?cols=60&rows=20&question=Change%20Promo%20Description&primaryKeyValue=<%=pageId%>&columnName=description&tableName=product_promo_bridge&valueType=string",600,600)' class='greybutton'>&raquo;&nbsp;EDIT DESCRIPTION</a>&nbsp;<hr size=1 color=red><%}%>
	<div class=Title><%=rs.getString("prod_name")+": "+rs.getString("prod_code")%></div><br>
	<div class=subtitle><%=((rs.getString("title")==null || rs.getString("title").equals(""))?"":rs.getString("title"))%></div><%=((rs.getString("promo_description")==null || rs.getString("promo_description").equals(""))?"":rs.getString("promo_description"))%>
	<br /><div align="center"><a href="javascript:window.close();" class="menuLINK">CLOSE</a></div></body>	</html><%
}else{
%><html>
	<head>
		<title>Page Not Found</title>
		<link rel="stylesheet" href="<%=(String)session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css">
		<script language="javascript" src="/javascripts/mainlib.js"></script>
	</head>
	<body><br><blockquote><div class=title>Promotion Not Found</div>
	<p>This is an invalid promotion reference, or this promotion has expired. </p><div align='center'><a href="javascript:window.close()" class='greybutton'>CLOSE</a></div></blockquote></body>
	</html><%
}
	stB.close();
	conn.close();
	%>
