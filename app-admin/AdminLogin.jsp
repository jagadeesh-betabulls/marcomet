<html>
<head>
<title>Marcomet Site Administration Login</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
</head>

<body leftmargin="0" topmargin="0" marginwidth="0" marginheight="0" bgcolor="#336699">
<form method="post" action="/servlet/com.marcomet.admin.security.AdminLoginServlet">
<table width="100%" height="100%" cellpadding="0" cellspacing="0" border="0">
  <tr>
    <td align="center" valign="center">
      <table cellpadding="0" cellspacing="0" border="1" width="275" bordercolor="#003366">
        <tr>
          <td valign="top" height="50" bgcolor="#003366">
            <table width="100%" cellpadding="0" cellspacing="0" border="0" valign="top" height="50">
              <tr>
                <td align="center"><img src="/app-admin/images/marcometlogo.gif" width="99" height="28" align="center"></td>
              </tr>
            </table>
          </td> 
        </tr>
        <tr>
          <td valign="top">
            <table width="100%" cellpadding="0" cellspacing="0" border="0" valign="top">
              <tr><td bgcolor="#FFFFFF" colspan="2" align="center"><% if (request.getAttribute("errorMessage") != null) { %> <p/><font color="FF0000"><%=request.getAttribute("errorMessage")%></font> <% } else { %>&nbsp;<% } %></td></tr>
              <tr>
                <td bgcolor="#FFFFFF">&nbsp;&nbsp;<b>Username:</b></td>
                <td bgcolor="#FFFFFF"><input type="text" name="userName"></td>
              </tr>
              <tr>
                <td bgcolor="#FFFFFF">&nbsp;&nbsp;<b>Password:</b></td>
                <td bgcolor="#FFFFFF"><input type="password" name="password"></td>
              </tr>
              <tr>
                <td bgcolor="#FFFFFF">&nbsp;&nbsp;<b>Site:</b></td>
                <td bgcolor="#FFFFFF"><input type="text" name="site"></td>
              </tr>
              <tr><td bgcolor="#FFFFFF">&nbsp;</td><td bgcolor="#FFFFFF">&nbsp;</td></tr>
              <tr><td bgcolor="#FFFFFF" colspan="2" align="center"><input type="image" border="0" src="/app-admin/images/login.gif"></td></tr>
              <tr><td bgcolor="#FFFFFF">&nbsp;</td><td bgcolor="#FFFFFF">&nbsp;</td></tr>
            </table>
          </td>
        </tr>
      </table>
    </td>
  </tr>
</table>
<input type="hidden" name="$$Return" value="[/app-admin/index.jsp]">
</form>
</body>
</html>