
<%@ include file="/includes/SessionChecker.jsp" %>
<%@ page import="java.sql.*,com.marcomet.tools.*;" %>
<%@ taglib uri="/WEB-INF/tld/taglib.tld" prefix="taglib" %>

<jsp:useBean id="connection" class="com.marcomet.jdbc.ConnectionBean" scope="session" />
<jsp:useBean id="pB" class="com.marcomet.commonprocesses.ProcessProduct" scope="page" />
<jsp:useBean id="validator" class="com.marcomet.tools.FieldValidationBean" scope="page" />
<%
String siteHostId=session.getAttribute("siteHostId").toString();
String companyId=pB.getCompanyId(session.getAttribute("siteHostId").toString());
String imagesFilePath="/home/htdocs/salestrack"+(String)session.getAttribute("siteHostRoot")+"/fileuploads/product_images";
String demosFilePath="/home/htdocs/salestrack"+(String)session.getAttribute("siteHostRoot")+"/fileuploads/product_demos";
String printFilePath="/home/htdocs/salestrack"+(String)session.getAttribute("siteHostRoot")+"/fileuploads/product_print_pages";
%><html>
<head>
<title><%
	String formAction ="";
	String prodId ="";
	String returnString="";
	String formMethod="post";	
if (request.getParameter("productId")!=null){
	prodId=request.getParameter("productId");
	pB.select(prodId);
	formAction = "/servlet/com.marcomet.products.UpdateProduct";
	returnString="[/products/productline_summary.jsp?productLineId="+pB.getProdLineId()+"&editFlag=true]";
	formMethod="post";	
	%>Edit <%=pB.getProdName()%> Product<%
}else if (request.getAttribute("productId")!=null){
	prodId=request.getAttribute("productId").toString();
	pB.select(prodId);
	formAction = "/servlet/com.marcomet.products.UpdateProduct";
	returnString="[/products/productline_summary.jsp?productLineId="+pB.getProdLineId()+"&editFlag=true]";
	formMethod="post";	
	%>Edit <%=pB.getProdName()%> Product<%
}else{
	prodId="";
	formAction = "/servlet/com.marcomet.products.NewProduct";
	returnString="[/products/product_form.jsp]";
	formMethod="post";		
	%>Create Product<%	
}
%></title>
<jsp:getProperty name="validator" property="javaScripts" />
<script language="JavaScript" src="/javascripts/mainlib.js"></script>
<%=((com.marcomet.users.security.RoleResolver)session.getAttribute("roles")).roleCheckRedirect("admin","/admin/no_rights.jsp")%>
<script>
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
<form method="<%=formMethod%>" action="<%=formAction%>">
<table width="100%" border="0" cellspacing="1" cellpadding="1">
    <tr> 
      <td colspan="4" class="tableheader">Enter/Edit Product</td>
    </tr>
	    <tr> 
      <td colspan="4"> 
        <p><%= (request.getAttribute("errorMessage")==null)?"":request.getAttribute("errorMessage")%></p>
        </td>
    </tr>
	    <tr> 
      <td colspan="4" class="prodPageSummary"> Product Name: 
        <input name="prodName" type="text" size="50" value="<%= pB.getProdName() %>" >
        &nbsp;&nbsp;Product Line:  <%String tableStr="product_lines where company_id='"+companyId+"'";%><taglib:LUCustomDropDownTag  orderbyField = "prod_line_name" valueField="prod_line_name" dropDownName="prodLineId" table="<%=tableStr%>" selected="<%= pB.getProdLineId()%>"/> 
        &nbsp;&nbsp;Template:<% 
        String lookupStr = "lu_product_templates WHERE site_host_id='"+siteHostId+"'";
		String templateStr = ((pB.getTemplate()==null || pB.getTemplate().equals(""))?"product_page.jsp":pB.getTemplate());%>&nbsp;<taglib:LUCustomDropDownTag  key="template" orderbyField = "name" valueField="name" dropDownName="template" table="<%=lookupStr%>" selected="<%=templateStr%>"/> 
      </td>
    </tr>
	<tr> 
      <td colspan="4" class="prodPageSummary"> Product Status: <taglib:LUCustomDropDownTag  orderbyField = "sequence" valueField="value" dropDownName="statusId" table="lu_product_status" selected="<%= pB.getStatusId()%>"/> 
     Allow user to ask for: <input type="checkbox" name="sendLiterature" value="1" <%=((pB.getSendLiterature()==1)?"checked":"")%>>
        Literature 
        <input type="checkbox" name="sendSample" value="1" <%=((pB.getSendSample()==1)?"checked":"")%> >
        Product Sample </td>
    </tr>
	<tr> 
      <td colspan="4" class="prodPageSummary"> Show on Product Line Summary Page: 
        <input type="checkbox" name="showManuals" value="1" <%=((pB.getShowManuals()==1)?"checked":"")%>>Download Manuals 
        <input type="checkbox" name="showDrivers" value="1" <%=((pB.getShowDrivers()==1)?"checked":"")%> >Download Drivers
        <input type="checkbox" name="showSampleRequest" value="1" <%=((pB.getShowSampleRequest()==1)?"checked":"")%> >Request Sample
        <input type="checkbox" name="showSupportRequest" value="1" <%=((pB.getShowSupportRequest()==1)?"checked":"")%> >Request Support</td>
    </tr>		
    <tr><% 
	  if (!prodId.equals("")){ 	  
        %><td align="left" valign="top" width="22%" rowspan=3>
		<p><b>Related Files:</b><br>
          Small Pic File Name: 
          <a href="javascript:uploadFile('<%=pB.getId()%>','<%=pB.getProdName()%>','product_images','products','small_picurl','<%=imagesFilePath%>');" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('upload1','','/images/buttons/uploadover.gif',1)" onMouseDown="MM_swapImage('upload1','','/images/buttons/uploaddown.gif',1)"><img name="upload1" border="0" src="/images/buttons/upload.gif" width="65" height="20"></a>&nbsp;
          <input name="productSmallPicURL" type="text" size="30" max="30" value="<%= ((pB.getProdSmallPicURL()==null)?"":pB.getProdSmallPicURL()) %>" >
          Full Pic File Name: 
		  <a href="javascript:uploadFile('<%=pB.getId()%>','<%=pB.getProdName()%>','product_images','products','full_picurl','<%=imagesFilePath%>');" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('upload2','','/images/buttons/uploadover.gif',1)" onMouseDown="MM_swapImage('upload2','','/images/buttons/uploaddown.gif',1)"><img name="upload2" border="0" src="/images/buttons/upload.gif" width="65" height="20"></a>&nbsp;
          <input name="productFullPicURL" type="text" size="30" max="30" value="<%= ((pB.getProdFullPicURL()==null)?"":pB.getProdFullPicURL()) %>" >
          Spec Diagram File Name(if any): 
		  <a href="javascript:uploadFile('<%=pB.getId()%>','<%=pB.getProdName()%>','product_images','products','spec_diagram_picurl','<%=imagesFilePath%>');" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('upload3','','/images/buttons/uploadover.gif',1)" onMouseDown="MM_swapImage('upload3','','/images/buttons/uploaddown.gif',1)"><img name="upload3" border="0" src="/images/buttons/upload.gif" width="65" height="20"></a>&nbsp;
          <input name="productSpecDiagramPicURL" type="text" size="30" max="30" value="<%= ((pB.getProdSpecDiagramPicURL()==null)?"":pB.getProdSpecDiagramPicURL()) %>" >
          Product Demo File Name(if any): 
		  <a href="javascript:uploadFile('<%=pB.getId()%>','<%=pB.getProdName()%>','product_images','products','demo_url','<%=demosFilePath%>');" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('upload4','','/images/buttons/uploadover.gif',1)" onMouseDown="MM_swapImage('upload4','','/images/buttons/uploaddown.gif',1)"><img name="upload4" border="0" src="/images/buttons/upload.gif" width="65" height="20"></a>&nbsp;
          <input name="productDemoURL" type="text" size="30" max="30" value="<%= ((pB.getProdDemoURL()==null)?"":pB.getProdDemoURL()) %>" >
          Product Print File Name(if any): 
		  <a href="javascript:uploadFile('<%=pB.getId()%>','<%=pB.getProdName()%>','product_print_pages','products','print_file_url','<%=printFilePath%>');" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('upload5','','/images/buttons/uploadover.gif',1)" onMouseDown="MM_swapImage('upload5','','/images/buttons/uploaddown.gif',1)"><img name="upload5" border="0" src="/images/buttons/upload.gif" width="65" height="20"></a>&nbsp;
          <input name="productPrintURL" type="text" size="30" max="30" value="<%= ((pB.getProdPrintURL()==null)?"":pB.getProdPrintURL()) %>" >
        </p></td><%}%>
        
      <td class="prodPageSummary" align="left" colspan=2>
      </td>
    </tr>
  <tr> 
            
      <td class="prodPageSummary" height="24" align="left" colspan=2>
        <p>Be sure to use &lt;br&gt; wherever you want a line to break in the 
          Summary, Features, or Description.<br>
          Product Summary<br>
          <textarea name="summary" cols="80" rows="3"><%= pB.getSummary() %></textarea>
        </p>
      </td>
  </tr>
  <tr> 
            
      <td colspan="5" height="69" valign="top" class="prodPageSummary">Product 
        Features <i>-- Paste HTML if available</i><br>
        <textarea name="prodFeatures" cols="80" rows="4"><%= pB.getProdFeatures() %></textarea>
        <br>
        Product Application<br>
        <textarea name="application" cols="80" rows="4"><%= pB.getApplication() %></textarea>
		</td>
  </tr>
</table>
  <table>
  <tr align="left" valign="top"> 
      <td colspan="6" height="142" class="prodPageSummary"> Detailed Description -- <i>Paste 
        HTML if available</i> 
        <textarea name="description" cols="120" rows="7"><%= pB.getDescription() %></textarea>
      </td>
            <td height="142" class="body" width="490" > 
              <blockquote>
                
          <p>&nbsp;</p>
                
          <p>&nbsp; </p>
            </blockquote>
          </td>
  </tr>
  <tr>
            <td  height="20" width="422"> 
              <table cellpadding="0" cellspacing="0" border="0">
      </table>
  </td></tr>
  <tr><td height="1" colspan=5>  
<table width=100% border="0">
<tr><td class="tableheader" colspan=4>Product Specifications</td></tr>
<tr><td class='specTableCells' colspan=4>Choose a specification from the drop down menu or enter a new spec in the entry field. Leave Entry field blank if using a drop-down value.</td></tr>
<%if (prodId!=""){
	%><%=pB.getProductSpecsTable()%><%
	}
 %></table>
  </td></tr>
   </table>
  <table width=600 align="center">
    <tr> 
      <td width="40%">&nbsp;</td>
      <td  width="75"><a href="javascript:submitForm()" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('Image2','','/images/buttons/submitover.gif',1)"><img name="Image2" border="0" src="/images/buttons/submit.gif" width="74" height="20"></a></td>
      <td width="6%">&nbsp;</td>
      <td width="75"><a href="javascript:history.go(-1)" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('cancel','','/images/buttons/cancelbtover.gif',1)" onMouseDown="MM_swapImage('cancel','','/images/buttons/cancelbtdown.gif',1)"><img name="cancel" border="0" src="/images/buttons/cancelbt.gif" width="74" height="20"></a></td>
      <td width="40%">&nbsp;</td>
    </tr>
  </table>
  <input type="hidden" name="prodId" value="<%=prodId%>">
  <input type="hidden" name="prodCompanyId" value="<%=companyId%>">  
  <input type="hidden" name="$$Return" value="<%=returnString%>">
  <input type="hidden" name="errorPage" value="/products/product_form.jsp">

</form>
</body>
</html>
