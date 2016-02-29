<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<%@ include file="/includes/SessionChecker.jsp" %>
<%@ taglib uri="/WEB-INF/tld/taglib.tld" prefix="taglib" %>

<jsp:useBean id="pB" class="com.marcomet.commonprocesses.ProcessProduct" scope="page" />
<jsp:useBean id="str" class="com.marcomet.tools.StringTool" scope="page" />
<%	String productId = ((request.getParameter("productId")==null)?"":(String)request.getParameter("productId")); 
	pB.select(productId);%>
<html>
<head>
<title>Product Spec Sheet</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link rel="stylesheet" href="<%=(String)session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css">
<style type="text/css">
<!--
-->
</style>
<script language="JavaScript" src="/javascripts/mainlib.js"></script>
</head>

<body bgcolor="#FFFFFF" background="<%=(String)session.getAttribute("siteHostRoot")%>/images/back.jpg" leftmargin="0" topmargin="0">
<table width="100%"  border="0" cellspacing="0" cellpadding="0">
<%=((request.getAttribute("errorMessage")==null)?"":"<tr><td height=\"1\" class=\"prodPageProductLine\">"+request.getAttribute("errorMessage")+"</td></tr>")%>
  <tr><td colspan=2>
        <table cellpadding="0" cellspacing="0" border="0">
        <tr> 
          <%String demoButton="<td class=\"yellowButtonBox\"><a href="+(String)session.getAttribute("siteHostRoot")+"/fileuploads/product_demos/pl"+pB.getProdLineId()+"/"+pB.getProdDemoURL()+" class=\"yellowButton\">Demo</a></td>";
		  	%><%=((pB.getProdDemoURL()==null || pB.getProdDemoURL().equals(""))?"":demoButton)%>		  
               <%=((pB.getProdPrintURL().equals(""))?"":"<td><a href=\"http://www.adobe.com/products/acrobat/readstep2.html\" target=\"_blank\"><img src=\"/images/acrobat_logo.gif\"></a></td>")%>
			  <td class="yellowButtonBox" width="16"><a href="<%=((!pB.getProdPrintURL().equals(""))?(String)session.getAttribute("siteHostRoot")+"/fileuploads/product_print_pages/"+pB.getProdPrintURL():"/products/product_print_page_2.jsp?productId="+productId)%>" class="yellowButton" target="_blank">Printer&nbsp;Version</a></td>
              <td class="yellowButtonBox" width="150"><a href="/files/support_page.jsp?relatedTable=products&relatedId=<%=productId%>"  class="yellowButton">Downloads&nbsp;&amp;&nbsp;Support</a></td>  
		<%if (pB.getSendLiterature()==1){%>
              <td class="yellowButtonBox" width="122"><a href="/files/useremailform.jsp?productId=<%=productId%>&emailType=3"  class="yellowButton">Request&nbsp;Information</a></td> 
              <%}%> 
		<%if (pB.getSendSample()==1){%>
              <td class="yellowButtonBox" width="98"><a href="/files/useremailform.jsp?productId=<%=productId%>&emailType=4"  class="yellowButton">Request&nbsp;Sample</a></td>
              <%}%> 		   
        </tr>
      </table>
  </td></tr>
    <tr><td class="prodPageProductName" align="center" colspan=2><%=pB.getProdName()%></td>
	</tr>
      <tr valign="bottom"> 
        <td class="prodPageProductLine" align="center" height="26" colspan=2><a href="/products/productline_summary.jsp?productLineId=<%=pB.getProdLineId()%>" target="main" class="prodPageProductLine"><%=pB.getProdLineName()%></a></td>
	</tr>
	  <tr valign="center"> 
        <td class="prodPageSummary" align="center" colspan=2 height="22"><%=pB.getSummary()%></td>
	</tr>
  <tr> 
<td colspan=2><table width=100%><tr>
              <td width="50%" class="body" valign="top">
<%=pB.getProdFeatures()%></td>
		      <td width="50%" class="body" valign="top"><%=pB.getApplication()%></td>
            </tr></table></td>
  </tr>
  <tr> 
    <td align="left" valign="top" width="10%" ><%=((pB.getProdFullPicURL()==null || pB.getProdFullPicURL().equals(""))?"":"<img src='"+(String)session.getAttribute("siteHostRoot")+"/fileuploads/product_images/"+ str.replaceSubstring(pB.getProdFullPicURL()," ","%20") +"'>")%></td>
    <td width="90%"  class="body">
			<table width=100%>
			  <tr> <td colspan="2" class="tableheader" bgcolor="#000099" height="21"><%=pB.getProdName()%>Product 
						Specifications</td></tr>
			<tr><td height="1" colspan=2>  
					<table width=100% border="0">
						<%=pB.getSpecsTable()%>
					</table>
			  </td></tr>
			</table>
          </td>
  </tr>
  <tr align="left" valign="top"> 
    <td colspan="2"class="body"><%=pB.getDescription()%><br><%=pB.getProdSpecDiagramPicURL()%></td>
  </tr>

  <tr>
    <td valign="bottom" colspan=2> 
      <table width=100% border=0 cellpadding=0 cellspacing=0>
    <tr>
	<td width=100% align="center"><a href="javascript:window.history.back()" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('back','','../images/buttons/backover.gif',1)" onMouseDown="MM_swapImage('back','','../images/buttons/backdown.gif',1)"><img name="back" border="0" src="../images/buttons/back.gif" width="74" height="20"></a></td>
	</tr><tr>
<td bgcolor="#FFFFFF" height="30" colspan=2> 
      <jsp:include page="/footers/inner_footer.jsp" flush="true"></jsp:include></td></tr>
</table>
</td></tr>
</table>
</body>
</html>
