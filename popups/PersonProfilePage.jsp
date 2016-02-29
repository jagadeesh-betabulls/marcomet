<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<%@ include file="/includes/SessionChecker.jsp" %>
<%@ page import="java.sql.*,com.marcomet.tools.*,com.marcomet.environment.SiteHostSettings;" %>
<%@ taglib uri="/WEB-INF/tld/taglib.tld" prefix="taglib" %>
<jsp:useBean id="connection" class="com.marcomet.jdbc.ConnectionBean" scope="session" />
<jsp:useBean id="cB" class="com.marcomet.beans.SBPContactBean" scope="page" />
<%
	SiteHostSettings shs = (SiteHostSettings)session.getAttribute("siteHostSettings");
	boolean showTaxID=((shs.getShowTaxID().equals("1"))?true:false);
	boolean validateSite=((shs.getRequireSiteValidation().equals("1"))?true:false);
	String siteFieldLabel1=((shs.getSiteFieldLabel1()==null)?"":shs.getSiteFieldLabel1());
	String siteFieldLabel2=((shs.getSiteFieldLabel2()==null)?"":shs.getSiteFieldLabel2());
	String siteFieldLabel3=((shs.getSiteFieldLabel3()==null)?"":shs.getSiteFieldLabel3());
	String sql;
	ResultSet rs1;
	cB.setSitehostId(shs.getSiteHostId());
	cB.setContactId(request.getParameter("personId"));
	
%><html>
<head>
<title>Person Profile</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link rel="stylesheet" href="<%=(String)session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css">
</head>
<script lanugage="JavaScript" src="/javascripts/mainlib.js"></script>
<body bgcolor="#FFFFFF" onLoad="MM_preloadImages('/images/buttons/editover.gif','/images/buttons/okover.gif')" background="<%=(String)session.getAttribute("siteHostRoot")%>/images/back.jpg">
<p class="Title">Contact Information</p>
<p>
</p>
<table border="0" cellspacing="0" cellpadding="5" class="body" width="85%">
  <tr> 
    <td height="21" width="2"></td>
    <td colspan="2" class="minderheaderleft" height="21">Contact Info
  </tr>
  <tr> 
    <td width="2"></td>
    <td class="minderheaderright" width="176">Name:</td>
    <td class=lineitems width="300"><span onClick='document.getElementById("cid").innerHTML="Contact ID:<%= cB.getContactId() %>; Company ID:<%= cB.getCompanyId() %>"'><%= cB.getFirstName() %> <%= cB.getLastName() %></span></td>
<%if (!siteFieldLabel1.equals("")){%>
    <td width="3">&nbsp;</td>
    <td class="minderheaderright" width="186"><%=siteFieldLabel1%>:</td>
    <td class="lineitems" width="245"><%= cB.getSiteField1() %></td>
<%}else{%>
    <td colspan=3>&nbsp;</td>
<%}%>
  </tr>
  <tr> 
    <td width="2"></td>
    <td class="minderheaderright" width="176">Title:</td>
    <td class="lineitems" width="300"><%= cB.getJobTitle() %></td>
<%if (!siteFieldLabel2.equals("")){%>
    <td width="3">&nbsp;</td>
    <td class="minderheaderright" width="186"><%=siteFieldLabel2%>:</td>
    <td class="lineitems" width="245"><%= cB.getSiteField2() %></td>
<%}else{%>
    <td colspan=3>&nbsp;</td>
<%}%>
  </tr>
  <tr> 
    <td width="2"></td>
    <td class="minderheaderright" width="176">Email:</td>
    <td class="lineitems" width="300"><%= cB.getEmail() %></td>
<%if (!siteFieldLabel3.equals("")){%>
    <td width="3">&nbsp;</td>
    <td class="minderheaderright" width="186"><%=siteFieldLabel3%>:</td>
    <td class="lineitems" width="245"><%= cB.getSiteField3() %></td>
<%}else{%>
    <td colspan=3>&nbsp;</td>
<%}%>
  </tr>
  <tr> 
    <td width="2"></td>
    <td class="minderheaderright" width="176">Company:</td>
    <td class="lineitems" width="300"><span onClick='document.getElementById("cid").innerHTML="Contact ID:<%= cB.getContactId() %>; Company ID:<%= cB.getCompanyId() %>"'><%= cB.getCompanyName() %></span></td>
    <td colspan=3>&nbsp;</td>
  </tr>
  
    <tr> 
    <td width="2"></td>
    <td class="minderheaderright" width="176">DBA:</td>
    <td class="lineitems" width="300"><%= cB.getDBA() %></td>
    <td colspan=3>&nbsp;</td>
  </tr>
  <%if(validateSite || session.getAttribute("proxyId")!=null ){
  	%>  <tr> 
    <td width="2"></td>
    <td class="minderheaderright" width="176">Franchise Site #:</td>
    <td class="lineitems" width="300"><%= cB.getSiteNumber() %></td>
    <td colspan=3>&nbsp;</td>
  </tr><%
  }
  if(showTaxID || session.getAttribute("proxyId")!=null ){
  	%>  <tr> 
    <td width="2"></td>
    <td class="minderheaderright" width="176">Tax ID #:</td>
    <td class="lineitems" width="300"><%= cB.getTaxID() %></td>
    <td colspan=3>&nbsp;</td>
  </tr><%
  }%>
  
  <tr> 
    <td width="2"></td>
    <td class="minderheaderright" width="176">Property Mngmt Site #:</td>
    <td class="lineitems" width="300"><%= cB.getPMSiteNumber() %></td>
    <td colspan=3>&nbsp;</td>
  </tr>
  <tr> 
    <td width="2"></td>
    <td class="minderheaderright" width="176">Web Address:</td>
    <td class="lineitems" width="300"><%= cB.getCompanyURL() %></td>
    <td colspan=3>&nbsp;</td>
  </tr>
  <tr> 
    <td width="2"></td>
    <td class="minderheaderleft" colspan=2>Default Shipping Address:</td>
    <td width="3">&nbsp;</td>
    <td class="minderheaderleft" colspan=2>Billing Address:</td>
  </tr>
  <tr> 
    <td width="2"></td>
    <td class="minderheaderright" width="176">Address:</td>
    <td class="lineitems" width="300"><%= cB.getAddressMail1() %></td>
    <td width="3">&nbsp;</td>
    <td class="minderheaderright" width="186">Address:</td>
    <td class="lineitems" width="245"><%= cB.getAddressBill1() %></td>
  </tr>
  <tr> 
    <td width="2"></td>
    <td class="minderheaderright" width="176">&nbsp;</td>
    <td class="lineitems" width="300"><%= cB.getAddressMail2() %></td>
    <td width="3">&nbsp;</td>
    <td class="minderheaderright" width="186">&nbsp;</td>
    <td class="lineitems" width="245"><%= cB.getAddressBill2() %></td>
  </tr>
  <tr> 
    <td width="2"></td>
    <td class="minderheaderright" width="176">&nbsp;</td>
    <td class="lineitems" width="300"><%= cB.getCityMail()%>,<taglib:LUTableValueTag table="lu_abreviated_states" selected="<%= cB.getStateMailId()%>"/><%= cB.getZipcodeMail() %></td>
    <td width="3">&nbsp;</td>
    <td class="minderheaderright" width="186">&nbsp;</td>
    <td class="lineitems" width="245"><%= cB.getCityBill()%>,<taglib:LUTableValueTag table="lu_abreviated_states" selected="<%= cB.getStateBillId()%>"/><%= cB.getZipcodeBill() %></td>
  </tr>
  <%	if(!cB.getPrefix(0).equals("")){	%>
  <tr> 
    <td width="2"></td>
    <td class="minderheaderright" width="176"><taglib:LUTableValueTag table="lu_phone_types" selected="<%= cB.getPhoneTypeId(0)%>"/>:</td>
    <td class="lineitems" width="300"><%= cB.getAreaCode(0) %>-<%= cB.getPrefix(0) %>-<%= cB.getLineNumber(0) %> 
      <%= (cB.getExtension(0).equals(""))?"":" Ext " + cB.getExtension(0)%></td>
    <td width="3">&nbsp;</td>
    <td class="minderheaderright" width="186">&nbsp;</td>
    <td class="lineitems" width="245">&nbsp;</td>
  </tr><%	} 	

if(!cB.getPrefix(1).equals("")){	
	%><tr> 
    <td width="2"></td>
    <td class="minderheaderright" width="176"><taglib:LUTableValueTag table="lu_phone_types" selected="<%= cB.getPhoneTypeId(1)%>"/>:</td>
    <td class="lineitems" width="300"><%= cB.getAreaCode(1) %>-<%= cB.getPrefix(1) %>-<%= cB.getLineNumber(1) %> 
      <%= (cB.getExtension(1).equals(""))?"":" Ext " + cB.getExtension(1) %></td>
    <td width="3">&nbsp;</td>
    <td class="minderheaderright" width="186">&nbsp;</td>
    <td class="lineitems" width="245">&nbsp;</td>
  </tr><%
	}
	if(!cB.getPrefix(2).equals("")){	%>
  <tr> 
    <td width="2"></td>
    <td class="minderheaderright" width="176"><taglib:LUTableValueTag table="lu_phone_types" selected="<%= cB.getPhoneTypeId(2)%>"/>:</td>
    <td class="lineitems" width="300"><%= cB.getAreaCode(2) %>-<%= cB.getPrefix(2) %>-<%= cB.getLineNumber(2) %> 
      <%= (cB.getExtension(2).equals(""))?"":" Ext " + cB.getExtension(2) %></td>
    <td width="3">&nbsp;</td>
    <td class="minderheaderright" width="186">&nbsp;</td>
    <td class="lineitems" width="245">&nbsp;</td>
  </tr>  <%	} 	
%></table>
<p>
<%if (request.getParameter("popup")==null || request.getParameter("popup").equals("true")){%><div align="center"><a href="javascript:close()" class="greybutton">Close</a></div><%}%>
<div class=lineitems id='cid'></div>
</body>
</html>
