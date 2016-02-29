<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<%@ page import="java.sql.*,com.marcomet.tools.*;" %>
<%@ taglib uri="/WEB-INF/tld/taglib.tld" prefix="taglib" %>
<jsp:useBean id="sl" class="com.marcomet.tools.SimpleLookups" scope="page" />
<%
Connection conn = com.marcomet.jdbc.DBConnect.getConnection();
Statement st = conn.createStatement();
String promoCode=request.getParameter("promoCode");
String removeCode=((request.getParameter("removeCode")==null)?"":request.getParameter("removeCode"));
String titleText="Apply Promo Code";
String promoCodeStatus="";
String jobId=((request.getParameter("jobId")!=null)?request.getParameter("jobId"):"");
String submitted=((request.getParameter("submitted")!=null)?request.getParameter("submitted"):"");
if(!removeCode.equals("")){
		session.removeAttribute("promoCode");
		titleText="";
}else if(submitted.equals("remove")){
	st.executeUpdate("Update jobs set promo_code='' where id="+jobId);
	titleText="";
}else if(promoCode !=null && promoCode.equals("")){
	titleText="Error - No Promo Code supplied";
}else if (request.getParameter("submitted")!=null && !request.getParameter("submitted").equals("bypass")){
	String newValSQL="Select if(end_date<NOW(),'expired',if(start_date>NOW(),'early','Valid')) as status from promotions where promo_code='"+promoCode+"'";
	ResultSet rsNV=st.executeQuery(newValSQL);
	if (rsNV.next()){
		promoCodeStatus=rsNV.getString("status");
	}
	
	if (promoCodeStatus==null || promoCodeStatus.equals("")){
		titleText="This is not a valid promo code, please choose another";
		titleText+=((jobId.equals(""))?".":", or click 'Apply' to use this code.");
	}else if(promoCodeStatus.equals("expired")){
		titleText="This promotion has expired.";
	}else if(promoCodeStatus.equals("early")){
		titleText="This promotion has not started yet.";
	}else{
		if(jobId.equals("")){
			session.setAttribute("promoCode",promoCode);
			titleText="";
		}else{
			st.executeUpdate("Update jobs set promo_code='"+promoCode+"' where id="+jobId);
			titleText="";	
		}
	}
}else if (request.getParameter("submitted")!=null && request.getParameter("submitted").equals("bypass")){
	if(jobId.equals("")){
		session.setAttribute("promoCode",promoCode);
		titleText="";
	}else{
		st.executeUpdate("Update jobs set promo_code='"+promoCode+"' where id="+jobId);
		titleText="";
	}
}

if (titleText.equals("")){
	%><html><head><script>parent.window.opener.location="/catalog/checkout/Checkout.jsp?coStep=step2";setTimeout('close()',500);</script></head><body></body></html><%
}else{
%><html>
<head>
  <title><%= titleText %></title>
  <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
  <link rel="stylesheet" href="<%=(String)session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css">
</head>
<script language="JavaScript" src="/javascripts/mainlib.js"></script>
<script>
	function removePromoCode(){
		document.forms[0].promoCode.value='';
		document.forms[0].removeCode.value='true';
		document.forms[0].submit();
	}
</script>
<body>
<form method="post" action="/popups/PromoCode.jsp">
<table border="0" cellpadding="5" cellspacing="0" align="center" width="100%">
  <tr><td class="tableheader"><%=titleText%></td></tr>
  <tr><td class="lineitems" align="center">
      <input type="text" name="promoCode" size='30' value="<%=((promoCode==null)?((session.getAttribute("promoCode")!=null)?session.getAttribute("promoCode").toString():((jobId.equals(""))?"":((sl.getValue("jobs","id","'"+jobId+"'","promo_code")==null)?"":sl.getValue("jobs","id","'"+jobId+"'","promo_code")))):promoCode)%>"></td></tr>
<tr><td align="center">
<input type="submit" value="Update" >&nbsp;&nbsp;<%
if(!jobId.equals("")){
	%><input type="button" value="Remove Code" onClick="document.forms[0].submitted.value='remove';document.forms[0].submit();" >&nbsp;&nbsp;<%
	if(!titleText.equals("") && !submitted.equals("")){
		%><input type="button" value="Apply without Validation" onClick="document.forms[0].submitted.value='bypass';document.forms[0].submit();" >&nbsp;&nbsp;<%
	}
}else if(session.getAttribute("promoCode")!=null && !session.getAttribute("promoCode").toString().equals("")){
	%><input type="button" value="Remove Code" onClick="removePromoCode();" >&nbsp;&nbsp;<%
}
%><input type="button" value="Cancel" onClick="self.close()" ></td></tr>
</table>
<input type="hidden" name="submitted" value="true">
<input type="hidden" name="removeCode" value="">
<input type="hidden" name="jobId" value="<%=jobId%>">
<input type="hidden" name="$$Return" value="<script><%=((request.getParameter("refreshOpener")!=null)?"":"parent.window.opener.location.reload();")%>setTimeout('close()',500);</script>">
<%=((request.getParameter("autosubmit")!=null && request.getParameter("autosubmit").equals("true"))?"<script>document.forms[0].submit()</script>":"")%>
</form></body>
</html><%
}
st.close();conn.close();%>