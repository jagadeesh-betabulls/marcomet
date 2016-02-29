


<%@ page language="java" %>


<%@ page import="com.vgl.payment.CustomerPaymentDAO" %>


<%@ page import="java.util.*" %>





<html>





<head>


<meta http-equiv="Content-Language" content="en-us">


<meta http-equiv="Content-Type" content="text/html; charset=windows-1252">


<meta name="GENERATOR" content="Microsoft FrontPage 4.0">


<meta name="ProgId" content="FrontPage.Editor.Document">


<title>CHECK LIST</title>


<link rel="stylesheet" type="text/css" href="css/master.css" title="Style" >


<link rel="stylesheet" type="text/css" href="css/rfnet.css">


<script type="text/javascript" src="javascripts/datetimepicker.js"></script>


<script type="text/javascript"  src="javascripts/dataentry.js"></script>


<script type="text/javascript" src="javascripts/sorttable.js"></script>





</head>





<body class="body" onload="document.forms[0].compName.focus();">


<form name="viewListForm" method="POST" action="ViewListFormFromQuick.jsp" onSubmit="return setCompInfo()">


<input type="hidden" name="cId" value="">


<input type="hidden" name="cName" value="">


<input type="hidden" name="act" value="">


<%


    String __act = (String)request.getParameter("act");


     System.out.println("Act " + __act);


    if(__act!=null && __act.equals("exit")){


      response.sendRedirect("/reports/vendors/index.jsp");


      System.out.println("In view list form exit" + __act);


     return;


     }


        String siteHostId = (String)request.getSession().getAttribute("siteHostId");

//	commented out by CSA to eliminate secondary login

//        if(siteHostId==null)


//        {


//          response.sendRedirect("/app-admin/AdminLogin.jsp");


//          return;


//         } 


	String callBy = request.getParameter("call");


	String cId = request.getParameter("cId");


	//if((cId == null) || (cId.trim().length()==0)){


	//  response.sendRedirect("EntryForm.jsp");


      //return;


    //}


   if(cId == null)


     cId="0"; 


    String invoiceNo = null;


	String checkNumber = null;


	String checkDateFrom = null;


	String checkDateTo = null;


	Vector companyInfoMap = CustomerPaymentDAO.getCompanies();


	if((callBy!=null) && (callBy.equalsIgnoreCase("view"))){


		invoiceNo = request.getParameter("InvoiceNo");


		checkNumber = request.getParameter("ChequeNumber");


		checkDateFrom = request.getParameter("checkDateFrom");


		checkDateTo = request.getParameter("checkDateTo");


	}


	if(invoiceNo == null) {


		invoiceNo ="";


	}


	if(checkNumber == null) {


		checkNumber ="";


	}


	if(checkDateFrom == null) {


		checkDateFrom ="";


	}


	if(checkDateTo == null) {


		checkDateTo ="";


	}


%>	





<table width="100%" cellspacing="1" cellpadding="0" bgcolor="#333333">


  <tr>


    <td valign="top" >


      <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#F3F1F1">


        <tr>


          <td >


            <table width="100%" border="0" cellpadding="0" cellspacing="1">


              <tr> 


                <td width="100%" colspan="4" class="table-heading"> VIEW CUSTOMER PAYMENT</td>


              </tr>


              <tr> 


                <td width=42% class="text-row1" >Company</td>


                <td  colspan="3" class="text-row2" >


                  <select size="1" name="compName" class="Select-List">


                  <%


                  if(Integer.parseInt(cId.trim()) == 0) {


                  %>


                    <option selected value="0">-- Select Company --&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</option>


                  <%


                  }


                  else{


                  %>


                    <option value="0">-- Select Company --</option>


                  <%


                  }


                  Enumeration iter = companyInfoMap.elements();


                  int cIdValue = Integer.parseInt(cId.trim());


                  while(iter.hasMoreElements())


		  {


                   // Integer compId = (Integer)iter.nextElement();


                   String compName = (String)iter.nextElement();


                   String t_compName = compName;


		   compName = compName.substring(0,compName.indexOf("##"));


Integer compId = new Integer(t_compName.substring(t_compName.indexOf("##") +2,t_compName.length()));


                   if(cId.equals("0"))


                      cId = compId.toString();


                    //String compName = (String)companyInfoMap.get(compId);


                    if((cIdValue != 0)&&(compId.intValue() == cIdValue)) {                    	                    	


                  %>


                      <option selected value="<%=cId%>"><%=compName%></option>


                  <%


                    } else {


                    	System.out.println("Comp Name :" + compName);


                  %>	


                      <option value="<%=""+compId.intValue()%>"><%=compName%></option>


                  <%


                    }


                  }


                  %>


                  </select>


                </td>


              </tr>


              <tr> 


                <td  class="text-row1">Invoice Number</td>


                <td  colspan="3" class="text-row2" > 


                  <input type="text" name="InvoiceNo" value="" size="24" maxlength="8" class="TextBox" >


                </td>


              </tr>


              <tr> 


                <td  class="text-row1">Check Number</td>


                <td  colspan="4" class="text-row2" >


                  <input type="text" name="ChequeNumber" value="" size="24"  maxlength="32" class="TextBox" >


                </td>


              </tr>


              <tr> 


                <td  class="text-row1" >Check Date From [mm-dd-yyyy]  </td>


                <td colspan="3" class="text-row2">


                  <input type="text" id='checkDateFrom' name="checkDateFrom" value=""  size="24" class="textBox">


                  <a href="javascript:NewCal('checkDateFrom','mmddyyyy',false,24)">


                    <img id="date1" src="images/cal.gif" width="16" height="16" border="0" alt="Pick a date">


                  </a>


                </td>


              </tr>


              <tr> 


                <td  class="text-row1">Check Date To [mm-dd-yyyy] </td>


                <td  colspan="3" class="text-row2">


                  <input type="text" id='checkDateTo' name="checkDateTo" value=""  size="24" class="textBox">


                  <a href="javascript:NewCal('checkDateTo','mmddyyyy',false,24)">


                    <img id="date2" src="images/cal.gif" width="16" height="16" border="0" alt="Pick a date">


                  </a>


                </td>


              </tr>


              <tr> 


                <td  colspan="4" align="left" class="table-subheading"> 


                  <div align="center">


                    <input type="submit" value="Submit" name="submit" class="Field-Button" onClick="return checkViewFormData();">


                    <input type="reset" value=" Reset " name="cancel" class="Field-Button">


                   <input type="submit" value="  Exit   " name="exit" class="Field-Button" onclick="doExit()">


                    <input type="hidden" value="view" name="call">


                  </div>


                </td>


              </tr>


              <tr> 


                <td  align="left" colspan="4" class="table-subheading" > 


                  <!--<table width="100%" border="0" cellpadding="0" cellspacing="1" >


                    <tr> 


                    <td colspan="4" align="left" class="table-subheading"> -->


                        <table width="100%" border="0" cellspacing="0" cellpadding="0" >


                    <%


                      System.out.println("TYest");


                      String currentPage = request.getParameter("CURRENT_PAGE");


                      String gotoNext = request.getParameter("NEXT");


                      int curPage = 1;


                      int counter = 10;


                      


                      if(!((currentPage ==null) || (currentPage.length()==0))){


                        curPage = Integer.parseInt(currentPage.trim());


                      }





                      StringBuffer fromDateBuffer = new StringBuffer();


                      String tmpFromDate = checkDateFrom.trim();


                      if(tmpFromDate.length()>0){


                        StringTokenizer fromDateTokenizer = new StringTokenizer(tmpFromDate, "-");


                        String month1 = fromDateTokenizer.nextToken();


                        String day1 = fromDateTokenizer.nextToken();


                        String year1 = fromDateTokenizer.nextToken();


                        fromDateBuffer.append(year1);


                        fromDateBuffer.append("-");


                        fromDateBuffer.append(month1);


                        fromDateBuffer.append("-");


                        fromDateBuffer.append(day1);


                      } 





                      StringBuffer toDateBuffer = new StringBuffer();


                      String tmpToDate = checkDateTo.trim();


                      if(tmpToDate.length()>0){


                        StringTokenizer toDateTokenizer = new StringTokenizer(tmpToDate, "-");


                        String month2 = toDateTokenizer.nextToken();


                        String day2 = toDateTokenizer.nextToken();


                        String year2 = toDateTokenizer.nextToken();


                        toDateBuffer.append(year2);


                        toDateBuffer.append("-");


                        toDateBuffer.append(month2);


                        toDateBuffer.append("-");


                        toDateBuffer.append(day2);


                      }





                      ArrayList checkList = null;


                     System.out.println("CID " + cId);


                      if(gotoNext == null){


                      	System.out.println("GOTONEXT = null " );


                        checkList= CustomerPaymentDAO.getCheques(cId.trim(), invoiceNo.trim(), checkNumber.trim(),fromDateBuffer.toString(), toDateBuffer.toString());


                        System.out.println("GOTONEXT = 1 " );


                        request.getSession().setAttribute("CHECK_LIST",checkList);


                        System.out.println("creating again !!!!!!!!");


                      }


                      else {


                      	System.out.println("CID 1");


                        checkList = (ArrayList)request.getSession().getAttribute("CHECK_LIST");


                        if((checkList == null) || (checkList.size() == 0)){


                          System.out.println("CID 2");


                          checkList= CustomerPaymentDAO.getCheques(cId.trim(), invoiceNo.trim(), checkNumber.trim(),fromDateBuffer.toString(), toDateBuffer.toString());


                          request.getSession().setAttribute("CHECK_LIST",checkList);


                          System.out.println("getting from session !!!!!!!!");


                        }


                      }


                       System.out.println("CID 3");


                      int recordCount = checkList.size();


                      int startIndex = (curPage - 1) * counter; 


                      int pageRecordCount = 0;





                      int firstPage=1;


                      int lastPage=1;


                      if((recordCount%counter) == 0){


                        lastPage=recordCount/counter;


                      }


                      else{


                        lastPage=recordCount/counter + 1;


                      }





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


                        if(recordCount ==0){


                          pageRecordCount = 0;


                        }


                        else if(recordCount%counter > 0){


                          pageRecordCount = recordCount%counter;


                        }


                        else{


                          pageRecordCount = counter;


                        }


                      }


                      else {


                        pageRecordCount = (recordCount/counter)>0?counter:(recordCount%counter);


                      }


                    %>


                    <tr>


                      <%


                        if(curPage == firstPage) {


                      %>


                      <td width="3%" class="textlb" align="left" color='#ffffff'>First </td>


                      <td width="3%" class="textlb" align="left" color='#ffffff'>&nbsp;Prev</td>


                      <%


                      } else{


                      	System.out.println("curPage : "+ curPage + " firstPage : "+ firstPage);


                      %> 


                      <td width="3%" class="textlb" align="left">


                        <a  class="textlb" href="ViewListFormFromQuick.jsp?NEXT=First&CURRENT_PAGE=<%=firstPage%>&call=view&cId=<%=cId%>" onClick='return setCompInfo()' >First </a>


                      </td>


					  <td width="3%" class="textlb" align="left">


                        <a  class="textlb" href="ViewListFormFromQuick.jsp?NEXT=Prev&CURRENT_PAGE=<%=prevPage%>&call=view&cId=<%=cId%>" onClick='return setCompInfo()' >Prev </a>


                      </td>


                      <%


                        }


                      %>


                      <td width="88%" class="text">


                        <div align="center">


                          <a class="textpg"><%=curPage%></a>


                        </div>


                      </td>


                      <%


                      if(recordCount == 0) {


		       	lastPage = 1;


                      }


                      if(curPage == lastPage) {


                      %>


                      <td width="3%" class="textlb" align="right">Next </td>


                      <td width="3%" class="textlb" align="right">Last </td>


                      <%


                      } else{


                      	System.out.println("curPage : "+ curPage + " lastPage : "+ lastPage);


                      %> 


                      <td width="3%" class="textlb" align="right">


                        <a class="textlb" href="ViewListFormFromQuick.jsp?NEXT=Next&CURRENT_PAGE=<%=nextPage%>&call=view&cId=<%=cId%>" onClick='return setCompInfo()'>Next </a> 


                      </td>


                      <td width="3%" class="textlb" align="right">


                        <a  class="textlb" href="ViewListFormFromQuick.jsp?NEXT=Last&CURRENT_PAGE=<%=lastPage%>&call=view&cId=<%=cId%>" onClick='return setCompInfo()'>Last </a>


                      </td>


                      <%


                      }


                      %>


                    </tr>


                  </table>


                </td>


              </tr>


              <tr>


                <td colspan='4'>


                  <table id='cheques' class='sortable' width='100%'>


                    <tr>


                      <td align="left" class="text-row1" >Check No</td>


                      <td  align="left" class="text-row1">Check Date [mm-dd-yyyy]</td>


                      <td  align="right" class="text-row1">Check Amount</td>


                      <td  align="left" class="text-row1">Deposit Date [mm-dd-yyyy]</td>


                    </tr>


                    <% 


                    for(int ii=0; ii<pageRecordCount; ii++) {


                      Map checkInfo = (HashMap)checkList.get(startIndex + ii);


                      String compId = (String)checkInfo.get("COMP_ID");


                      String compName = (String)checkInfo.get("COMP_NAME");


                      String checkNo = (String)checkInfo.get("CHECK_NUMBER");


                      String checkDate = (String)checkInfo.get("CHECK_DATE");


                      String checkAmt = (String)checkInfo.get("CHECK_AMOUNT");


                      String depositDate = (String)checkInfo.get("DEPOSIT_DATE");


                    %>


                  <tr>


                    <td align="left" class="text-row2" >


                      <a href="EditFormFromQuick.jsp?cId=<%=compId%>&cName=<%=compName%>&checkNo=<%=checkNo%>&checkDate=<%=checkDate%>&checkAmt=<%=checkAmt%>&depositDate=<%=depositDate%>"><%=checkNo%></a>


                    </td>


                    <td  align="left" class="text-row2"><%=checkDate%></td>


                    <td align="right" class="text-row2" >$<%=checkAmt%></td>


                    <td  align="left" class="text-row2"><%=depositDate%></td>


                  </tr>


                  <%


                  }


                  %>


                </table>


              </td>


            </tr>





            <%


            if(recordCount == 0){


            %>


            <tr> 


              <td align="center" class="text-row2" colspan="4"> No records found.</td>


            </tr>


            <%


            }


            startIndex = 0;


            %>


          </table>


        </td>


      </tr>


    </table>


  </td>


</tr>


</table>





</form>





</body>





</html>


