<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<%@ page import="javax.servlet.*,javax.servlet.http.*,java.sql.*,java.util.*,com.marcomet.users.security.*, com.marcomet.jdbc.*, com.marcomet.environment.*;" %>
<%
boolean editor= ( session.getAttribute("roles")!= null && (((RoleResolver)session.getAttribute("roles")).roleCheck("editor")) );
SiteHostSettings shs = (SiteHostSettings)session.getAttribute("siteHostSettings");

String pageId=((request.getParameter("pageId")==null)?"":request.getParameter("pageId"));
String pageName=((request.getParameter("pageName")==null)?"":request.getParameter("pageName"));
boolean partial=((request.getParameter("partial")==null)?false:true);

Connection conn = DBConnect.getConnection();
Statement stB = conn.createStatement();
String QryStr=((pageName.equals(""))?"select * from pages where id='"+pageId+"'":"select * from pages where (company_id='1066' or company_id="+shs.getSiteHostCompanyId()+") and page_name='"+pageName+"'");
ResultSet rs = stB.executeQuery(QryStr);

if (rs.next()){
	if(!partial){%><html>
	<head>
  	<link rel="stylesheet" href="<%=(String)session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css">
  	<link rel="stylesheet" href="/styles/marcomet.css" type="text/css">
  		<script language="javascript" src="/javascripts/mainlib.js"></script>
  		<title><%=((rs.getString("title")==null || rs.getString("title").equals(""))?"":rs.getString("title"))%></title>
	</head>
	<body><%
}
	if(rs.getString("title")!=null && !rs.getString("title").equals("")){%><div class=title><%if (editor){%><a href='javascript:pop("/popups/QuickChangeForm.jsp?cols=60&rows=1&question=Change%20Title&primaryKeyValue=<%=rs.getString("id")%>&columnName=title&tableName=pages&valueType=string",500,150)'>&raquo;<%=((rs.getString("title")==null || rs.getString("title").equals(""))?"[Edit Title]":"")%></a>&nbsp;<%}%><%=((rs.getString("title")==null || rs.getString("title").equals(""))?"":rs.getString("title"))%></div><%}%>
		<%if (editor){%><a href='javascript:pop("/popups/QuickChangeHTMLForm.jsp?cols=60&rows=20&question=Change%20Body&primaryKeyValue=<%=rs.getString("id")%>&columnName=html&tableName=pages&valueType=string",600,600)'>&raquo;<%=((rs.getString("html")==null || rs.getString("html").equals(""))?"[Edit Body]":"")%></a>&nbsp;<%}%><%=((rs.getString("html")==null || rs.getString("html").equals(""))?"":rs.getString("html"))%>
<%if(!partial){%></body></html><%}
}else{
%><html>
	<head>
		<title>Page Not Found</title>
	</head>
	<body><p>This is an invalid page reference, or this page has expired. Please click here to continue to the marketing home page: <a href="/" class='menuLINK'>HOME</a></p></body>
	</html><%
}
stB.close();
conn.close();
%>
