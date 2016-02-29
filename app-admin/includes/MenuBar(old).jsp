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
<table cellpadding="0" border="0" cellspacing="0" width="100%">
  <tr> 
    <td class="mastentry" width="100%">&nbsp;&nbsp;&nbsp;&nbsp;Welcome <%= session.getAttribute("UserFullName") %>!</td>
    <%
//is there an order
	if(isOrder){
%>
    <td class="menuLINK" nowrap> <a href="/frames/InnerFrameset.jsp?contents=/catalog/summary/OrderSummary.jsp" target="_top" class="menuLINK">My 
      Order</a> <img src="<%=session.getAttribute("siteHostRoot")%>/images/bullet.gif" width="20" height="21" border="0" align="absmiddle">	
    </td>
    <%
	}
    if(((RoleResolver)session.getAttribute("roles")).isBuyer()) {
%>
    <td class="menuLINK" nowrap> 
      <div id="newOrder" style="display: '';"> <a href="/" target="_top" class="menuLINK">New 
        Order </a> <img src="<%=session.getAttribute("siteHostRoot")%>/images/bullet.gif" width="20" height="21" border="0" align="absmiddle"> 
      </div>
    </td>
    <%
     }
%>
    <td class="menuLINK" nowrap> <a href="/minders/JobMinderSwitcher.jsp" target="main" class="menuLINK"> 
      Jobs </a> <img src="<%=session.getAttribute("siteHostRoot")%>/images/bullet.gif" width="20" height="21" border="0" align="absmiddle">	
    </td>
    <td class="menuLINK" nowrap> <a href="/files/fileManager.jsp" target="main" class="menuLINK"> 
      Files </a> <img src="<%=session.getAttribute("siteHostRoot")%>/images/bullet.gif" width="20" height="21" border="0" align="absmiddle">	
    </td>
    <%
//show vendors report link
	if(((RoleResolver)session.getAttribute("roles")).isVendor()){
%>
    <td class="menuLINK" nowrap> <a href="/reports/" target="main" class="menuLINK"> 
      Reports</a> <img src="<%=session.getAttribute("siteHostRoot")%>/images/bullet.gif" width="20" height="21" border="0" align="absmiddle">	
    </td>
    <%
	}
%>
    <td class="menuLINK" nowrap> <a href="/users/AccountInformationPage.jsp" target="main" class="menuLINK">Account 
      Info </a> <img src="<%=session.getAttribute("siteHostRoot")%>/images/bullet.gif" width="20" height="21" border="0" align="absmiddle">	
    </td>
    <td class="menuLINK" nowrap> <a href="/jspscripts/KillLogin.jsp" target="scriptor" class="menuLINK">Logout 
      &nbsp;&nbsp;</a> </td>
  </tr>
</table>
<script language="JavaScript">
parent.window.main.location.href = parent.window.main.location.href;
</script>