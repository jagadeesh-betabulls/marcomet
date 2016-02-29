<%
session.setAttribute("ProxyOrderObject", "");
String minder = "/minders/BuyerJobMinder.jsp";
if (session.getAttribute("roles") != null) {
	
	if (((com.marcomet.users.security.RoleResolver)session.getAttribute("roles")).roleCheck("sitehost_manager")) {
			minder = "/minders/SiteHostManagerJobMinder.jsp";
	}else if (((com.marcomet.users.security.RoleResolver)session.getAttribute("roles")).isVendor()) {
		if (((com.marcomet.users.security.RoleResolver)session.getAttribute("roles")).isSiteHost()) {
			minder = "/minders/SiteHostVendorJobMinder.jsp";
		} else {
			minder = "/minders/VendorJobMinder.jsp";
		}	
	} else if (((com.marcomet.users.security.RoleResolver)session.getAttribute("roles")).isSiteHost()) {
		minder = "/minders/SiteHostJobMinder.jsp";
	} else {
		minder = "/minders/BuyerJobMinder.jsp";
	}

%><script language="JavaScript">
	window.location.replace("<%= minder %>");
</script><%}else{%>	<script language="JavaScript">
		top.window.location.replace("/");
	</script><%}%>