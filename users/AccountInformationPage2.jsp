<%@ include file="/includes/SessionChecker.jsp" %>
<%@ page import="java.sql.*,com.marcomet.tools.*;" %>
<%@ taglib uri="/WEB-INF/tld/taglib.tld" prefix="taglib" %>

<jsp:useBean id="connection" class="com.marcomet.jdbc.ConnectionBean" scope="session" />
<jsp:useBean id="cB" class="com.marcomet.beans.SBPContactBean" scope="page" />
<%!
	String sql;
	ResultSet rs1;
%>
<%		
	String loginId = (session.getAttribute("contactId")==null)?"":(String)session.getAttribute("contactId"); 
	loginId = ((request.getParameter("userId")==null)?loginId:request.getParameter("userId"));
	cB.setContactId(loginId);
%>


<html>
<head>
<title>User Account Information</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link rel="stylesheet" href="<%=(String)session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css">
</head>
<script lanugage="JavaScript" src="/javascripts/mainlib.js"></script>
<body background="<%=(String)session.getAttribute("siteHostRoot")%>/images/back3.jpg" leftmargin="10">
<p class="Title">Account Information for username: </p>
<table border="0" cellspacing="0" cellpadding="3" width="759" class="body">
  <tr> 
    <td colspan="6"><%= (request.getAttribute("returnMessage") == null)?"":(String)request.getAttribute("returnMessage") %></td>
  </tr>
  <tr> 
    <td height="21" rowspan="13" width="0"></td>
    <td colspan="2" height="8" class="minderheaderleft">Contact 
      Info / Default Ship To Address</td>
    <td height="8" width="1" class="minderheader">&nbsp;</td>
    <td colspan="2" height="8" class="minderheaderleft">Billing Address</td>
  </tr>
  <tr>
    <td width="178" class="label" height="25">Name:</td>
    <td width="220" class=bodyBlack height="25"></td>
    <td width="1" height="25">&nbsp;</td>
    <td width="104" class="label" height="25">Address:</td>
    <td width="220" class="bodyBlack" height="25"></td>
  </tr>
  <tr> 
    <td width="178" class="label" height="25">Title:</td>
    <td width="220" class="bodyBlack" height="25"></td>
    <td width="1" height="25">&nbsp;</td>
    <td width="104" height="25">&nbsp;</td>
    <td width="220" class="bodyBlack" height="25"></td>
  </tr>
  <tr> 
    <td width="178" class="label" height="25">Email:</td>
    <td width="220" class="bodyBlack" height="25"></td>
    <td width="1" height="25">&nbsp;</td>
    <td width="104" height="25">&nbsp;</td>
    <td width="220" class="bodyBlack" height="25">,</td>
  </tr>
  <tr> 
    <td width="178" class="label" height="25">Company:</td>
    <td width="220" class="bodyBlack" height="25"></td>
    <td width="1" height="25">&nbsp;</td>
    <td width="104" class="label" height="25">Country:</td>
    <td width="220" class="bodyBlack" height="25"></td>
  </tr>
  <tr> 
    <td width="178" class="label" height="25">Web Address:</td>
    <td width="220" class="bodyBlack" height="25"></td>
    <td width="1" height="25">&nbsp;</td>
    <td width="104" height="25">&nbsp;</td>
    <td width="220" class="bodyBlack" height="25">&nbsp;</td>
  </tr>
  <tr> 
    <td width="178" class="label" height="25">Address:</td>
    <td width="220" class="bodyBlack" height="25"></td>
    <td width="1" height="25">&nbsp;</td>
    <td width="104" height="25">&nbsp;</td>
    <td width="220" class="bodyBlack" height="25"></td>
  </tr>
  <tr> 
    <td width="178" height="25">&nbsp;</td>
    <td width="220" class="bodyBlack" height="25"></td>
    <td width="1" height="25">&nbsp;</td>
    <td width="104" height="25">&nbsp;</td>
    <td width="220" class="bodyBlack" height="25"></td>
  </tr>
  <tr> 
    <td width="178" height="25">&nbsp;</td>
    <td width="220" class="bodyBlack" height="25">,</td>
    <td width="1" height="25">&nbsp;</td>
    <td width="104" height="25">&nbsp;</td>
    <td width="220" class="bodyBlack" height="25"></td>
  </tr>
  <tr> 
    <td width="178" class="label" height="25">Country:</td>
    <td width="220" class="bodyBlack" height="25"></td>
    <td width="1" height="25">&nbsp;</td>
    <td width="104" height="25">&nbsp;</td>
    <td width="220" class="bodyBlack" height="25"></td>
  </tr>
  
  <tr> 
    <td width="178" class="label" height="25">:</td>
    <td width="220" class="bodyBlack" height="25">-- 
      </td>
    <td width="1" height="25">&nbsp;</td>
    <td width="104" height="25">&nbsp;</td>
    <td width="220" class="bodyBlack" height="25">&nbsp;</td>
  </tr>


  <tr> 
    <td width="178" class="label" height="25">:</td>
    <td width="220" class="bodyBlack" height="25">--
     </td>
    <td width="1" height="25">&nbsp;</td>
    <td width="104" height="25">&nbsp;</td>
    <td width="220" class="bodyBlack" height="25">&nbsp;</td>
  </tr>

  <%	if(!cB.getPrefix(2).equals("")){	%>
  <tr> 
    <td width="178" class="label" height="25"><taglib:LUTableValueTag table="lu_phone_types" selected="<%= cB.getPhoneTypeId(2)%>"/>:</td>
    <td width="220" class="bodyBlack" height="25"><%= cB.getAreaCode(2) %>-<%= cB.getPrefix(2) %>-<%= cB.getLineNumber(2) %> 
      <%= (cB.getExtension(2).equals(""))?"":" Ext " + cB.getExtension(2) %></td>
    <td width="1" height="25">&nbsp;</td>
    <td width="104" height="25">&nbsp;</td>
    <td width="220" class="bodyBlack" height="25">&nbsp;</td>
  </tr>
  <%	} 	%>
</table>
<%if (request.getParameter("editFlag")==null || request.getParameter("editFlag").equals("true")){%>
<hr size=1>
<table alin="center" align="center">
  <tr> 
    <td><a href="/users/AccountInformationForm.jsp" class="greybutton">Edit 
      Information</a></td>
    <td width="1%">
      <div align="center"></div>
    </td>
    <td><a href="/users/ChangePasswordForm.jsp" class="greybutton">Change 
      Password</a></td>
      </tr>
</table>
<%}else{%>
<%}%>
( <%= (session.getAttribute("contactId")) %> )
</body>
</html>
