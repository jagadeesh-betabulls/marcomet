<%@ page errorPage="/errors/ExceptionPage.jsp" %><%@ page import="com.marcomet.users.security.*,com.marcomet.users.security.RoleResolver, com.marcomet.environment.SiteHostSettings" %><% 
session.setAttribute("currentSession","true");
 if (session.getAttribute("contactId") == null) { 
 %><script language="JavaScript">
	window.location.replace("/app-admin/AdminLogin.jsp"); 
   </script><%
    } 
   %><jsp:include page="/app-admin/includes/LoadSiteHostInformation.jsp" flush="true"/><%
    if( request.getParameter("site") != null) request.getSession().setAttribute("siteHostRoot", "/sitehosts/" + request.getParameter("site")); 
    %><html>
<head>
  <title>Marcomet Site Administration</title>
  <meta http-equiv="pragma" content="no-cache">
  <meta http-equiv="Pragma-directive" content="no-cache">
  <meta http-equiv="cache-directive" content="no-cache">
  <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
  <link rel="stylesheet" href="<%=(String)session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css">
<script language="javascript" type="text/javascript">
if (parent.frames.length > 0) {
    parent.location.href = self.document.location
}
</script>
</head>
<frameset ID=outerFr framespacing="0" border="0" rows="<%=((SiteHostSettings)session.getAttribute("siteHostSettings")).getInnerFrameSetHeight() %>,*,40" frameborder="0" cols="*">
<frame name="header" scrolling="no" noresize target="main" src="<%=session.getAttribute("siteHostRoot")%>/headers/topmast_inner.jsp">
<frame name="main" scrolling="auto" noresize target="main" src="/app-admin/includes/AdminMenu.jsp">
<frame name="footer" scrolling="no" noresize target="main" src="<%=session.getAttribute("siteHostRoot")%>/footers/home_footer.jsp"></frameset>
</html>
