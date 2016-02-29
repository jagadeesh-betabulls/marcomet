<%@ include file="/includes/SessionChecker.jsp" %>
<%@ page import="java.sql.*,com.marcomet.tools.*,java.util.*,com.marcomet.environment.SiteHostSettings;" %>
<%@ taglib uri="/WEB-INF/tld/taglib.tld" prefix="taglib" %>
<% SiteHostSettings shs = (SiteHostSettings)session.getAttribute("siteHostSettings"); %>

<jsp:useBean id="connection" class="com.marcomet.jdbc.ConnectionBean" scope="session" />
<jsp:useBean id="prB" class="com.marcomet.commonprocesses.ProcessRole" scope="page" />
<jsp:useBean id="validator" class="com.marcomet.tools.FieldValidationBean" scope="page" />
<%String siteHostId=shs.getSiteHostId();

String sql="";
String foundFlag="";
String contactName="";
String userName=((request.getParameter("userName")==null)?"":request.getParameter("userName"));
Connection conn = com.marcomet.jdbc.DBConnect.getConnection();
Statement st = conn.createStatement();
if (request.getParameter("submit")!=null){
	if (!userName.equals("")){
		sql="Select * from contacts c,logins l where user_name=\""+userName+"\" AND email=\""+request.getParameter("emailAddress")+"\" AND c.id=l.contact_id";
	}else{
		sql="Select * from contacts c where email=\""+request.getParameter("emailAddress")+"\"";
	}
	ResultSet rsContact=st.executeQuery(sql);
	if (rsContact.next()){
		contactName=rsContact.getString("firstname")+" "+rsContact.getString("lastname");
		foundFlag="true";
	}else{
		foundFlag="false";	
	}
}%><html>
<head>
<title>Password Reset Request</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link rel="stylesheet" href="<%=(String)shs.getSiteHostRoot()%>/styles/vendor_styles.css" type="text/css">
<link rel="stylesheet" href="file:///C|/Documents%20and%20Settings/Louis%20DeTitta/My%20Documents/Data/Marcomet%20Sites/WinGate/styles/vendor_styles.css" type="text/css">
</head>

<body bgcolor="#FFFFFF" background="<%=(String)shs.getSiteHostRoot()%>/images/back.jpg" leftmargin="30"  class='body' topmargin="30">
<form name='edit' method="post" action='/admin/user_password_reset.jsp?submit=true'>

  <p align="center"><font face="Arial, Helvetica, sans-serif" size="3" color="#000000"><b>Forgot 
    Your User Name and/or Password? </b></font> 
  <hr size=1 color=red align="center">
  <font face="Arial, Helvetica, sans-serif">
  <%if (foundFlag.equals("false")){

  	%>
  </font>
  <div align="center">
    <p align="center"><font face="Arial, Helvetica, sans-serif"><br>
      </font>
    <p align="center"><b><font face="Arial, Helvetica, sans-serif" size="3" color="#FF0000">***This 
      Email address was not found. Please check the spelling and try again.***</font></b></p>
  </div>
  <div align="center"><font face="Arial, Helvetica, sans-serif"> 
    <%}else if (foundFlag.equals("true")){%>
    </font></div>
  <p align="center"><font face="Arial, Helvetica, sans-serif">The information 
    you've entered is registered to <b><%=contactName%></b>. If this is not you, 
    please enter the correct information below and click continue. If this is 
    correct click continue to have your password reset. The new password and user 
    name will be emailed to the address used to register for the site.</font></p>
  <font face="Arial, Helvetica, sans-serif"> 
  <%}else{%>
  </font> 
  <p align="center">
  <div align="center"><b>For security purposes user passwords are encrypted and 
    therefore will need to be reset.<br>
    By submitting your email address below you will receive an email with your 
    newly reset password and your original user name.<br>
    </b>
    <!--<br>
    Enter your login name and the email address used when registering for our 
    site and click 'continue.</font></p>-->
  </div>
 <BR>
  <div align="center">Enter your email address used when you originally registered 
    and click 'continue.<br>
    <br></div>
  <!--<p align="center"><font face="Arial, Helvetica, sans-serif"> If you've forgotten 
    your login name as well as your password, enter your email address only.</font></p>
  <font face="Arial, Helvetica, sans-serif">--> 
  <%}%> 
  <div align="center"> 
    <table width="50%">
      <tr> 
        <!--<td width="24%"><font face="Arial, Helvetica, sans-serif" class="bodyBlack"><b>Login 
          Name:</b></font></td>
        <td width="76%"> <font face="Arial, Helvetica, sans-serif"> 
          <input type="text" name="userName" size="40" value="<%=((request.getParameter("userName")==null)?"":request.getParameter("userName"))%>">
          </font></td>-->
      </tr>
      <tr> 
        <td height="23" width="24%"><font face="Arial, Helvetica, sans-serif" class="bodyBlack"><b>Email 
          Address:</b></font></td>
        <td height="23" width="76%"> <font face="Arial, Helvetica, sans-serif"> 
          <input type="text" name="emailAddress" size="40" value="<%=((request.getParameter("emailAddress")==null)?"":request.getParameter("emailAddress"))%>">
          </font></td>
      </tr>
    </table>
    <font face="Arial, Helvetica, sans-serif"> 
    <%if (foundFlag.equals("true")){%>
    </font></div>
  <p align="center"> <font face="Arial, Helvetica, sans-serif"> 
    <input type=button value="This is me, reset my password" name="Button" onClick="document.forms[0].action='/servlet/com.marcomet.users.admin.ResetPasswordServlet';document.forms[0].submit()">
    <input type=submit value="This is NOT me, try again" name="Submit2">
    <input type=button value="Cancel" name="Submit3" onClick="window.location.replace('/index.jsp')">
    </font></p>
  <div align="center"> <font face="Arial, Helvetica, sans-serif"> 
    <input type="hidden" name="siteHostId" value="<%=shs.getSiteHostId().toString()%>">
    <input type="hidden" name="domainName" value="<%=shs.getDomainName().toString()%>">
    <input type="hidden" name="siteHostCompanyId" value="<%=shs.getSiteHostCompanyId().toString()%>">
    <input type="hidden" name="$$Return" value="[/admin/user_password_reset_confirm.jsp]">
    </font></div>
</form>
<div align="center"> <font face="Arial, Helvetica, sans-serif"> 
  <%}else{%>
  <input type=submit value="Continue" name="Submit2">
  <input type=button value="Cancel" name="Submit3" onClick="window.location.replace('/index.jsp')">
  <%}%>
  </font></div>
</body>
</html><%conn.close();%>
