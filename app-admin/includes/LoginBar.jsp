<%@ page import="java.util.Vector, com.marcomet.catalog.*" %><%
  ShoppingCart cart = (ShoppingCart)session.getAttribute("shoppingCart");
  Vector projects = null;
  if (cart != null) {
    projects = cart.getProjects();
  } else {
    projects = new Vector();
  }
%>

<body background="<%=session.getAttribute("siteHostRoot")%>/images/we_topmast_back.jpg">
<jsp:include page="/includes/AutoLogin.jsp" flush="true" />
<table border="0" cellpadding="0" cellspacing="0" width="100%" style="border-top-style: solid; border-top-width:1" class="mastentry">
  <%
  if (projects.size() > 0) { %>
  
    <td width="13%">&nbsp;&nbsp;&nbsp;<a href="javascript:parent.window.location.replace('/frames/InnerFrameset.jsp?contents=/catalog/summary/OrderSummary.jsp')" class="menuLINK">Process&nbsp; 
      Jobs</a></td>
  <%
  } else { %>
  <td width="0%" class="mastentry">&nbsp;</td>
  <%
  } %>
    <td width="26%">&nbsp;</td>
    <td align="right" width="23%"> 
      <div align="right"><b><span class="label">User&nbsp;Name:</span><font size="2" face="Arial, Helvetica, sans-serif" color="#FFFFFF">&nbsp;</font></b></div>
  </td>
  <td align="left" width="3%" class="mastentry"> 
    <div align="right"><font size="2"><b><font face="Arial, Helvetica, sans-serif" color="#FFFFFF"> 
        <input type="text" name="userName" size="10">
      </font></b></font></div>
  </td>
    <td align="right" width="7%"> 
      <div align="right"><b><font size="2" face="Arial, Helvetica, sans-serif" color="#FFFFFF">&nbsp;</font><span class="label">Password:</span><font size="2" face="Arial, Helvetica, sans-serif" color="#FFFFFF">&nbsp;</font></b></div>
  </td>
    <td align="left" width="6%"> 
      <div align="right"> 
      <input type=password name="password" value="" size=10>
    </div>
  </td>
    <td width="2%"> 
      <div align="right">&nbsp;&nbsp;</div>
  </td>
    <td align="right" width="13%" nowrap> 
      <div align="right"><a href="javascript: document.forms[0].submit()" class="menuLINK">Login</a><a href="/users/NewUserForm.jsp" target="main" class="menuLINK">&nbsp;&nbsp;New?&nbsp;Register</a> 
      </div>
  </td>
  <td width="7%"></td>
  </tr>
</table>

<input type="hidden" name="$$Return" value="<script language='JavaScript'>parent.window.parent.window.location = parent.window.parent.window.location;</script>">
<script language="JavaScript">
	document.forms[0].userName.focus();
</script>