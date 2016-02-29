<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<%@ page import="java.text.*,java.sql.*,java.util.*" %>
<%@ include file="/includes/SessionChecker.jsp" %>
<jsp:useBean id="formater" class="com.marcomet.tools.FormaterTool" scope="page" />
<%
Connection conn = com.marcomet.jdbc.DBConnect.getConnection();
Statement st = conn.createStatement();
	String jobId = request.getParameter("jobId");
%><html>
<head>
  <title>Final Invoice <%= request.getParameter("invoiceNumber")%></title>
  <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
  <link rel="stylesheet" href="<%=(String)session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css">
</head>

<body class="contentstitle">
<p class="Title"> Final Invoice</p>
<jsp:include page="/includes/JobDetailHeader.jsp" flush="true"><jsp:param  name="jobId" value="<%=request.getParameter("jobId")%>" /></jsp:include>
<hr width="100%" size="1">
<table width="24%" align="center">
  <tr> 
    <td width="48%" height="7"> 
      <div align="right"></div>
    </td>
  </tr>
  <tr> 
    <td class='minderheaderright' width="48%">Description</td>
    <td align='right' width="52%" class="minderheaderright">Cost</td>
  </tr>
  <tr> 
    <td class='lineitemright' width="48%"> 
      <div align="right"><b>Original Order</b></div>
    </td>
    <%
	//Orginal Price section	
	double origPrice = 0;
	String sqlOrigPrice = "SELECT SUM(js.price) 'sum' FROM job_specs js WHERE js.job_id = " + jobId;
	ResultSet rsOrigPrice = st.executeQuery(sqlOrigPrice);
	if(rsOrigPrice.next()){
		origPrice = rsOrigPrice.getDouble("sum");
	}	
%>
    <td align='right' width="52%" class="body"><%= formater.getCurrency(origPrice) %></td>
  </tr>
  <%
  
	//Change Prices
	double changesTotalPrice = 0;
	String sqlChangePrices = "SELECT jc.price 'price' FROM jobchanges jc WHERE jc.statusid = 2 AND jc.jobid = " + jobId;
	ResultSet rsChangePrices = st.executeQuery(sqlChangePrices);
	if(rsChangePrices.next()){
		do{ 
			changesTotalPrice += rsChangePrices.getDouble("price");
%>
  <tr> 
    <td class='lineitemright' width="48%"> 
      <div align="right">Change Order</div>
    </td>
    <td align='right' width="52%" class="body"><%= formater.getCurrency(rsChangePrices.getDouble("price")) %></td>
  </tr>
  <% 		
		}while(rsChangePrices.next()); 
	}else{	
%>
  <td class='lineitemright' width="48%"> 
    <div align="right">Change Order</div>
  </td>
  <td align='right' width="52%" class="body"><%= formater.getCurrency(0) %></td>
  <%
	}
%>
  <tr> 
    <td class='lineitemright' width="48%"> 
      <div align="right"><b>Subtotal</b></div>
    </td>
    <td align='right' width="52%" class="TopborderLable"> <%= formater.getCurrency( origPrice + changesTotalPrice ) %> 
    </td>
  </tr>
  <%
	//job table info
	double tax = 0;
	double shipping = 0;
	double escrow = 0;
	
	String sqlJobInfo = "SELECT sales_tax, shipping_price, escrow_amount FROM jobs WHERE id = " + jobId;
	ResultSet rsJobInfo = st.executeQuery(sqlJobInfo);
	if(rsJobInfo.next()){
		tax = rsJobInfo.getDouble("sales_tax");
		shipping = rsJobInfo.getDouble("shipping_price");
		escrow = rsJobInfo.getDouble("escrow_amount");	
	}
%>
  <tr> 
    <td class='lineitemright' width="48%"> 
      <div align="right">Shipping</div>
    </td>
    <td align='right' width="52%" class="body"> <%= formater.getCurrency(shipping) %> 
    </td>
  </tr>
  <tr> 
    <td class='lineitemright' width="48%"> 
      <div align="right">Sales Tax</div>
    </td>
    <td align='right' width="52%" class="body"> <%= formater.getCurrency( tax ) %> 
    </td>
  <tr> 
  <tr> 
    <td class='lineitemright' width="48%"> 
      <div align="right"><b>Total Invoice</b></div>
    </td>
    <td align='right' width="52%" class="TopborderLable"> <%= formater.getCurrency( origPrice + changesTotalPrice + shipping + tax ) %> 
    </td>
  </tr>
  <tr> 
    <td class='lineitemright' width="48%" height="36" valign="top"> 
      <div align="right">Escrowed</div>
    </td>
    <td align='right' width="52%" class="body" height="36"><%= formater.getCurrency(escrow) %></td>
  </tr>
  <tr valign="top"> 
    <td class='lineitemright' width="48%" height="21"> 
      <div align="right"><b>Remainder Due</b></div>
    </td>
    <td align='right' width="52%" class="TopborderLable" height="21"> <%= formater.getCurrency(( origPrice + changesTotalPrice + shipping + tax ) - escrow) %> 
    </td>
  </tr>
</table>

<hr width="100%" size="1">
<div align="center">
  <input type="button" value="Pay this Invoice" onClick="window.location.replace('/minders/workflowforms/FinalCollectionsForm.jsp?jobId=<%= request.getParameter("jobId")%>')">
</div>
</body>
</html><%st.close();conn.close(); %>
