
<%@ include file="/includes/SessionChecker.jsp" %>
<%@ taglib uri="/WEB-INF/tld/taglib.tld" prefix="taglib" %>
<html>
<head>
<jsp:useBean id="psB" class="com.marcomet.products.ProductLineSummaryBean" scope="page" />
<%String editFlag=((request.getParameter("editFlag")==null)?"false":request.getParameter("editFlag"));
if (editFlag!=null && editFlag.equals("true")){%>
	<%=((com.marcomet.users.security.RoleResolver)session.getAttribute("roles")).roleCheckRedirect("admin","/admin/no_rights.jsp")%>
<%}%>
<%	String productLineId = ((request.getParameter("productLineId")==null || request.getParameter("productLineId").equals(""))?"":(String)request.getParameter("productLineId")); 
if(productLineId.equals("")){
%><script language=javascript>document.location.replace("/products/productline_list.jsp")</script><%
}
psB.setSiteHostRoot(session.getAttribute("siteHostRoot").toString());
psB.setEditFlag(editFlag);
psB.setProductLineId(productLineId);
%>
<script language="JavaScript" src="/javascripts/mainlib.js">
</script>

<title><%=psB.getProductLineName()%> Product Line Summary
</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link rel="stylesheet" href="<%=(String)session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css">
</head>

<body leftmargin="0" topmargin="1" background="<%=(String)session.getAttribute("siteHostRoot")%>/images/back.jpg">
<table width=100% border="0" cellspacing="0" cellpadding="0"><tr> <td>
  <table width="90%" border="0" cellspacing="1" cellpadding="4">
        <tr>
          <td class= "ProductLineTitle" height="41"> 
            <%=psB.getProductLineName()%></td>
        </tr><%
    if (editFlag!=null && editFlag.equals("true")){
	%><tr>
          <td> 
            <table border=0 cellpadding=0 cellspacing=0>
              <tr> 
                <td class="yellowButtonBox"><a href="/products/product_line_form.jsp?prodLineParentId=<%=productLineId%>&prodLineManagerId=<%=psB.getProductLineManagerId()%>" class="yellowButton">Add&nbsp;SubProduct&nbsp;Line</a></td>
                <td class="yellowButtonBox"><a href="/products/product_form.jsp" class="yellowButton" >Add&nbsp;Product</a></td>
                <td class="yellowButtonBox"><a href="/products/product_line_form.jsp?productLineId=<%=productLineId%>" class="yellowButton" >Edit&nbsp;This&nbsp;Line</a></td>
                <td class="yellowButtonBox"><a href="/products/product_specs.jsp?productLineId=<%=productLineId%>" class="yellowButton" >Edit&nbsp;Product&nbsp;Spec&nbsp;Template</a></td>
                <td class="yellowButtonBox"><a href="/products/productline_list.jsp" class="yellowButton" >Return&nbsp;To&nbsp;Product&nbsp;Line&nbsp;List</a></td>				
              </tr>
            </table>
          </td>
        </tr>
        <%
}%>
  <hr size="1" noshade width="100%" align="left">
    <tr> 
      <td class=body><%=psB.getProductLineDescription()%></td>
    </tr>
  </table>
<table width="100%" border="0" cellpadding="4" cellspacing="0">
<%=psB.getSummaryTable().toString()%>
  </table>
</tr>
  <tr>
  <td height=20%>&nbsp;</td>
  </tr>
  <tr>
<td bgcolor="#FFFFFF" height="30"> 
      <jsp:include page="/footers/inner_footer.jsp" flush="true"></jsp:include></td></tr>
</table>
<%psB=null;%>
</body>
</html>
