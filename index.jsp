<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<%@ page import="com.marcomet.users.security.RoleResolver, com.marcomet.environment.SiteHostSettings" %>
<% session.setAttribute("currentSession","true"); %>
<jsp:include page="/includes/LoadSiteHostInformation.jsp" flush="true"/>
<%
	String mainFrameSource = session.getAttribute("siteHostRoot")+"/contents/SiteHostIndex.jsp";
if(request.getParameter("contents")!=null){
	String tmpStr=request.getParameter("contents").replace('|','?');
	session.setAttribute("contents",tmpStr.replace('~','&'));
}
	if (request.getParameter("cmyp")!=null){
			Cookie c2 =new Cookie("qwerty",request.getParameter("cmyp"));
			c2.setPath("/");
			c2.setComment("MC: Customer Service");
			c2.setMaxAge(30*24*60*60);
			response.addCookie(c2);
   	 }	
if(session.getAttribute("contents") == null){
		if(session.getAttribute("roles") != null){
			if(((RoleResolver)session.getAttribute("roles")).roleCheck("sitehost_manager")){
					mainFrameSource = session.getAttribute("siteHostRoot")+"/contents/SiteHostIndex.jsp";
			}else if(((RoleResolver)session.getAttribute("roles")).isVendor()){
					mainFrameSource = "/minders/JobMinderSwitcher.jsp";
			}else if(((RoleResolver)session.getAttribute("roles")).isSiteHost()){
					mainFrameSource = session.getAttribute("siteHostRoot")+"/contents/SiteHostIndex.jsp";
				}else{
					mainFrameSource = session.getAttribute("siteHostRoot")+"/contents/SiteHostIndex.jsp";
				}
		}	

	}else{
		if(session.getAttribute("contactId") != null){
			mainFrameSource = session.getAttribute("siteHostRoot")+"/contents/SiteHostIndex.jsp?content="+((String)session.getAttribute("contents")).replace("&","^");
		//	session.removeAttribute("contents");
		}
	}	
%>
<html>
<head><%
	if (request.getParameter("cmyp")!=null && session.getAttribute("allowGuestLogin").toString().equals("1") && session.getAttribute("guestEID").toString().equals(request.getParameter("cmyp")) ){
			Cookie c2 =new Cookie("qwerty",request.getParameter("cmyp"));
			c2.setPath("/");
			c2.setComment("MC: Customer Service");
			c2.setMaxAge(30*24*60*60);
			response.addCookie(c2);
    }
%><meta http-equiv="Content-Type" content="text/html; charset=windows-1252">
<META HTTP-EQUIV="pragma" CONTENT="no-cache">
<META HTTP-EQUIV="Pragma-directive" CONTENT="no-cache">
<META HTTP-EQUIV="cache-directive" CONTENT="no-cache">
<title><%=((session.getAttribute("UserFullName")==null)?"Marketing":session.getAttribute("UserFullName"))%></title>
<script lanugage="JavaScript" src="/javascripts/mainlib.js"></script>
<script language="JavaScript">
	if (self.parent.frames.length != 0){ self.parent.location=self.location; }
<%	if (request.getParameter("cmyp")!=null && session.getAttribute("allowGuestLogin").toString().equals("1") && session.getAttribute("guestEID").toString().equals(request.getParameter("cmyp")) ){
%>	var today = new Date();
 	var expire = new Date();
 	var nDays=30;
	expire.setTime(today.getTime() + 3600000*24*nDays);
	document.cookie = "qwerty=<%=request.getParameter("cmyp")%>;expires="+expire.toGMTString();
	<%}%>
</script>
<script type="text/javascript">
 
  var _gaq = _gaq || [];
  _gaq.push(['_setAccount', 'UA-18515846-1']);
  _gaq.push(['_setDomainName', '.marcomet.com']);
  _gaq.push(['_trackPageview']);
 
  (function() {
    var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
    ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
    var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
  })();
 
</script>
</head>
<frameset ID=outerFr framespacing="0" border="0" rows="<%= ((session.getAttribute("homeNotice")==null)?"":Integer.toString((request.getSession().getAttribute("homeNotice").toString().length()/90)*28)+",")+((SiteHostSettings)session.getAttribute("siteHostSettings")).getOuterFrameSetHeight() %>,*,40,0,0" frameborder="0" cols="*">
<%=((session.getAttribute("homeNotice")==null)?"":"<frame name='proxy' scrolling='no' noresize src='/contents/homenotice.jsp'>")%>
	<frame name="header" scrolling="no" noresize target="main" src="<%=session.getAttribute("siteHostRoot")%>/headers/topmast_home.jsp">
  	<frame name="main" scrolling="auto" noresize target="main" src="<%=mainFrameSource%>">
	<frame name="footer" scrolling="no" noresize target="main" src="<%=session.getAttribute("siteHostRoot")%>/footers/home_footer.jsp">
	<frame name="scriptor" scrolling="no" noresize src="/contents/blankpage.jsp">
	<frame name="refresher" scrolling="no" noresize src="/contents/TimedRefreshPage.jsp">
<noframes>
<body>
<p>This page uses frames, but your browser doesn't support them.</p>
</body>
</noframes>
</frameset>

</html>
