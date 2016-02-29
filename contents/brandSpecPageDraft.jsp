<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<%@ page import="javax.servlet.*,javax.servlet.http.*,java.sql.*,java.util.*,com.marcomet.users.security.*, com.marcomet.jdbc.*, com.marcomet.environment.*;" %>
<%

boolean editor=false;
if(session.getAttribute("contactId") != null){
 editor=((((RoleResolver)session.getAttribute("roles")).roleCheck("editor")) );
}
SiteHostSettings shs = (SiteHostSettings)session.getAttribute("siteHostSettings");
String pageId=((request.getParameter("pageId")==null)?"":request.getParameter("pageId"));
String pageName=((request.getParameter("pageName")==null)?"":request.getParameter("pageName"));
Connection conn = DBConnect.getConnection();
Statement stB = conn.createStatement();
boolean hasPic=true;
boolean picBottom=((request.getParameter("picBottom")==null)?false:true);
boolean draft=((request.getParameter("Draft")==null)?false:true);
String QryStr=((pageName.equals(""))?"select *,concat('<img src=\""+(String)session.getAttribute("siteHostRoot")+"/images/',replace(full_picurl,',','\" ><br><br><img src=\""+(String)session.getAttribute("siteHostRoot")+"/images/'),'\">') pic  from pages where id='"+pageId+"'":"Select *,concat('<img src=\""+(String)session.getAttribute("siteHostRoot")+"/images/',replace(full_picurl,',','\" ><br><br><img src=\""+(String)session.getAttribute("siteHostRoot")+"/images/'),'\">') pic from pages where company_id="+shs.getSiteHostCompanyId()+" and page_name='"+pageName+"'");
ResultSet rs = stB.executeQuery(QryStr);
if (rs.next()){
	hasPic=((rs.getString("full_picurl") ==null || rs.getString("full_picurl").equals(""))?false:true);
%><html>
<head><!-- <%=QryStr%> -->
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<title><%=((rs.getString("title")==null || rs.getString("title").equals(""))?"":rs.getString("title"))%></title>
  <link rel="stylesheet" href="<%=(String)session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css">
  <script language="javascript" src="/javascripts/mainlib.js"></script>
<style type="text/css">
.thrColLiq {
  font: 100% Verdana, Arial, Helvetica, sans-serif;  background: white;  margin: 0;  padding: 0;  text-align: center;  color: #000000;
}
.thrColLiq #container {
	width: 100%;  margin: auto; text-align: left; margin-top: 15px;
}

.floatright { /* this class can be used to float an element right in your page. The floated element must precede the element it should be next to on the page. */
  float: right;margin-left: 8px;
}

.floatleft { /* this class can be used to float an element left in your page The floated element must precede the element it should be next to on the page. */
  float: left;
  margin-right: 8px;
}
.clearfloat { /* this class should be placed on a div or break element and should be the final element before the close of a container that should fully contain its child floats */
  clear: both;  height: 0;  font-size: 1px;  line-height: 0px;
}
</style>

<style type="text/css"> 
/* place css fixes for all versions of IE in this conditional comment */
.thrColLiq #images, .thrColLiq #sidebar1 { padding-top: 30px; }
.thrColLiq #mainContent { zoom: 1; padding-top: 15px; }
/* the above proprietary zoom property gives IE the hasLayout it needs to avoid several bugs */
</style>
</head>

<body class="thrColLiq"><%if (draft) {%><div class="title">[D R A F T]</div><div class='subtitle'>Note: This page is under construction and specifications listed here should not be used for production of materials without prior authorization from the Brand.</div>
<%}%><table width="100%" cellpadding="0" cellspacing="0" height="100%"><tr>
<td valign="bottom" style="background: url(<%=(String)session.getAttribute("siteHostRoot")%>/images/left_gradient_top.jpg) top left no-repeat;" width="50"><img src="<%=(String)session.getAttribute("siteHostRoot")%>/images/left_gradient_bottom.jpg" align="bottom" /></td>
<td valign="top">
<div id="container">
<div class=title><%if (editor){%><a href='javascript:pop("/popups/QuickChangeForm.jsp?cols=50&rows=1&question=Change%20Title&primaryKeyValue=<%=rs.getString("id")%>&columnName=title&tableName=pages&valueType=string",500,150)'>&raquo;<%=((rs.getString("title")==null || rs.getString("title").equals(""))?"[Edit Title]":"")%></a>&nbsp;<%}%><%=((rs.getString("title")==null || rs.getString("title").equals(""))?"":rs.getString("title"))%></div> <%

if(!picBottom){

%><div class="floatright" ><%if (editor){%><a href='javascript:pop("/popups/QuickChangeForm.jsp?cols=60&rows=1&question=Change%20Image&primaryKeyValue=<%=rs.getString("id")%>&columnName=full_picurl&tableName=pages&valueType=string",500,150)'>[Edit IMAGE URL]</a><br><%}%><%=((rs.getString("full_picurl")==null || rs.getString("full_picurl").equals(""))?"":rs.getString("pic"))%>
  </div>
  <p style="margin-right:20px;">
<div class="bodyBlack"><%if (editor){%><a href='javascript:pop("/popups/QuickChangeHTMLForm.jsp?cols=80&rows=50&question=Change%20Title&primaryKeyValue=<%=rs.getString("id")%>&columnName=html&tableName=pages&valueType=string",700,800)'>&raquo;<%=((rs.getString("html")==null || rs.getString("html").equals(""))?"[Edit Body]":"")%></a>&nbsp;<%}%><%=((rs.getString("html")==null || rs.getString("html").equals(""))?"":rs.getString("html"))%></div>
</p><%

}else{

%> <p  style="margin-right:20px;">
<div class="bodyBlack"><%if (editor){%><a href='javascript:pop("/popups/QuickChangeHTMLForm.jsp?cols=80&rows=50&question=Change%20Title&primaryKeyValue=<%=rs.getString("id")%>&columnName=html&tableName=pages&valueType=string",700,800)'>&raquo;<%=((rs.getString("html")==null || rs.getString("html").equals(""))?"[Edit Body]":"")%></a>&nbsp;<%}%><%=((rs.getString("html")==null || rs.getString("html").equals(""))?"":rs.getString("html"))%></div>
</p><br><br>
<div style="text-align: center;"><%if (editor){%><a href='javascript:pop("/popups/QuickChangeForm.jsp?cols=60&rows=1&question=Change%20Image&primaryKeyValue=<%=rs.getString("id")%>&columnName=full_picurl&tableName=pages&valueType=string",500,150)'>[Edit IMAGE URL]</a><br><%}%><%=((rs.getString("full_picurl")==null || rs.getString("full_picurl").equals(""))?"":rs.getString("pic"))%>
</div><%
}
%>
<br class="clearfloat" />
</div></td></tr></table>
</body>
</html><%
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
