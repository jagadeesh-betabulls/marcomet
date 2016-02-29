<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<%@ page import="java.sql.*,com.marcomet.users.security.*;" %>
<%@ taglib uri="/WEB-INF/tld/taglib.tld" prefix="taglib" %>
<%@ include file="/includes/SessionChecker.jsp" %>
<jsp:useBean id="formater" class="com.marcomet.tools.FormaterTool" scope="page" />
<jsp:useBean id="validator" class="com.marcomet.tools.FieldValidationBean" scope="page" />
<jsp:useBean id="cB" class="com.marcomet.beans.SBPContactBean" scope="page" />
<jsp:setProperty name="cB" property="*"/>  
<%
Connection conn = com.marcomet.jdbc.DBConnect.getConnection();
Statement st = conn.createStatement();
	//load up required fields always present
	String[] flds = {"firstName","lastName","addressBill1","cityBill","zipcodeBill","email"};
	validator.setReqTextFields(flds); 
 
	if(request.getParameter("firstName")==null){
		String loginId = (session.getAttribute("contactId")==null)?"":(String)session.getAttribute("contactId"); 
		cB.setContactId(loginId);
	}
%><html>
<head>
  <title>Final Collection</title>
  <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
  <link rel="stylesheet" href="<%=(String)session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css">
</head>
<jsp:getProperty name="validator" property="javaScripts" />
<script language="JavaScript" src="/javascripts/mainlib.js"></script>

<body class="body" onLoad="MM_preloadImages('/images/buttons/continueover.gif','/images/buttons/cancelbtover.gif')">
<form method="post" action="/servlet/com.marcomet.sbpprocesses.ProcessJobSubmit">

  <p class="Title">Final Payment </p>
  <table align="left" width="80%" class=label>
    <tr> 
      <td colspan="4"><font color="red"><%= (request.getAttribute("errorMessage")==null)?"":request.getAttribute("errorMessage")%></font></td>
    </tr>
    <tr> 
      <td colspan="4"><u>User Information</u></td>
    <tr> </tr>
      <td height="22" width="31%">Title:</td>
      <td height="22" colspan="3" class="body" width="69%"> <taglib:LUDropDownTag dropDownName="titleId" table="lu_titles" extra="onChange=\"formChangedArea('Contact')\"" selected="<%= cB.getTitleIdString()%>"/> 
      </td>
    </tr>
    <tr> 
      <td width="31%">First &amp; Last Name:</td>
      <td colspan="3" class="body" width="69%"> 
        <input name="firstName" type="text" size="20" max="20" value="<%= cB.getFirstName() %>" onChange="formChangedArea('Contact')">
        <input name="lastName" type="text" size="30" max="30" value="<%= cB.getLastName() %>" onChange="formChangedArea('Contact')">
      </td>
    </tr>
    <tr> 
      <td width="31%">Company Name:</td>
      <td colspan="3" class="body" width="69%"> 
        <input name="companyName" type="text" size="32" max="64" value="<%= cB.getCompanyName() %>" onChange="formChangedArea('Company')">
      </td>
    </tr>
    <tr> 
      <td width="31%">Job Title:</td>
      <td colspan="3" class="body" width="69%"> 
        <input type="text" name="jobTitle" size="20" max="20" value="<%= cB.getJobTitle() %>" onChange="formChangedArea('Contact')">
      </td>
    </tr>
    <tr> 
      <td width="31%">E-mail:</td>
      <td colspan="3" class="body" width="69%"> 
        <input type="text" name="email" value="<%= cB.getEmail() %>" onChange="formChangedArea('Contact')">
      </td>
    </tr>
    <tr> 
      <td width="31%">Company URL:</td>
      <td colspan="3" class="body" width="69%"> 
        <input type="text" name="companyURL" value="<%= cB.getCompanyURL() %>" onChange="formChangedArea('Company')">
      </td>
    </tr>
  </table>
  <p>&nbsp;</p>
  <p>&nbsp;</p>
  <p>&nbsp;</p>
  <p>&nbsp;</p>
  <p>&nbsp;</p>
  <p>&nbsp;</p>
  <p>&nbsp;</p>
  <table align="left" width="80%" class=label>
    <tr> 
      <td colspan="4" height="16"><u>Billing Information:</u></td>
    </tr>
    <tr> 
      <td width="31%">Address: 
        <input type="hidden" name="locationBillId" value="<%= cB.getLocationBillIdString()%>">
        <input type="hidden" name="locationBillTypeId" value="<%= cB.getLocationBillTypeIdString()%>">
      </td>
      <td colspan="3" class="body" width="69%"> 
        <input type="text" name="addressBill1" size=56 max=200 value="<%= cB.getAddressBill1() %>" onChange="formChangedArea('Locations')" >
        <input type="text" name="addressBill2" size=56 max=200 value="<%= cB.getAddressBill2() %>" onChange="formChangedArea('Locations')" >
      </td>
    </tr>
    <tr> 
      <td width="31%">City, State &amp; Zip:</td>
      <td colspan="3" class="body" width="69%"> 
        <input type="text" name="cityBill" value="<%= cB.getCityBill() %>" onChange="formChangedArea('Locations')">
        , <taglib:LUDropDownTag dropDownName="stateBillId" table="lu_abreviated_states" extra="onChange=\"formChangedArea('Locations')\"" selected="<%= cB.getStateBillId()%>" /> 
        <input type="text" name="zipcodeBill" value="<%= cB.getZipcodeBill() %>" onChange="formChangedArea('Locations')">
      </td>
    </tr>
    <tr> 
      <td width="31%">Country:</td>
      <td colspan="3" class="body" width="69%"> <taglib:LUDropDownTag dropDownName="countryBillId" table="lu_countries"  extra="onChange=\"formChangedArea('Locations')\""  selected="<%= cB.getCountryBillId()%>"/> 
      </td>
    </tr>
    <tr> 
      <td colspan="4">&nbsp;</td>
    </tr>
    <tr> 
      <td colspan="4"><u>Credit Card Information:</u></td>
    </tr>
    <tr> 
      <td width="31%">Credit Card Type:</td>
      <td colspan="3" class="body" width="69%"> <taglib:LUDropDownTag dropDownName="ccType" table="lu_credit_cards" selected="<%= (request.getParameter("ccType")==null)? "":request.getParameter("ccType")%>"/> 
      </td>
    </tr>
    <tr> 
      <td width="31%">Credit Card Number:</td>
      <td colspan="3" class="body" width="69%"> 
        <input type="text" name="ccNumber" value="<%= (request.getParameter("ccNumber")==null)?"":request.getParameter("ccNumber")%>" size="19">
      </td>
    </tr>
    <tr> 
      <td width="31%">Credit Card Exp. Date:</td>
      <td colspan="3" class="body" width="69%"> Month: 
        <select name="ccMonth">
          <% String ccMonth = (request.getParameter("ccMonth")==null)?"":request.getParameter("ccMonth"); %>
          <option value="01" <%=(ccMonth.equals("01"))?"Selected":""%>>January</option>
          <option value="02" <%=(ccMonth.equals("02"))?"Selected":""%>>February</option>
          <option value="03" <%=(ccMonth.equals("03"))?"Selected":""%>>March</option>
          <option value="04" <%=(ccMonth.equals("04"))?"Selected":""%>>April</option>
          <option value="05" <%=(ccMonth.equals("05"))?"Selected":""%>>May</option>
          <option value="06" <%=(ccMonth.equals("06"))?"Selected":""%>>June</option>
          <option value="07" <%=(ccMonth.equals("07"))?"Selected":""%>>July</option>
          <option value="08" <%=(ccMonth.equals("08"))?"Selected":""%>>August</option>
          <option value="09" <%=(ccMonth.equals("09"))?"Selected":""%>>September</option>
          <option value="10" <%=(ccMonth.equals("10"))?"Selected":""%>>October</option>
          <option value="11" <%=(ccMonth.equals("11"))?"Selected":""%>>November</option>
          <option value="12" <%=(ccMonth.equals("12"))?"Selected":""%>>December</option>
        </select>
        Year: 
        <select name="ccYear">
          <% String ccYear = (request.getParameter("ccYear")==null)?"":request.getParameter("ccYear"); %>
          <option value="01" <%=(ccYear.equals("01"))?"Selected":""%>>2001</option>
          <option value="02" <%=(ccYear.equals("02"))?"Selected":""%>>2002</option>
          <option value="03" <%=(ccYear.equals("03"))?"Selected":""%>>2003</option>
          <option value="04" <%=(ccYear.equals("04"))?"Selected":""%>>2004</option>
          <option value="05" <%=(ccYear.equals("05"))?"Selected":""%>>2005</option>
          <option value="06" <%=(ccYear.equals("06"))?"Selected":""%>>2006</option>
          <option value="07" <%=(ccYear.equals("07"))?"Selected":""%>>2007</option>
          <option value="08" <%=(ccYear.equals("08"))?"Selected":""%>>2008</option>
          <option value="09" <%=(ccYear.equals("09"))?"Selected":""%>>2009</option>
          <option value="10" <%=(ccYear.equals("10"))?"Selected":""%>>2010</option>
        </select>
      </td>
    </tr>
    <tr> 
      <td width="31%">Phone: 
        <input type="hidden" name="phoneCount" value="3">
      </td>
      <td colspan="3" class="body" width="69%"> <taglib:LUDropDownTag dropDownName="phoneTypeId0" table="lu_phone_types" extra="onChange=\"formChangedArea('Phones')\"" selected="<%= cB.getPhoneTypeIdString(0)%>"/>	
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
  <p>&nbsp;</p>
  <p>&nbsp;</p>
  <p>&nbsp;</p>
  <p>&nbsp;</p>
  <p>&nbsp;</p>
  <p>&nbsp;</p>
  <p>&nbsp;</p>
  <p>&nbsp;</p>
  <p>&nbsp;</p>
  <p>&nbsp;</p>
  <%	
	//SimpleConnection sc = new SimpleConnection();
	//Connection conn = sc.getConnection();
	//Statement qs1 = conn.createStatement();
	String sql1 = "SELECT ai.id 'id', aid.ar_invoice_amount 'ar_invoice_amount' FROM ar_invoices ai, ar_invoice_details aid, ar_invoice_types ait WHERE ai.id = aid.ar_invoiceid AND ai.ar_invoice_type = ait.invoice_type AND ait.value='final' AND aid.jobid = " +request.getParameter("jobId");
	//ResultSet rsInvoiceInfo = qs1.executeQuery(sql1);
	ResultSet rsInvoiceInfo = st.executeQuery(sql1);

	if(rsInvoiceInfo.next()){
		;
	}else{
		throw new Exception("no final invoice found");
	}
%>
  <hr width="100%" size="1">
  <table align="left" width="80%">
    <tr> 
      <td colspan="4" class="tableheader" > 
        <p>Invoice Summary</p>
      </td>
    </tr>
    <tr valign="top"> 
      <td class="label" width="36%" height="6"> 
        <div align="right">Invoice Number: </div>
      </td>
      <td class="body" width="11%" height="6"><%= rsInvoiceInfo.getString("id")%> 
      </td>
      <td class="label" width="26%" height="6"> 
        <div align="right">Total Amount Due: </div>
      </td>
      <td class="body" width="27%" height="6"><b><font color="#FF0000"><%= formater.getCurrency(rsInvoiceInfo.getDouble("ar_invoice_amount")) %></font> 
        </b></td>
    </tr>
  </table>
<p><br>
</p><p>&nbsp;</p>
  <table border="0" width="80%" align="left">
    <tr><td width=3%>&nbsp;</td>
<%
	ResultSet rsJobActions = st.executeQuery("SELECT a.id 'id', a.actionperform 'actionperform', j.id 'jobId' FROM jobflowactions a, jobs j WHERE a.currentstatus = j.status_id AND a.fromstatus = j.last_status_id AND a.whosaction = "+ ((((RoleResolver)session.getAttribute("roles")).isVendor())?"2":"1") +" AND j.id = " + request.getParameter("jobId")+" ORDER BY actionorder");
	while(rsJobActions.next()) { %>			
	    <td class="graybutton"><a href="javascript:moveWorkFlow('<%=rsJobActions.getString("id")%>')"><%= rsJobActions.getString("actionperform")%></a></td>
		<td width=3%>&nbsp;</td>
<% } %>
</tr>
</table>
<input type="hidden" name="dollarAmount" value="<%= rsInvoiceInfo.getDouble("ar_invoice_amount")%>">
<input type="hidden" name="invoiceId" value="<%= rsInvoiceInfo.getString("id")%>">
<input type="hidden" name="errorPage" value="/minders/workflowforms/FinalCollectionsForm.jsp?jobId=<%= request.getParameter("jobId")%>">
<input type="hidden" name="companyId" value="<%=cB.getCompanyIdString()%>">
<input type="hidden" name="$$Return" value="[/minders/JobMinderSwitcher.jsp]">
<input type="hidden" name="formChangedPhones" value="<%= (request.getParameter("formChangedPhones") == null )?"0":request.getParameter("formChangedPhones") %>">
<input type="hidden" name="formChangedLocations" value="<%= (request.getParameter("formChangedLocations") == null )?"0":request.getParameter("formChangedLocations") %>">
<input type="hidden" name="formChangedContact" value="<%= (request.getParameter("formChangedCompany") == null )?"0":request.getParameter("formChangedContact") %>">
<input type="hidden" name="formChangedCompany" value="<%= (request.getParameter("formChangedCompany") == null )?"0":request.getParameter("formChangedCompany") %>">
<input type="hidden" name="nextStepActionId" value="">  
<input type="hidden" name="jobId" value="<%= request.getParameter("jobId") %>" >
</form>
</body>
</html><%conn.close(); %>
