<%@ page language="java" %> 
<%@ page import="java.util.*" %>
<%@ page import="com.vgl.payment.CustomerPaymentDAO" %>
<html> 
 
<head>
<meta http-equiv="Content-Language" content="en-us">
<meta http-equiv="Content-Type" content="text/html; charset=windows-1252">
<meta name="GENERATOR" content="Microsoft FrontPage 4.0">
<meta name="ProgId" content="FrontPage.Editor.Document">
<title>ENTRY FORM</title>
<link rel="stylesheet" type="text/css" href="css/master.css" title="Style" >
<script type="text/javascript" src="javascripts/dataentry.js">
</script>
</head>
<body class="body" onload="document.forms[0].compName.focus();">
<form name="entryForm" method="POST" action="AddEntry.jsp" onSubmit="return setCompInfo()">
<input type="hidden" name="cId" value="">
<input type="hidden" name="cName" value="">
<input type="hidden" name="act" value="">
<%
    String siteHostId = (String)request.getSession().getAttribute("siteHostId"); 
      if(siteHostId==null)
      {
        response.sendRedirect("/app-admin/AdminLogin.jsp");
        return;
       }
	Vector companyInfoMap = CustomerPaymentDAO.getCompanies();
%>	

<table width="100%" cellspacing="1" cellpadding="0" bgcolor="#333333">
  <tr>
      <td valign="top" ><table width="100%" border="0" cellspacing="0" cellpadding="0">
          <tr>
            <td bgcolor="f3f1f1"> <table width="100%" border="0" cellpadding="0" cellspacing="1">
                <tr> 
                  <td colspan="2" class="table-heading">ENTER COMPANY/INVOICE/JOB INFORMATION</td>
                </tr>
                <tr> 
                  <td class="text-row1" >Company</td>
                  <td class="text-row2" >
                    <select size="1" name="compName" class="text-list" width="28">
				    <option selected value="0">Select Company&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</option>
					<%
		Enumeration iter = companyInfoMap.elements();
		while(iter.hasMoreElements())
		{
                   String compName = (String)iter.nextElement();
                   //System.out.println("Compa=" + compName);
                   String t_compName = compName;
                   compName = compName.substring(0,compName.indexOf("##"));
                   Integer compId = new Integer(t_compName.substring(t_compName.indexOf("##") +2,t_compName.length())); 
		   //Integer compId = (Integer)iter.nextElement();
		   //String compName = (String)companyInfoMap.get(compId);
                    //String compName = (String)iter.nextElement();
                 //System.out.println("Company Name: " +compId +" " + compName);
					%>	
                      <option value="<%=""+compId.intValue()%>"><%=compName%></option>
					<%
					}
					%>
                    </select>
                  </td>
                </tr>
                <tr> 
                  <td class="text-row1" >Invoice Number</td>
                  <td class="text-row2" >
                  <input type="text" name="invoiceNo" size="24" class="textbox" maxlength="8"> 
                </tr>
		  <tr> 
                  <td class="text-row1" >Job Id</td>
                  <td class="text-row2" >
                  <input type="text" name="jobNo" size="24" class="textbox" maxlength="8">
                </tr>
		  <tr> 
                  <td class="text-row1" >Customer Number</td>
                  <td class="text-row2" >
                  <input type="text" name="custNo" size="24" class="textbox" maxlength="10">
                </tr>
		  <tr> 
                  <td class="text-row1" >Show All Invoices</td>
                  <td class="text-row2" >
                  <input type="checkbox" name="showAll" value="y">
                </tr>


                <tr> 
                  <td colspan="3" class="table-subheading" > <div align="center"> 
                      <input type="submit" value="Submit" name="submit2" class="Field-Button" onClick="return checkEntryFormData();">
					  <input type="reset" value=" Reset " name="cancel2" class="Field-Button">
<input type="submit" value="  Exit   " name="submit2" class="Field-Button" onclick="doExit()">
					  </div></td>
                </tr>
              </table>
            </td>
          </tr>
			<%
				String mode = request.getParameter("mode");
				String message ="";
				if(mode != null && mode.equalsIgnoreCase("repeat")) {
					message = request.getParameter("message");
			%>
			<tr >
            <td colspan="2" class="text-row2" align='center'> <%=message%>
            </td>
          </tr>
			<%
				}
			%>
        </table> </td>
</tr>
</table>

</form>

</body>

</html>
