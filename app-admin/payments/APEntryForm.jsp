<%@ include file="/includes/SessionChecker.jsp" %><%@ page language="java" %>
<%@ page import="java.sql.*,java.util.*,java.text.*,com.marcomet.users.security.*, com.marcomet.jdbc.*, com.marcomet.environment.*,org.apache.commons.beanutils.*;" %>
<%@ taglib uri="/WEB-INF/tld/formTagLib.tld" prefix="formtaglib" %>
<%@ taglib uri="/WEB-INF/tld/taglib.tld" prefix="taglib" %><%
if (!((RoleResolver)session.getAttribute("roles")).roleCheck("admin") ){
//        response.sendRedirect("/app-admin/AdminLogin.jsp");
 //       return;
%><%=((RoleResolver)session.getAttribute("roles")).roleCheck("admin")%><%
}
String siteHostId = ((SiteHostSettings)session.getAttribute("siteHostSettings")).getSiteHostId(); 
if(siteHostId==null){
   response.sendRedirect("/app-admin/AdminLogin.jsp");
   return;
}
String mode = request.getParameter("mode");
String message ="";
%><html> 
<head>
<meta http-equiv="Content-Language" content="en-us">
<meta http-equiv="Content-Type" content="text/html; charset=windows-1252">
<meta name="GENERATOR" content="Microsoft FrontPage 4.0">
<meta name="ProgId" content="FrontPage.Editor.Document">
<title>AP ENTRY FORM</title>
<link rel="stylesheet" type="text/css" href="css/master.css" title="Style" >
<link rel="stylesheet" type="text/css" href="/sitehosts/lms/styles/vendor_styles.css" title="Style" >
<script type="text/javascript"  src="javascripts/dataentry.js"></script>
<script type="text/javascript" src="/javascripts/jscalendar/calendar.js"></script>
<script type="text/javascript" src="/javascripts/jscalendar/lang/calendar-en.js"></script>
<script type="text/javascript" src="/javascripts/jscalendar/calendar-setup.js"></script>
<link rel="stylesheet" href="/javascripts/jscalendar/calendar-win2k-1.css" type="text/css">
<script>
function popVendorFields(el){
	var arr=el.value.split('|');
	document.forms[0].cName.value=el.options[el.selectedIndex].text
	document.forms[0].cId.value=arr[0];
	document.forms[0].companyId.value=arr[1];
	document.forms[0].contactId.value=arr[2];
}
</script>
</head>
<body class="body" onload="document.forms[0].poNo.focus();">
<form name="entryForm" method="POST" action="APAddEntry.jsp">
<table border=0><tr><td><input type="hidden" name="cName" value=""><input type="hidden" name="contactId" value=""><input type="hidden" name="companyId" value=""><input type="hidden" name="cId" value=""><input type="hidden" name="compName" value=""><input type="hidden" name="act" value="">
	<table  cellspacing="1" cellpadding="0" bgcolor="#333333">
	<tr><td valign="top" ><table border="0" cellspacing="0" cellpadding="0"><tr><td bgcolor="f3f1f1"><table border="0" cellpadding="0" cellspacing="1">
          				<tr> <td colspan="2" class="table-heading">APPLY SUBVENDOR INVOICE TO JOBS</td></tr>
                		<tr><td class="text-row2" colspan=2><b>SubVendor Invoice Information:</b></td></tr>
                		<tr><td class="text-row1" >Vendor Company</td><%
                  String sql="Select concat(v.id,'|',v.company_id,'|',c.id) as value,v.notes as text from vendors v,companies co,contacts c where  v.company_id=c.companyid and co.id=c.companyid and v.subvendor=1 and if(v.default_rep =0,1=1, v.default_rep=c.id)";
                  			%><td class="text-row2" ><formtaglib:SQLDropDownTag dropDownName="cIdChoices" sql="<%=sql%>" extraCode="class=\"text-list\" onChange=\"popVendorFields(this)\"" extraFirstOption="<option value=\"0\" selected>Select SubVendor Company</option>" /></td></tr>
                		<tr><td class="text-row1" >Vendor Invoice Number</td><td class="text-row2" ><input type="text" name="poNo" size="24" class="textbox" maxlength="10"></tr>
                		<tr><td class="text-row1" >Vendor Invoice Amount</td><td class="text-row2" >
                  $<input type="text" name="poAmt" size="24" class="textbox" maxlength="8"></tr>
                		<tr><td class="text-row1" >Invoice Date</td><td class="text-row2" ><jsp:include page="/includes/DatePicker.jsp?fieldNum=1&fieldName=txtInvDate&class=textBox&defaultDate=today" /></tr>
               			<tr><td class="text-row2" colspan=2><hr><b>Apply To Jobs:</b></td></tr>
                		<tr><td class="text-row1" >Show Jobs Posted Before</td>
                  			<td class="text-row2" ><jsp:include page="/includes/DatePicker.jsp?fieldNum=2&fieldName=txtJobDate&class=textBox&defaultDate=today" /></tr>
                		<tr><td class="text-row1" ><b>- OR-</b> Show Job Id</td><td class="text-row2" ><input type="text" name="jobId" size="24" class="textbox" maxlength="6"></tr>
                		<tr><td colspan="3" class="table-subheading" > <div align="center"><input type="submit" value=" APPLY " name="submit2" class="Field-Button" onClick="document.forms[0].submit();"><input type="reset" value=" RESET " name="cancel2" class="Field-Button">
<input type="submit" value="  EXIT   " name="submit2" class="Field-Button" onclick="doExit()"></div></td>
                		</tr>
                	</table>
            	</td></tr><%
				if(mode != null && mode.equalsIgnoreCase("repeat")) {
					message = request.getParameter("message");
			%><tr ><td colspan="2" class="text-row2" align='center'> <%=message%></td></tr><%}%>
			</table></td></tr></table>
</td><td class=subtitle></td><td></td></tr><%
	if(mode != null && mode.equalsIgnoreCase("repeat")) {
		message = request.getParameter("message");
%><tr ><td colspan="2" class="text-row2" align='center'> <%=message%></td></tr><%
				}%></table></td></tr></table></td></tr></table>
</form>
</body>
</html>
