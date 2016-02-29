<%@ page errorPage="/errors/ExceptionPage.jsp" %>

<%@ page import="java.sql.*,java.util.*,com.marcomet.admin.accounting.*;" %>
<%@ taglib uri="/WEB-INF/tld/taglib.tld" prefix="taglib" %>
<jsp:useBean id="formater" class="com.marcomet.tools.FormaterTool" scope="page" />
<jsp:useBean id="validator" class="com.marcomet.tools.FieldValidationBean" scope="page" />
<%
	String[] flds = {"paidContactId","refNo"};
	validator.setReqTextFields(flds);	

	String[] numFlds = {"paidContactId","refNo"};
	validator.setNumberFields(numFlds);
%>

<html>
<head>
<title>Create an AP Payment and Details</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
</head>
<jsp:getProperty name="validator" property="javaScripts" />
<script language="JavaScript">
function refresh(){
	document.forms[0].action = window.location;
	document.forms[0].submit();
}
</script>
<script lanugage="JavaScript" src="/javascripts/mainlib.js"></script>
<body bgcolor="#FFFFFF" text="#000000">
<form method="post" action="/servlet/com.marcomet.admin.accounting.CreateAPPaymentForm">
<table>
	<tr>
		<td>Pay To Contact Id:</td><td><input type="text" name="paidContactId" value="<%= (request.getParameter("paidContactId") == null)?"":request.getParameter("paidContactId")%>"></td>		
	</tr>
	<tr>
		<td>Check Date:</td><td><taglib:DropDownDateTag extraCode="onChange=\"popHiddenDateField('paymentDate')\"" />
		<input type="hidden" name="paymentDate" value="2001-01-01"></td>
	</tr>
	<tr>
		<td>Payment(ie: Check) Number:</td><td><input type="text" name="refNo" value="<%= (request.getParameter("refNo") == null)?"":request.getParameter("refNo")%>"></td>
	</tr>
	<tr>
		<td>Payment Type:</td><td><taglib:LUDropDownTag dropDownName="paymentTypeId" table="lu_ap_payment_types"/></td>
	</tr>
	<tr>
		<td>Accounting System Reference:</td><td><input type="text" name="acctgSysRef" value="<%= (request.getParameter("acctgSysRef") == null)?"":request.getParameter("acctgSysRef")%>"></td>
	</tr>
</table>
<input type="button" value="Submit" onClick="submitForm()">
<p>
<input type="button" value="Add Detail" onClick="pop('/admin/accounting/ap/PopUpCreateAPDetailForm.jsp','400','300')">
<%
	
	Vector  details = (Vector)session.getAttribute("apPaymentDetails");
	if(details != null){
%>
	<p><p>
	<table>
<%		
		double detailTotal = 0;
		for(int i=0; i < details.size(); i++){   
		APPaymentDetailObject apDetail = (APPaymentDetailObject)details.elementAt(i);
		detailTotal += apDetail.getAmount();
%>	
		<tr>
			<td colspan="3">AP Payment Detail # <%= i + "" %></td>
		<tr>
			<td>&nbsp;</td><td>Ap Invoice Id:</td><td><%= apDetail.getApInvoiceId()%></td>
		</tr>
		<tr>
			<td>&nbsp;</td><td>Ap Payment Id:</td><td>determined on save</td>
		</tr>
		<tr>
			<td>&nbsp;</td><td>Amount:</td><td><%= formater.getCurrency(apDetail.getAmount())%></td>
		</tr>
		<tr>
			<td>&nbsp;</td><td>Account System Reference:</td><td><%= apDetail.getAcctgSysRef() %></td>
		</tr>
		<tr>
			<td colspan="3">&nbsp;</td>
		</tr>
<%		}	%>	
		<tr>
			<td colspan="3">&nbsp;</td>
		</tr>	
		<tr>
			<td colspan="2">Total:</td><td><%= formater.getCurrency(detailTotal) %></td>
		</tr>
	</table>	
<%		
	}
%>
<input type="hidden" name="$$Return" value="[/admin/accounting/ap/CreateAPPaymentForm.jsp]">
<input type="hidden" name="errorPage" value="/admin/accounting/ap/CreateAPPaymentForm.jsp">
<input type="hidden" name="nextStepActionId" value="56">
</form>
</body>
</html>
