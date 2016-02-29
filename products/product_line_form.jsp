
<%@ include file="/includes/SessionChecker.jsp" %>
<%@ page import="java.sql.*,com.marcomet.tools.*;" %>
<%@ taglib uri="/WEB-INF/tld/taglib.tld" prefix="taglib" %>


<jsp:useBean id="connection" class="com.marcomet.jdbc.ConnectionBean" scope="session" />
<jsp:useBean id="plB" class="com.marcomet.commonprocesses.ProcessProductLine" scope="page" />
<jsp:useBean id="validator" class="com.marcomet.tools.FieldValidationBean" scope="page" />
<%String siteHostId=session.getAttribute("siteHostId").toString();
String companyId=session.getAttribute("siteHostCompanyId").toString();
String tableField= "contacts c where companyid="+companyId;
String imagesFilePath="/home/htdocs/salestrack"+(String)session.getAttribute("siteHostRoot")+"/fileuploads/product_images";
%><html>
<head>
<title><%
	String formAction ="";
	String prodLineId ="";
	String returnString="";
	String prodLineParent="";
	String prodLineManagerId="";		
if (request.getParameter("productLineId")!=null){
	prodLineId=request.getParameter("productLineId");
	plB.select(prodLineId);
	formAction = "/servlet/com.marcomet.products.UpdateProductLine";
//	returnString="/products/product_specs.jsp?productLineId="+prodLineId;
	returnString="[/products/productline_list.jsp?productLineId="+prodLineId+"&editFlag=true]";
	prodLineParent=Integer.toString(plB.getProdLineParentId()); 
	prodLineManagerId=Integer.toString(plB.getProdManagerId()); 	
	%>Edit <%=plB.getProdLineName()%> Product Line<%
}else{
	prodLineId="";
	formAction = "/servlet/com.marcomet.products.NewProductLine";
//	returnString="/products/product_specs.jsp?productLineId="+prodLineId;
	if (request.getParameter("prodLineParentId")!=null){
		returnString="[/products/productline_summary.jsp?productLineId="+request.getParameter("prodLineParentId")+"&editFlag=true]";
	}else{
		returnString="[/products/productline_list.jsp?editFlag=true]";		
	}
	prodLineParent=((request.getParameter("prodLineParentId")==null)? Integer.toString(plB.getProdLineParentId()): request.getParameter("prodLineParentId") ) ;		
	prodLineManagerId=((request.getParameter("prodLineManagerId")==null)? Integer.toString(plB.getProdManagerId()): request.getParameter("prodLineManagerId") ) ;		
	%>Create Product Line<%	
}
%></title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link rel="stylesheet" href="<%=(String)session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css">
<style type="text/css">
</style>
</head>
<jsp:getProperty name="validator" property="javaScripts" />
<script language="JavaScript" src="/javascripts/mainlib.js"></script>
<script language="javascript">
function displayHomePageHTML(){
	if (document.forms[0].topLevelFlag.checked==true){
		homepagehtml_div.style.display = "";
		homepagehtml_1_div.style.display = "";			
	}else{
		homepagehtml_div.style.display = "none";
		homepagehtml_1_div.style.display = "none";				
	}
}
</script>
<%=((com.marcomet.users.security.RoleResolver)session.getAttribute("roles")).roleCheckRedirect("admin","/admin/no_rights.jsp")%>
<body bgcolor="#FFFFFF" background="<%=(String)session.getAttribute("siteHostRoot")%>/images/back.jpg" leftmargin="0" topmargin="1">
<form method="post" action="<%=formAction%>">
  <table align="center" width="95%">
    <tr> 
      <td colspan="4"> 
        <p><%= (request.getAttribute("errorMessage")==null)?"":request.getAttribute("errorMessage")%></p>
        </td>
    </tr>
    <tr> 
      <td colspan="4" class=tableheader align="left"> Product Line Information</td>
    </tr><%
		  if (!prodLineId.equals("")){ 	  
        %><td align="left" valign="top" width="22%" rowspan=5>
		<p><b>Related Files:</b><br>
          Small Pic File Name: 
          <a href="javascript:uploadFile('<%=plB.getId()%>','<%=plB.getProdLineName()%>','product_images','product_lines','small_picurl','<%=imagesFilePath%>');" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('upload1','','/images/buttons/uploadover.gif',1)" onMouseDown="MM_swapImage('upload1','','/images/buttons/uploaddown.gif',1)"><img name="upload1" border="0" src="/images/buttons/upload.gif" width="65" height="20"></a>&nbsp;
          <input name="smallPicURL" type="text" size="30" max="30" value="<%= ((plB.getSmallPicURL()==null)?"":plB.getSmallPicURL()) %>" >
          Full Pic File Name: <a href="javascript:uploadFile('<%=plB.getId()%>','<%=plB.getProdLineName()%>','product_images','product_lines','full_picurl','<%=imagesFilePath%>');" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('upload2','','/images/buttons/uploadover.gif',1)" onMouseDown="MM_swapImage('upload2','','/images/buttons/uploaddown.gif',1)"><img name="upload2" border="0" src="/images/buttons/upload.gif" width="65" height="20"></a>&nbsp; 
          <input name="fullPicURL" type="text" size="30" max="30" value="<%= ((plB.getFullPicURL()==null)?"":plB.getFullPicURL()) %>" >
        </p>
      </td><%}%>
      <td height="22" class="label" width="18%">Parent Product Line:</td>
      <td height="22" colspan="3" width="82%"> <%String tableStr="product_lines where company_id='"+companyId+"'";%><taglib:LUCustomDropDownTag  orderbyField = "prod_line_name" valueField="prod_line_name" dropDownName="prodLineParentId" table="<%=tableStr%>" selected="<%=prodLineParent%>"/> 
      </td>
    </tr>
    <tr> 
      <td class="label" width="18%">Product Line Name:</td>
      <td colspan="3" width="82%"> 
        <input name="prodLineName" type="text" size="34" max="30" value="<%= plB.getProdLineName() %>" >
      </td>
    </tr>
    <tr> 
      <td class="label" width="18%">Product Line Manager:</td>
      <td colspan="3" width="82%"> <taglib:LUCustomDropDownTag  key="c.id" orderbyField = "c.lastname" valueField="concat(c.firstname,' ',c.lastname)" dropDownName="prodManagerId" table="<%=tableField%>" selected="<%= prodLineManagerId%>"/> 
      </td>
    </tr>
<tr>
      <td class="label"> Product Line Status:</td>
      <td colspan="3" width="82%"> <taglib:LUCustomDropDownTag  orderbyField = "sequence" valueField="value" dropDownName="statusId" table="lu_product_status" selected="<%= plB.getStatusId()%>"/> 
</tr>

    <tr> 
      <td class="label" width="18%">Sequence #:
        <input name="sequence" type="text" size="5" max="30" value="<%= plB.getSequence() %>" >
      </td>
      <td colspan="3" width="82%"> 
        <input name="topLevelFlag" type="checkbox"  value="1" onClick="displayHomePageHTML()"  <%= ((plB.getTopLevelFlag()==null || plB.getTopLevelFlag().equals("0") || plB.getTopLevelFlag().equals(""))?"":"checked") %>>Top-Level Product Line?		
      </td>
    </tr>
<table align="center" width="80%" dwcopytype="CopyTableRow">    <!-- </table>
<table align="center" width="80%" class=label>	 -->
    <!--</table>
<table align="center" width="80%" class=label>-->
  </table>
    <tr> 
      <td colspan="4" class=tableheader> 
        <div align="left">Description: </div>
      </td>
    </tr>
    <tr> 
      <td class="label" colspan="4"> 
        <textarea name="description" cols="100" rows="3"><%= plB.getDescription() %></textarea>
      </td>
    </tr>
    <tr> 
      <td colspan="4" class=tableheader> 
        <div align="left">Print Header: </div>
      </td>
    </tr>
    <tr> 
      <td class="label" colspan="4"> 
        <textarea name="header" cols="100" rows="3"><%= plB.getHeader() %></textarea>
      </td>
    </tr>
    <tr> 
      <td colspan="4" class=tableheader> 
        <div align="left">Print Footer: </div>
      </td>
    </tr>
    <tr> 	
      <td class="label" colspan="4"> 
        <textarea name="footer" cols="100" rows="3"><%= plB.getFooter() %></textarea>
      </td>
    </tr>
	
	    <tr> 
      <td colspan="4" class=tableheader> 
        <div align="left" id='homepagehtml_div' <%=((plB.getHomepageHtml()==null || plB.getHomepageHtml().equals(""))?"STYLE=\"display:none\"":"")%> >Home Page HTML: </div>
      </td>
    </tr>
    <tr> 	
      <td class="label" colspan="4"> 
        <div align="left" id='homepagehtml_1_div' <%=((plB.getHomepageHtml()==null || plB.getHomepageHtml().equals(""))?"STYLE=\"display:none\"":"")%>>
          <textarea name="homepageHtml" cols="100" rows="30"><%= plB.getHomepageHtml() %></textarea></div>
      </td>
    </tr>
			
    <tr> 
      <td class="label" width="18%">&nbsp;</td>
      <td colspan="3" width="82%">&nbsp;</td>
    </tr>
    <!-- </table>
<table align="center" width="80%" class=label>	 -->
    <!--</table>
<table align="center" width="80%" class=label>-->
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
  <input type="hidden" name="prodLineId" value="<%=prodLineId%>">
  <input type="hidden" name="prodLineCompanyId" value="<%=companyId%>">  
  <input type="hidden" name="$$Return" value="<%=returnString%>">
  <input type="hidden" name="errorPage" value="/errors/ExceptionPage.jsp">
  <!--"/products/product_line_form.jsp?productLineId=<%=prodLineId%>&editFlag=true"> -->
</form>
</body>
</html>
