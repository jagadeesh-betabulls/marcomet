<%@ page errorPage="/errors/ExceptionPage.jsp" %><%@ page import="com.marcomet.users.security.RoleResolver, com.marcomet.environment.SiteHostSettings" %><% session.setAttribute("currentSession","true"); %><jsp:include page="/includes/LoadSiteHostInformation.jsp" flush="true"/>
<html><head><title>Marketing Services</title>
   <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
   <link rel="stylesheet" href="<%=(String)session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css">  
</head>
<script language="JavaScript" src="/javascripts/mainlib.js"></script>
<body leftmargin="0" topmargin="10">
<table width="100%" align="top" height=100% border=0 cellpadding="0" cellspacing="0" >
  <tr align="top">
    <td valign=top> <%
	String mainFrameSource = session.getAttribute("siteHostRoot")+"/includes/Logged_Home.jsp";
		if (request.getParameter("cmyp")!=null){
			Cookie c2 =new Cookie("qwerty",request.getParameter("cmyp"));
			c2.setPath("/");
			c2.setComment("MC: Customer Service");
			c2.setMaxAge(30*24*60*60);
			response.addCookie(c2);   	 
		}
		if(session.getAttribute("contents") == null){
			if(session.getAttribute("roles") != null){
				if(((RoleResolver)session.getAttribute("roles")).isVendor()){
					mainFrameSource = "/minders/JobMinderSwitcher.jsp";
				}else if(((RoleResolver)session.getAttribute("roles")).isSiteHost()){
					mainFrameSource = session.getAttribute("siteHostRoot")+"/includes/Logged_Home.jsp";
				}else{
					mainFrameSource = session.getAttribute("siteHostRoot")+"/includes/Logged_Home.jsp";
				}
			}else{
				mainFrameSource = session.getAttribute("siteHostRoot")+"/includes/NonLogged_Home.jsp";
			}
		}else{
			if(session.getAttribute("contactId") != null){
				mainFrameSource = (String)session.getAttribute("contents");
				session.removeAttribute("contents");
			}else{
				mainFrameSource = session.getAttribute("siteHostRoot")+"/includes/NonLogged_Home.jsp";
			}
		}%>
      <jsp:include page="<%=mainFrameSource%>" flush="true" />
    </td>
  </tr>
</table>
</body>
</html>
