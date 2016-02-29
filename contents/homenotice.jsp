<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<%@ page import="com.marcomet.users.security.RoleResolver, com.marcomet.environment.SiteHostSettings" %>
<jsp:useBean id="sl" class="com.marcomet.tools.SimpleLookups" scope="page" />
<%
    SiteHostSettings shs = (SiteHostSettings) session.getAttribute("siteHostSettings");
    String targetStr=sl.getValue("site_hosts","id",shs.getSiteHostId(),"sh_target");
    if(session.getAttribute("homeNotice")!=null){
    	session.setAttribute("homeNotice",((session.getAttribute("homeNotice")==null)?"":session.getAttribute("homeNotice").toString().replace("target='mainFr'","target='"+targetStr+"'").replace("target='main'","target='"+targetStr+"'")));
    }
%>
<html>
<head>
<title>Proxy Order</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
  <link rel="stylesheet" href="/sitehosts/lms/styles/vendor_styles.css" type="text/css">
</head>

<body bgcolor="#FFFFFF" text="#000000" topmargin='0'>
<div class='lineitemsselected' align='center'><span class='subtitle'><%=((session.getAttribute("homeNotice")==null)?"":session.getAttribute("homeNotice").toString())%></span></div>
</body>
</html>
