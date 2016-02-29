<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<%@ include file="/includes/SessionChecker.jsp" %>
<%@ page import="java.sql.*,com.marcomet.tools.*;" %>
<%@ taglib uri="/WEB-INF/tld/taglib.tld" prefix="taglib" %>

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
<body bgcolor="#FFFFFF" class=body onLoad="MM_preloadImages('/images/buttons/editover.gif')" background="<%=(String)session.getAttribute("siteHostRoot")%>/images/back.jpg" leftmargin="0" topmargin="10">

<p><span class="Title">Account Information for: <%= cB.getLoginName() %> </span> 
</p>

<table border="0" cellspacing="0" cellpadding="5" width="759" class="body">
  <tr> 
    <td colspan="6"><%= (request.getAttribute("returnMessage") == null)?"":(String)request.getAttribute("returnMessage") %></td>
  </tr>
  <tr> 
    <td height="21" rowspan="13" width="0"></td>
    <td colspan="2" class="minderheaderleft" height="21">Contact Info</td>
    <td class="minderheader" height="21" width="1">&nbsp;</td>
    <td colspan="2" height="21" class="minderheaderleft">Billing Address</td>
  </tr>
  <tr> 
    <td class="label" width="154">Name:</td>
    <td class=body width="220"><%= cB.getFirstName() %> <%= cB.getLastName() %></td>
    <td width="1">&nbsp;</td>
    <td class="label" width="104">Address:</td>
    <td class="body" width="220"><%= cB.getAddressBill1() %></td>
  </tr>
  <tr> 
    <td class="label" width="154">Title:</td>
    <td class="body" width="220"><%= cB.getJobTitle() %></td>
    <td width="1">&nbsp;</td>
    <td class="label" width="104">&nbsp;</td>
    <td class="body" width="220"><%= cB.getAddressBill2() %></td>
  </tr>
  <tr> 
    <td class="label" width="154">Email:</td>
    <td class="body" width="220"><%= cB.getEmail() %></td>
    <td width="1">&nbsp;</td>
    <td class="label" width="104">&nbsp;</td>
    <td class="body" width="220"><%= cB.getCityBill()%>,<taglib:LUTableValueTag table="lu_abreviated_states" selected="<%= cB.getStateBillId()%>"/><%= cB.getZipcodeBill() %></td>
  </tr>
  <tr> 
    <td class="label" width="154">Company:</td>
    <td class="body" width="220"><%= cB.getCompanyName() %></td>
    <td width="1">&nbsp;</td>
    <td class="label" width="104">Country:</td>
    <td class="body" width="220"><taglib:LUTableValueTag table="lu_countries" selected="<%= cB.getCountryBillId()%>"/></td>
  </tr>
  <tr> 
    <td class="label" width="154">Web Address:</td>
    <td class="body" width="220"><%= cB.getCompanyURL() %></td>
    <td width="1">&nbsp;</td>
    <td class="label" width="104">&nbsp;</td>
    <td class="body" width="220">&nbsp;</td>
  </tr>
  <tr> 
    <td class="label" width="154">Address:</td>
    <td class="body" width="220"><%= cB.getAddressMail1() %></td>
    <td width="1">&nbsp;</td>
    <td class="label" width="104">&nbsp;</td>
    <td class="body" width="220"></td>
  </tr>
  <tr> 
    <td class="label" width="154">&nbsp;</td>
    <td class="body" width="220"><%= cB.getAddressMail2() %></td>
    <td width="1">&nbsp;</td>
    <td class="label" width="104">&nbsp;</td>
    <td class="body" width="220"></td>
  </tr>
  <tr> 
    <td class="label" width="154">&nbsp;</td>
    <td class="body" width="220"><%= cB.getCityMail()%>,<taglib:LUTableValueTag table="lu_abreviated_states" selected="<%= cB.getStateMailId()%>"/><%= cB.getZipcodeMail() %></td>
    <td width="1">&nbsp;</td>
    <td class="label" width="104">&nbsp;</td>
    <td class="body" width="220"></td>
  </tr>
  <tr> 
    <td class="label" width="154">Country:</td>
    <td class="body" width="220"></td>
    <td width="1">&nbsp;</td>
    <td class="label" width="104">&nbsp;</td>
    <td class="body" width="220"></td>
  </tr>
  <%	if(!cB.getPrefix(0).equals("")){	%>
  <tr> 
    <td class="label" width="154"><taglib:LUTableValueTag table="lu_phone_types" selected="<%= cB.getPhoneTypeId(0)%>"/>:</td>
    <td class="body" width="220"><%= cB.getAreaCode(0) %>-<%= cB.getPrefix(0) %>-<%= cB.getLineNumber(0) %> 
      <%= (cB.getExtension(0).equals(""))?"":" Ext " + cB.getExtension(0)%></td>
    <td width="1">&nbsp;</td>
    <td class="label" width="104">&nbsp;</td>
    <td class="body" width="220">&nbsp;</td>
  </tr>
  <%	} 	%>
  <%	if(!cB.getPrefix(1).equals("")){	%>
  <tr> 
    <td class="label" width="154"><taglib:LUTableValueTag table="lu_phone_types" selected="<%= cB.getPhoneTypeId(1)%>"/>:</td>
    <td class="body" width="220"><%= cB.getAreaCode(1) %>-<%= cB.getPrefix(1) %>-<%= cB.getLineNumber(1) %> 
      <%= (cB.getExtension(1).equals(""))?"":" Ext " + cB.getExtension(1) %></td>
    <td width="1">&nbsp;</td>
    <td class="label" width="104">&nbsp;</td>
    <td class="body" width="220">&nbsp;</td>
  </tr>
  <%	} 	%>
  <%	if(!cB.getPrefix(2).equals("")){	%>
  <tr> 
    <td class="label" width="154"><taglib:LUTableValueTag table="lu_phone_types" selected="<%= cB.getPhoneTypeId(2)%>"/>:</td>
    <td class="body" width="220"><%= cB.getAreaCode(2) %>-<%= cB.getPrefix(2) %>-<%= cB.getLineNumber(2) %> 
      <%= (cB.getExtension(2).equals(""))?"":" Ext " + cB.getExtension(2) %></td>
    <td width="1">&nbsp;</td>
    <td class="label" width="104">&nbsp;</td>
    <td class="body" width="220">&nbsp;</td>
  </tr>
  <%	} 	%>
</table>
  <%if (session.getAttribute("demo")==null && (request.getParameter("editFlag")==null || request.getParameter("editFlag").equals("true")) ){%>
<table align="center">
  <tr> 
    <td>
      <div align="center"><a href="/users/AccountInformationForm.jsp"class="greybutton">Edit 
        Information</a></div>
    </td>
    <td>&nbsp;</td>
    <td>
      <div align="center"><a href="/users/ChangePasswordForm.jsp"class="greybutton">Change 
        Password</a></div>
    </td>
    </tr>
</table>
<%}else{%>
<%}%>
</body>
</html>
