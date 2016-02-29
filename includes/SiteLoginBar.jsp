<%String errorMsg=((request.getParameter("errorMessage")==null)?"":request.getParameter("errorMessage"));
%><jsp:include page="/includes/AutoLogin.jsp" flush="true" />
<table border="0" cellpadding="0" cellspacing="0" width="100%" valign="middle" class="header">
<td width="0%" height="28">&nbsp;</td>
<td width="26%" height="28">&nbsp;</td>
    <td align="right" width="23%" height="28"> 
      <div align="right"><b><font size="2" face="Arial, Helvetica, sans-serif" color="#FFFFFF"><span style="color:red"><%=errorMsg%></span>&nbsp;User&nbsp;Name:&nbsp;</font></b></div>
  </td>
    <td align="left" width="3%" height="28"> 
      <div align="right"><font size="2"><b><font face="Arial, Helvetica, sans-serif" color="#FFFFFF"> 
      <input type="text" name="userName" size="10">
      </font></b></font></div>
  </td>
    <td align="right" width="7%" height="28"> 
      <div align="right"><b><font size="2" face="Arial, Helvetica, sans-serif" color="#FFFFFF">&nbsp;Password:&nbsp;</font></b></div>
  </td>
    <td align="left" width="6%" height="28"> 
      <div align="right"> 
      <input type=password name="password" value="" size=10>
    </div>
  </td>
    <td width="2%" height="28"> 
      <div align="right">&nbsp;&nbsp;</div>
  </td>
    <td align="right" width="13%" nowrap height="28"> 
      <div align="left"><a href="javascript: document.forms[0].submit()" class="menuLINK">Login</a><%
%></div>
  </td>
    <td width="7%" height="28"></td>
  </tr>
</table>
<input type="hidden" name="$$Return" value="[<%=session.getAttribute("siteHostRoot")+"/contents/SiteHostIndex.jsp"%>]">
<script language="JavaScript">
	document.forms[0].userName.focus();
</script>