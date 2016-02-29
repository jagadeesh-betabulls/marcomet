<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<%@ include file="/includes/SessionChecker.jsp" %>
<%@ page import="java.sql.*,com.marcomet.tools.*;" %>
<%@ taglib uri="/WEB-INF/tld/taglib.tld" prefix="taglib" %>

<jsp:useBean id="connection" class="com.marcomet.jdbc.ConnectionBean" scope="session" />
<jsp:useBean id="validator" class="com.marcomet.tools.FieldValidationBean" scope="page" />
<jsp:useBean id="cB" class="com.marcomet.beans.SBPContactBean" scope="page" />

<%	
String loginId = (session.getAttribute("contactId")==null)?"":(String)session.getAttribute("contactId"); 
String proxyId = (session.getAttribute("proxyId")==null)?"":(String)session.getAttribute("proxyId"); 
	cB.setContactId(loginId);
%>
<html>
<head>
  <title>Edit Password</title>
  <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
  <link rel="stylesheet" href="<%=(String)session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css">
<script>
	function confirmMatch(){
		if (document.forms[0].newPassword.value==document.forms[0].newPasswordConfirm.value){
			document.forms[0].submit();
		}else{
			alert("The new passwords entered do not match, please retype one or both.");
		}
	}
</script>
</head>
<jsp:getProperty name="validator" property="javaScripts" />
<script lanugage="JavaScript" src="/javascripts/mainlib.js"></script>
<body onLoad="MM_preloadImages('/images/buttons/submitover.gif')" background="<%=(String)session.getAttribute("siteHostRoot")%>/images/back3.jpg">
<form method="post" action="<%=((proxyId.equals(""))?"/servlet/com.marcomet.users.admin.EditPasswordServlet":"/users/ChangePasswordAction.jsp")%>"><%
if (request.getAttribute("returnMessage") == null) { %>
  <p>&nbsp;</p>
  <p>&nbsp;</p>
  <table align="center">
    <%
    if (request.getAttribute("errorMessage") != null) { %>
    <tr> 
      <td><%= request.getAttribute("errorMessage") %></td>
    </tr>
    <%
	} %>
    <tr> 
      <td colspan="4" height="2" class="minderheadercenter"><%=((proxyId.equals(""))?"":"CUSTOMER SERVICE PROXY: ")%>Change Password<%= (request.getParameter("errormessage")==null)?"":request.getParameter("errormessage")%></td>
    </tr>
    <tr> 
      <td class="label" height="30">Current User Name:</td>
      <td colspan="3" class="label" height="30"><b><font color="#FF0000"><%= cB.getLoginName() %></font></b> 
        <input type="hidden" name="userName" value="<%=cB.getLoginName()%>">
      </td>
    </tr>
<%	if (session.getAttribute("proxyId")==null || session.getAttribute("proxyId").equals("")){
    %><tr> 
      <td class="label">Old Password:</td>
      <td colspan="3" class="label"> 
        <input type="text" name="oldPassword">
      </td>
    </tr>
    <%
	}else{
		%><input type=hidden name='proxyId' value='<%=session.getAttribute("proxyId")%>'><%
	}
	%><tr> 
      <td class="label">New Password:</td>
      <td colspan="3" class="label"> 
        <input type="text" name="newPassword">
      </td>
    </tr>
    <tr> 
      <td class="label">Confirm New Password:</td>
      <td colspan="3" class="label"> 
        <input type="text" name="newPasswordConfirm">
      </td>
    </tr>
    <tr> 
      <td class="minderheader" colspan="4" height="12">&nbsp;</td>
    </tr>
  </table>
  <p></p><table width=600 align="center">
    <tr> 
      <td width="236"> 
        <div align="right">&nbsp;</div>
      </td>
      <td width="36"><a href="javascript:history.go(-1)" class="greybutton">Cancel</a></td>
      <td width="30">&nbsp;</td>
      <td width="42"><a href="javascript:confirmMatch()" class="greybutton">Submit</a></td>
      <td width="232">&nbsp;</td>
    </tr>
  </table>
  <input type="hidden" name="$$Return" value="[/users/AccountInformationPage.jsp]">
    <input type="hidden" name="contactId" value="<%=loginId%>">
  <input type="hidden" name="errorPage" value="/users/ChangePasswordForm.jsp"><%
  } else { %>
  <table height="100%" width="100%">
    <tr>
      <td align="center"><%= request.getAttribute("returnMessage") %></td>
    </tr>
	<tr>
	  <td align="center"><a href="<%=(String)session.getAttribute("siteHostRoot")%>/contents/SiteHostIndex.jsp" class="greybutton">Continue</a></td>
	</tr>
  </table><%
  } %>
</form>
</body>
</html>
