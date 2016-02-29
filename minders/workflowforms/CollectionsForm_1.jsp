<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<%@ page import="java.sql.*,com.marcomet.environment.*" %>
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
  <title>Check out <%=Integer.parseInt(((SiteHostSettings)request.getSession().getAttribute("siteHostSettings")).getCCommerce())%></title>
  <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
  <link rel="stylesheet" href="<%=(String)session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css">
</head>
<jsp:getProperty name="validator" property="javaScripts" />
<script language="JavaScript" src="/javascripts/mainlib.js"></script>
<body onLoad="MM_preloadImages('/images/buttons/continueover.gif','/images/buttons/cancelbtover.gif')" background="<%=(String)session.getAttribute("siteHostRoot")%>/images/back3.jpg">
<span class="Title">Credit Card Payment Processing Form</span> 
<form method="post" action="/servlet/com.marcomet.sbpprocesses.ProcessJobSubmit">
CC Processing: <%=((SiteHostSettings)request.getSession().getAttribute("siteHostSettings")).getCCommerce()%>
  <table align="left" width="80%" class=label>
    <tr>
		<td ><font color="red"><%= (request.getAttribute("errorMessage")==null)?"":"There was a problem processing this Credit Card Transaction: "+request.getAttribute("errorMessage")%><%= (session.getAttribute("errorMessage")==null) || session.getAttribute("errorMessage").toString().equals("")?"":"There was a problem processing this Credit Card Transaction: "+session.getAttribute("errorMessage")%></font></td>
	</tr>
        <input name="titleId" type="hidden" size="20" max="20" value="<%= cB.getTitleIdString() %>" onChange="formChangedArea('Contact')">
        <input name="firstName" type="hidden" size="20" max="20" value="<%= cB.getFirstName() %>" onChange="formChangedArea('Contact')">
        <input name="lastName" type="hidden" size="30" max="30" value="<%= cB.getLastName() %>" onChange="formChangedArea('Contact')">
		<input name="companyName" type="hidden" size="32" max="64" value="<%= cB.getCompanyName() %>" onChange="formChangedArea('Company')">
		<input type="hidden" name="jobTitle" size="20" max="20" value="<%= cB.getJobTitle() %>" onChange="formChangedArea('Contact')">
		<input type="hidden" name="email" value="<%= cB.getEmail() %>" onChange="formChangedArea('Contact')">
		<input type="hidden" name="companyURL" value="<%= cB.getCompanyURL() %>" onChange="formChangedArea('Company')"><%
		
			int commerce = Integer.parseInt(((SiteHostSettings)request.getSession().getAttribute("siteHostSettings")).getCCommerce());
			String hostAddress="";
			if (commerce == 0) {
				hostAddress="";
			} else if (commerce == 1) {
		        hostAddress="pilot-payflowpro.verisign.com";
			} else if (commerce == 2) {
		        hostAddress="payflowpro.verisign.com";
		    }
		%><input type="hidden" name="cch" value="<%= hostAddress %>">
</table>
  <p>&nbsp;</p>
  <table align="left" width="80%" class=label>
        <input type="hidden" name="locationBillId" value="<%= cB.getLocationBillIdString()%>">
        <input type="hidden" name="locationBillTypeId" value="<%= cB.getLocationBillTypeIdString()%>">
        <input type="hidden" name="addressBill1" size=56 max=200 value="<%= cB.getAddressBill1() %>" onChange="formChangedArea('Locations')" >
        <input type="hidden" name="addressBill2" size=56 max=200 value="<%= cB.getAddressBill2() %>" onChange="formChangedArea('Locations')" >
        <input type="hidden" name="cityBill" value="<%= cB.getCityBill() %>" onChange="formChangedArea('Locations')">
        <input type="hidden" name="stateBillId" value="<%= cB.getStateBillId() %>" onChange="formChangedArea('Locations')">
        <input type="hidden" name="zipcodeBill" value="<%= cB.getZipcodeBill() %>" onChange="formChangedArea('Locations')">
        <input type="hidden" name="phoneCount" value="3">
        <input type="hidden" name="phoneTypeId0" size="3" value="<%= cB.getPhoneTypeIdString(0) %>" onChange="formChangedArea('Phones')">
        <input type="hidden" name="areaCode0" size="3" value="<%= cB.getAreaCode(0) %>" onChange="formChangedArea('Phones')">
        <input type="hidden" name="prefix0" size="4" value="<%= cB.getPrefix(0) %>" onChange="formChangedArea('Phones')">
        <input type="hidden" name="lineNumber0" size="5" value="<%= cB.getLineNumber(0) %>" onChange="formChangedArea('Phones')">
        <input type="hidden" name="extension0" size="4" value="<%= cB.getExtension(0) %>" onChange="formChangedArea('Phones')">
        <input type="hidden" name="phoneTypeId1" size="3" value="<%= cB.getPhoneTypeIdString(1) %>" onChange="formChangedArea('Phones')">
        <input type="hidden" name="areaCode1" size="3" value="<%= cB.getAreaCode(1) %>" onChange="formChangedArea('Phones')">
        <input type="hidden" name="prefix1" size="4" value="<%= cB.getPrefix(1) %>" onChange="formChangedArea('Phones')">
        <input type="hidden" name="lineNumber1" size="5" value="<%= cB.getLineNumber(1) %>" onChange="formChangedArea('Phones')">
        <input type="hidden" name="extension1" size="4" value="<%= cB.getExtension(1) %>" onChange="formChangedArea('Phones')">
        <input type="hidden" name="phoneTypeId2" size="3" value="<%= cB.getPhoneTypeIdString(2) %>" onChange="formChangedArea('Phones')">
        <input type="hidden" size="3" name="areaCode2" value="<%= cB.getAreaCode(2) %>" onChange="formChangedArea('Phones')">
        <input type="hidden" name="prefix2" size="4" value="<%= cB.getPrefix(2) %>" onChange="formChangedArea('Phones')">
        <input type="hidden" name="lineNumber2" size="5" value="<%= cB.getLineNumber(2) %>" onChange="formChangedArea('Phones')">
        <input type="hidden" name="extension2" size="4" value="<%= cB.getExtension(2) %>" onChange="formChangedArea('Phones')">
    <tr> 
      <td height="35" valign="top" width="28%"><u>Credit Card Information:</u>&nbsp;</td>
      <td valign="top" height="35">
        <div align="left"><font color="#990000">(Note: charge will appear on your 
          credit card statement as MarComet.com, Inc.)</font></div>
      </td>
    </tr>
    <tr> 
      <td width="28%">Credit Card Type:</td>
      <td ><%String selStr=(request.getParameter("ccType")==null)?"":request.getParameter("ccType"); %><taglib:LUDropDownTag dropDownName="ccType" table="lu_credit_cards" selected="<%=selStr%>"/> 
      </td>
    </tr>
    <tr> 
      <td width="28%">Credit Card Number:</td>
      <td> 
        <input type="text" name="ccNumber" value="<%= (request.getParameter("ccNumber")==null)?"":request.getParameter("ccNumber")%>" size="19">
      </td>
    </tr>
    <tr> 
      <td width="28%">Credit Card Exp. Date:</td>
      <td> 
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
        <select name="ccYear">
          <% String ccYear = (request.getParameter("ccYear")==null)?"":request.getParameter("ccYear"); %>
          <option value="07" <%=(ccYear.equals("07"))?"Selected":""%>>2007</option>
          <option value="08" <%=(ccYear.equals("08"))?"Selected":""%>>2008</option>
          <option value="09" <%=(ccYear.equals("09"))?"Selected":""%>>2009</option>
          <option value="10" <%=(ccYear.equals("10"))?"Selected":""%>>2010</option>
          <option value="11" <%=(ccYear.equals("11"))?"Selected":""%>>2011</option>
          <option value="12" <%=(ccYear.equals("12"))?"Selected":""%>>2012</option>
          <option value="13" <%=(ccYear.equals("13"))?"Selected":""%>>2013</option>
          <option value="14" <%=(ccYear.equals("14"))?"Selected":""%>>2014</option>
          <option value="15" <%=(ccYear.equals("15"))?"Selected":""%>>2015</option>
          <option value="16" <%=(ccYear.equals("16"))?"Selected":""%>>2016</option>
		<option value="17" <%=(ccYear.equals("17"))?"Selected":""%>>2017</option>
        </select>
      </td>
    </tr>
    <tr> 
      <td colspan="2"> 
        <hr>
      </td>
    </tr>
  </table>	
  <p>&nbsp;</p>
  <p>&nbsp;</p>
  <p>&nbsp;</p>
  <p>&nbsp;</p>
   <%	
	String sql1 = "select * from ar_invoices where id = " +request.getParameter("invoiceId");
	String sql2 = "select * from ar_invoice_details where ar_invoiceid = " + request.getParameter("invoiceId");
	ResultSet rsInvoice = st.executeQuery(sql1);
	ResultSet rsInvoiceDetail = st2.executeQuery(sql2);
	rsInvoice.next();
	rsInvoiceDetail.next();	
%>
  <table align="left" width="80%">
    <tr> 
      <td class="label" width="30%" valign="top"><u>Invoice Summary</u></td>
      <td class="label" width="15%" valign="top">Invoice Number: </td>
      <td class="catalogTITLE" valign="top"> 
        <div align="left"><%= rsInvoice.getString("id")%> </div>
      </td>
      <td class="catalogTITLE">&nbsp;</td>
    </tr>
    <tr> 
      <td width="30%">&nbsp;</td>
      <td class="label" valign="top">Total Amount: </td>
      <td class="catalogTITLE" valign="top"> 
        <div align="left"><%= formater.getCurrency(rsInvoiceDetail.getDouble("ar_invoice_amount")) %> </div>
      </td>
      <td class="catalogTITLE">&nbsp;</td>
    </tr>
  </table>
  <p>&nbsp;</p><p>&nbsp;</p>
  <table width=100%>
    <tr> 
      <td width="46%" align="right"><a href="javascript:history.back(1)" class ="greybutton" >Cancel</a></td>
      <td width="4%">&nbsp;</td>
      <td width="46%"><a href="javascript:submitForm()" class="greybutton">Continue</a></td>
    </tr>
  </table>
  
<input type="hidden" name="dollarAmount" value="<%= rsInvoiceDetail.getDouble("ar_invoice_amount")%>">	
<input type="hidden" name="id" value="<%= rsInvoice.getString("id") %>" >
<input type="hidden" name="jobId" value="<%= rsInvoiceDetail.getString("jobid") %>" >
<input type="hidden" name="invoiceId" value="<%= request.getParameter("invoiceId")%>">
<input type="hidden" name="errorPage" value="/contents/CollectionsForm.jsp">
<input type="hidden" name="nextStepActionId" value="91">
<input type="hidden" name="companyId" value="<%=cB.getCompanyIdString()%>">
<input type="hidden" name="statusId" value="2">
<input type="hidden" name="contactId" value="<%=session.getAttribute("contactId").toString()%>">
<input type="hidden" name="$$Return" value="[/contents/FrameBreaker.jsp]">
<input type="hidden" name="redirect" value="[/contents/FrameBreaker.jsp]">
<input type="hidden" name="formChangedPhones" value="<%= (request.getParameter("formChangedPhones") == null )?"0":request.getParameter("formChangedPhones") %>">
<input type="hidden" name="formChangedLocations" value="<%= (request.getParameter("formChangedLocations") == null )?"0":request.getParameter("formChangedLocations") %>">
<input type="hidden" name="formChangedContact" value="<%= (request.getParameter("formChangedCompany") == null )?"0":request.getParameter("formChangedContact") %>">
<input type="hidden" name="formChangedCompany" value="<%= (request.getParameter("formChangedCompany") == null )?"0":request.getParameter("formChangedCompany") %>">
<%	session.setAttribute("errorMessage","");%>
</form>
</body>
</html><%conn.close(); %>
