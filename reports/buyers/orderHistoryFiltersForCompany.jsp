
<%@ include file="/includes/SessionChecker.jsp" %>
<%@ taglib uri="/WEB-INF/tld/formTagLib.tld" prefix="formtaglib" %>
<%@ taglib uri="/WEB-INF/tld/taglib.tld" prefix="taglib" %>
<%String companyId=session.getAttribute("companyId").toString();
%>
<html>
<head>
<META HTTP-EQUIV="pragma" CONTENT="no-cache">
<META HTTP-EQUIV="Pragma-directive" CONTENT="no-cache">
<META HTTP-EQUIV="cache-directive" CONTENT="no-cache">
<title>Filters</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link rel="stylesheet" href="<%=(String)session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css">
</head>
<script language="JavaScript" src="/javascripts/mainlib.js"></script>
<script language="JavaScript">
function popHiddenDateField2(fieldName){
	var month = document.forms[0].dateMonth2[document.forms[0].dateMonth2.selectedIndex].value;
	var day = document.forms[0].dateDay2[document.forms[0].dateDay2.selectedIndex].value;
	var year = document.forms[0].dateYear2[document.forms[0].dateYear2.selectedIndex].value;
	eval("document.forms[0]."+ fieldName + ".value = '" + year + "-" + month + "-" + day+"'");
}
</script>
<body bgcolor="#FFFFFF" text="#000000" background="<%=(String)session.getAttribute("siteHostRoot")%>/images/back3.jpg">
<form method="post" action="/reports/buyers/orderHistory.jsp">
  <p class="TITLE">Order History Report Generator 
    <input type="hidden" name="companyId" value="<%=companyId%>">
  </p>
  <p></p>
  <p>&nbsp;</p><table dwcopytype="CopyTableRow" width="100%">
    <tr> 
      <td class="label">By:</td>
      <td> 
        <select name="reportType"  >
          <option value="1">By Date</option>
          <option value="2">By Root Product</option>
        </select>
      </td>
    </tr>
    <tr> 
      <td class="label">Date From:</td>
      <td><formtaglib:DropDownDateTag extraCode="onChange=\"popHiddenDateField('dateFrom')\"" /> 
        <input type="hidden" name="dateFrom" value="0000-00-00">
      </td>
    </tr>
    <tr> 
      <td class="label">Date To:</td>
      <td><formtaglib:DropDownDateTag dropDownMonthName="dateMonth2" dropDownDayName="dateDay2" dropDownYearName="dateYear2" extraCode="onChange=\"popHiddenDateField2('dateTo')\"" /> 
        <input type="hidden" name="dateTo" value="2029-12-31">
      </td>
    </tr>
    <tr> 
      <td class="label">&nbsp;</td>
      <td>&nbsp;</td>
      <td class="label">&nbsp;</td>
      <td>&nbsp;</td>
      <td class="label">&nbsp;</td>
      <td>&nbsp;</td>
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

<input type="hidden" name="siteHostCompanyFromText" value="">
<input type="hidden" name="siteHostCompanyToText" value="">
<input type="hidden" name="buyerCompanyFromText" value="">
<input type="hidden" name="buyerCompanyToText" value="">
</form>
</body>
</html>
