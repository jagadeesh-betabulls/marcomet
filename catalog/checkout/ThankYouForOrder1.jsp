<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<%
//if this page was entered as a result of a self-help designed file run remove the 'usePreview' and 'selfDesigned' attributes from session.
boolean selfDesigned=((session.getAttribute("selfDesigned")!=null && session.getAttribute("selfDesigned").toString().equals("true"))?true:false);
if(session.getAttribute("selfDesigned")!=null && session.getAttribute("selfDesigned").toString().equals("true")){
	session.removeAttribute("usePreview");
	session.removeAttribute("selfDesigned");
}

if (session.getAttribute("promoCode")!=null){
	session.removeAttribute("promoCode");
}
String finalFileAddress=((request.getAttribute("finalFileAddress")==null)?"":request.getAttribute("finalFileAddress").toString());

boolean rePrint=((session.getAttribute("reprintJob")==null || session.getAttribute("reprintJob").toString().equals("") || session.getAttribute("reprintJob").toString().equals("false"))?false:true);

String jobId=((request.getAttribute("jobId")==null)?"":request.getAttribute("jobId").toString());
boolean fileSaved=((finalFileAddress.equals(""))?false:true);
if(!jobId.equals("") && !finalFileAddress.equals("")){
	%>
	<jsp:include page="/catalog/moveTempImageFiles.jsp" flush="true" >
		<jsp:param name="id" value="<%=jobId%>" />
	</jsp:include><%
	
//if this file should be immediately printed go to the reprint page.
}

if(rePrint){
%>
<html><head><script>window.location.replace("/catalog/reprintJobsFromFile.jsp?gtc=true&jobId=<%=jobId%>")</script></head></html>

<%	
}else{

%>
<html>
<head>
<title><%=((selfDesigned)?"File Saved":"Order")%> Confirmation</title>
  <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1"> 
  <link rel="stylesheet" href="<%=(String)session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css">
</head>
<script language="javascript" src="/javascripts/mainlib.js"></script>
<body style="margin-left:20px;" topmargin="10" marginwidth="0" marginheight="0" onLoad="MM_preloadImages('/images/buttons/continueover.gif')" background="<%=(String)session.getAttribute("siteHostRoot")%>/images/back3.jpg">
<%if(fileSaved){%>
<jsp:include page="/catalog/SHDCHeader.jsp" flush="true" >
	<jsp:param name="subTitle" value="File Saved" />
</jsp:include>
<%}%>
<div style="display:none;" id="pdfPrepDiv"><iframe height="0" width="0" marginwidth="0" marginheight="0" frameborder="0" id="pdfPrep" name="downloads" ></iframe></div>
<table height="100%" width="100%">
  <tr> 
    <td valign="top"> 

    </td>
  </tr>
  <tr> 
    <td align="center" class="catalogLABEL"> <%
    if(selfDesigned){
    %>          <p class="bodyBlack"><blockquote>Your file has been saved. You may download it now by clicking on the link below, or at anytime in the future by going to your 'Self-Help Designed Files' under the FILES menu.<br> Click 'Continue' to return to your marketing site home page.</blockquote></p><br>
      <div align="center"><a href="/popups/downloadOneFile.jsp?dlFile=<%=finalFileAddress%>" class="plainLink" target="downloads">&nbsp;DOWNLOAD FILE&nbsp;&raquo;</a></div><br><br>
         </td>
  </tr>
  <tr> 
    <td>&nbsp;</td>
  </tr>
  <tr> 
    <td colspan="2" align="center"> <a href="javascript:parent.window.location.replace('/index.jsp?contents=/files/fileManager.jsp?shdc=true')" class="greybutton">Continue</a> 
    <%
    }else{%>
      <p class="catalogTITLE"><font size="4">Your jobs have been successfully processed.</font></p><p><%
      if(request.getParameter("pay_type")==null){
      %>NO PAYMENT TYPE<%      
      } else if(request.getParameter("pay_type").equals("cc")){
      %>INSERT CREDIT CARD RECEIPT HERE<%
      } else if(request.getParameter("pay_type").equals("ach")){
      %>INSERT ACH RECEIPT HERE<%
      } else if(request.getParameter("pay_type").equals("check")){
      %>INSERT CHECK REQUEST HERE<%
      } else if(request.getParameter("pay_type").equals("account")){
      %>INSERT ON ACCOUNT RECEIPT HERE<%
      }

      %></p><p>Thank you!</p>
         </td>
  </tr>
  <tr> 
    <td>&nbsp;</td>
  </tr>
  <tr> 
    <td colspan="2" align="center"> <a href="javascript:parent.window.location.replace('/index.jsp?contents=/minders/JobMinderSwitcher.jsp')" class="greybutton">Continue</a> 
      <%}%>
    </td>
  </tr>
  <tr> 
    <td>&nbsp;</td>
  </tr>
  <tr> 
    <td valign="bottom" colspan="2"> 
      <jsp:include page="/footers/inner_footer.jsp" flush="true"></jsp:include>
    </td>
  </tr>
</table>
</body>
</html><%}%>
