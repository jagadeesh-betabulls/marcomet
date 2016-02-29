

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

</head>



<body onload="if(document.forms[0].payments[0]==null){document.forms[0].payments.focus();} else { document.forms[0].payments[0].focus();}" >

<form method="POST" name="editEntry" action="SubmitForm.jsp" onSubmit="return checkEditFormData(); return setCompInfo();">

<input type="hidden" name="act" value="">

<%

    String siteHostId = (String)request.getSession().getAttribute("siteHostId");

    if(siteHostId==null)

    {

      response.sendRedirect("/app-admin/AdminLogin.jsp");

      return;

    }

    String compId = request.getParameter("cId");

	if((compId == null) || (compId.trim().length()==0)){

	  response.sendRedirect("EntryForm.jsp");

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

                  <td  class="text-row2"><input type="hidden" name="txtCheckNumber" value="<%=checkNo%>"><%=checkNo%>

				  </td>

                  <td  class="text-row1">Check Amount</td>

                  <td  class="text-row2">$<%=checkAmt%>

                    <input type="hidden" name="txtCheckAmt" value="<%=checkAmt%>">

				  </td>

                </tr>

                <tr> 

                  <td   class="text-row1">Check Date</td>

                  <td  class="text-row2" ><%=checkDate%>

				  </td>

                  <td  class="text-row1">Deposit Date</td>

                  <td  class="text-row2"><%=depositDate%>

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

                int tmpInvoiceNumber=0;

                String tmpInvoiceDate;

                double tmpInvoiceAmt = 0.00;

                double tmpInvoiceBalance=0.00;

                double totalBalance = 0.00;

                double totalPayments = 0.00;



                for(int j=0;j<pageRecordCount;j++){

                    details = (Map)invoiceList.get(startIndex + j);

                    tmpInvoiceId = ((Integer)details.get("ID")).intValue();

                    tmpInvoiceNumber = ((Integer)details.get("INVOICE_NUMBER")).intValue();

                    tmpInvoiceDate= (String)details.get("INVOICE_DATE");

                    tmpInvoiceAmt = ((Double)details.get("INVOICE_AMT")).doubleValue();

                            StringBuffer invFormate = new StringBuffer(""+tmpInvoiceAmt);

		    	    String suffIStr = invFormate.toString().substring(invFormate.toString().indexOf(".")+1);

		    	    if(suffIStr.length() == 0) {

		    	    	invFormate.append("00");

		    	    } else if(suffIStr.length() == 1) {

		    		invFormate.append("0");

			    }

                    tmpInvoiceBalance = ((Double)details.get("INVOICE_BAL_AMT")).doubleValue();

                    StringBuffer invBalFormate = new StringBuffer(""+tmpInvoiceBalance);

		    String subStr = invBalFormate.toString().substring(invBalFormate.toString().indexOf(".")+1);

		    if(subStr.length() == 0) {

		    	invBalFormate.append("00");

		    } else if(subStr.length() == 1) {

		    	invBalFormate.append("0");

		    }

                    totalBalance = totalBalance + tmpInvoiceBalance;

                %>

                <tr> 

                    <input type="hidden" name="invoiceId" value="<%=""+tmpInvoiceId%>">

                    <td class="text-row2"><%=""+tmpInvoiceNumber%></td>

                    <input type="hidden" value="<%=""+tmpInvoiceNumber%>" name="invoicenum" >

                    <td class="text-row2" ><%=tmpInvoiceDate%></td>

                    <td class="text-row2" align="right">$<%=""+invFormate.toString()%></td>

                    <td class="text-row2" align="right">$<%=""+invBalFormate.toString()%></td>

                    <input type="hidden" value="<%=""+tmpInvoiceBalance%>" name="balance" >

                    <%

                      double payAmt = ((Double)details.get("PAYMENT")).doubleValue();

                      if(payAmt != 0) {

                        StringBuffer payFormate = new StringBuffer(""+payAmt);

                        String suffStr = payFormate.toString().substring(payFormate.toString().indexOf(".")+1);

                        if(suffStr.length() == 0) {

                            payFormate.append("00");

                        } else if(suffStr.length() == 1) {

                            payFormate.append("0");

                        }

		    %>

		      <td class="text-row2">

                      <input type="hidden" name="oldPayments" value="<%=""+payAmt%>">

                      <input type="text" name="payments" size="20" class="TextBox" onBlur="addEditPayments(this);" style='text-align:right'  value="<%=""+payFormate.toString()%>">

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

             

                }

                StringBuffer totBalFormate = new StringBuffer(""+totalBalance);

                String subTStr = totBalFormate.toString().substring(totBalFormate.toString().indexOf(".")+1);

	        if(subTStr.length() == 0) {

			totBalFormate.append("00");

		} else if(subTStr.length() == 1) {

			totBalFormate.append("0");

	    	}

	    	

	    	StringBuffer totPayFormate = new StringBuffer(""+totalPayments);

		String subTPStr = totPayFormate.toString().substring(totPayFormate.toString().indexOf(".")+1);

			        if(subTPStr.length() == 0) {

					totPayFormate.append("00");

				} else if(subTPStr.length() == 1) {

					totPayFormate.append("0");

	    	}

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

                              <td class="text-row1" align='right' width='20%'>$ <%=totBalFormate.toString()%></td>

                              <td class="text-row1" width='20%'>

                              <input type="text" name="totalPayment" readonly='true' size="20" style='text-align:right' class="TextBox" value="<%=totPayFormate.toString()%>">

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

