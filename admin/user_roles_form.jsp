<%@ include file="/includes/SessionChecker.jsp" %>
<%@ page import="java.sql.*,com.marcomet.tools.*;" %>
<%@ taglib uri="/WEB-INF/tld/taglib.tld" prefix="taglib" %>


<jsp:useBean id="connection" class="com.marcomet.jdbc.ConnectionBean" scope="session" />
<jsp:useBean id="prB" class="com.marcomet.commonprocesses.ProcessRole" scope="page" />
<jsp:useBean id="validator" class="com.marcomet.tools.FieldValidationBean" scope="page" />
<%String siteHostId=session.getAttribute("siteHostId").toString();
String companyId=session.getAttribute("siteHostCompanyId").toString();
String contactId=request.getParameter("contactId");
%><html>
<head>
<%=((com.marcomet.users.security.RoleResolver)session.getAttribute("roles")).roleCheckRedirect("admin","/admin/no_rights.jsp")%>
<title><%
	String formAction ="";
	String returnString="[/admin/user_list.jsp?editFlag=true]";
	boolean contactError=false;	
if (request.getParameter("contactId")!=null){
	formAction = "/servlet/com.marcomet.users.admin.UpdateUserRoles";
	prB.selectContact(Integer.parseInt(contactId),Integer.parseInt(siteHostId));
	%>Edit User Roles<%
}else{
contactError=true;	
}

%></title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link rel="stylesheet" href="<%=(String)session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css">
<style type="text/css">
</style>
</head>
<jsp:getProperty name="validator" property="javaScripts" />
<script language="JavaScript" src="/javascripts/mainlib.js"></script>
<script language="JavaScript" >
	function resetPassword(){
		document.forms[0].action="/servlet/com.marcomet.users.admin.UpdatePassword";
		document.forms[0].$$Return.value="[/admin/password_reset.jsp]"
		document.forms[0].submit();
	}
</script>
<body bgcolor="#FFFFFF" background="<%=(String)session.getAttribute("siteHostRoot")%>/images/back.jpg" leftmargin="0" topmargin="1">
<form method="post" action="<%=formAction%>">
  <table align="center" width="80%">
    <tr> 
      <td colspan="4"> 
        <p><%= (request.getAttribute("errorMessage")==null)?"":request.getAttribute("errorMessage")%></p>
      </td>
    </tr>
    <tr> 
      <td colspan="4" class=tableheader align="left">Edit User Roles/Password</td>
    </tr>
    <td height="22" class="label" width="12%">User Name:</td>
    <td height="22" colspan="3" width="88%"><%=prB.getContactName()%></td>
    </tr>
    <tr> 
      <td class="label" width="12%">Company:</td>
      <td colspan="3" width="88%"><%=prB.getCompanyName()%></td>
    </tr>
    <tr> 
      <td class="label" width="12%">Login Name:</td>
      <td colspan="3" width="88%"><%=prB.getUserName()%></td>
    </tr>
    <tr> 
      <td width="12%" class="graybutton" nowrap><a href="javascript:resetPassword()">Reset Password</a></td>
      <td colspan="3" width="88%"> 
        <input type="text" name="userpw">
    </tr>
    <tr> 
      <td colspan="4" class=tableheader> 
        <div align="left">Roles:</div>
      </td>
    </tr>
    <tr> 
      <td class="label" colspan="4"><%=prB.getRoleCheckBoxes()%>
        </td>
    </tr>
    <tr> 
      <td class="label" width="12%">&nbsp;</td>
      <td colspan="3" width="88%">&nbsp;</td>
    </tr>
    <!-- </table>
<table align="center" width="80%" class=label>	 -->
    <!--</table>
<table align="center" width="80%" class=label>-->
  </table>
  <table width=600 align="center">
    <tr> 
      <td width="40%">&nbsp;</td>
      <td  width="75"><a href="javascript:submitForm()" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('Image2','','/images/buttons/submitover.gif',1)"><img name="Image2" border="0" src="/images/buttons/submit.gif" width="74" height="20"></a></td>
      <td width="6%">&nbsp;</td>
      <td width="75"><a href="javascript:history.go(-1)" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('cancel','','/images/buttons/cancelbtover.gif',1)" onMouseDown="MM_swapImage('cancel','','/images/buttons/cancelbtdown.gif',1)"><img name="cancel" border="0" src="/images/buttons/cancelbt.gif" width="74" height="20"></a></td>
      <td width="40%">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="siteHostId" value="<%=session.getAttribute("siteHostId")%>">
<input type="hidden" name="contactId" value="<%=contactId%>">
<input type="hidden" name="$$Return" value="<%=returnString%>">
<input type="hidden" name="errorPage" value="/admin/user_roles_form.jsp">

</form>
</body>
</html>
