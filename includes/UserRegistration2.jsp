<%@ page import="com.marcomet.environment.SiteHostSettings;" %>
<%@ taglib uri="/WEB-INF/tld/taglib.tld" prefix="taglib" %>
<jsp:useBean id="cB" class="com.marcomet.beans.SBPContactBean" scope="page" />
<jsp:useBean id="validator" class="com.marcomet.tools.FieldValidationBean" scope="page" />
<jsp:setProperty name="cB" property="*"/> 

<%
	SiteHostSettings shs = (SiteHostSettings)session.getAttribute("siteHostSettings");
	boolean validateSite=((shs.getRequireSiteValidation().equals("1"))?true:false);
	boolean showTaxID=((shs.getShowTaxID().equals("1"))?true:false);
	boolean useSiteFields=((shs.getSiteFieldLabel1().equals("") && shs.getSiteFieldLabel2().equals("") && shs.getSiteFieldLabel3().equals("") )?false:true);
	String siteFieldLabel1=((shs.getSiteFieldLabel1()==null)?"":shs.getSiteFieldLabel1());
	String siteFieldLabel2=((shs.getSiteFieldLabel2()==null)?"":shs.getSiteFieldLabel2());
	String siteFieldLabel3=((shs.getSiteFieldLabel3()==null)?"":shs.getSiteFieldLabel3());
	
	if(validateSite){
		String[] flds = {"firstName","lastName","siteNumber","addressMail1","dba","cityMail","zipcodeMail","email","newUserName","newPassword"};
		validator.setReqTextFields(flds);
	}else{
		String[] flds = {"firstName","lastName","addressMail1","dba","cityMail","zipcodeMail","email","newUserName","newPassword"};
		validator.setReqTextFields(flds);	
	}	
	String[] checkBoxes = {"userAgreement"};
	validator.setReqCheckBoxes(checkBoxes);
	String[] passwords = {"newPassword","newPasswordCheck"};
	validator.setPasswordMatchesIP(passwords);	
	if(validateSite){
		validator.setExtraCode("if((zip.indexOf(document.forms[0].zipcodeMail.value)<0)){alert('There is a problem with the data entered, please call customer service at 888-777-9832 before submitting this form again.');return;}");
	}
%>
<SCRIPT LANGUAGE="Javascript">
function checkAndSubmitForm(){
	if(processing){ 
		document.getElementById('processing').innerHTML ='Registration Processing in progress, please wait.<br><img src=\'/images/loader.gif\'/> Processing. . .';
	}else{
		document.getElementById('processing').innerHTML = "<img src='/images/loader.gif'/> Processing. . ."; 
		processing=true;
		if (emailCheck(document.forms[0].email.value)){
			if(submitForm()){
				processing=true;
				document.getElementById('processing').innerHTML = "<img src='/images/loader.gif'/> Processing. . ."; 
			}else{
				processing=false;
				document.getElementById('processing').innerHTML = '';
			}
		}else{
			processing=false;
			document.getElementById('processing').innerHTML = '';
		}
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
			return false;
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
<table width="100%" class=label>
    <tr> 
      <td colspan="2" class="subtitle1">New User Information</td>
    </tr>
    <tr> 
      <td colspan="2">&nbsp;</td>
    </tr><%
      if (validateSite){
        %>
        <tr> 
      		<td  height="34" width='20%'>Franchise Site #:<font color="#FF0000"><b> *</b></font></td>
      		<td  height="34" width='80%'> 
        		<input name="siteNumber" id="aName" type="text" size="10" max="64" value="<%= cB.getSiteNumber() %>" ><span id='chkUsrRst'>**</span>
            </td>
    	</tr>
    	<tr><td colspan=4>** By processing this registration I warrant under penalty of law that I am authorized to purchase on behalf of the above referenced property.</td></tr>
    	<%
      }else{
        %><input name="siteNumber" id="aName" type="hidden" value="<%= ((cB.getSiteNumber()==null)?"":cB.getSiteNumber()) %>" ><%
      }

      if (showTaxID){
        %>
        <tr>
      		<td  width='20%'>Tax ID #:</td>
      		<td  width='80%'> 
        		<input name="taxId" id="taxId" type="text" size="30" value="<%= cB.getTaxID() %>" >
            </td>
    	</tr>
    	<%
      }else{
        %><input name="taxId" id="taxId" type="hidden" value="<%= ((cB.getTaxID()==null)?"":cB.getTaxID()) %>" ><%
      }
%><input name="billing_entity_id" id="billing_entity_id" type="hidden" value="<%= ((cB.getBillingEntityID()==0)?"-1":cB.getBillingEntityID()) %>" ><%

      if (useSiteFields){

	      if (!siteFieldLabel1.equals("")){
	        %>
	        <tr> 
	      		<td  height="34" width='20%'><%=siteFieldLabel1%></td>
	      		<td  height="34" width='80%'> 
	        		<input name="siteField1" id="siteField1" type="text" value="<%= ((cB.getSiteField1()==null)?"":cB.getSiteField1()) %>" >
	            </td>
	    	</tr>
	    	<%
	      }else{
	        %><input name="siteField1" type="hidden" value="<%= ((cB.getSiteField1()==null)?"":cB.getSiteField1()) %>" ><%
	      }
	      
	      if (!siteFieldLabel2.equals("")){
	        %>
	        <tr> 
	      		<td  height="34" width='20%'><%=siteFieldLabel2%></td>
	      		<td  height="34" width='80%'> 
	        		<input name="siteField2" id="siteField2" type="text" value="<%= ((cB.getSiteField2()==null)?"":cB.getSiteField2()) %>" >
	            </td>
	    	</tr>
	    	<%
	      }else{
	        %><input name="siteField2" type="hidden" value="<%=  ((cB.getSiteField2()==null)?"":cB.getSiteField2()) %>" ><%
	      }
	      	      
	      if (!siteFieldLabel3.equals("")){
	        %>
	        <tr> 
	      		<td  height="34" width='20%'><%=siteFieldLabel3%></td>
	      		<td  height="34" width='80%'> 
	        		<input name="siteField3" id="siteField3" type="text" value="<%= ((cB.getSiteField3()==null)?"":cB.getSiteField3()) %>" >
	            </td>
	    	</tr>
	    	<%
	      }else{
	        %><input name="siteField3" type="hidden" value="<%= ((cB.getSiteField3()==null)?"":cB.getSiteField3())  %>" ><%
	      }
	      
	      
	    }
	      %>
    <tr align="left"> 
      <td height="22" >Title</td>
      <td height="22" ><taglib:LUDropDownTag dropDownName="titleId" table="lu_titles" extra="onChange=\"formChangedArea('Contact')\"" selected="<%= cB.getTitleIdString()%>"/> 
      </td>
    </tr>
    <tr> 
      <td >First &amp; Last Name: <font color="#FF0000"><b>*</b></font></td>
      <td > 
        <input name="firstName" type="text" size="20" max="20" value="<%= cB.getFirstName() %>" >
        <input name="lastName" type="text" size="30" max="30" value="<%= cB.getLastName() %>" >
      </td>
    </tr>
    <tr> 
      
    <td  height="34">Company Name:<font color="#FF0000"><b> *</b></font></td>
      <td  height="34"> 
        <input name="companyName" type="text" size="32" max="64" value="<%= cB.getCompanyName() %>" >
      </td>
    </tr>
        <tr> 
      
    <td  height="34">DBA(Property Name, etc):<font color="#FF0000"><b> *</b></font></td>
      <td  height="34"> 
        <input name="dba" type="text" size="32" max="64" value="<%= cB.getDBA() %>" >
      </td>
    </tr>
    <tr>
	    <tr> 
	      <td  height="34">Property Management Site #:</td>
	      <td  height="34"> 
	        <input name="pmSiteNumber" type="text" size="10" max="64" value="<%= cB.getPMSiteNumber() %>" >
	      </td>
	    </tr>
	    <tr>
    <tr> 
      <td >Job Title:</td>
      <td > 
        <input type="text" name="jobTitle" size="20" max="20" value="<%= cB.getJobTitle() %>" >
      </td>
    </tr>
    <tr> 
      <td >E-mail:<font color="#FF0000"><b>*</b></font></td>
      <td > 
        <input type="text" name="email" id="aEmail" value="<%= cB.getEmail() %>"><span id='emailD'></span>
      </td>
    </tr>
        <tr>
    	<td colspan=2>NOTE: A valid email address must be entered here to complete this registration.</td>
    </tr>
    <tr> 
      
    <td >Web Address:</td>
      <td > 
        <input type="text" name="companyURL" value="<%= cB.getCompanyURL() %>" >
      </td>
    </tr>
    <tr> 
      
    <td colspan="2" height="23" class="subtitle1">Default Ship To Address:</td>
    </tr>
    <tr> 
      <td >Address: <b><font color="#FF0000">*</font></b></td>
      <td > 
        <input type="text" name="addressMail1" size=56 max=200 value="<%= cB.getAddressMail1() %>" >
        <br>
        <input type="text" name="addressMail2" size=56 max=200 value="<%= cB.getAddressMail2() %>" >
      </td>
    </tr>
    <tr> 
      <td >City, State &amp; Zip:<b><font color="#FF0000"> *</font></b></td>
      <td > 
        <input type="text" name="cityMail" value="<%= cB.getCityMail() %>" >
        ,&nbsp;<taglib:LUDropDownTag dropDownName="stateMailId" table="lu_abreviated_states" selected="<%=cB.getStateMailIdString()%>" /> 
        <input type="text" name="zipcodeMail" value="<%= cB.getZipcodeMail() %>" >
      </td>
    </tr>
    <tr> 
      <td >Country:</td>
      <td ><taglib:LUDropDownTag dropDownName="countryMailId" table="lu_countries" /></td>
    </tr>
    <%if (request.getParameter("noBill")==null || !request.getParameter("noBill").equals("true")){%>
    <tr> 
      <td  height="33" colspan="2"><span class="subtitle1">Billing Information:</span><b><font color="#FF0000">*</font></b> <br>
        <input type="checkbox" value="true" name="sameAsAbove" <%= (cB.getSameAsAbove())?"checked ":"" %> >
        Same as above</td>
    </tr>
    <tr> 
      <td >Address:</td>
      <td > 
        <input type="text" name="addressBill1" size=56 max=200 value="<%= cB.getAddressBill1() %>"  >
        <br>
        <input type="text" name="addressBill2" size=56 max=200 value="<%= cB.getAddressBill2() %>"  >
      </td>
    </tr>
    <tr> 
      <td >City, State &amp; Zip:</td>
      <td > 
        <input type="text" name="cityBill" value="<%= cB.getCityBill() %>" >
        , <taglib:LUDropDownTag dropDownName="stateBillId" table="lu_abreviated_states" selected="<%=cB.getStateBillIdString()%>" /> 
        <input type="text" name="zipcodeBill" value="<%= cB.getZipcodeBill() %>" >
      </td>
    </tr>
    <tr> 
      <td >Country:</td>
      <td ><taglib:LUDropDownTag dropDownName="countryBillId" table="lu_countries" /></td>
    </tr>
    <%}else{%>
    <input type="hidden" value="true" name="sameAsAbove" >
    <%}%>
    <tr> 
      <td >Phone: <b><font color="#FF0000">*</font></b>
        <input type="hidden" name="phoneCount" value="3">
      </td>
      <td > <taglib:LUDropDownTag dropDownName="phoneTypeId0" table="lu_phone_types" selected="1"/>	
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
      <td >Choose Login Name: <font color="#FF0000"><b>*</b></font></td>
      <td > 
        <input type="text" name="newUserName" id="aUserName" value="<%=cB.getNewUserName()%>"><span id='usernameD'>**</span>
      </td>
    </tr>
    <tr> 
      <td>Choose Password: <b><font color="#FF0000">*</font></b></td><td colspan=3><input type="password" name="newPassword" value="">&nbsp;&nbsp;&nbsp;&nbsp;Confirm Password: <b><font color="#FF0000">*</font></b>&nbsp;<input type="password" name="newPasswordCheck" value="">
      </td>
    </tr>
    <tr>
      <td colspan="2">&nbsp;</td>
      <td colspan="2" >&nbsp;</td>
    </tr>
    <tr> 
      <%if (request.getParameter("noBill")==null || !request.getParameter("noBill").equals("true")){%>
      
    <td colspan="2">I have read and agree to the <a href="javascript:pop('/legal/privacy_page_2.jsp','700','650')" class="minderACTION"> 
      Privacy Policy</a> 
      <input type="checkbox" name="userAgreement" value="true">
        &lt;= Please check before continuing.</td>
      <%}else{%>
      
    <td colspan="2" >I have read and agree to the <a href="javascript:pop('<%=(String)session.getAttribute("siteHostRoot")%>/contents/privacy_page_2.jsp','600','650')" class="minderACTION">Privacy 
      Policy </a> 
      <input type="checkbox" name="userAgreement" value="true">
        &lt;= Please check before continuing. </td>
      <%}%>
    </tr>
  </table>