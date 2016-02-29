<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<%@ include file="/includes/SessionChecker.jsp" %>
<%@ page import="java.sql.*,com.marcomet.tools.*;" %>
<%@ taglib uri="/WEB-INF/tld/taglib.tld" prefix="taglib" %>


<jsp:useBean id="pB" class="com.marcomet.commonprocesses.ProcessProductLine" scope="page" />
<jsp:useBean id="pPLS" class="com.marcomet.commonprocesses.ProcessProductSpecs" scope="page" />
<jsp:useBean id="validator" class="com.marcomet.tools.FieldValidationBean" scope="page" />
<%String siteHostId=session.getAttribute("siteHostId").toString();
String companyId=session.getAttribute("siteHostCompanyId").toString();
%><html>
<head>
<title><%
	String formAction ="";
	String prodLineId ="";
	String returnString="";
	String formMethod="post";	
if (request.getParameter("productLineId")!=null){
	prodLineId=request.getParameter("productLineId");
	pB.select(prodLineId);
	pPLS.setProdLineId( ( (pB.getProdLineTopParentId()>0)?Integer.toString(pB.getProdLineTopParentId()):prodLineId ) );
	pPLS.setCompanyId(companyId);
	formAction = "/servlet/com.marcomet.products.UpdateProductSpecs";
	returnString="[/products/productline_summary.jsp?productLineId="+prodLineId+"&editFlag=true]";	
	%>Edit <%=pB.getProdLineName()%> Product Line Specification Template<%
}else if (request.getAttribute("productLineId")!=null){
	prodLineId=request.getAttribute("productLineId").toString();
	pB.select(prodLineId);
	pPLS.setProdLineId( ( (pB.getProdLineTopParentId()>0)?Integer.toString(pB.getProdLineTopParentId()):prodLineId ) );
	pPLS.setCompanyId(companyId);
	formAction = "/servlet/com.marcomet.products.UpdateProductSpecs";
	returnString = "[/products/productline_summary.jsp?productLineId="+prodLineId+"&editFlag=true]";	
	%>Edit <%=pB.getProdLineName()%> Product Specification Template<%
}else{
	prodLineId="";
	formAction = "/servlet/com.marcomet.products.UpdateProductSpecs";
	returnString="[/products/product_form.jsp]";		
	%>Create Product<%	
}
%></title>
<jsp:getProperty name="validator" property="javaScripts" />
<script language="JavaScript" src="/javascripts/mainlib.js"></script>
<script>
function replaceSub(val1,out,add){
	while (val1.indexOf(out)>-1) {
		pos= val1.indexOf(out);
		val1 = "" + (val1.substring(0, pos) + add + 
		val1.substring((pos + out.length), val1.length));
	}
	return val1;
}
function setval(temp,val){
	val1=eval("document.forms[0].productSpecValue"+temp+".options[document.forms[0].productSpecValue"+temp+".selectedIndex].text;");
	document.forms[0].elements["productSpecValueEntry"+temp].value=val1;
}
</script>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link rel="stylesheet" href="<%=(String)session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css">
<style type="text/css">
<!--
-->
</style>
</head>

<body bgcolor="#FFFFFF" background="<%=(String)session.getAttribute("siteHostRoot")%>/images/back.jpg" leftmargin="0" topmargin="1">
<form method="post" action="<%=formAction%>">
<table width="100%" border="0" cellspacing="1" cellpadding="1">
<%=((request.getAttribute("errorMessage")==null)?"":"<tr><td colspan=\"5\" class=\"tableheader\">"+request.getAttribute("errorMessage")+"</td></tr>")%>
	  <tr> 
      <td colspan="5" class="tableheader">Edit Product Line Specification Template</td>
    </tr>
	    <tr> 
      <td colspan="5"> 
        <p><%= (request.getParameter("errormessage")==null)?"":request.getParameter("errormessage")%></p>
        </td>
    </tr>
	    <tr> 
      <td colspan="5" class="prodPageSummary">Product Line Name: <%= pB.getProdLineName()%></td>
    </tr>	
  <tr>          
      <td class="prodPageSummary" height="24" align="left" colspan=5>Choose Specifications for this product line form the dropdowns or Enter new specifications in the space provided.<br>
      </td>
  </tr>
  <tr>   
<%if (prodLineId!=""){
	%><%=((pPLS.getProductSpecsTable()==null)?"</td>":pPLS.getProductSpecsTable())%><%
	}
 %></table>
  <table width=600 align="center">
    <tr> 
      <td width="40%">&nbsp;</td>
      <td  width="75"><a href="javascript:submitForm()" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('Image2','','/images/buttons/submitover.gif',1)"><img name="Image2" border="0" src="/images/buttons/submit.gif" width="74" height="20"></a></td>
      <td width="6%">&nbsp;</td>
      <td width="75"><a href="javascript:history.go(-1)" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('cancel','','/images/buttons/cancelbtover.gif',1)" onMouseDown="MM_swapImage('cancel','','/images/buttons/cancelbtdown.gif',1)"><img name="cancel" border="0" src="/images/buttons/cancelbt.gif" width="74" height="20"></a></td>
      <td width="40%">&nbsp;</td>
    </tr>
  </table>
  <input type="hidden" name="prodLineId" value="<%=prodLineId%>">
  <input type="hidden" name="prodCompanyId" value="<%=companyId%>">  
  <input type="hidden" name="$$Return" value="<%=returnString%>">
  <input type="hidden" name="errorPage" value="/products/product_specs.jsp">

</form>
</body>
</html>
