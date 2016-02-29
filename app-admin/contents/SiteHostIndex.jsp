<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<%@ include file="/includes/SessionChecker.jsp" %>
<%@ taglib uri="/WEB-INF/tld/taglib.tld" prefix="taglib" %>
<html>
<head>
   <title>Services for Graphic Designers</title>
   <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
   <link rel="stylesheet" href="<%=(String)session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css">  
</head>
<script language="JavaScript" src="/javascripts/mainlib.js"></script>
<style></style>
<body onLoad="toggleNewOrder('off')" onUnload="toggleNewOrder('on')" leftmargin="0" topmargin="0" >
<table width="100%" align="top" height=100% border=0 cellpadding="0" cellspacing="0" >
  <tr align="top"><td width=8 class="leftNavBarSpaceFiller">&nbsp;</td>
    	<td nowrap align="left" valign="top" width="170" class='leftNavBarTable'> <taglib:SiteVendorOfferingsTag siteHostId="<%= (String)session.getAttribute(\"siteHostId\") %>"/> 
    	</td><td width=2>&nbsp;</td>
		<td valign=top>
		<%
			if(request.getParameter("content") ==null){
	  			if(session.getAttribute("contactId") == null){	
					String dPage = (String)session.getAttribute("siteHostRoot") + "/includes/UnloginHome.jsp";%>
					<jsp:include page="<%= dPage %>" flush="true" /><%
  				} else { 
					String dPage = (String)session.getAttribute("siteHostRoot") + "/includes/LoginHome.jsp";%>
					<jsp:include page="<%= dPage %>" flush="true" /><%
  				}
			}else{
				String dPage = (String)request.getParameter("content");
			%>
				<jsp:include page="<%= dPage %>" flush="true" />
		<%	
			}	
		%>
		</td>
	</tr>
</table>		
		
</body>
</html>
