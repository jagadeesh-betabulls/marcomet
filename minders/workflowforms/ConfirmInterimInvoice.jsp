<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<%@ page import="java.sql.*,java.util.*,java.text.*,com.marcomet.jdbc.*,com.marcomet.workflow.*,com.marcomet.users.security.*;" %>
<%@ taglib uri="/WEB-INF/tld/taglib.tld" prefix="taglib" %>
<%@ include file="/includes/SessionChecker.jsp" %>
<jsp:useBean id="validator" class="com.marcomet.tools.FieldValidationBean" scope="page" />
<jsp:useBean id="formater" class="com.marcomet.tools.FormaterTool" scope="page" />
<%
String jobId = request.getParameter("jobId");

String query = "select price, escrow_amount, shipping_price as shipping from jobs where id = " + jobId;

Connection conn = DBConnect.getConnection();
Statement st = conn.createStatement();
ResultSet rs = st.executeQuery(query);

Hashtable rehash = new Hashtable();

while (rs.next()) {
	//rehash.put("price", (new Double(rs.getDouble("price"))).toString());
	rehash.put("escrow", (new Double(rs.getDouble("escrow_amount"))).toString());
	rehash.put("shipping", (new Double(rs.getDouble("shipping"))).toString());
}

String queryJSPrice = "SELECT SUM(js.price) 'price' FROM job_specs js WHERE js.cost != -1 AND js.job_id = " + jobId;
ResultSet rsPrice = st.executeQuery(queryJSPrice);
if(rsPrice.next()){
	rehash.put("price", rsPrice.getString("price"));
}else{
	rehash.put("price", "0");
}

int counter = 0;
double sum = 0;
String changesQuery = "select price from jobchanges where jobid = " + jobId;
ResultSet rs2 = st.executeQuery(changesQuery);
while (rs2.next()) {
	rehash.put("change" + counter, (new Double(rs2.getDouble("price"))).toString());
	sum = sum + rs2.getDouble("price");
	counter++;
}
rehash.put("sum", (new Double(sum)).toString());

	st.close();
	conn.close();
%>

<html>
<head>
  <title>Confirm Invoice</title>
  <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
  <link rel="stylesheet" href="<%=(String)session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css">
</head>
<jsp:getProperty name="validator" property="javaScripts" />
<script language="JavaScript" src="/javascripts/mainlib.js"></script>

<body class="body" onLoad="MM_preloadImages('/images/buttons/continueover.gif','/images/buttons/cancelbtover.gif')">
<form method="post" action="/servlet/com.marcomet.sbpprocesses.InterimInvoiceServlet">
  <p class="Title">Confirm Invoice</p>
  
  <jsp:include page="/includes/JobDetailHeader.jsp" flush="true"><jsp:param  name="jobId" value="<%=request.getParameter("jobId")%>" /></jsp:include>
<p>
  <b>Instructions:</b> Please verify the following information and choose the amount to be billed.
</p>
<p>
  <span class=label>Sender's Message:</span><br>
  <textarea cols="60" rows=3 name="message"><%= request.getParameter("message") %> </textarea><br>
</p>
  <table class="body" width="25%">
    <tr> 
      <td class='label' width="70%">Sales Tax:</td>
      <td width="30%">&nbsp;</td>
    </tr>
    <tr> 
      <td class='minderheaderleft' width="70%">Tax Entity</td>
      <td width="30%"> <taglib:LUTableValueTag table="lu_abreviated_states" selected="<%= (String)request.getParameter("taxEntity")%>"/> 
        <input type='hidden' name='taxEntity' value=<%= request.getParameter("taxEntity") %> >
      </td>
    </tr>
    <tr> 
      <td class='minderheaderleft' width="70%">Tax Rate</td>
      <td width="30%"> <%= request.getParameter("taxRate") %>% 
        <input type='hidden' name='taxRate' value=<%= request.getParameter("taxRate") %> >
      </td>
    </tr>
    <tr> 
      <td class='minderheaderleft' width="70%">Tax Shipping</td>
      <td width="30%"> <%= request.getParameter("taxShipping").equals("1") ? "Yes":"No" %> 
        <input type='hidden' name='taxShipping' value=<%= request.getParameter("taxShipping") %> >
      </td>
    </tr>
    <tr> 
      <td class='minderheaderleft' width="70%">Tax Job</td>
      <td width="30%"> <%= request.getParameter("taxJob").equals("1") ? "Yes":"No" %> 
        <input type='hidden' name='taxJob' value=<%= request.getParameter("taxJob") %> >
      </td>
    </tr>
    <tr> 
      <td class='minderheaderleft' width="70%">Buyer Exempt</td>
      <td width="30%"> <%= request.getParameter("buyerExempt").equals("1") ? "Yes":"No" %> 
        <input type='hidden' name='buyerExempt' value=<%= request.getParameter("buyerExempt") %> >
      </td>
    </tr>
  </table>
<br>
  <table class="TopborderText" width="30%">
    <tr> 
      <td class='label' width="59%">Job Totals</td>
    </tr>
    <tr> 
      <td class='minderheaderleft' width="59%">Original Order</td>
      <td align='right' width="41%" class="body"><%= formater.getCurrency((String)rehash.get("price")) %></td>
    </tr>
    <% for (int i=0; i<counter; i++) { %>
    <tr> 
      <td class='minderheaderleft' width="59%">Change Order</td>
      <td align='right' width="41%" class="body"><%= formater.getCurrency((String)rehash.get("change" + i)) %></td>
    </tr>
    <% } %>
    <tr> 
      <td class='minderheaderleft' width="59%">Subtotal</td>
      <td align='right' width="41%" class="TopborderText"> 
        <% double subtotal = Double.parseDouble((String)rehash.get("sum")) + Double.parseDouble((String)rehash.get("price")); %>
        <%= formater.getCurrency( subtotal ) %> 
        <input type='hidden' name='subtotal' value=<%= subtotal %> >
      </td>
    </tr>
    <tr> 
      <td class='minderheaderleft' width="59%">Shipping</td>
      <td align='right' width="41%" class="body"> <%= formater.getCurrency((String)rehash.get("shipping")) %> 
        <input type='hidden' name='shipping' value=<%= (String)rehash.get("shipping") %> >
      </td>
    </tr>
    <tr> 
      <td class='minderheaderleft' width="59%">Sales Tax</td>
      <td align='right' width="41%" class="body"> 
        <% double salesTax;
	     if (request.getParameter("buyerExempt").equals("1")) {
            salesTax = 0;
		 } else {
            double tempShipping = Double.parseDouble((String)rehash.get("shipping"));
            double tempTotal = subtotal;
            double taxRate = Double.parseDouble((String)request.getParameter("taxRate"));
            if (request.getParameter("taxShipping").equals("1")) {
                tempShipping = tempShipping * (taxRate/100);
            } else {
				tempShipping = 0;
			}
            if (request.getParameter("taxJob").equals("1")) {
                tempTotal = tempTotal * (taxRate/100);
            } else {
				tempTotal = 0;
			}
	   		salesTax = tempShipping + tempTotal;
			DecimalFormat precisionTwo = new DecimalFormat("0.##");
			String formattedSalesTax = precisionTwo.format(salesTax);
			salesTax = Double.parseDouble(formattedSalesTax);
		 } %>
        <%= formater.getCurrency( salesTax ) %> 
        <input type="hidden" name='salesTax' value=<%= salesTax %> >
      </td>
    <tr> 
    <tr> 
      <td class='minderheaderleft' width="59%">Total Invoice</td>
      <td align='right' width="41%" class="TopborderLable"> 
        <% double total = subtotal + Double.parseDouble((String)rehash.get("shipping")) + salesTax; %>
        <%= formater.getCurrency( total ) %> </td>
    </tr>
    <tr> 
      <td class='minderheaderleft' width="59%">Escrow Charged to Date</td>
      <td align='right' width="41%" class="body"><%= formater.getCurrency((String)rehash.get("escrow")) %></td>
    </tr>
    <tr> 
      <td class='minderheaderleft' width="59%">Remainder Chargeable</td>
      <td align='right' width="41%" class="TopborderLable"> 
        <% double remainder = total - Double.parseDouble((String)rehash.get("escrow")); %>
        <%= formater.getCurrency(remainder) %> 
        <input type='hidden' name='remainder' value=<%= remainder %> >
      </td>
    </tr>
    <tr> 
      <td width="59%">&nbsp;</td>
    </tr>
  </table>
<table>
  <tr> 
    <td class=label><input type="radio" name="billType" value="1" checked> Bill Remainder </td>
    <td class=label><input type="radio" name="billType" value="2"> Bill Other Amount <input type="text" name="amount" size="10"> </td>
  </tr>
</table>
<br>
<table border="0" width="25%" align="center">
  <tr>
    <td>
      <a href="javascript:document.forms[0].submit()" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('Image1','','/images/buttons/continueover.gif',1)"><img name="Image1" border="0" src="/images/buttons/continue.gif" width="74" height="20"></a>
    </td>
    <td>&nbsp;</td>
    <td>
      <a href="/minders/JobMinderSwitcher.jsp" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('Image2','','/images/buttons/cancelbtover.gif',1)"><img name="Image2" border="0" src="/images/buttons/cancelbt.gif" width="74" height="20"></a>
    </td>
  </tr>
</table>
<input type="hidden" name="jobId" value="<%= request.getParameter("jobId") %>" >
<input type="hidden" name="$$Return" value="[/minders/JobMinderSwitcher.jsp]">
</form>
</body>
</html><%conn.close(); %>
