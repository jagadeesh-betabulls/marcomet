<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<%@ include file="/includes/SessionChecker.jsp" %>
<%@ page import="java.sql.*,com.marcomet.tools.*,com.marcomet.environment.SiteHostSettings;" %>
<%@ taglib uri="/WEB-INF/tld/taglib.tld" prefix="taglib" %>

<jsp:useBean id="connection" class="com.marcomet.jdbc.ConnectionBean" scope="session" />
<jsp:useBean id="validator" class="com.marcomet.tools.FieldValidationBean" scope="page" />
<jsp:useBean id="cB" class="com.marcomet.beans.SBPContactBean" scope="page" />
<%	
	SiteHostSettings shs = (SiteHostSettings)session.getAttribute("siteHostSettings");
	boolean showTaxID=((shs.getShowTaxID().equals("1"))?true:false);
	boolean validateSite=((shs.getRequireSiteValidation().equals("1"))?true:false);
	boolean useSiteFields=((shs.getSiteFieldLabel1().equals("") && shs.getSiteFieldLabel2().equals("") && shs.getSiteFieldLabel3().equals("") )?false:true);
	String siteFieldLabel1=((shs.getSiteFieldLabel1()==null)?"":shs.getSiteFieldLabel1());
	String siteFieldLabel2=((shs.getSiteFieldLabel2()==null)?"":shs.getSiteFieldLabel2());
	String siteFieldLabel3=((shs.getSiteFieldLabel3()==null)?"":shs.getSiteFieldLabel3());
	String loginId = (session.getAttribute("contactId")==null)?"":(String)session.getAttribute("contactId"); 
	cB.setSitehostId(shs.getSiteHostId());
	cB.setContactId(loginId);
%>
<html>
<head>
<title>Account Information</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link rel="stylesheet" href="<%=(String)session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css">
</head>
<jsp:getProperty name="validator" property="javaScripts" />
<script lanugage="JavaScript" src="/javascripts/mainlib.js"></script>
<body bgcolor="#FFFFFF" text="#000000" onLoad="MM_preloadImages('/images/buttons/submitover.gif')" background="<%=(String)session.getAttribute("siteHostRoot")%>/images/back3.jpg" leftmargin="10" topmargin="10">
<form method="post" action="/servlet/com.marcomet.users.admin.UpdateUserRegistration">
  <p class="Title">Edit Account Information Form</p>
  <table width="80%" cellpadding="3">
    <tr> 
      <td class="subtitle1" align="right">Contact Information<%= (request.getParameter("errormessage")==null)?"":request.getParameter("errormessage")%></td><td  colspan="3">&nbsp;</td>
    </tr>
    <tr>
    <td height="33" class="label" align="right" width="30%" valign="bottom">Title:</td>
    <td height="33" colspan="3" valign="bottom" width="70%"> <taglib:LUDropDownTag dropDownName="titleId" table="lu_titles" extra="onChange=\"formChangedArea('Contact')\"" selected="<%= cB.getTitleIdString()%>"/> 
    </td>
    </tr> 
    <tr> 
      <td class="label" align="right">First &amp; Last Name:</td>
      <td colspan="3"><%if (session.getAttribute("proxyId")!=null){
      		%><input name="firstName" type="text" size="20" max="20" value="<%= cB.getFirstName() %>" onChange="formChangedArea('Contact')">
        <input name="lastName" type="text" size="34" max="30" value="<%= cB.getLastName() %>" onChange="formChangedArea('Contact')"><%
        }else{
        	%>*<%= cB.getFirstName() %> <%= cB.getLastName() %><input name="firstName" type="hidden" value="<%= cB.getFirstName() %>"><input name="lastName" type="hidden" value="<%= cB.getLastName() %>">
        <%}%>
      </td>
    </tr>
          <%
      if (useSiteFields){
	      if (!siteFieldLabel1.equals("")){%>
	        <tr> 
	      		<td  height="34"  class="label" align="right" ><%=siteFieldLabel1%></td>
	      		<td  height="34"> 
	        		<input name="siteField1" id="siteField1" type="text" onChange="formChangedArea('SiteFields')" value="<%= cB.getSiteField1() %>" >
	            </td>
	    	</tr>
	    	<%
	      }else{%><input name="siteField1" type="hidden" value="<%= cB.getSiteField1() %>" ><%
	      
	      }
	      
	      if (!siteFieldLabel2.equals("")){%>
	        <tr> 
	      		<td  height="34"  class="label" align="right" ><%=siteFieldLabel2%></td>
	      		<td  height="34"> 
	        		<input name="siteField2" id="siteField2" type="text"  onChange="formChangedArea('SiteFields')"  value="<%= cB.getSiteField2() %>" >
	            </td>
	    	</tr>
	    	<%}else{
	        %><input name="siteField2" type="hidden" value="<%= cB.getSiteField2() %>" ><%
	      }
	      	      
	      if (!siteFieldLabel3.equals("")){%>
	        <tr> 
	      		<td  height="34"  class="label" align="right" ><%=siteFieldLabel3%></td>
	      		<td  height="34"> 
	        		<input name="siteField3" id="siteField3"  onChange="formChangedArea('SiteFields')"  type="text" value="<%= cB.getSiteField3() %>" >
	            </td>
	    	</tr>
	    	<%}else{
	        %><input name="siteField3" type="hidden" value="<%= cB.getSiteField3() %>" ><%
	      }
	      
	      
	    }
	      %>
    <tr> 
      <td class="label" align="right">Company Name:</td>
      <td colspan="3"><%if (session.getAttribute("proxyId")!=null){
     		%><input name="companyName" type="text" size="56" value="<%= cB.getCompanyName() %>" onChange="formChangedArea('Company')"><%
        }else{
        	%>*<%= cB.getCompanyName() %><input name="companyName" type="hidden" value="<%= cB.getCompanyName() %>" ><%
        }%></td>
    </tr>
    <tr> 
      <td class="label" align="right">DBA (Name of Hotel, etc):</td>
      <td colspan="3"> 
        <input name="dba" type="text" size="56" value="<%= cB.getDBA() %>" onChange="formChangedArea('Company')">
        <input type="hidden" name="companyPhone" value="<%=cB.getCompPhone()%>">
        <input type="hidden" name="companyFax" value="<%=cB.getCompFax()%>">
        <input type="hidden" name="creditLimit" value="<%=cB.getCreditLimit()%>">
        <input type="hidden" name="attention" value="<%=cB.getAttention()%>">
        <input type="hidden" name="billing_entity_id" value="<%=cB.getBillingEntityID()%>">

      </td>
    </tr><%
if((cB.getTaxID()!=null && !cB.getTaxID().equals("")) || session.getAttribute("proxyId")!=null || showTaxID){%>
    <tr> 
      <td class="label" align="right">Tax ID #:</td>
      <td colspan="3"><%
      if (session.getAttribute("proxyId")!=null || showTaxID){
     		%><input name="taxId" type="text" value="<%= cB.getTaxID() %>" onChange="formChangedArea('Company')"><%
      }else{
        	%><%= cB.getTaxID() %><input type='hidden' name='taxId' value='<%=cB.getTaxID()%>'><%
      }%></td>
    </tr>
<%
}

if(validateSite || session.getAttribute("proxyId")!=null){%>
  <tr> 
	<td class="label" align="right">Franchise Site #:</td>
	<td colspan="3"><%
	if (session.getAttribute("proxyId")!=null){
		%><input name="siteNumber" type="text" size="10" max="64" value="<%= cB.getSiteNumber() %>" onChange="formChangedArea('Contact')"><%
	}else{
        %>*<%= cB.getSiteNumber() %><input name="siteNumber" type="hidden" value="<%= cB.getSiteNumber() %>" ><%
 	}%>
	</td>
  </tr><%
}else{
	%><input name="siteNumber" type="hidden"><%
}
%>		<tr> 
		    <td class="label" align="right">Property Management Site #(if any):</td>
		      <td colspan="3"> 
		        <input name="pmSiteNumber" type="text" size="10" max="64" value="<%= cB.getPMSiteNumber() %>" onChange="formChangedArea('Contact')">
		      </td>
		    </tr>
		    <tr>
      <td class="label" align="right">Your Title:</td>
      <td colspan="3"> 
        <input type="text" name="jobTitle" size="56" max="20" value="<%= cB.getJobTitle() %>" onChange="formChangedArea('Contact')">
      </td>
    </tr>
    <tr> 
      <td class="label" align="right">E-mail:</td>
      <td colspan="3"> 
        <input type="text" name="email" value="<%= cB.getEmail() %>" size="56" onChange="formChangedArea('Contact')">
      </td>
    </tr>
    <tr> 
      <td class="label" align="right">Company URL:</td>
      <td colspan="3"> 
        <input type="text" name="companyURL" value="<%= cB.getCompanyURL() %>" size="56" onChange="formChangedArea('Company')">
      </td>
    </tr>
    <tr> 
      <td class="subtitle1" align="right"><br>Default Shipping Address:</td><td  colspan="3">&nbsp;</td>
    </tr>
    <tr> 
      <td class="label" align="right">Address:</td>
      <td colspan="3"> 
        <input type="text" name="addressMail1" size=56 max=200 value="<%= cB.getAddressMail1() %>"  onChange="formChangedArea('Locations')">
        <br>
        <input type="text" name="addressMail2" size=56 max=200 value="<%= cB.getAddressMail2() %>"  onChange="formChangedArea('Locations')">
      </td>
    </tr>
    <tr> 
      <td class="label" align="right">City,&nbsp;State&nbsp;&amp;&nbsp;Zip:</td>
      <td colspan="3"> 
        <input type="text" name="cityMail" value="<%= cB.getCityMail() %>"  onChange="formChangedArea('Locations')">
        , <taglib:LUDropDownTag dropDownName="stateMailId" table="lu_abreviated_states" extra="onChange=\"formChangedArea('Locations')\"" selected="<%= cB.getStateMailId()%>"/>	
        <input type="text" name="zipcodeMail" value="<%= cB.getZipcodeMail() %>" size="20"  onChange="formChangedArea('Locations')">
      </td>
    </tr>
    <tr> 
      <td class="label" align="right">Country:</td>
      <td colspan="3"> <taglib:LUDropDownTag dropDownName="countryMailId" table="lu_countries" extra="onChange=\"formChangedArea('Locations')\"" selected="<%= cB.getCountryMailId()%>"/> 
      </td>
    </tr>
    <tr> 
      <td colspan="4">&nbsp;</td>
    </tr>
    <tr> 
      <td class="subtitle1" align="right"><br>Billing Addresss:</td><td  colspan="3">&nbsp;</td>
    </tr>
    <tr>
      <td class="label" align="right"><input type="checkbox" value="true" name="sameAsAbove" onClick="formChangedArea('Locations')">Same&nbsp;as&nbsp;above</td><td  colspan="3">&nbsp;</td>
    </tr>
    <tr> 
      <td height="59" class="label" align="right">Address:</td>
      <td colspan="3"> 
        <input type="text" name="addressBill1" size=56 max=200 value="<%= cB.getAddressBill1() %>"   onChange="formChangedArea('Locations')">
        <br>
        <input type="text" name="addressBill2" size=56 max=200 value="<%= cB.getAddressBill2() %>"  onChange="formChangedArea('Locations')" >
      </td>
    </tr>
    <tr> 
      <td class="label" align="right">City, State &amp; Zip:</td>
      <td colspan="3"> 
        <input type="text" name="cityBill" value="<%= cB.getCityBill() %>"  onChange="formChangedArea('Locations')">
        , <taglib:LUDropDownTag dropDownName="stateBillId" table="lu_abreviated_states" extra="onChange=\"formChangedArea('Locations')\"" selected="<%= cB.getStateBillId()%>" /> 
        <input type="text" name="zipcodeBill" value="<%= cB.getZipcodeBill() %>" size="20"  onChange="formChangedArea('Locations')">
      </td>
    </tr>
    <tr> 
      <td class="label" align="right">Country:</td>
      <td colspan="3"> <taglib:LUDropDownTag dropDownName="countryBillId" table="lu_countries" extra="onChange=\"formChangedArea('Locations')\"" selected="<%= cB.getCountryBillId()%>"/> 
      </td>
    </tr>
    <tr> 
      <td colspan="4">&nbsp;</td>
    </tr>
    <tr> 
      <td class="label" align="right" height="70">Phone: 
        <input type="hidden" name="phoneCount" value="3">
      </td>
      <td colspan="3" height="70"> <taglib:LUDropDownTag dropDownName="phoneTypeId0" table="lu_phone_types" extra="onChange=\"formChangedArea('Phones')\"" selected="<%= cB.getPhoneTypeIdString(0)%>"/>	
        <input type="text" name="areaCode0" size="3" value="<%= cB.getAreaCode(0) %>" onChange="formChangedArea('Phones')">
        <input type="text" name="prefix0" size="4" value="<%= cB.getPrefix(0) %>" onChange="formChangedArea('Phones')">
        <input type="text" name="lineNumber0" size="5" value="<%= cB.getLineNumber(0) %>" onChange="formChangedArea('Phones')">
        ex: 
        <input type="text" name="extension0" size="4" value="<%= cB.getExtension(0) %>" onChange="formChangedArea('Phones')">
        <br>
        <taglib:LUDropDownTag dropDownName="phoneTypeId1" table="lu_phone_types" extra="onChange=\"formChangedArea('Phones')\"" selected="<%= cB.getPhoneTypeIdString(1)%>"/>	
        <input type="text" name="areaCode1" size="3" value="<%= cB.getAreaCode(1) %>" onChange="formChangedArea('Phones')">
        <input type="text" name="prefix1" size="4" value="<%= cB.getPrefix(1) %>" onChange="formChangedArea('Phones')">
        <input type="text" name="lineNumber1" size="5" value="<%= cB.getLineNumber(1) %>" onChange="formChangedArea('Phones')">
        ex: 
        <input type="text" name="extension1" size="4" value="<%= cB.getExtension(1) %>" onChange="formChangedArea('Phones')">
        <br>
        <taglib:LUDropDownTag dropDownName="phoneTypeId2" table="lu_phone_types" extra="onChange=\"formChangedArea('Phones')\"" selected="<%= cB.getPhoneTypeIdString(2)%>"/>	
        <input type="text" size="3" name="areaCode2" value="<%= cB.getAreaCode(2) %>" onChange="formChangedArea('Phones')">
        <input type="text" name="prefix2" size="4" value="<%= cB.getPrefix(2) %>" onChange="formChangedArea('Phones')">
        <input type="text" name="lineNumber2" size="5" value="<%= cB.getLineNumber(2) %>" onChange="formChangedArea('Phones')">
        ex: 
        <input type="text" name="extension2" size="4" value="<%= cB.getExtension(2) %>" onChange="formChangedArea('Phones')">
      </td>
    </tr>
  </table><%

if (session.getAttribute("proxyId")==null){
	%><br><br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;*Note: Starred values cannot be changed, please call customer service for assistance if a change is necessary.<%
}%><hr>
  <div align='center'>
	<table>
    <tr> 
      <td><a href="javascript:history.go(-1)" class="greybutton">Cancel</a></td>
      <td width="2%"></td>
      <td><a href="javascript:submitForm()" class="greybutton">Submit</a></td>
      </tr>
  </table></div>
  	<input type="hidden" name="companyId" value="<%=cB.getCompanyId()%>">
	<input type="hidden" name="siteHostId" value="<%=shs.getSiteHostId()%>">
  	<input type="hidden" name="useSiteFields" value="<%=useSiteFields%>">
	<input type="hidden" name="lastIP" value="<%=request.getRemoteAddr()+((request.getHeader("x-forwarded-for")==null || request.getHeader("x-forwarded-for").equals(""))?"":":"+request.getHeader("x-forwarded-for"))%>">
  	<input type="hidden" name="defaultWebsite" value="<%=cB.getDefaultWebsite()%>">
  	<input type="hidden" name="formChangedPhones" value="<%= (request.getParameter("formChangedPhones") == null )?"0":request.getParameter("formChangedPhones") %>">
	<input type="hidden" name="formChangedLocations" value="<%= (request.getParameter("formChangedLocations") == null )?"0":request.getParameter("formChangedLocations") %>">
	<input type="hidden" name="formChangedContact" value="<%= (request.getParameter("formChangedContact") == null )?"0":request.getParameter("formChangedContact") %>">
	<input type="hidden" name="formChangedCompany" value="<%= (request.getParameter("formChangedCompany") == null )?"0":request.getParameter("formChangedCompany") %>">
	<input type="hidden" name="formChangedSiteFields" value="<%= (request.getParameter("formChangedSiteFields") == null )?"0":request.getParameter("formChangedSiteFields") %>">
  	<input type="hidden" name="$$Return" value="[/users/AccountInformationPage.jsp]">
  	<input type="hidden" name="errorPage" value="/users/AccountInformationForm.jsp">
</form><!-- <%=( (session.getAttribute("errMsg1")==null) ? "" : session.getAttribute("errMsg1").toString() )%>|<%=( (session.getAttribute("errMsg2")==null) ? "" : session.getAttribute("errMsg2").toString() )%>-->
</body>
</html>
