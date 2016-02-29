<%if (request.getParameter("reportType")==null){%>
<%@ include file="/includes/SessionChecker.jsp" %>
<%@ page import="java.text.*,java.io.*,java.sql.*,java.util.*,com.marcomet.users.security.*, com.marcomet.jdbc.*,com.marcomet.tools.*,com.marcomet.environment.*;" %><%}%>
<%@ taglib uri="/WEB-INF/tld/formTagLib.tld" prefix="formtaglib" %>
<%@ taglib uri="/WEB-INF/tld/taglib.tld" prefix="taglib" %>
<%
SimpleDateFormat df = new SimpleDateFormat("MM/dd/yyyy");
String siteHostT = session.getAttribute("siteHostRoot").toString();
String siteHost = siteHostT.substring(11,siteHostT.length());
String siteSQL="SELECT distinct sh.id 'value', concat(sh.site_name,' [',sh.id,']') 'text' FROM site_hosts sh where sh.active=1 ORDER BY site_name";
String vendorSQL="SELECT distinct v.id 'value', concat(v.notes,' [',v.id,']') 'text' FROM vendors v where v.subvendor=1 ORDER BY v.notes";
String rootProdSQL="SELECT distinct root_prod_code 'value', concat(description,'[',root_prod_code,']') 'text' FROM product_roots where active=1 ORDER BY root_prod_code";
String rootGroupSQL="SELECT distinct root_group 'value', root_group 'text' FROM product_roots where active=1 ORDER BY root_group";
String buildSQL="SELECT distinct id 'value', concat(left(description,40),'...','[',id,']') 'text' FROM lu_build_types where description<>'' ORDER BY sequence";
String brandSQL="SELECT distinct p.brand_code 'value', concat(p.brand_code,' [ Company ID ',p.company_id,']') 'text' from products p,brands b where p.brand_code=b.brand_code and b.active=1 and p.status_id<>3 and p.status_id<>4 and p.brand_code is not null and p.brand_code<>'' ORDER BY p.brand_code";
String releaseSQL="SELECT distinct p.release 'value', p.release 'text' from products p where p.status_id<>3 and p.status_id<>4 and p.release is not null and p.release <>'' ORDER BY p.release";

String fDateFrom=((request.getParameter("dateFrom")==null)?"":request.getParameter("dateFrom"));
String fDateTo=((request.getParameter("dateTo")==null)?"":request.getParameter("dateTo"));
String noLines="yes";

if (request.getParameter("reportType")==null){
	%><html>
	<head>
	<META HTTP-EQUIV="pragma" CONTENT="no-cache">
	<META HTTP-EQUIV="Pragma-directive" CONTENT="no-cache">
	<META HTTP-EQUIV="cache-directive" CONTENT="no-cache">
	<title><%=((request.getParameter("reportTitle")==null)?"Accrual Reports":request.getParameter("reportTitle"))%></title>
	<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
	<link rel="stylesheet" href="<%=(String)session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css">
	<link rel="stylesheet" href="/javascripts/jscalendar/calendar-win2k-1.css" type="text/css">
	<script type="text/javascript" src="/javascripts/jscalendar/calendar.js"></script>
	<script type="text/javascript" src="/javascripts/jscalendar/lang/calendar-en.js"></script>
	<script type="text/javascript" src="/javascripts/jscalendar/calendar-setup.js"></script>
	<script language="JavaScript" src="/javascripts/mainlib.js"></script>
	<script language="JavaScript">
	</script>
	<style>div#filters{margin: 0px 20px 0px 20px;display: none;}</style>
	</head>
	<body bgcolor="#FFFFFF" text="#000000" background="<%=(String)session.getAttribute("siteHostRoot")%>/images/back3.jpg"><%
}
%><p class='Title' ><%=((request.getParameter("reportTitle")==null)?"Accrual Reports":request.getParameter("reportTitle"))%> as of <%=df.format(new java.util.Date())%></p>
<span id='loading'><div align='center'> L O A D I N G . . . <br><br><img src='/images/loading.gif'><br></div></span><div id='filtertoggle' ></div><div id='filters'>
<form method="post" action="<%=((request.getParameter("reportType")==null)?"/app-admin/payments/reports/AccruedBalanceReport.jsp":request.getParameter("reportType"))%>" >
  <p>&nbsp;</p>
  <table dwcopytype="CopyTableRow"><tr> 
      <td class="tableheader">Report Type:</td>
      <td><select name="reportType" onChange='document.forms[0].action=this.value' >
      <OPTION value="/app-admin/payments/reports/AccruedBalanceReport.jsp" <%=((request.getParameter("reportType")==null || request.getParameter("reportType").equals("/app-admin/payments/reports/AccruedBalanceReport.jsp"))?"SELECTED":"")%> >Accrued Balance Report</OPTION>
      <OPTION value="/app-admin/payments/reports/AccrualXtionReport.jsp" onChange='document.forms[0].action=this.value' <%=((request.getParameter("reportType")!=null && request.getParameter("reportType").equals("/app-admin/payments/reports/AccrualXtionReport.jsp"))?"SELECTED":"")%> >Job Accrual Transaction Report (Original PO)</OPTION>
      <OPTION value="/app-admin/payments/reports/AccrualAdjustmentsXtionReport.jsp" onChange='document.forms[0].action=this.value' <%=((request.getParameter("reportType")!=null && request.getParameter("reportType").equals("/app-admin/payments/reports/AccrualAdjustmentsXtionReport.jsp"))?"SELECTED":"")%> >Job Accrual Adjustments Transaction Report (Adjustments to original PO)</OPTION>
      <OPTION value="/app-admin/payments/reports/ShipAccrualXtionReport_2.jsp" onChange='document.forms[0].action=this.value' <%=((request.getParameter("reportType")!=null && request.getParameter("reportType").equals("/app-admin/payments/reports/ShipAccrualXtionReport_2.jsp"))?"SELECTED":"")%> >Ship Accrual Transaction Report</OPTION>
      <OPTION value="/app-admin/payments/reports/ShipAccrualAdjustmentsXtionReport.jsp" onChange='document.forms[0].action=this.value' <%=((request.getParameter("reportType")!=null && request.getParameter("reportType").equals("/app-admin/payments/reports/ShipAccrualAdjustmentsXtionReport.jsp"))?"SELECTED":"")%> >Ship Accrual Adjustments Transaction Report</OPTION>
      <OPTION value="/app-admin/payments/reports/APAppliedXtionReport.jsp" onChange='document.forms[0].action=this.value' <%=((request.getParameter("reportType")!=null && request.getParameter("reportType").equals("/app-admin/payments/reports/APAppliedXtionReport.jsp"))?"SELECTED":"")%> >AP Applied Transaction Report</OPTION>
      <OPTION value="/app-admin/payments/reports/AccruedInventoryXtionReport.jsp" onChange='document.forms[0].action=this.value' <%=((request.getParameter("reportType")!=null && request.getParameter("reportType").equals("/app-admin/payments/reports/AccruedInventoryXtionReport.jsp"))?"SELECTED":"")%> >Accrued Inventory Cost Report</OPTION>
      </select></td><%//      <!--<OPTION value="/app-admin/payments/reports/AccruedJobCostsReport.jsp" onChange='document.forms[0].action=this.value'>Accrued Job/Ship Costs Transaction Report</OPTION>-->%></tr>
    <tr> 
      <td class="tableheader">Site:</td>
      <td><formtaglib:SQLDropDownTag dropDownName="siteId" sql="<%=siteSQL%>" extraCode="onChange=\"document.forms[0].siteText.value=this.options[this.selectedIndex].text\"" selected="<%=((request.getParameter("siteId")==null)?"":request.getParameter("siteId"))%>" extraFirstOption="<option value=\"\" Selected>All</option>" /></td>
    </tr>
    <tr> 
      <td class="tableheader">Vendor:</td>
      <td><formtaglib:SQLDropDownTag dropDownName="vendorId" sql="<%=vendorSQL%>" extraCode="onChange=\"document.forms[0].vendorCompanyText.value=this.options[this.selectedIndex].text\"" selected="<%=((request.getParameter("vendorId")==null)?"":request.getParameter("vendorId"))%>" extraFirstOption="<option value=\"\" Selected>All</option>" /></td>
    </tr>
    <tr> 
      <td class="tableheader">Root Product:</td>
      <td class=lineitems><formtaglib:SQLDropDownTag dropDownName="rootProdCode" selected="<%=((request.getParameter("rootProdCode")==null)?"":request.getParameter("rootProdCode"))%>" sql="<%=rootProdSQL%>" extraCode="" extraFirstOption="<option value=\"\" Selected>All</option>" /> </td>
    </tr>
    <tr>
      <td class="tableheader">Root Group:</td>
      <td class=lineitems><formtaglib:SQLDropDownTag dropDownName="rootGroup" selected="<%=((request.getParameter("rootGroup")==null)?"":request.getParameter("rootGroup"))%>" sql="<%=rootGroupSQL%>" extraCode="" extraFirstOption="<option value=\"\" Selected>All</option>" /></td>
    </tr>
     <tr> 
      <td class="tableheader">Build Type:</td>
      <td class=lineitems><formtaglib:SQLDropDownTag dropDownName="buildType" selected="<%=((request.getParameter("buildType")==null)?"":request.getParameter("buildType"))%>" sql="<%=buildSQL%>" extraCode="" extraFirstOption="<option value=\"\" Selected>All</option>" /></td>
    </tr>
    <tr> 
      <td class="tableheader">Additional<br>Parameters</td>
      <td class=lineitems><input type='checkbox' name="preaccrual" value='true' <%=((request.getParameter("preaccrual")!=null && request.getParameter("preaccrual").equals("true") ) ?"Checked":"")%> >Include Pre-Accrual Data<br><input type='checkbox' name="openbalances" value='true' <%=((request.getParameter("openbalances")==null || request.getParameter("openbalances").equals("true") ) ?"Checked":"")%>>Show Open Balances Only (where applicable)<br><input type='checkbox' name="totalsonly" value='true' <%=((request.getParameter("totalsonly")!=null && request.getParameter("totalsonly").equals("true") ) ?"Checked":"")%> >Show Total Lines Only (where applicable)<br><input type='checkbox' name="excel" value='true' <%=((request.getParameter("excel")!=null && request.getParameter("excel").equals("true") ) ?"Checked":"")%> >Export to Excel<br>
     <br> <div class=lineitems>Subtotal Report:<br><input type=radio name='subtotal' value='None' <%=((request.getParameter("subtotal")==null || request.getParameter("subtotal").equals("None") ) ?"Checked":"")%> >No Subtotals <input type=radio name='subtotal' value='v' <%=((request.getParameter("subtotal")!=null && request.getParameter("subtotal").equals("v") ) ?"Checked":"")%>>By Vendor <input type=radio name='subtotal' value='m' <%=((request.getParameter("subtotal")!=null && request.getParameter("subtotal").equals("m") ) ?"Checked":"")%>>By Accrual Month</div>
      </td>
    </tr>
    <tr> 
      <td class="tableheader">Accrued Date From:</td>
      <td class=lineitems>&nbsp;&nbsp;<input type="hidden" name="dateFrom" id="f_datefrom_d"><span class="lineitemsselected" id="show_d"></span>&nbsp;<img src="/javascripts/jscalendar/img.gif" align="absmiddle" id="f_trigger_c"
				     style="cursor: pointer; border: 1px solid red;"
				     title="Date selector"
				     onmouseover="this.style.background='red';"
				     onmouseout="this.style.background=''" />
					<script type="text/javascript">
 Calendar.setup({
 inputField: "f_datefrom_d", ifFormat: "%Y-%m-%d",displayArea: "show_d",daFormat: "%m-%d-%Y", button:"f_trigger_c", align: "BR", singleClick: true}); 
 	var d=new Date();
 	var dMonth=(d.getMonth()+1)+''; dMonth=((dMonth.length==2)?dMonth:'0'+dMonth);
 	document.forms[0].dateFrom.value=<%=((fDateFrom.equals(""))?"d.getFullYear()+'-'+dMonth+'-01'":"'"+fDateFrom+"'")%>; 
 	document.getElementById('show_d').innerHTML=<%=((fDateFrom.equals(""))?"(dMonth)+'-01-'+d.getFullYear()":"'"+fDateFrom.substring(5,7)+"-"+fDateFrom.substring(8,10)+"-"+fDateFrom.substring(0,4)+"'")%>;
</script></td>
    </tr>
    <tr> 
      <td class="tableheader">As Of Date/<br>&nbsp;&nbsp;&nbsp;Accrued Date To:</td>
      <td class=lineitems>&nbsp;&nbsp;<input type="hidden" name="dateTo" id="f_dateto_d"><span class="lineitemsselected" id="show_d2"></span>&nbsp;<img src="/javascripts/jscalendar/img.gif" align="absmiddle" id="f_trigger_c2"
				     style="cursor: pointer; border: 1px solid red;"
				     title="Date selector"
				     onmouseover="this.style.background='red';"
				     onmouseout="this.style.background=''" />
<script type="text/javascript">
Calendar.setup({
	inputField: "f_dateto_d", ifFormat : "%Y-%m-%d", displayArea : "show_d2", daFormat : "%m-%d-%Y", button : "f_trigger_c2", align: "BR", singleClick : true });
	var d=new Date();
	var dMonth=(d.getMonth()+1)+''; dMonth=((dMonth.length==2)?dMonth:'0'+dMonth);
	var dDay=(d.getDate())+''; dDay=((dDay.length==2)?dDay:'0'+dDay);
	document.forms[0].dateTo.value=<%=((fDateTo.equals(""))?"d.getFullYear()+'-'+dMonth+'-'+ dDay ":"'"+fDateTo+"'")%>; document.getElementById('show_d2').innerHTML=<%=((fDateTo.equals(""))?"(dMonth)+'-'+dDay+'-'+d.getFullYear()":"'"+fDateTo.substring(5,7)+"-"+fDateTo.substring(8,10)+"-"+fDateTo.substring(0,4)+"'")%>;
</script></td>
    </tr>
    <tr> 
      <td colspan="6" class="label" height="35">&nbsp;</td>
    </tr>
    <tr> 
      <td colspan="6" class="label"> 
        <div align="center"> 
          <input type="button" value="Cancel" onClick="history.go(-1)">
          <input type="button" value="Generate Report" onClick="submit()">
          <input type="reset">
        </div>
      </td>
    </tr>
  </table>
<input type="hidden" name="vendorCompanyText" value="<%=((request.getParameter("vendorCompanyText")==null)?"All":request.getParameter("vendorCompanyText"))%>">
<input type="hidden" name="siteText" value="<%=((request.getParameter("siteText")==null)?"All":request.getParameter("siteText"))%>">
</form><hr></div>
<%if (request.getParameter("reportType")==null){%><script>
	document.getElementById('loading').innerHTML='';
	function toggleLayer(whichLayer){
		var style2 = document.getElementById(whichLayer).style;
		style2.display = style2.display=="block"? "none":"block";
	}
	function togglefilters(){
		var style2 = document.getElementById('filters').style;
		if (style2.display=="block"){
			document.getElementById('filtertoggle').innerHTML='<div align=right><div class=menuLink><a href="javascript:togglefilters()">+ Show Filters</a></div></div>';
		}else{
			document.getElementById('filtertoggle').innerHTML=<%=((noLines.equals("yes"))?"''":"'<div class=menuLink><a href=\"javascript:togglefilters()\">&raquo; Hide Filters</a></div>'")%>;
		}
		toggleLayer('filters');
	}
	<%=((noLines.equals("yes"))?"togglefilters();":"document.getElementById('filtertoggle').innerHTML='<div align=right><div class=menuLink><a href=\"javascript:togglefilters()\">+ Show Filters</a></div></div>'")%>
	</script>
	</body></html><%}%>