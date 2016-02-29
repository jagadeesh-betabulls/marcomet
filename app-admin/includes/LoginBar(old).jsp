<%@ page import="java.util.Vector, com.marcomet.catalog.*" %><%
  ShoppingCart cart = (ShoppingCart)session.getAttribute("shoppingCart");
  Vector projects = null;
  if (cart != null) {
    projects = cart.getProjects();
  } else {
    projects = new Vector();
  }
%>
<jsp:include page="/includes/AutoLogin.jsp" flush="true" />
<table border="0" cellpadding="0" cellspacing="0" width="100%">
  <tr> 
    <td class="menuLINK" width="5%">&nbsp;</td>
    <%
  if (projects.size() > 0) { %>
    <td class="menuLINK" width="10%"><a href="javascript:parent.window.location.replace('/frames/InnerFrameset.jsp?contents=/catalog/summary/OrderSummary.jsp')" class="menuLINK">My 
      Order</a></td>
    <%
  } else { %>
    <td class="menuLABEL" width="10%">&nbsp;</td>
    <%
  } %>
    <td class="menuLABEL" width="32%">&nbsp;</td>
    <td class="menuLABEL" align="right" width="8%">User&nbspName:&nbsp</td>
    <td class="menuLABEL" align="left" width="8%"> 
      <input type="text" name="userName" size="10">
    </td>
    <td class="menuLABEL" align="right" width="8%">Password:&nbsp</td>
    <td class="menuLABEL" align="left" width="8%"> 
      <input type=password name="password" value="" size=10>
    </td>
    <td class="menuLINK" width="3%">&nbsp;</td>
    <td class="menuLINK" align="right" width="15%" nowrap> <a href="javascript: document.forms[0].submit()" class="menuLINK">Login</a> 
      &nbsp;&nbsp; <img src="<%=session.getAttribute("siteHostRoot")%>/images/bullet.gif" width="20" height="21" border="0" align="absmiddle"> 
      &nbsp;&nbsp; <a href="/users/NewUserForm.jsp" target="main" class="menuLINK">New? 
      Register</a> </td>
    <td class="menuLINK" width="3%">&nbsp;</td>
  </tr>
</table>

<input type="hidden" name="$$Return" value="<script language='JavaScript'>parent.window.parent.window.location = parent.window.parent.window.location;</script>">
<script language="JavaScript">
	document.forms[0].userName.focus();
</script>