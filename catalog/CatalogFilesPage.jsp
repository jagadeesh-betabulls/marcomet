<%@ page import="java.sql.*, com.marcomet.catalog.*, com.marcomet.jdbc.*" %>
<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<jsp:useBean id="validator" class="com.marcomet.tools.FieldValidationBean" scope="page" />
<html>
<head>
  <title>Catalog Wizard</title>
  <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
  <link rel="stylesheet" href="<%=(String)session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css">
</head>
<script language="javascript" src="/javascripts/mainlib.js"></script>
<jsp:getProperty name="validator" property="javaScripts" />
<body leftmargin="0" topmargin="0" marginwidth="0" marginheight="0" onLoad="populateTitle('<%= (String)request.getAttribute("title")%>')">

<div id="waitSection" style="display: block;">
<br><br><br><br><br><br>
  <div align="center" > 
    <h2>Please Standby<img src="/images/generic/dotdot.gif" width="72" height="10"></h2>
  </div>
</div>

<div id="formSection" style="display: '';">

<form method="post" action="/servlet/com.marcomet.catalog.CatalogUploadServlet" enctype="multipart/form-data">
    <table border="0" cellpadding="0" cellspacing="0" width="100%" height="100%">
      <tr>
        <td valign="top"></td>
        <td valign="top"></td>
  </tr>
  <tr>
        <td align="center" valign="top" height="2"> 
          <table width="98%"><%
	String descriptionString="";
	String titleString="";
	String query0 = "select description,use_title_flag,title from catalog_pages cp where page_type = 'fileupload' and cat_job_id = " + request.getParameter("catJobId");
  
   Connection conn = DBConnect.getConnection();
   Statement st0 = conn.createStatement();
   ResultSet rs0 = st0.executeQuery(query0);
   if (rs0.next()){
		titleString=((rs0.getString("use_title_flag") != null && rs0.getString("use_title_flag").equals("1"))?"<tr><td class='title'>"+rs0.getString("title")+"</td></tr>":"");
		descriptionString=((rs0.getString("description") != null)?"<tr><td class='body' valign='top' colspan='2'>"+rs0.getString("description")+"</td></tr>":"");
	}%>
         <%=titleString%> 
         <%=descriptionString%>
     	  </table>
    </td>
  </tr>
  <tr>
        <td colspan="2" valign="top" align="center" height="33"> 
          <hr color="red" width="98%" size="1">
          <table width="98%">
        <tr>
              <td><jsp:include page="/includes/UploadFilesInclude.jsp" flush="true"/>
          </td>
        </tr>
      </table>
    </td>
  </tr><%
   if (session.getAttribute("contactId") != null) { %>
  <tr>
        <td colspan="2" valign="top" align="center"> 
          <table width="98%"><tr><td><hr>
          	<div id='filtertoggle' ><a href="javascript:togglefilters()" class="greybutton">+ Show Files From Archives</a></div><div id='filters' Style='display: none;' >
          		<jsp:include page="/includes/AssociateFilesInclude.jsp" flush="true" />
          	</div><hr>
           </td></tr></table>
  </tr>
<% } %>
  <tr>
        <td valign="middle" align="center" colspan="2"> 
          <table width="20%">
            <tr>
              <td align="right"> 
                <div align="center"><a href="javascript:parent.window.location.replace('/index.jsp?contents=<%=(String)session.getAttribute("siteHostRoot")%>/contents/SiteHostCommerceIndex.jsp')" class="greybutton">Cancel</a> 
                </div>
              </td>
          <td width="10%">&nbsp;</td>
              <td align="left"> 
                <div align="center"><a href="javascript:submitForm()" class="greybutton">Continue</a> 
                </div>
              </td>
        </tr>
      </table>
    </td>
  </tr>
  <tr>
        <td valign="top">&nbsp;</td>
    <td>&nbsp;</td>
	<td>&nbsp;</td>
      </tr>
	  <td valign="top">&nbsp;</td>
    <td>&nbsp;</td>
	<td>&nbsp;</td>
      </tr>
	  <tr>
        <td valign="top">&nbsp;</td>
    <td>&nbsp;</td>
	<td>&nbsp;</td>
      </tr>
  <tr>
        <td valign="top"> 
          <!--<jsp:include page="/catalog/includes/JobSpecsInclude.jsp" flush="true" />-->
        </td>
  </tr>
  <tr>
        <td valign="top" colspan="2"> 
          <jsp:include page="/footers/inner_footer.jsp" flush="true" />
    </td>
  </tr>
</table>
<input type="hidden" name="vendorId" value="<%=request.getParameter("vendorId")%>">
<input type="hidden" name="currentCatalogPage" value="<%=request.getAttribute("currentCatalogPage")%>">
<input type="hidden" name="catJobId" value="<%=request.getParameter("catJobId")%>">
<input type="hidden" name="offeringId" value="<%=request.getParameter("offeringId")%>">
<input type="hidden" name="tierId" value="<%=request.getParameter("tierId")%>"><%
  ProjectObject po = (ProjectObject)session.getAttribute("currentProject");
  JobObject jo = po.getCurrentJob();
%>
<input type="hidden" name="jobId" value="<%=jo.getId()%>">
<input type="hidden" name="projectId" value="<%=po.getId()%>">
<script>
	function toggleLayer(whichLayer){
		var style2 = document.getElementById(whichLayer).style;
		style2.display = style2.display=="block"? "none":"block";
	}
	function togglefilters(){
		var style2 = document.getElementById('filters').style;
		if (style2.display=="block"){
			document.getElementById('filtertoggle').innerHTML='<a href="javascript:togglefilters()" class="greybutton">+ Show Files From Archives</a>';
		}else{
			document.getElementById('filtertoggle').innerHTML='<a href="javascript:togglefilters()" class="greybutton">&raquo; Hide Files</a>';
		}
		toggleLayer('filters');
	}
	toggleLayer('waitSection');
</script>
</form>
</div>
</body>
</html>

<%
	st0.close();
	conn.close();
%>
