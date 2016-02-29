<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<%@ page import="javax.servlet.*,javax.servlet.http.*,java.sql.*,java.util.*,com.marcomet.users.security.*, com.marcomet.jdbc.*, com.marcomet.environment.*;" %>
<%
    boolean editor = (session.getAttribute("roles") != null && (((RoleResolver) session.getAttribute("roles")).roleCheck("editor")));
    SiteHostSettings shs = (SiteHostSettings) session.getAttribute("siteHostSettings");
    String sitehostId = ((SiteHostSettings) session.getAttribute("siteHostSettings")).getSiteHostId();
    String pageId = ((request.getParameter("pageId") == null) ? "" : request.getParameter("pageId"));
    String pageName = ((request.getParameter("pageName") == null) ? "" : request.getParameter("pageName"));
    boolean createPage = ((request.getParameter("createPage") != null && request.getParameter("createPage").equals("true")) ? true : false);
    boolean div = ((request.getParameter("div") != null && request.getParameter("div").equals("true")) ? true : false);
    boolean partial = ((request.getParameter("partial") == null) ? false : true);

    Connection conn = DBConnect.getConnection();
    Statement stB = conn.createStatement();
    String QryStr = ((pageName.equals("")) ? "select * from pages where id='" + pageId + "'" : "select * from pages where (company_id=" + shs.getSiteHostCompanyId() + " or company_id='1066') and page_name='" + pageName + "' order by sequence");
    ResultSet rs = stB.executeQuery(QryStr);

    if (rs.next()) {
      if (!partial) {
%>
<html>
  <head>
    <link rel="stylesheet" href="<%=(String) session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css">
    <link rel="stylesheet" href="/styles/marcomet.css" type="text/css">
    <script language="javascript" src="/javascripts/mainlib.js"></script>
    <title><%=((rs.getString("title") == null || rs.getString("title").equals("")) ? "" : rs.getString("title"))%></title>
  </head>
  <body>
    <%}
  if (rs.getString("title") != null && !rs.getString("title").equals("")) {%><div class=title><%if (editor) {%><a href='javascript:pop("/popups/QuickChangeForm.jsp?cols=60&rows=1&question=Change%20Title&primaryKeyValue=<%=rs.getString("id")%>&columnName=title&tableName=pages&valueType=string",500,150)'>&raquo;<%=((rs.getString("title") == null || rs.getString("title").equals("")) ? "[Edit Title]" : "")%></a>&nbsp;<%}%><%=((rs.getString("title") == null || rs.getString("title").equals("")) ? "" : rs.getString("title"))%></div><%}%>
    <%if (editor) {%><a href='javascript:pop("/popups/QuickChangeHTMLForm.jsp?cols=60&rows=20&question=Change%20Body&primaryKeyValue=<%=rs.getString("id")%>&columnName=html&tableName=pages&valueType=string",600,600)'>&raquo;<%=((rs.getString("html") == null || rs.getString("html").equals("")) ? "[Edit Body]" : "")%></a>&nbsp;<%}%><%=((rs.getString("html") == null || rs.getString("html").equals("")) ? "" : rs.getString("html"))%>
<%if (!partial) {%></body></html><%}
} else if (!div && editor) {
%>
<div id="divConfirmBrandSpecPage" style="background-color: #fffccc; border: 2px solid black;">
  <br><%if (pageName.equals("")){%>
  No page was found with that page id (<%=pageId%>) for this site host. Would you like to create a new one?  
  <%}else{%>
  No page was found with that page name (<%=pageName%>) for this site host. Would you like to create a new one?
  <%}%>
  <br><br><br>
  &nbsp;&nbsp;&nbsp;&nbsp;
  <input type="button" value="Yes" onclick="javascript:window.location.replace(window.location.href+'&createPage=true&div=true')">
  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  <input type="button" value="No" onclick="javascript:window.location.replace(window.location.href+'&createPage=false&div=true')">
  <br>
</div>
<%} else {
  	if (createPage) {
%>
<html>
  <head>
    <title>Create New Page</title>
  </head>
  <body>
    <%
    String sql = "INSERT INTO pages (page_name, sequence, company_id, contact_id, status_id, sitehost_id_p) VALUES ('" + pageName + "', 0, " + shs.getSiteHostCompanyId() + ", " + shs.getSiteHostCompanyId() + ", 2, " + sitehostId + ")";
    stB.executeUpdate(sql);
    %>
    <script>window.location.replace('/contents/page.jsp?pageName=<%= pageName%>&createPage=false&div=true');</script>
  </body>
</html>
<%} else {
%><html>
  <head>
    <title>Page Not Found</title>
  </head>
  <body><p>This is an invalid page reference, or this page has expired. Please click here to continue to the marketing home page: <a href="/" class='menuLINK'>HOME</a></p></body>
</html><%    }
    }
    stB.close();
    conn.close();
%>
