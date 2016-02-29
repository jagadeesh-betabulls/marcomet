<%@ page language="java" %>
<%@ page import="com.vgl.payment.CustomerPaymentDAO" %>
<%@ page import="java.util.*" %>

<html>

<head>
<meta http-equiv="Content-Language" content="en-us">
<meta http-equiv="Content-Type" content="text/html; charset=windows-1252">
<meta name="GENERATOR" content="Microsoft FrontPage 4.0">
<meta name="ProgId" content="FrontPage.Editor.Document">
<title>CHECK EDIT FORM</title>
<link rel="stylesheet" type="text/css" href="css/master.css" title="Style" >
<link rel="stylesheet" type="text/css" href="css/rfnet.css">
<script type="text/javascript"  src="javascripts/dataentry.js"></script>
<script type="text/javascript" src="javascripts/sorttable.js"></script>
<script type="text/javascript" src="javascripts/datetimepicker.js"></script>
</head>

<body onload="if(document.forms[0].payments[0]==null){document.forms[0].payments.focus();} else { document.forms[0].payments[0].focus();}" >
<form method="POST" name="editEntry" action="SubmitFormFromQuick.jsp" onSubmit="return checkEditFormData(); return setCompInfo();">
<input type="hidden" name="act" value="">
<%
    String siteHostId = (String)request.getSession().getAttribute("siteHostId");
// commented out by CSA to eliminate secondary login
//    if(siteHostId==null)
//    {
//      response.sendRedirect("/app-admin/AdminLogin.jsp");
//      return;
//    }
    String compId = request.getParameter("cId");
	if((compId == null) || (compId.trim().length()==0)){
	  response.sendRedirect("EntryFormFromQuick.jsp");
      return;
    }
    String compName = request.getParameter("cName");
    String checkNo = request.getParameter("checkNo");
    String checkAmt = request.getParameter("checkAmt");
    String checkDate = request.getParameter("checkDate");
    String depositDate = request.getParameter("depositDate");
    
%>
  <input type="hidden" name="cId" value="<%=compId%>">
  <input type="hidden" name="cName" value="<%=compName%>">
  <input type="hidden" name="cn" value="<%=CustomerPaymentDAO.getChequeList()%>">
  <table width="100%" border="0" cellspacing="1" cellpadding="0" bgcolor="#333333">
    <tr>
      <td><table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#F3F1F1">
          <tr> 
            
            <td  valign="top" > <table width="100%" cellpadding="0" cellspacing="1">
                <tr> 
                  <td  colspan="4" class="table-heading"> 
                     EDIT CUSTOMER PAYMENT</td>
                </tr>
                <tr> 
                  <td  class="text-row1"> Client Company</td>
                  <td  colspan="3" class="text-row2" ><%=compName%>
<!--				  <input type="text" readonly=true name="T5" value="<%=compName%>" size="20" class="TextBox"> -->
				  </td>
                </tr>
                <tr> 
                  <td  class="text-row1">Check Number/Ref</td>
                  <td  class="text-row2"><input type="text" size="20" maxlength='32' name="txtCheckNumber" class="textBox" value="<%=checkNo%>">
				 <input type="hidden"  name="oldCheckNumber" value="<%=checkNo%>">
				  </td>
                  <td  class="text-row1">Check Amount</td>
                  <td  class="text-row2">$
                    <input type="text" name="txtCheckAmt" size="20" maxlength='10' style='text-align:right' class="TextBox"  value="<%=checkAmt%>">
				  </td>
                </tr>
                <tr> 
                  <td   class="text-row1">Check Date [mm-dd-yyyy]</td>
                  <td  class="text-row2" ><input type="text" id='txtCheckDate' name="txtCheckDate" value="<%=checkDate%>" size="20" class="textBox">
                  <a href="javascript:NewCal('txtCheckDate','mmddyyyy',false,24)">
                    <img id="date1" src="images/cal.gif" name="checkDate" width="16" height="16" border="0" alt="Pick a date">
                  </a>
				  </td>
                  <td  class="text-row1">Deposit Date [mm-dd-yyyy]</td>
                  <td  class="text-row2">&nbsp;&nbsp;
                  <input type="text" id ='txtDepositDate'  name="txtDepositDate" value="<%=depositDate%>" size="20" class="textBox"> 
                  <a href="javascript:NewCal('txtDepositDate','mmddyyyy',false,24)">
                    <img id="date2" src="images/cal.gif" name="depositDate" width="16" height="16" border="0" alt="Pick a date">
                  </a>
				  </td>
                </tr><tr><td colspan="4">&nbsp;</td></tr>
              </table>
              <table width="100%" cellpadding="0" cellspacing="1">
                <tr> 
                  <td width="100%" colspan="5" class="table-subheading">Detailed list of invoices for client companies that have outstanding invoice balances</td>
                </tr>

                <tr> 
                  <td colspan="5" align="left" class="table-subheading">
                    <table width="100%" border="0" cellspacing="0" cellpadding="0">
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
                        invoiceList= CustomerPaymentDAO.getEditableInvoices( checkNo.trim());
                        request.getSession().setAttribute("INVOICE_LIST",invoiceList);
                      }
                      else {
                        invoiceList = (ArrayList)request.getSession().getAttribute("INVOICE_LIST");
                        if((invoiceList == null) || (invoiceList.size() == 0)){
                          invoiceList= CustomerPaymentDAO.getEditableInvoices(checkNo.trim());
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

                <tr><td colspan='5'><table id='editinvoices' class='sortable' width='100%'>
                <tr> 
                  <td  class="text-row1" width='20%'>Invoice Number</td>
                  <td  class="text-row1" width='20%'>Invoice Date</td>
                  <td  class="text-row1" align="right" width='20%'>Invoice Amount</td>
                  <td  class="text-row1" align="right" width='20%'>Invoice Balance</td>
                  <td  class="text-row1" width='20%'>Payment Amount $</td>
                </tr>
				 <%
                Map details = null;
                int tmpInvoiceId=0;
                String tmpInvoiceNumber="0";
                String tmpInvoiceDate;
                double tmpInvoiceAmt = 0.00;
                double tmpInvoiceBalance=0.00;
                double totalBalance = 0.00;
                double totalPayments = 0.00;

                for(int j=0;j<pageRecordCount;j++){
                    details = (Map)invoiceList.get(startIndex + j);
                    tmpInvoiceId = ((Integer)details.get("ID")).intValue();
                    //System.out.println("Test1");
                    tmpInvoiceNumber = (String)details.get("INVOICE_NUMBER");
                    System.out.println("Test2 " + tmpInvoiceNumber);
                    tmpInvoiceDate= (String)details.get("INVOICE_DATE");
                    tmpInvoiceAmt = ((Double)details.get("INVOICE_AMT")).doubleValue();
                            StringBuffer invFormate = new StringBuffer(""+tmpInvoiceAmt);
		    	    String suffIStr = invFormate.toString().substring(invFormate.toString().indexOf("."));
		    	    if(suffIStr.length() == 0) {
		    	    	invFormate.append("00");
		    	    } else if(suffIStr.length() == 1) {
		    		    invFormate.append("0");
		    		 } else if(suffIStr.length() == 2) {
		    		    invFormate.append("0");
		    	    } 
		    		 if(invFormate.toString().indexOf(".") + 3 < invFormate.toString().length())
		               suffIStr = invFormate.toString().substring(0,invFormate.toString().indexOf(".")+3);
		            else
		              suffIStr = invFormate.toString(); 
			    
                    tmpInvoiceBalance = ((Double)details.get("INVOICE_BAL_AMT")).doubleValue();
                    StringBuffer invBalFormate = new StringBuffer(""+tmpInvoiceBalance);
		    String subStr = invBalFormate.toString().substring(invBalFormate.toString().indexOf("."));
		    //System.out.println("Invoice Bal " + subStr);
		    if(subStr.length() == 0) {
		    	invBalFormate.append("00");
		    } else if(subStr.length() == 1) {
		    	invBalFormate.append("0");
		    } else if(subStr.length() == 2) {
		    	invBalFormate.append("0");
		    }
		         if(invBalFormate.toString().indexOf(".") + 3 < invBalFormate.toString().length())
		            subStr = invBalFormate.toString().substring(0,invBalFormate.toString().indexOf(".")+3);
		         else
		            subStr = invBalFormate.toString(); 
                    totalBalance = totalBalance + tmpInvoiceBalance;
                %>
                <tr> 
                    <input type="hidden" name="invoiceId" value="<%=""+tmpInvoiceId%>">
                    <td class="text-row2"><%=""+tmpInvoiceNumber%></td>
                    <input type="hidden" value="<%=""+tmpInvoiceNumber%>" name="invoicenum" >
                    <td class="text-row2" ><%=tmpInvoiceDate%></td>
                    <td class="text-row2" align="right">$<%=""+suffIStr%></td>
                    <td class="text-row2" align="right">$<%=""+subStr%></td>
                    <input type="hidden" value="<%=""+tmpInvoiceBalance%>" name="balance" >
                    <%
                      double payAmt = ((Double)details.get("PAYMENT")).doubleValue();
                      if(payAmt != 0) {
                        StringBuffer payFormate = new StringBuffer(""+payAmt);
                        
                        String suffStr = payFormate.toString().substring(payFormate.toString().indexOf("."));
                        System.out.println("Formate " + suffStr.length());
                        if(suffStr.length() == 0) {
                            payFormate.append("00");
                        } else if(suffStr.length() == 1) {
                            payFormate.append("0");
                        } else if(suffStr.length() == 2) {
                            payFormate.append("0");
                        }
                       // System.out.println("Pay-->" + payFormate.toString());
                        if(payFormate.toString().indexOf(".") + 3 < payFormate.toString().length())
		            		suffStr = payFormate.toString().substring(0,payFormate.toString().indexOf(".")+3);
		         		else
		            		suffStr = payFormate.toString();
		    %>
		      <td class="text-row2">
                      <input type="hidden" name="oldPayments" value="<%=""+payAmt%>">
                      <input type="text" name="payments" size="20" class="TextBox" onBlur="addEditPayments(this);" style='text-align:right'  value="<%=""+suffStr%>">
                      <input type="hidden" name="lastValue" value="<%=""+payFormate.toString()%>">
                    </td>
		    <%
  		       } else {
		     %>
		      <td class="text-row2">
                      <input type="hidden" name="oldPayments" value="0">
                      <input type="hidden" name="lastValue" value="0">
                      <input type="text" name="payments" size="20" class="TextBox" onBlur="addEditPayments(this);"  value="" style='text-align:right' >
                    </td>
                    <%
	                } 
	            %>
		   </tr>
		<%   
                     totalPayments = totalPayments + payAmt;
                    //System.out.println("TPay-->3 " + totalPayments);
                }
               // System.out.println("TPay-->1" );
                StringBuffer totBalFormate = new StringBuffer(""+ (new Double(totalBalance)).toString());
               // System.out.println("TPay-->2" );
                String subTStr = totBalFormate.toString().substring(totBalFormate.toString().indexOf("."));
	        if(subTStr.length() == 0) {
			totBalFormate.append("00");
		} else if(subTStr.length() == 1) {
			totBalFormate.append("0");
	    } else if(subTStr.length() == 2) {
              totBalFormate.append("0");
          }
	    	  if(totBalFormate.toString().indexOf(".") + 3 < totBalFormate.toString().length())
	    	     subTStr = totBalFormate.toString().substring(0,totBalFormate.toString().indexOf(".") + 3);
	    	   else
	    	     subTStr = totBalFormate.toString(); 
	    	//System.out.println("StrPay-->" + subTStr);
	    	StringBuffer totPayFormate = new StringBuffer(""+totalPayments);
		    String subTPStr = totPayFormate.toString().substring(totPayFormate.toString().indexOf("."));
			        if(subTPStr.length() == 0) {
					totPayFormate.append("00");
				} else if(subTPStr.length() == 1) {
					totPayFormate.append("0");
	    	    } else if(subTPStr.length() == 2) {
                    totPayFormate.append("0");
                }
                 if(totPayFormate.toString().indexOf(".") + 3 < totPayFormate.toString().length())
	    	     subTPStr = totPayFormate.toString().substring(0,totPayFormate.toString().indexOf(".") + 3);
	    	   else
	    	     subTPStr = totPayFormate.toString();
	    		//subTPStr = totPayFormate.toString().substring(0,totPayFormate.toString().indexOf(".")+2);
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
                              <input type="text" name="totalPayment" readonly='true' size="20" style='text-align:right' class="TextBox" value="<%=subTPStr%>">
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
                  <td align="center" class="text-row2" colspan="4"> No records found.</td>
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
					  <input type="hidden" value="Edit" name="data">
        <input type="submit" value="Submit" name="submit"  class="Field-Button" onclick="doEdit();">
        <input type="reset" value="Reset" name="reset" class="Field-Button">
       <input type="submit" value="Delete" name="delete" class="Field-Button" onClick="return confirmDelete();">
       <input type="submit" value="Cancel" name="cancel" class="Field-Button" onclick="doView();">
                    </div>
                  </td>
                </tr>
              </table>
            </td>
          </tr>
        </table></td>
    </tr>
  </table>
</form>
</body>

</html>
