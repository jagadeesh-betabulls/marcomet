<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<%
	//if this page was entered as a result of a self-help designed file run remove the 'usePreview' and 'selfDesigned' attributes from session.
	if(session.getAttribute("selfDesigned")!=null && session.getAttribute("selfDesigned").toString().equals("true")){
		session.removeAttribute("usePreview");
		session.removeAttribute("selfDesigned");
	}
	String finalFileAddress=((request.getAttribute("finalFileAddress")==null)?"":request.getAttribute("finalFileAddress").toString());
%><html>
<head>
<title>File Save Confirmation</title>
  <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
  <link rel="stylesheet" href="<%=(String)session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css">
</head>
<script language="javascript" src="/javascripts/mainlib.js"></script>
<body leftmargin="10" topmargin="10" marginwidth="0" marginheight="0" onLoad="MM_preloadImages('/images/buttons/continueover.gif')" background="<%=(String)session.getAttribute("siteHostRoot")%>/images/back3.jpg"><table height="100%" width="100%">
  <tr> 
    <td valign="top"> 
      <table width="100%">
        <tr> 
          <td class="s" valign="top"><span class=subtitle>Self-Help Design Center<br></span></td>
        </tr>
      </table>
    </td>
  </tr>
  <tr> 
    <td align="center" class="catalogLABEL"> 
    <%=if(finalFileAddress.equals("")){%>
          <p class="catalogTITLE">Your file has been saved. You may download it on the following page, or at any time by going to your 'DIY Files' under the MY FILES menu.<br></p>
    <%}else{%>
      <p class="catalogTITLE">Your file has been saved. You may download it on the following page, or at any time by going to your 'DIY Files' under the MY FILES menu.</p><br>
<!--      <div align="center"><a href="<%=request.getParameter("")%>") class="plainLink">&nbsp;DOWNLOAD FILE&nbsp;&raquo;</a></div><br><br>  -->
      <%}%>
      <p>Thank you!</p><p>&nbsp;</p>
    </td>
  </tr>
    <td colspan="2" align="center"> <a href="javascript:parent.window.location.replace('<%=(String)session.getAttribute("siteHostRoot")%>/contents/SiteHostIndex.jsp')" class="greybutton">Continue</a> 
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
</html>
