<%@ page import="java.sql.*,java.util.*,com.marcomet.jdbc.*,com.marcomet.tools.*,com.marcomet.catalog.*,com.marcomet.users.security.*" %>
<jsp:include page="/includes/AutoLogin.jsp" flush="true"/>
<%
	boolean isOrder = false;
	ShoppingCart cart = (ShoppingCart)session.getAttribute("shoppingCart");
  	if(cart != null){
  		Vector projects = cart.getProjects();
		if(projects.size() > 0){
			isOrder = true;
		}
	}
%>
<body leftmargin="0" topmargin="0">
<table class="mastentry" cellpadding="0" border="0" cellspacing="0" width="100%">
  <tr> 
    <td width="40%">&nbsp;&nbsp;&nbsp;&nbsp;Welcome <%= session.getAttribute("UserFullName") %>!</td>
    <%
	if (isOrder) { %>
    <td align="right" width="10%"><a href="/frames/InnerFrameset.jsp?contents=/catalog/summary/OrderSummary.jsp" target="_top" class="menuLINK">Process&nbsp;Jobs</a></td>
    <%
	}
    if ( !(((RoleResolver)session.getAttribute("roles")).isVendor()) && !(((RoleResolver)session.getAttribute("roles")).isSiteHost()) ) { %>
    <td align="right" width="50%" nowrap><a href="<%=session.getAttribute("siteHostRoot")%>/contents/SiteHostCommerceIndex.jsp"" target="main" class="menuLINK">New&nbsp;Job</a><a href="/minders/JobMinderSwitcher.jsp" target="main" class="menuLINK">Jobs&nbsp;Console</a><a href="/files/fileManager.jsp" target="main" class="menuLINK">All&nbsp;Files</a><a href="/users/AccountInformationPage.jsp" target="main" class="menuLINK">User&nbsp;Info</a><a href="/jspscripts/KillLogin.jsp" target="scriptor" class="menuLINK">Logout</a></td>
    <%
    } else if (((RoleResolver)session.getAttribute("roles")).isSiteHost() && ((RoleResolver)session.getAttribute("roles")).isVendor()) { %>
    <td align="right" width="50%" nowrap><a href="<%=session.getAttribute("siteHostRoot")%>/contents/SiteHostCommerceIndex.jsp"" target="main" class="menuLINK">New&nbsp;Job</a><a href="/minders/JobMinderSwitcher.jsp" target="main" class="menuLINK">Jobs&nbsp;Console</a><a href="/files/fileManager.jsp" target="main" class="menuLINK">All&nbsp;Files</a><a href="/users/AccountInformationPage.jsp" target="main" class="menuLINK">User&nbsp;Info</a><a href="/jspscripts/KillLogin.jsp" target="scriptor" class="menuLINK">Logout</a></td>
    <%
    } else if (((RoleResolver)session.getAttribute("roles")).isSiteHost()) { %>
    <td align="right" width="50%" nowrap><a href="<%=session.getAttribute("siteHostRoot")%>/contents/SiteHostCommerceIndex.jsp"" target="main" class="menuLINK">New&nbsp;Job</a><a href="/minders/JobMinderSwitcher.jsp" target="main" class="menuLINK">Jobs&nbsp;Console</a><a href="/files/fileManager.jsp" target="main" class="menuLINK">All&nbsp;Files</a><a href="/users/AccountInformationPage.jsp" target="main" class="menuLINK">User&nbsp;Info</a><a href="/jspscripts/KillLogin.jsp" target="scriptor" class="menuLINK">Logout</a></td>
    <%
    } else if (((RoleResolver)session.getAttribute("roles")).isVendor()) { %>
    <td align="right" width="50%" nowrap><a href="<%=session.getAttribute("siteHostRoot")%>/contents/SiteHostCommerceIndex.jsp"" target="main" class="menuLINK">New&nbsp;Job</a><a href="/files/fileManager.jsp" target="main" class="menuLINK">All&nbsp;Files</a><a href="/users/AccountInformationPage.jsp" target="main" class="menuLINK">User&nbsp;Info</a><a href="/jspscripts/KillLogin.jsp" target="scriptor" class="menuLINK">Logout</a></td>
    <%
    } %>
  </tr>
</table>
<script language="JavaScript">
parent.window.main.location.href = parent.window.main.location.href;
</script>