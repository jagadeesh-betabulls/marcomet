<%@ include file="/includes/SessionChecker.jsp" %>
<%@ taglib uri="/WEB-INF/tld/formTagLib.tld" prefix="formtaglib" %>
<%@ taglib uri="/WEB-INF/tld/taglib.tld" prefix="taglib" %>
<%String companyId=session.getAttribute("companyId").toString();
String dateFrom="";
String dateTo="";
%><html>
<head>
<META HTTP-EQUIV="pragma" CONTENT="no-cache">
<META HTTP-EQUIV="Pragma-directive" CONTENT="no-cache">
<META HTTP-EQUIV="cache-directive" CONTENT="no-cache">
<title>Filters</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link rel="stylesheet" href="<%=(String)session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css">
<script language="JavaScript" src="/javascripts/mainlib.js"></script>
<script language="JavaScript">
function popHiddenDateField2(fieldName){
	var month = document.forms[0].dateMonth2[document.forms[0].dateMonth2.selectedIndex].value;
	var day = document.forms[0].dateDay2[document.forms[0].dateDay2.selectedIndex].value;
	var year = document.forms[0].dateYear2[document.forms[0].dateYear2.selectedIndex].value;
	eval("document.forms[0]."+ fieldName + ".value = '" + year + "-" + month + "-" + day+"'");
}
</script>
<link rel="stylesheet" href="/javascripts/jscalendar/calendar-win2k-1.css" type="text/css">
<script type="text/javascript" src="/javascripts/jscalendar/calendar.js"></script>
<script type="text/javascript" src="/javascripts/jscalendar/lang/calendar-en.js"></script>
<script type="text/javascript" src="/javascripts/jscalendar/calendar-setup.js"></script>
</head>
<body bgcolor="#FFFFFF" text="#000000" background="<%=(String)session.getAttribute("siteHostRoot")%>/images/back3.jpg">
<form method="post" action="/reports/vendors/invoiceHistoryForCompany.jsp">
  <p class="TITLE">Purchases: Invoice History Report Generator 
    <input type="hidden" name="companyId" value="<%=companyId%>">
  </p>
  <p></p>
  <p>&nbsp;</p><table dwcopytype="CopyTableRow" cellpadding="2">
	<tr><td class="minderHeader" style="text-align:right">&nbsp;Date From:&nbsp;&nbsp;</td>

 	<td>&nbsp;&nbsp;<input type="hidden" name="dateFrom" id="f_datefrom_d"><span class="lineitemsselected" id="show_d"></span>&nbsp;<img src="/javascripts/jscalendar/img.gif" align="absmiddle" id="f_trigger_c" style="cursor: pointer; border: 1px solid red;" title="Date selector" onmouseover="this.style.background='red';" onmouseout="this.style.background=''" />
<script type="text/javascript">
 Calendar.setup({
 inputField: "f_datefrom_d", ifFormat: "%Y-%m-%d",displayArea: "show_d",daFormat: "%m-%d-%Y", button:"f_trigger_c", align: "BR", singleClick: true}); var d=new Date();
 document.forms[0].dateFrom.value=<%=((dateFrom.equals(""))?"d.getFullYear()+'-'+(d.getMonth()+1)+'-01'":"'"+dateFrom+"'")%>; 
 document.getElementById('show_d').innerHTML=<%=((dateFrom.equals(""))?"(d.getMonth()+1)+'-01-'+d.getFullYear()":"'"+dateFrom+"'")%>;
</script></td></tr><tr><td class="minderHeader" style="text-align:right">&nbsp;Date To:&nbsp;&nbsp;</td>
<td>&nbsp;&nbsp;<input type="hidden" name="dateTo" id="f_dateto_d"><span class="lineitemsselected" id="show_d2"></span>&nbsp;<img src="/javascripts/jscalendar/img.gif" align="absmiddle" id="f_trigger_c2" style="cursor: pointer; border: 1px solid red;" title="Date selector" onmouseover="this.style.background='red';" onmouseout="this.style.background=''" />

<script type="text/javascript">
Calendar.setup({
	inputField: "f_dateto_d", ifFormat : "%Y-%m-%d", displayArea : "show_d2", daFormat : "%m-%d-%Y", button : "f_trigger_c2", align: "BR", singleClick : true });
	var d=new Date();
	document.forms[0].dateTo.value=<%=((dateTo.equals(""))?"d.getFullYear()+'-'+(d.getMonth()+1)+'-'+d.getDate()":"'"+dateTo+"'")%>; document.getElementById('show_d2').innerHTML=<%=((dateTo.equals(""))?"(d.getMonth()+1)+'-'+d.getDate()+'-'+d.getFullYear()":"'"+dateTo+"'")%>;
</script></td></tr>
    <tr> 
      <td colspan="6" class="label" height="35">&nbsp;</td>
    </tr>
    <tr> 
      <td colspan="6" class="label"> 
        <div align="center"> 
          <input type="button" value="Exit" onClick="history.go(-1)">
          <input type="button" value="Generate Report" onClick="submit()">
          <input type="reset">
        </div>
      </td>
    </tr>
  </table>
<input type="hidden" name="siteHostCompanyFromText" value="">
<input type="hidden" name="siteHostCompanyToText" value="">
<input type="hidden" name="buyerCompanyFromText" value="">
<input type="hidden" name="buyerCompanyToText" value="">
</form>
</body>
</html>
