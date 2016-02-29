
<%@ page language="java" %>

<%@ page import="java.util.*" %>
<%@ page import="com.vgl.payment.CustomerPaymentDAO" %>
<html>

<head>
<meta http-equiv="Content-Language" content="en-us">
<meta http-equiv="Content-Type" content="text/html; charset=windows-1252">
<meta name="GENERATOR" content="Microsoft FrontPage 4.0">
<meta name="ProgId" content="FrontPage.Editor.Document">
<title></title>
<link rel="stylesheet" type="text/css" href="css/master.css" title="Style" >
<script type="text/javascript"  src="javascripts/dataentry.js">
</script>
</head>

<body >
<form method="POST" name="submitForm" action="EntryForm.jsp">
<input type="hidden" name="act" value="">
<%
    String __act = request.getParameter("act");
    System.out.println("Submit Act " + __act);
    if(__act!=null && __act.equals("cancel")){
      response.sendRedirect("EntryForm.jsp");
      return;
    }
    if(__act!=null && __act.equals("showAll")){
      response.sendRedirect("AddEntry.jsp?showAll=y");
      return;
    }
   if(__act!=null && __act.equals("viewlist")){
    response.sendRedirect("ViewListForm.jsp");
   System.out.println("View List Act");
    return;
  }
    String compId = request.getParameter("cId");
	if((compId == null) || (compId.trim().length()==0)){
	  response.sendRedirect("EntryForm.jsp");
      return;
    }
	System.out.println("SubmitForm::compId " + compId);
	String compName = request.getParameter("cName").trim();
	String checkNumber = request.getParameter("txtCheckNumber").trim();
	String oldCheckNumber = "";
	if(request.getParameter("oldCheckNumber")!=null)
	 oldCheckNumber = request.getParameter("oldCheckNumber").trim();
	else 
	  System.out.println("Old Check Number is null" );
	String[] invoiceIds = request.getParameterValues("invoiceId");
	String[] payments = request.getParameterValues("payments");
	String[] oldPayments = null; 
	String data = request.getParameter("data"); 
	System.out.println("SubmitForm::data = " + data);
	ArrayList invoiceDetails = new ArrayList();
	if(data.equalsIgnoreCase("edit")) {
		String checkAmt = request.getParameter("txtCheckAmt").trim();
		String checkDate = request.getParameter("txtCheckDate").trim();
		String depositDate = request.getParameter("txtDepositDate").trim();
		

        StringTokenizer checkDateTokenizer = new StringTokenizer(checkDate.trim(), "-");
        StringBuffer checkDateBuffer = new StringBuffer();
        String month1 = checkDateTokenizer.nextToken();
        String day1 = checkDateTokenizer.nextToken();
        String year1 = checkDateTokenizer.nextToken();
        checkDateBuffer.append(year1);
        checkDateBuffer.append("-");
        checkDateBuffer.append(month1);
        checkDateBuffer.append("-");
        checkDateBuffer.append(day1);

        StringTokenizer depositDateTokenizer = new StringTokenizer(depositDate.trim(), "-");
        StringBuffer depositDateBuffer = new StringBuffer();
        String month2 = depositDateTokenizer.nextToken();
        String day2 = depositDateTokenizer.nextToken();
        String year2 = depositDateTokenizer.nextToken();
        depositDateBuffer.append(year2);
        depositDateBuffer.append("-");
        depositDateBuffer.append(month2);
        depositDateBuffer.append("-");
        depositDateBuffer.append(day2);

		HashMap checkInfo = new HashMap();
		checkInfo.put("COMP_ID", compId.trim());
		checkInfo.put("OLD_CHECK_NUMBER", oldCheckNumber);
		checkInfo.put("CHECK_NUMBER", checkNumber.trim());
		
		//checkInfo.put("CHECK_DATE", checkDate.trim());
        checkInfo.put("CHECK_DATE", checkDateBuffer.toString());
		checkInfo.put("CHECK_AMOUNT", checkAmt.trim());
		//checkInfo.put("DEPOSIT_DATE", depositDate.trim());
        checkInfo.put("DEPOSIT_DATE", depositDateBuffer.toString());
        System.out.println("CHECK_DATE"+ checkDateBuffer.toString());
        System.out.println("DEPOSIT_DATE"+ depositDateBuffer.toString());
        
		oldPayments = request.getParameterValues("oldPayments");
		ArrayList updatedInvoices = new ArrayList();
		for(int ii=0; ii< invoiceIds.length ; ii++) {
			if((payments[ii] == null || payments[ii].trim().length() == 0)){
				payments[ii] = "0";
			}
			if(!(payments[ii] == null || payments[ii].length() == 0)){
				HashMap invoicePays = new HashMap();
				Double oldPay = new Double(oldPayments[ii].trim());
				System.out.println("old Pay" + oldPay.doubleValue());
				Double newPay = new Double(payments[ii].trim());
				System.out.println("New Pay" + newPay.doubleValue());
				double payDiff = newPay.doubleValue() - oldPay.doubleValue();
				if(payDiff != 0) {
					invoicePays.put("ID",invoiceIds[ii].trim());
					invoicePays.put("PAYMENT_AMOUNT",""+payDiff);
					if(oldPay.doubleValue() != 0) {
						updatedInvoices.add(invoicePays);
					} else {
						invoiceDetails.add(invoicePays);
					}
				}
			}
		}
		CustomerPaymentDAO.updateCheckInfo(checkInfo);
		if(updatedInvoices.size() > 0) 
		{
			
			CustomerPaymentDAO.EditInvoicePayment(checkNumber.trim(), updatedInvoices);
		}
		if(invoiceDetails.size() > 0) 
		{		
			CustomerPaymentDAO.updateInvoicePayment(checkNumber.trim(), invoiceDetails);
		}
	} 
	else if(data.equalsIgnoreCase("delete")) 
	{
      System.out.println("In Delete");
		oldPayments = request.getParameterValues("oldPayments");
		ArrayList updatedInvoices = new ArrayList();
		for(int ii=0; ii< invoiceIds.length ; ii++) {
			payments[ii] = "0";
			if(!(payments[ii] == null || payments[ii].length() == 0)){
				HashMap invoicePays = new HashMap();
				Double oldPay = new Double(oldPayments[ii].trim());
				Double newPay = new Double(payments[ii].trim());
				double payDiff = newPay.doubleValue() - oldPay.doubleValue();
				if(payDiff != 0) {
					invoicePays.put("ID",invoiceIds[ii].trim());
					invoicePays.put("PAYMENT_AMOUNT",""+payDiff);
					if(oldPay.doubleValue() != 0) {
						updatedInvoices.add(invoicePays);
					} 
				}
			}
            
		}
		if(updatedInvoices.size() > 0) {
			CustomerPaymentDAO.DeleteCheckEntry(checkNumber.trim(), updatedInvoices);
		}
	}
	 else 
	 {
		String checkAmt = request.getParameter("txtCheckAmt").trim();
		String checkDate = request.getParameter("txtCheckDate").trim();
		String depositDate = request.getParameter("txtDepositDate").trim();

        StringTokenizer checkDateTokenizer = new StringTokenizer(checkDate.trim(), "-");
        StringBuffer checkDateBuffer = new StringBuffer();
        String month1 = checkDateTokenizer.nextToken();
        String day1 = checkDateTokenizer.nextToken();
        String year1 = checkDateTokenizer.nextToken();
        checkDateBuffer.append(year1);
        checkDateBuffer.append("-");
        checkDateBuffer.append(month1);
        checkDateBuffer.append("-");
        checkDateBuffer.append(day1);

        StringTokenizer depositDateTokenizer = new StringTokenizer(depositDate.trim(), "-");
        StringBuffer depositDateBuffer = new StringBuffer();
        String month2 = depositDateTokenizer.nextToken();
        String day2 = depositDateTokenizer.nextToken();
        String year2 = depositDateTokenizer.nextToken();
        depositDateBuffer.append(year2);
        depositDateBuffer.append("-");
        depositDateBuffer.append(month2);
        depositDateBuffer.append("-");
        depositDateBuffer.append(day2);

		HashMap checkInfo = new HashMap();
		checkInfo.put("COMP_ID", compId.trim());
		checkInfo.put("CHECK_NUMBER", checkNumber.trim());
		//checkInfo.put("CHECK_DATE", checkDate.trim());
        checkInfo.put("CHECK_DATE", checkDateBuffer.toString());
		checkInfo.put("CHECK_AMOUNT", checkAmt.trim());
		//checkInfo.put("DEPOSIT_DATE", depositDate.trim());
        checkInfo.put("DEPOSIT_DATE", depositDateBuffer.toString());
        System.out.println("CHECK_DATE"+ checkDateBuffer.toString());
        System.out.println("DEPOSIT_DATE"+ depositDateBuffer.toString());
/*********************************************************************/
/* Processing invoices  and job recalculation   sanjay              */
/********************************************************************/
for(int ii=0; ii< invoiceIds.length ; ii++) 
{
 	if(!(payments[ii] == null || payments[ii].length() == 0) && !(Double.parseDouble(payments[ii].trim()) == 0)) 
	{
		HashMap invoicePays = new HashMap();
		invoicePays.put("ID",invoiceIds[ii].trim());
		invoicePays.put("PAYMENT_AMOUNT",payments[ii].trim());
		invoiceDetails.add(invoicePays);
               // call method to do job calculation
		//CustomerPaymentDAO.jobRecalculate(invoiceIds[ii].trim());	
}
}
if(invoiceDetails.size() > 0) 
{
	CustomerPaymentDAO.insertCustomerPayment(checkInfo, invoiceDetails);
}
	}
System.out.println("Invoice Count -> " + invoiceIds.length);
//Call the job recalculation method
for(int ii=0; ii< invoiceIds.length ; ii++)
{ 
   if(!(payments[ii] == null || payments[ii].length() == 0) && !(Double.parseDouble(payments[ii].trim()) == 0))
 { 
   System.out.println("Job calculation for invoice-> " + invoiceIds[ii].trim());
   CustomerPaymentDAO.jobRecalculate(invoiceIds[ii].trim());
 }
}
 if(__act.equals("edit")){
   response.sendRedirect("ViewListForm.jsp?call=submit&cId="+compId.trim()+"&CURRENT_PAGE=1");
} else {
     response.sendRedirect("EntryForm.jsp");
  }
%>
</form>
</body>

</html>
