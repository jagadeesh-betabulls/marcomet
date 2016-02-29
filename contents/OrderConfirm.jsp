<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<%
String orderId=((request.getAttribute("orderId")==null)?((request.getParameter("orderId")==null)?"0":request.getParameter("orderId")):request.getAttribute("orderId").toString());
String payType=((request.getParameter("pay_type")==null)?"account":request.getParameter("pay_type"));
String ccNumberMasked = ((request.getParameter("ccNumberMasked")!=null)?request.getParameter("ccNumberMasked"):((request.getParameter("ccNumber")==null || request.getParameter("ccNumber").length()<5)?"":request.getParameter("ccNumber").substring(request.getParameter("ccNumber").length()-4,request.getParameter("ccNumber").length())));
String ccMonth=((request.getParameter("ccMonth")==null)?"":request.getParameter("ccMonth"));
String ccYear=((request.getParameter("ccYear")==null)?"":request.getParameter("ccYear"));
String pastref=((request.getParameter("pastref")==null)?"":request.getParameter("pastref"));
String ccType=((request.getParameter("ccType")==null)?"Other Card":request.getParameter("ccType"));
String totalDollarAmount=((request.getParameter("totalDollarAmount")==null)?"0":request.getParameter("totalDollarAmount"));
String pastACref=((request.getParameter("pastACref")==null)?"0":request.getParameter("pastACref"));
String bankName=((request.getParameter("bankName")==null)?"0":request.getParameter("bankName"));
String accountNumber=((request.getParameter("accountNumber")==null)?"0":request.getParameter("accountNumber"));

%>
<html>
<head>
<title>Order Confirmation</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link rel="stylesheet" href="<%=(String)session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css">
  <script language="javascript" src="/javascripts/mainlib.js" type="text/javascript"></script>
</head>
<body bgcolor="#FFFFFF" text="#000000">
      	<jsp:include page="/includes/OrderConfirmOnAccount.jsp" flush="true">
        	<jsp:param name="orderId" value="<%=orderId%>"></jsp:param>
        	<jsp:param name="print" value="true"></jsp:param>
        	<jsp:param name="pay_type" value="<%=payType%>"></jsp:param>
        	<jsp:param name="ccNumberMasked" value="<%=ccNumberMasked%>"></jsp:param>
        	<jsp:param name="ccMonth" value="<%=ccMonth%>"></jsp:param>
        	<jsp:param name="ccYear" value="<%=ccYear%>"></jsp:param>
        	<jsp:param name="pastref" value="<%=pastref%>"></jsp:param>
        	<jsp:param name="totalDollarAmount" value="<%=totalDollarAmount%>"></jsp:param>
        	<jsp:param name="pastACref" value="<%=pastACref%>"></jsp:param>
        	<jsp:param name="bankName" value="<%=bankName%>"></jsp:param>
        	<jsp:param name="accountNumber" value="<%=accountNumber%>"></jsp:param>
        	<jsp:param name="ccType" value="<%=ccType%>"></jsp:param>
        </jsp:include>
</body>
</html>
