<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<%@ page import="com.marcomet.tools.*,com.marcomet.catalog.*;" %>
<%@ taglib uri="/WEB-INF/tld/taglib.tld" prefix="taglib" %>

<jsp:useBean id="validator" class="com.marcomet.tools.FieldValidationBean" scope="page" />
<jsp:useBean id="cB" class="com.marcomet.beans.SBPContactBean" scope="page" />
<jsp:useBean id="sl" class="com.marcomet.tools.SimpleLookups" scope="page" />
<jsp:useBean id="formater" class="com.marcomet.tools.FormaterTool" scope="page" />

<jsp:setProperty name="cB" property="*"/>  
<%
cB.setContactId((String)session.getAttribute("contactId"));
	String jobId=request.getParameter("jobId");

//Thss form will process the self-designed 'job', reformat the pdf associated with the job for 8.5 x 11 with .5" margins
//and save the file as a 'self-designed laser' file.
//Once processed the file will be available for immediate download.

//Note: Add 'Self-Designed Laser File' to the job name in the job object.
//		Change the file type to one that will allow the user to see the job.

%>
<html>
<head>
<title>Save / Download Laser-Compatible File</title>
<META HTTP-EQUIV="pragma" CONTENT="no-cache">
<META HTTP-EQUIV="Pragma-directive" CONTENT="no-cache">
<META HTTP-EQUIV="cache-directive" CONTENT="no-cache">
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link rel="stylesheet" href="<%=(String)session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css">
</head>
<script language="JavaScript">
	function submitLogin(){
		document.forms[0].action ="/servlet/com.marcomet.users.security.LoginUserServlet";
		document.forms[0].$$Return.value= "[/catalog/checkout/SaveLaserFile.jsp]";
		document.forms[0].submit();
	}
</script>
<jsp:getProperty name="validator" property="javaScripts" />
<script language="JavaScript" src="/javascripts/mainlib.js"></script>
<body bgcolor="#FFFFFF" text="#000000"  onLoad="populateTitle('Process Laser File')" >
<div id="waitSection" style="display: 'none';">
<br><br><br><br><br><br>
  <div align="center"> 
    <h2>Processing File<img src="/images/generic/dotdot.gif" width="72" height="10"></h2>
  </div>
</div>
<div id="formSection" style="display: '';">
<form method="post" action="/servlet/com.marcomet.sbpprocesses.ProcessJobSubmit" >
<input type="hidden" name="nextStepActionId" value="">
<input type="hidden" name="jobId" value="0">
<input type="hidden" name="printFileType" value="Laser">
<input type="hidden" name="defaultRoleId" value="1">
<input type="hidden" name="errorPage" value="/catalog/checkout/SaveLaserFile.jsp">
<input type="hidden" name="dollarAmount" value="<%= ((ShoppingCart)session.getAttribute("shoppingCart")).getOrderEscrowTotal()%>">
<input type="hidden" name="companyId" value="<%=cB.getCompanyIdString()%>">
<input type="hidden" name="$$Return" value="[/catalog/checkout/SelfDesignedFileSaved.jsp]">
<input type="hidden" name="formChangedPhones" value="<%= (request.getParameter("formChangedPhones") == null )?"0":request.getParameter("formChangedPhones") %>">
<input type="hidden" name="formChangedLocations" value="<%= (request.getParameter("formChangedLocations") == null )?"0":request.getParameter("formChangedLocations") %>">
<input type="hidden" name="formChangedContact" value="<%= (request.getParameter("formChangedCompany") == null )?"0":request.getParameter("formChangedContact") %>">
<input type="hidden" name="formChangedCompany" value="<%= (request.getParameter("formChangedCompany") == null )?"0":request.getParameter("formChangedCompany") %>">
<% if(session.getAttribute("contactId") == null){ %>
<table>
	<tr>
		<td colspan="4">
			I'm a returning Registered User
		</td>
	</tr>
	<tr>	
		
      <td colspan="4" height="32">
	  	  <input type="text" name="userName" value="">
          <input type="password" name="password" value="">
          <a href="javascript:submitLogin()" class="menuLINK" >Login</a> --or 
          Complete the Information Below-- </td>
	</tr></table>
<%	} else { %>
<script>moveWorkFlow('1');</script>
<% } %>	
</form>
</div>
</body>
</html>
