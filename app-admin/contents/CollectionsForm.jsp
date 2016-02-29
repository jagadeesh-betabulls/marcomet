<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<%@ page import="java.sql.*" %>
<%@ taglib uri="/WEB-INF/tld/taglib.tld" prefix="taglib" %>
<jsp:useBean id="formater" class="com.marcomet.tools.FormaterTool" scope="page" />
<jsp:useBean id="validator" class="com.marcomet.tools.FieldValidationBean" scope="page" />
<jsp:useBean id="cB" class="com.marcomet.beans.SBPContactBean" scope="page" />

<jsp:setProperty name="cB" property="*"/>  
<%
Connection conn = com.marcomet.jdbc.DBConnect.getConnection();
Statement st = conn.createStatement();
Statement st2 = conn.createStatement();
	//load up required fields always present
	String[] flds = {"firstName","lastName","addressBill1","cityBill","zipcodeBill","email"};
	validator.setReqTextFields(flds); 
%>

<%-- How to return info to this page when errored out --%>
<% 
	if(request.getParameter("firstName")==null){
		String loginId = (session.getAttribute("contactId")==null)?"":(String)session.getAttribute("contactId"); 
		cB.setContactId(loginId);
	}
%>
<html>
<head>
  <title>Check out</title>
  <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
  <link rel="stylesheet" href="<%=(String)session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css">
</head>
<jsp:getProperty name="validator" property="javaScripts" />
<script language="JavaScript" src="/javascripts/mainlib.js"></script>
<body onLoad="MM_preloadImages('/images/buttons/continueover.gif','/images/buttons/cancelbtover.gif')">
<span class="Title">Credit Card Payment Processing Form </span>
<form method="post" action="/servlet/com.marcomet.sbpprocesses.ProcessCollectionSubmission">
  <table align="left" width="80%" class=label>
    <tr>
		<td colspan="4"><font color="red"><%= (request.getAttribute("errorMessage")==null)?"":request.getAttribute("errorMessage")%></font></td>
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
      <td width="28%">Address: 
        <input type="hidden" name="locationBillId" value="<%= cB.getLocationBillIdString()%>">
        <input type="hidden" name="locationBillTypeId" value="<%= cB.getLocationBillTypeIdString()%>">
      </td>
      <td colspan="3" width="72%"> 
        <input type="text" name="addressBill1" size=56 max=200 value="<%= cB.getAddressBill1() %>" onChange="formChangedArea('Locations')" >
        <br>
        <input type="text" name="addressBill2" size=56 max=200 value="<%= cB.getAddressBill2() %>" onChange="formChangedArea('Locations')" >
      </td>
    </tr>
    <tr> 
      <td width="28%">City, State &amp; Zip:</td>
      <td colspan="3" width="72%"> 
        <input type="text" name="cityBill" value="<%= cB.getCityBill() %>" onChange="formChangedArea('Locations')">
        , <taglib:LUDropDownTag dropDownName="stateBillId" table="lu_abreviated_states" extra="onChange=\"formChangedArea('Locations')\"" selected="<%= cB.getStateBillId()%>" /> 
        <input type="text" name="zipcodeBill" value="<%= cB.getZipcodeBill() %>" onChange="formChangedArea('Locations')">
      </td>
    </tr>
    <tr> 
      <td width="28%">Phone: 
        <input type="hidden" name="phoneCount" value="3">
      </td>
      <td colspan="3" width="72%"> <taglib:LUDropDownTag dropDownName="phoneTypeId0" table="lu_phone_types" extra="onChange=\"formChangedArea('Phones')\"" selected="<%= cB.getPhoneTypeIdString(0)%>"/>	
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
    <tr> 
      <td colspan="4">&nbsp;</td>
    </tr>
    <tr> 
      <td colspan="4"><u>Credit Card Information:</u>&nbsp;- <font color="#990000">(Note: 
        charge will appear on your credit card statement as MarComet.com, Inc.)</font></td>
    </tr>
    <tr> 
      <td width="28%">Credit Card Type:</td><%
      String selStr=((request.getParameter("ccType")==null)?"":request.getParameter("ccType"));
      %><td colspan="3" width="72%"> <taglib:LUDropDownTag dropDownName="ccType" table="lu_credit_cards" selected="<%=selStr%>"/> 
      </td>
    </tr>
    <tr> 
      <td width="28%">Credit Card Number:</td>
      <td colspan="3" width="72%"> 
        <input type="text" name="ccNumber" value="<%= (request.getParameter("ccNumber")==null)?"":request.getParameter("ccNumber")%>" size="19">
      </td>
    </tr>
    <tr> 
      <td width="28%">Credit Card Exp. Date:</td>
      <td colspan="3" width="72%"> Month: 
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
  <p>&nbsp;</p>
  <p>&nbsp;</p>
  <p>&nbsp;</p>
  <p> 
    <%	
	String sql1 = "select * from ar_invoices where id = " +request.getParameter("invoiceId");
	String sql2 = "select * from ar_invoice_details where ar_invoiceid = " + request.getParameter("invoiceId");
	ResultSet rsInvoice = st.executeQuery(sql1);
	ResultSet rsInvoiceDetail = st2.executeQuery(sql2);
	rsInvoice.next();
	rsInvoiceDetail.next();	
%>
  </p>
  <table align="left" width="80%">
    <tr> 
      <td class="catalogTITLE" width="28%">Invoice Summary</td>
      <td class="label" width="25%">Invoice Number: </td>
      <td class="label"><%= rsInvoice.getString("id")%> </td>
    </tr>
    <tr> 
      <td class="catalogTITLE" width="28%">&nbsp;</td>
      <td class="label">Total Amount: </td>
      <td class="label"><%= formater.getCurrency(rsInvoiceDetail.getDouble("ar_invoice_amount")) %> </td>
    </tr>
  </table>

  <p>&nbsp;</p>
  <p></p>
  <p></p><table width=100%>
    <tr> 
      <td width="46%"> 
        <div align="right"><a href="javascript:history.back(1)" class ="greybutton" >Cancel</a></div>
      </td>
      <td width="4%">&nbsp;</td>
      <td width="46%">
        <div align="left"><a href="javascript:submitForm()" class="greybutton">Continue</a></div>
      </td>
    </tr>
  </table>
<input type="hidden" name="dollarAmount" value="<%= rsInvoiceDetail.getDouble("ar_invoice_amount")%>">	
<input type="hidden" name="invoiceId" value="<%= request.getParameter("invoiceId")%>">
<input type="hidden" name="errorPage" value="/contents/CollectionsForm.jsp">
<input type="hidden" name="companyId" value="<%=cB.getCompanyIdString()%>">
<input type="hidden" name="$$Return" value="[/contents/FrameBreaker.jsp]">
<input type="hidden" name="formChangedPhones" value="<%= (request.getParameter("formChangedPhones") == null )?"0":request.getParameter("formChangedPhones") %>">
<input type="hidden" name="formChangedLocations" value="<%= (request.getParameter("formChangedLocations") == null )?"0":request.getParameter("formChangedLocations") %>">
<input type="hidden" name="formChangedContact" value="<%= (request.getParameter("formChangedCompany") == null )?"0":request.getParameter("formChangedContact") %>">
<input type="hidden" name="formChangedCompany" value="<%= (request.getParameter("formChangedCompany") == null )?"0":request.getParameter("formChangedCompany") %>">

</form>
</body>
</html><%conn.close();%>