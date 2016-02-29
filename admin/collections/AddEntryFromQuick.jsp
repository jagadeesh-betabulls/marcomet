
<%@ page language="java" %>

<%@ page import="java.util.*,java.text.*,java.lang.*" %>
<%@ page import="com.vgl.payment.CustomerPaymentDAO" %>
<html> 

<head>
<meta http-equiv="Content-Language" content="en-us">
<meta http-equiv="Content-Type" content="text/html; charset=windows-1252">
<meta name="GENERATOR" content="Microsoft FrontPage 4.0">
<meta name="ProgId" content="FrontPage.Editor.Document">
<title>ADD ENTRY</title>
<link rel="stylesheet" type="text/css" href="css/master.css" title="Style" >
<link rel="stylesheet" type="text/css" href="css/rfnet.css">
<script type="text/javascript" src="javascripts/datetimepicker.js"></script>
<script type="text/javascript" src="javascripts/dataentry.js"></script>
<script type="text/javascript" src="javascripts/sorttable.js"></script>
<script language="JavaScript" src="/javascripts/mainlib.js"></script>

</head>

<body onload="checkTest();document.forms[0].txtCheckNumber.focus();" >
<form method="POST" name="addEntry" action="SubmitFormFromQuick.jsp" onSubmit="return checkAddFormData(); return setCompInfo();">
<input type="hidden" name="act" value="">
<%
   NumberFormat cf = new DecimalFormat("#,###,##0.00");
   String showAllObj = request.getParameter("showAll");
   boolean showAll = showAllObj!=null && showAllObj.equals("y");
	

    String __act = request.getParameter("act");
   if(__act == null || __act!=null && __act.equals("exit")) {
    response.sendRedirect("/reports/vendors/index.jsp");
    return;
   }
    String compId = request.getParameter("cId");
    String siteHostId = (String)request.getSession().getAttribute("siteHostId");
 // commented out by CSA to eliminate secondary login
 //   if(siteHostId==null)
 //   {
 //       response.sendRedirect("/app-admin/AdminLogin.jsp");
 //       return ;
 //   }
    if((compId == null) || (compId.trim().length()==0)){
	  response.sendRedirect("EntryFormFromQuick.jsp");
      return;
    }
    String compName = request.getParameter("cName");
    String invoiceNo = request.getParameter("invoiceNo");
    String jobId = request.getParameter("jobNo");
    String orderNumber=request.getParameter("orderNumber");
    String custId = request.getParameter("custNo");
    int companyID = Integer.parseInt(compId.trim());
    if(companyID <= 0  ) {
        String id = compId.trim();
        int idType = CustomerPaymentDAO.COMP_TYPE;
        if(!(invoiceNo == null || invoiceNo.trim().length() == 0)) { 
            id  = invoiceNo.trim();
            idType = CustomerPaymentDAO.INVOICE_TYPE;
        }else if(!(jobId == null || jobId.trim().length() == 0)) { 
            id  = jobId.trim();
            idType = CustomerPaymentDAO.JOB_TYPE;
        }else if(!(custId == null || custId.trim().length() == 0)) { 
            id  = custId.trim();
            idType = CustomerPaymentDAO.CUST_TYPE;
    	}else if(!(orderNumber == null || orderNumber.trim().length() == 0)) { 
        id  = orderNumber.trim();
        idType = CustomerPaymentDAO.ORDER_TYPE;
    	}
        System.out.println("id is "+id);
        System.out.println("idType is "+idType);
        
	 	companyID = CustomerPaymentDAO.getCompID(id, idType);
        compName = CustomerPaymentDAO.getCompanyName(companyID);
        System.out.println("companyID is : " + companyID);
        System.out.println("compName is : " + compName);
    }
    compId = ""+companyID;
	System.out.println("compId jsp : " + compId);
	if(compId.equals("-1")) {
		System.out.println("compId jsp inside : " + compId);
		response.sendRedirect("EntryFormFromQuick.jsp?mode=repeat&message=No records found.");
		return;
	}
%>
  <input type="hidden" name="cId" value="<%=compId%>">
  <input type="hidden" name="cName" value="<%=compName%>">
  <input type="hidden" name="cn" value="<%=CustomerPaymentDAO.getChequeList(companyID)%>">
  <table width="100%" border="0" cellspacing="1" cellpadding="0" bgcolor="#333333">
    <tr>
      <td><table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#F3F1F1">
          <tr> 
            
            <td  valign="top" > <table width="100%" cellpadding="0" cellspacing="1">
                <tr> 
                  <td  colspan="4" class="table-heading">ADD CUSTOMER PAYMENT</td>
                </tr>
                <tr> 
                  <td  class="text-row1"> Client Company</td>
                  <td  colspan="3" class="text-row2" ><%=compName%></td>
                </tr>
                <tr> 
                  <td  class="text-row1">Check Number/Ref</td>
                  <td  class="text-row2"><input type="text" name="txtCheckNumber" size="20" maxlength='32' class="textBox">
                  <input type="hidden"  name="oldCheckNumber" value=""></td>
                  <td  class="text-row1" >Check Amount</td>
                  <td  class="text-row2" >$ <input type="text" style='text-align:right' name="txtCheckAmt" size="20" maxlength='10' class="TextBox" ></td>
                </tr>
                <tr> 
                  <td   class="text-row1">Check Date [mm-dd-yyyy]</td>
                  <td  class="text-row2" >
                  <input type="text" id='txtCheckDate' name="txtCheckDate"  size="20" class="textBox">
                  <a href="javascript:NewCal('txtCheckDate','mmddyyyy',false,24)">
                    <img id="date1" src="images/cal.gif" name="checkDate" width="16" height="16" border="0" alt="Pick a date">
                  </a>
                  </td>

                  <td  class="text-row1">Deposit Date [mm-dd-yyyy]</td>
                  <td  class="text-row2">&nbsp;&nbsp; 
                  <input type="text" id ='txtDepositDate'  name="txtDepositDate" size="20" class="textBox"> 
                  <a href="javascript:NewCal('txtDepositDate','mmddyyyy',false,24)">
                    <img id="date2" src="images/cal.gif" name="depositDate" width="16" height="16" border="0" alt="Pick a date">
                  </a>
                  </td>
                </tr><tr><td colspan="4">&nbsp;</td></tr>
              </table>
              <table width="100%" cellpadding="0" cellspacing="1">
                <tr> 
                  <td width="100%" colspan="5" class="table-subheading">Detailed list of invoices for client companies that have outstanding invoice balances.</td>
                </tr>
                <tr> 
                  <td colspan="5" align="left" class="table-subheading">
                    <table width="100%" border="0" cellspacing="0" cellpadding="0" >
                    <%
                      String currentPage = (String)request.getParameter("CURRENT_PAGE");
                      String gotoNext = (String)request.getParameter("NEXT");
                      int curPage = 1;
                      int counter = 10;
                      
                      if(!((currentPage ==null) || (currentPage.length()==0))){
                        curPage = Integer.parseInt(currentPage.trim());
                      }

                      ArrayList invoiceList = null;
                      if(gotoNext == null){
                        invoiceList= CustomerPaymentDAO.getInvoices(Integer.parseInt(compId.trim()), showAll);
                        request.getSession().setAttribute("INVOICE_LIST",invoiceList);
                      }
                      else {
                        invoiceList = (ArrayList)request.getSession().getAttribute("INVOICE_LIST");
                        if((invoiceList == null) || (invoiceList.size() == 0)){
                          invoiceList= CustomerPaymentDAO.getInvoices(Integer.parseInt(compId.trim()), showAll);
                          request.getSession().setAttribute("INVOICE_LIST",invoiceList);
                        }
                      }
                      int recordCount = invoiceList.size();
                      counter = recordCount + 1; // added to remove pagination 
                      int startIndex = (curPage - 1) * counter; 
                      int pageRecordCount = 0;

                      int firstPage=1;
                      int lastPage=recordCount/counter + 1;
                      int nextPage=1;
                      int prevPage=1;
                      if(curPage + 1 >= lastPage){
                        nextPage = lastPage;
                      }
                      else{
                        nextPage = curPage + 1;
                      }

                      if(curPage - 1 <= firstPage){
                        prevPage = firstPage;
                      }
                      else{
                        prevPage = curPage - 1;
                      }

                      if (curPage == lastPage){
                        pageRecordCount = recordCount%counter;
                      }
                      else {
                        pageRecordCount = (recordCount/counter)>0?counter:(recordCount%counter);
                      }
                    %>
                      </table> 
                  </td>
                </tr>
                <tr>
                <td colspan='5'>
                <table id='invoice' class='sortable' width='100%'>
                <tr> 
                  <td  class="text-row1" width='15%'><p>Invoice Number</p></td>
                  <td  class="text-row1" width='15%'><p>Job Number</p></td>
                  <td  class="text-row1" width='15%'>Invoice Date</td>
                  <td  class="text-row1" align="right" width='15%'>Invoice Amount</td>
                  <td  class="text-row1" align="right" width='20%'>Invoice Balance</td>
                  <td  class="text-row1" width='20%'>Payment Amount ($)</td> 
                </tr>
                <%
                Map details = null;
                int tmpInvoiceId=0;
                String tmpInvoiceNumber="0";
                String tmpJobNumber;
                String tmpInvoiceDate;
                double tmpInvoiceAmt = 0.00;
                double tmpInvoiceBalance=0.00;
                double totalBalance = 0.00;
                String totalPayments = "0.00";

                for(int j=0;j<pageRecordCount;j++){
                    details = (Map)invoiceList.get(startIndex + j);
                    tmpInvoiceId = ((Integer)details.get("ID")).intValue();
                    tmpInvoiceNumber = (String)details.get("INVOICE_NUMBER");
                    tmpJobNumber = (String)details.get("JOB_NUMBER");
                    tmpInvoiceDate= (String)details.get("INVOICE_DATE");
                    tmpInvoiceAmt = ((Double)details.get("INVOICE_AMT")).doubleValue();

			String suffStr = cf.format(tmpInvoiceAmt);

	    	     	tmpInvoiceBalance = ((Double)details.get("INVOICE_BAL_AMT")).doubleValue();
			String subStr = cf.format(tmpInvoiceBalance);
                    totalBalance = totalBalance + tmpInvoiceBalance;
                %>
                <tr> 
                    <input type="hidden" name="invoiceId" value="<%=""+tmpInvoiceId%>">
                    <td class="text-row2"><a href="javascript:popw('/minders/workflowforms/PrintInvoice.jsp?invoiceId=<%=tmpInvoiceNumber%>','640','480')"><%=""+tmpInvoiceNumber%></a></td>
                    <input type="hidden" value="<%=""+tmpInvoiceNumber%>" name="invoicenum" >
                    <td class="text-row2"><a href="javascript:pop('/popups/JobDetailsPage.jsp?jobId=<%=tmpJobNumber%>','700','300')"><%=""+tmpJobNumber%></a></td>
                    <td class="text-row2"><%=tmpInvoiceDate%></td>
                    <td class="text-row2" align="right">$<%=""+suffStr%></td>
                    <td class="text-row2" align="right">$<%=""+subStr%></td>
                    <input type="hidden" value="<%=""+tmpInvoiceBalance%>" name="balance" >
                    <td class="text-row2">
                      <input type="hidden" name="oldPayments" value="0.00">
                      <input type="hidden" name="lastValue" value="0.00">
                      <input type="text" name="payments" size="20" style='text-align:right' class="TextBox" onBlur="addEditPayments(this);">
                    </td>
                </tr>
                <%
                }

			String subTStr = cf.format(totalBalance);
                 %>
                </table>
                </td>
                </tr>
                <tr> 
                  <td colspan="5" class="text-row1">
                    <table width='100%' cellspacing="0" cellpadding="0">
                    <tr> 
                      <td colspan="5" >
                      <table width='100%' cellpadding='5' >
                        <tr> 
                          <td colspan='3' class="text-row1" align='right' width='60%'><B>Total</B></td>
                          <td class="text-row1" align='right' width='20%'>$ <%=subTStr%></td>
                          <td class="text-row1" width='20%'> 
                          <input type="text" name="totalPayment" readonly='true' size="20" style='text-align:right' class="TextBox" value="<%=totalPayments%>">
                          </td>
                        </tr>
                      </table>
                      </td>
                    </tr>
                    </table>
                  </td>
                </tr>
                <%
                if(recordCount <= 0){
                %>
                <tr>
                  <td align="center" class="text-row2" colspan="4"> No outstanding invoices exist.</td>
                  <input type="hidden" name="recordCount" value="0">
                </tr>
                <%
                } else {
                %>
                  <input type="hidden" name="recordCount" value="<%=recordCount%>">
                <%
                }
                %>
                <tr> 
                  <td colspan="6" class="table-subheading"">
                    <div align="center" >
                      <input type="submit" value="Submit" name="submit" class="Field-Button">
                      <input type="reset" value="Reset" name="reset" class="Field-Button">
                      <input type="submit" value="Cancel" name="cancel" class="Field-Button" onclick="doCancel()">
                      <!--input type="submit" value="Show All Invoices" name"showAll" class="Field-Button" onclick="doShowAll()"-->
					  <input type="hidden" value="Add" name="data">
                    </div>
                  </td>
                </tr>
              </table></td>
          </tr>
        </table></td>
    </tr>
  </table>
</form>
</body>
</html>
