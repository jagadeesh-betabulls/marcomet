<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<%@ page import="java.sql.*,java.util.*,com.marcomet.jdbc.*,com.marcomet.workflow.*" %>
<%@ taglib uri="/WEB-INF/tld/taglib.tld" prefix="taglib" %>

<jsp:useBean id="validator" class="com.marcomet.tools.FieldValidationBean" scope="page" />
<jsp:useBean id="cB" class="com.marcomet.beans.SBPContactBean" scope="page" />

<jsp:setProperty name="cB" property="*"/>  

<%
	//load up required fields always present
	String[] flds = {"firstName","lastName","addressMail1","cityMail","zipcodeMail","email"};
    String[] ipflds = {"usernamenew","passwordnew"};
	validator.setReqTextFields(flds); 
	validator.setReqTextFieldsIP(ipflds);
%>
<%-- How to return info to this page when errored out --%>
<% 
	if(request.getParameter("firstName")==null){
		String loginId = (session.getAttribute("Login")==null)?"":(String)session.getAttribute("Login"); 
		cB.setContactId(loginId);
	}
%>

<html>
<head>
<title>Check out</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link rel="stylesheet" href="<%=(String)session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css">
</head>
<script>
function cancelCat(){
	parent.window.location.replace("/index.jsp");
}
</script>
<script language="JavaScript">
	function submitLogin(){
		document.forms[0].action ="/jspscripts/CatalogLoginScript.jsp?returnpage=" + window.location.href;
		document.forms[0].submit();
	}	
</script>
<jsp:getProperty name="validator" property="javaScripts" />
<script language="JavaScript" src="/javascripts/mainlib.js"></script>
<body bgcolor="#FFFFFF" text="#000000" onLoad="MM_preloadImages('/contents/images/buttons/cancelbtover.gif')">
<form method="post" action="/servlet/com.marcomet.sbpprocesses.ProcessJobSubmit">
<% if(session.getAttribute("Login") == null || ((String)session.getAttribute("Login")).equals("")){ %>
<script language="JavaScript">
	alert("You must be a logged in, registered user to create a Custom Order\n\nThank you.");
	window.parent.window.location.replace("/index.jsp");
</script>
<%	} 	%>
<hr size=1 color=red>
<!-- RFQ section start-->
<table align="center" width="80%" class=label>	
	<tr>		
    	<td>Service Types:</td>		
      	<td>
        	<taglib:LUDropDownTag dropDownName="serviceTypeId" table="lu_service_types" />
      	</td>
	  	<td>Job Type:</td>
	  	<td>
			<taglib:LUDropDownTag dropDownName="jobTypeId" table="lu_job_types" />
	  	</td>
	</tr>
	<tr>
		<td colspan="4">Requirements:
		</td>
	</tr>
	<tr>
		<td colspan="4"><textarea name="notes" rows="5" cols="75"><%= (request.getParameter("notes")==null)?"":request.getParameter("notes")%></textarea></td>
	</tr>
</table>
<!-- RFQ section end -->
<hr size=1 color=red>
<table align="center" width="80%" class=label>
	<tr>
		<td colspan="4"><font color="red"><%= (request.getParameter("errormessage")==null)?"":request.getParameter("errormessage")%></font></td>
	</tr>
	<tr>
		<td colspan="4"><u>User Information</u></td>	
	<tr>
	</tr>	
      <td height="22">Title:</td>
    	<td height="22" colspan="3"> 
			<taglib:LUDropDownTag dropDownName="titleId" table="lu_titles" extra="onChange=\"formChangedArea('Contact')\"" selected="<%= cB.getTitleIdString()%>"/>		
		</td>
	</tr>
	<tr>
		<td>First &amp; Last Name:</td>
		
      <td colspan="3"> 
        <input name="firstName" type="text" size="20" max="20" value="<%= cB.getFirstName() %>" onChange="formChangedArea('Contact')">
        <input name="lastName" type="text" size="30" max="30" value="<%= cB.getLastName() %>" onChange="formChangedArea('Contact')">
		</td>
	</tr>
	<tr>
		<td>Company Name:</td>
		<td colspan="3"><input name="companyName" type="text" size="32" max="64" value="<%= cB.getCompanyName() %>" onChange="formChangedArea('Company')"></td>
	</tr>
	<tr>
		<td>Job Title:</td>
		<td colspan="3"><input type="text" name="jobTitle" size="20" max="20" value="<%= cB.getJobTitle() %>" onChange="formChangedArea('Contact')"></td>
	</tr>
	<tr>
		<td>E-mail:</td>
		<td colspan="3"><input type="text" name="email" value="<%= cB.getEmail() %>" onChange="formChangedArea('Contact')"></td>
	</tr>
	<tr>
		<td>Company URL:</td>
		<td colspan="3"><input type="text" name="companyURL" value="<%= cB.getCompanyURL() %>" onChange="formChangedArea('Company')"></td>
	</tr>	
</table>
<table align="center" width="80%" class=label>	
	<tr>
		<td colspan="4"><u>Mailing Address:</u>
			<input type="hidden" name="locationMailId" value="<%= cB.getLocationMailIdString()%>">
	  		<input type="hidden" name="locationMailTypeId" value="<%= cB.getLocationMailTypeIdString()%>">
		</td>
	</tr>	
	<tr>
		<td>Address:</td>
		<td colspan="3">
			<input type="text" name="addressMail1" size=56 max=200 value="<%= cB.getAddressMail1() %>" onChange="formChangedArea('MailLocation')"><br>
        	<input type="text" name="addressMail2" size=56 max=200 value="<%= cB.getAddressMail2() %>" onChange="formChangedArea('MailLocation')">
   		</td>
	</tr>
	<tr>
    	<td>City, State &amp; Zip:</td>
      	<td colspan="3">

        <input type="text" name="cityMail" value="<%= cB.getCityMail() %>" onChange="formChangedArea('MailLocation')">
        , 
			<taglib:LUDropDownTag extra="onChange=\"formChangedArea('MailLocation')\"" dropDownName="stateMailId" table="lu_abreviated_states" selected="<%= cB.getStateMailId()%>" /> 
        <input type="text" name="zipcodeMail" value="<%= cB.getZipcodeMail() %>" onChange="formChangedArea('MailLocation')">
		</td>
	</tr>
</table>
<table align="center" width="80%" class=label>	
	<tr>
		<td>Phone:<input type="hidden" name="phoneCount" value="3">
		</td>
		<td colspan="3">
			<taglib:LUDropDownTag dropDownName="phoneTypeId0" table="lu_phone_types" extra="onChange=\"formChangedArea('Phones')\"" selected="<%= cB.getPhoneTypeIdString(0)%>"/>		
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
          <br>
        </td>
	</tr>
</table>	


	
<hr size=1 color=red>
<br>
<table border="0" width="20%" align="center">
  <tr>
    <%
    Connection conn = DBConnect.getConnection();
    Statement st = conn.createStatement();
	ResultSet rsJobActions = st.executeQuery("select a.id 'id', a.actionperform 'actionperform' from jobflowactions a where a.currentstatus = 999"); 
	while(rsJobActions.next()) { %>
       <td class="graybutton" valign="middle"> 
         <div align="center"><a href="javascript:moveWorkFlow('<%=rsJobActions.getString("id")%>')" ><%= rsJobActions.getString("actionperform") %></a></div>
       </td>
    <% } %>
  </tr>
</table>

<input type="hidden" name="jobId" value="0" >
<input type="hidden" name="nextStepActionId" value="">
<input type="hidden" name="formchanged" value="<%= (request.getParameter("needsUpdate") == null || request.getParameter("needsUpdate").equals("null") )?"0":request.getParameter("needsUpdate") %>" >
<input type="hidden" name="companyId" value="<%=cB.getCompanyIdString()%>">
<input type="hidden" name="$$Return" value="[/catalog/rfq/ThankYouForRFQ.jsp]">
<input type="hidden" name="formChangedPhones" value="<%= (request.getParameter("formChangedPhones") == null )?"0":request.getParameter("formChangedPhones") %>">
<input type="hidden" name="formChangedMailLocation" value="<%= (request.getParameter("formChangedMailLocation") == null )?"0":request.getParameter("formChangedMailLocation") %>">
<input type="hidden" name="formChangedContact" value="<%= (request.getParameter("formChangedCompany") == null )?"0":request.getParameter("formChangedContact") %>">
<input type="hidden" name="formChangedCompany" value="<%= (request.getParameter("formChangedCompany") == null )?"0":request.getParameter("formChangedCompany") %>">

</form>
</body>
</html>

<%
	st.close();
	conn.close();
%>
