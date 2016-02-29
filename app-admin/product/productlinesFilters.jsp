<%@ include file="/includes/SessionChecker.jsp" %>
<%@ taglib uri="/WEB-INF/tld/formTagLib.tld" prefix="formtaglib" %>
<%@ taglib uri="/WEB-INF/tld/taglib.tld" prefix="taglib" %>
<%
String siteHostT = session.getAttribute("siteHostRoot").toString();
String siteHost = siteHostT.substring(11,siteHostT.length());
String vendorId=session.getAttribute("companyId").toString();
String sql="SELECT distinct c.id 'value', concat(sh.site_name,' [',c.id,']') 'text' FROM site_hosts sh,companies c where sh.company_id=c.id and sh.active=1 ORDER BY company_name";
String brandSQL="SELECT distinct p.brand_code 'value', concat(p.brand_code,' [ Company ID ',p.company_id,']') 'text' from products p,brands b where p.brand_code=b.brand_code and b.active=1 and p.status_id<>3 and p.status_id<>4 and p.brand_code is not null and p.brand_code<>'' ORDER BY p.brand_code";
String releaseSQL="SELECT distinct p.release 'value', p.release 'text' from products p where p.status_id<>3 and p.status_id<>4 and p.release is not null and p.release <>'' ORDER BY p.release";
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
</script>
<body bgcolor="#FFFFFF" text="#000000" background="<%=(String)session.getAttribute("siteHostRoot")%>/images/back3.jpg">
<form method="post" action="/app-admin/product/ProductsWithLines.jsp">
  <p class="TITLE">Products With Product Lines Report</p>
  <p></p>
  <p>&nbsp;</p>
  <table dwcopytype="CopyTableRow">
    <tr> 
      <td class="tableheader">Show Products:</td>
      <td class=lineitems> 
        <select name="reportType"  >
          <option value="By Product">By Product</option>
          <option value="By Product Line">By Product Line</option>
        </select>
          <input type='checkbox' name="excel" value='true'>Export to Excel
      </td>
    </tr>
    <tr> 
      <td class="tableheader">Product Company:</td>
      <td><formtaglib:SQLDropDownTag dropDownName="CID" sql="<%=sql%>" extraCode="onChange=\"document.forms[0].buyerCompanyText.value=this.options[this.selectedIndex].text\"" extraFirstOption="<option value=\"\">All</option>" /></td>
    </tr>
    <tr> 
      <td class="tableheader">Show Brand:</td>
      <td class=lineitems><formtaglib:SQLDropDownTag dropDownName="brand" sql="<%=brandSQL%>" extraCode="" extraFirstOption="<option value=\"\">All</option>" /></td>
    </tr>
     <tr> 
      <td class="tableheader">Show Release:</td>
      <td class=lineitems><formtaglib:SQLDropDownTag dropDownName="ShowRelease" sql="<%=releaseSQL%>" extraCode="" extraFirstOption="<option value=\"\">All</option>" /></td>
    </tr>
    <tr> 
      <td class="tableheader">Show Status:</td>
      <td class=lineitems><select name="ShowActive"  ><option value="ALL" selected>ALL</option><option value="Active Only">Active Only</option>
          <option value="Non-Retired">Non-Retired</option></select></td>
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
<input type="hidden" name="buyerCompanyText" value="">
</form>
</body>
</html>
