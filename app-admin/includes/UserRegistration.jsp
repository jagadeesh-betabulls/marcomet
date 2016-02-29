<%@ taglib uri="/WEB-INF/tld/taglib.tld" prefix="taglib" %>
<jsp:useBean id="cB" class="com.marcomet.beans.SBPContactBean" scope="page" />
<jsp:useBean id="validator" class="com.marcomet.tools.FieldValidationBean" scope="page" />
<jsp:setProperty name="cB" property="*"/> 

<%
	//load up required fields always present
	String[] flds = {"firstName","lastName","addressMail1","cityMail","zipcodeMail","email","newUserName","newPassword"};
	validator.setReqTextFields(flds);
	String[] checkBoxes = {"userAgreement"};
	validator.setReqCheckBoxes(checkBoxes);
	String[] passwords = {"newPassword","newPasswordCheck"};
	validator.setPasswordMatchesIP(passwords);	
%>
<SCRIPT LANGUAGE="Javascript">
function checkAndSubmitForm(){
	if (emailCheck(document.forms[0].email.value) ){
		submitForm();
	}
}
function emailCheck (emailStr) {
	var emailPat=/^(.+)@(.+)$/;
	var specialChars="\\(\\)<>@,;:\\\\\\\"\\.\\[\\]";
	var validChars="\[^\\s" + specialChars + "\]";
	var quotedUser="(\"[^\"]*\")";
	var ipDomainPat=/^\[(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})\]$/;
	var atom=validChars + '+';
	var word="(" + atom + "|" + quotedUser + ")";
	var userPat=new RegExp("^" + word + "(\\." + word + ")*$");
	var domainPat=new RegExp("^" + atom + "(\\." + atom +")*$");
	
	
	var matchArray=emailStr.match(emailPat);
	if (matchArray==null) {
		alert("Email address seems incorrect (check @ and .'s)");
		return false;
	}
	var user=matchArray[1];
	var domain=matchArray[2];
	
	// See if "user" is valid 
	if (user.match(userPat)==null) {
		// user is not valid
		alert("The username in the email address doesn't seem to be valid.");
		return false;
	}
	
	var IPArray=domain.match(ipDomainPat);
	if (IPArray!=null) {
		// this is an IP address
		  for (var i=1;i<=4;i++) {
			if (IPArray[i]>255) {
				alert("Destination IP address is invalid!");
			return true;
			}
		}
		return true;
	}

	// Domain is symbolic name
	var domainArray=domain.match(domainPat);
	if (domainArray==null) {
		alert("The domain name doesn't seem to be valid.");
		return false;
	}
	
	var atomPat=new RegExp(atom,"g");
	var domArr=domain.match(atomPat);
	var len=domArr.length;
	if (domArr[domArr.length-1].length<2 || 
		domArr[domArr.length-1].length>3) {
	   // the address must end in a two letter or three letter word.
	   alert("The address must end in a three-letter domain, or two letter country.");
	   return false;
	}
	
	// Make sure there's a host name preceding the domain.
	if (len<2) {
	   var errStr="This address is missing a hostname!";
	   alert(errStr);
	   return false;
	}
	return true;
	}
</script>
<jsp:getProperty name="validator" property="javaScripts" />
<table width="85%" class=label>
    <tr> 
      <td colspan="4" class="subtitle1">New User Information</td>
    </tr>
    <tr> 
      <td colspan="4">&nbsp;</td>
    </tr>
    <tr align="left"> 
      <td height="22" width="17%">Title</td>
      <td height="22" colspan="3"><taglib:LUDropDownTag dropDownName="titleId" table="lu_titles" extra="onChange=\"formChangedArea('Contact')\"" selected="<%= cB.getTitleIdString()%>"/> 
      </td>
    </tr>
    <tr> 
      <td width="17%">First &amp; Last Name: <font color="#FF0000"><b>*</b></font></td>
      <td colspan="3"> 
        <input name="firstName" type="text" size="20" max="20" value="<%= cB.getFirstName() %>" >
        <input name="lastName" type="text" size="30" max="30" value="<%= cB.getLastName() %>" >
      </td>
    </tr>
    <tr> 
      <td width="17%" height="34">Company Name:<font color="#FF0000"><b> *</b></font></td>
      <td colspan="3" height="34"> 
        <input name="companyName" type="text" size="32" max="64" value="<%= cB.getCompanyName() %>" >
      </td>
    </tr>
    <tr> 
      <td width="17%">Job Title:</td>
      <td colspan="3"> 
        <input type="text" name="jobTitle" size="20" max="20" value="<%= cB.getJobTitle() %>" >
      </td>
    </tr>
    <tr> 
      <td width="17%">E-mail: <font color="#FF0000"><b>*</b></font></td>
      <td colspan="3"> 
        <input type="text" name="email" value="<%= cB.getEmail() %>" onBlur="emailCheck(this.value)">
      </td>
    </tr>
    <tr> 
      <td width="17%">Company URL:</td>
      <td colspan="3"> 
        <input type="text" name="companyURL" value="<%= cB.getCompanyURL() %>" >
      </td>
    </tr>
    <tr> 
      <td colspan="4" height="23" class="subtitle1">Mailing Address:</td>
    </tr>
    <tr> 
      <td width="17%">Address: <b><font color="#FF0000">*</font></b></td>
      <td colspan="3"> 
        <input type="text" name="addressMail1" size=56 max=200 value="<%= cB.getAddressMail1() %>" >
        <br>
        <input type="text" name="addressMail2" size=56 max=200 value="<%= cB.getAddressMail2() %>" >
      </td>
    </tr>
    <tr> 
      <td width="17%">City, State &amp; Zip:<b><font color="#FF0000"> *</font></b></td>
      <td colspan="3"> 
        <input type="text" name="cityMail" value="<%= cB.getCityMail() %>" >
        ,&nbsp;<taglib:LUDropDownTag dropDownName="stateMailId" table="lu_abreviated_states" selected="<%=cB.getStateMailIdString()%>" /> 
        <input type="text" name="zipcodeMail" value="<%= cB.getZipcodeMail() %>" >
      </td>
    </tr>
    <tr> 
      <td width="17%">Country:</td>
      <td colspan="3"><taglib:LUDropDownTag dropDownName="countryMailId" table="lu_countries" /></td>
    </tr>
    <%if (request.getParameter("noBill")==null || !request.getParameter("noBill").equals("true")){%>
    <tr> 
      <td colspan="3" height="33"><span class="subtitle1">Billing Information:</span><b><font color="#FF0000">*</font></b> 
        <input type="checkbox" value="true" name="sameAsAbove" <%= (cB.getSameAsAbove())?"checked ":"" %>>
        Same as above</td>
      <td width="26%" height="33">&nbsp; </td>
    </tr>
    <tr> 
      <td width="17%">Address:</td>
      <td colspan="3"> 
        <input type="text" name="addressBill1" size=56 max=200 value="<%= cB.getAddressBill1() %>"  >
        <br>
        <input type="text" name="addressBill2" size=56 max=200 value="<%= cB.getAddressBill2() %>"  >
      </td>
    </tr>
    <tr> 
      <td width="17%">City, State &amp; Zip:</td>
      <td colspan="3"> 
        <input type="text" name="cityBill" value="<%= cB.getCityBill() %>" >
        , <taglib:LUDropDownTag dropDownName="stateBillId" table="lu_abreviated_states" selected="<%=cB.getStateBillIdString()%>" /> 
        <input type="text" name="zipcodeBill" value="<%= cB.getZipcodeBill() %>" >
      </td>
    </tr>
    <tr> 
      <td width="17%">Country:</td>
      <td colspan="3"><taglib:LUDropDownTag dropDownName="countryBillId" table="lu_countries" /></td>
    </tr>
    <%}else{%>
    <input type="hidden" value="true" name="sameAsAbove" >
    <%}%>
    <tr> 
      <td width="17%">Phone: 
        <input type="hidden" name="phoneCount" value="3">
      </td>
      <td colspan="3"> <taglib:LUDropDownTag dropDownName="phoneTypeId0" table="lu_phone_types" selected="1"/>	
        <input type="text" name="areaCode0" size="3" value="<%= cB.getAreaCode(0) %>" >
        <input type="text" name="prefix0" size="4" value="<%= cB.getPrefix(0) %>" >
        <input type="text" name="lineNumber0" size="5" value="<%= cB.getLineNumber(0) %>" >
        ex: 
        <input type="text" name="extension0" size="4" value="<%= cB.getExtension(0) %>" >
        <br>
        <taglib:LUDropDownTag dropDownName="phoneTypeId1" table="lu_phone_types" selected="2" />	
        <input type="text" name="areaCode1" size="3" value="<%= cB.getAreaCode(1) %>" >
        <input type="text" name="prefix1" size="4" value="<%= cB.getPrefix(1) %>" >
        <input type="text" name="lineNumber1" size="5" value="<%= cB.getLineNumber(1) %>" >
        ex: 
        <input type="text" name="extension1" size="4" value="<%= cB.getExtension(1) %>" >
        <br>
        <taglib:LUDropDownTag dropDownName="phoneTypeId2" table="lu_phone_types" selected="3"/> 
        <input type="text" size="3" name="areaCode2" value="<%= cB.getAreaCode(2) %>" >
        <input type="text" name="prefix2" size="4" value="<%= cB.getPrefix(2) %>" >
        <input type="text" name="lineNumber2" size="5" value="<%= cB.getLineNumber(2) %>" >
        ex: 
        <input type="text" name="extension2" size="4" value="<%= cB.getExtension(2) %>" >
        <br>
      </td>
    </tr>
    <tr> 
      <td colspan=4 height="20">New User Login</td>
    </tr>
    <tr> 
      <td width="17%">Choose Login Name: <font color="#FF0000"><b>*</b></font></td>
      <td colspan="3"> 
        <input type="text" name="newUserName" value="<%=cB.getNewUserName()%>">
      </td>
    </tr>
    <tr> 
      <td width="17%">Choose Password: <b><font color="#FF0000">*</font></b></td>
      <td width="16%"> 
        <input type="password" name="newPassword" value="">
      </td>
      <td width="17%">Confirm Password: <b><font color="#FF0000">*</font></b></td>
      <td width="26%"> 
        <input type="password" name="newPasswordCheck" value="">
      </td>
    </tr>
    <tr>
      <td colspan="4">&nbsp;</td>
      <td colspan="4" width="24%">&nbsp;</td>
    </tr>
    <tr> 
      <%if (request.getParameter("noBill")==null || !request.getParameter("noBill").equals("true")){%>
      
    <td colspan="4">I have read and agree to the <a href="javascript:pop('/legal/terms_page_1.jsp','600','650')" class="minderACTION"> 
      Site Use Agreement</a> 
      <input type="checkbox" name="userAgreement" value="true">
        &lt;= Please check before continuing.</td>
      <%}else{%>
      <td colspan="4" width="24%">I have read and agree to the <a href="javascript:pop('<%=(String)session.getAttribute("siteHostRoot")%>/contents/terms_page_1.jsp','600','650')" class="minderACTION">Site 
        Use Agreement</a> 
        <input type="checkbox" name="userAgreement" value="true">
        &lt;= Please check before continuing. </td>
      <%}%>
    </tr>
  </table>