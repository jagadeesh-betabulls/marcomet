<%@ taglib uri="/WEB-INF/tld/taglib.tld" prefix="taglib" %>
<jsp:useBean id="validator" class="com.marcomet.tools.FieldValidationBean" scope="page" />
<html>
<head>
<title>RFQ Job</title>
  <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
  <link rel="stylesheet" href="<%=(String)session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css">
</head>
<jsp:getProperty name="validator" property="javaScripts" />
<script language="JavaScript" src="/javascripts/mainlib.js"></script>
<body leftmargin="0" topmargin="0" marginwidth="0" marginheight="0" onLoad="MM_preloadImages('/images/buttons/continueover.gif', '/images/buttons/cancelbtover.gif')">
<form method="post" action="/servlet/com.marcomet.catalog.CatalogCustomJobCreationServlet">
  <table border="0" cellpadding="0" cellspacing="0" width="100%" height="100%" >
    <tr> 
      <td width="10%">&nbsp;</td>
      <td class="catalogLABEL">Service Types:</td>
      <td>
        <taglib:LUDropDownTag dropDownName="serviceTypeId" table="lu_service_types" /> 
      </td>
      <td class="catalogLABEL">Job Type:</td>
      <td>
        <taglib:LUDropDownTag dropDownName="jobTypeId" table="lu_job_types" />
      </td>
    </tr>
    <tr> 
      <td width="10%">&nbsp;</td>
      <td class="catalogLABEL" colspan="4">Requirements:</td>
    </tr>
    <tr> 
      <td width="10%">&nbsp;</td>
      <td colspan="4" align="center" valign="top"> 
        <textarea name="notes" rows="5" cols="75"><%= (request.getParameter("notes")==null)?"":request.getParameter("notes")%></textarea>
      </td>
    </tr>
    <tr> 
      <td colspan="5">&nbsp;</td>
    </tr>
    <tr> 
      <td colspan="5" align="center"> 
        <table>
          <tr> 
            <td align="right"><a href="javascript:history.go(-1)" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('cancel','','/images/buttons/cancelbtover.gif',1)" onMouseDown="MM_swapImage('cancel','','/images/buttons/cancelbtdown.gif',1)"><img name="cancel" border="0" src="/images/buttons/cancelbt.gif" width="74" height="20"></a></td>
            <td width="10%">&nbsp;</td>
            <td align="left"><a href="javascript:document.forms[0].submit()" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('OK','','/images/buttons/submitover.gif',1)" onMouseDown="MM_swapImage('OK','','/images/buttons/submitdown.gif',1)"><img name="OK" border="0" src="/images/buttons/submit.gif" width="74" height="20"></a></td>
          </tr>
        </table>
      </td>
    </tr>
    <tr> 
      <td valign="bottom" colspan="5"> 
        <jsp:include page="/footers/inner_footer.jsp" flush="true"></jsp:include>
      </td>
    </tr>
  </table>
<input type="hidden" name="$$Return" value="[/catalog/summary/OrderSummary.jsp]">
<input type="hidden" name="errorPage" value="/catalog/rfq/RFQJobCreationForm.jsp">
</form>
</body>
</html>
