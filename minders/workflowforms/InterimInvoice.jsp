<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<%@ page import="java.sql.*,java.util.*,com.marcomet.jdbc.*,com.marcomet.workflow.*,com.marcomet.users.security.*" %>
<%@ taglib uri="/WEB-INF/tld/taglib.tld" prefix="taglib" %>
<%@ include file="/includes/SessionChecker.jsp" %>
<jsp:useBean id="validator" class="com.marcomet.tools.FieldValidationBean" scope="page" />
<%
String jobId = request.getParameter("jobId");

String query = "select price, escrow_amount, shipping_price as shipping from jobs where jobs.id = " + jobId;

Connection conn = DBConnect.getConnection();
Statement st = conn.createStatement();
ResultSet rs = st.executeQuery(query);

Hashtable rehash = new Hashtable();

if (rs.next()) {
	//rehash.put("price", (new Double(rs.getDouble("price"))).toString());
	rehash.put("escrow", (new Double(rs.getDouble("escrow_amount"))).toString());
	rehash.put("shipping", (new Double(rs.getDouble("shipping"))).toString());
} else {
	//rehash.put("price", "0");
	rehash.put("escrow", "0");
	rehash.put("shipping", "0");
}

String queryJSPrice = "SELECT SUM(js.price) 'price' FROM job_specs js WHERE cost != -1 AND js.job_id = " + jobId;
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

String taxQuery = "select entity, rate, tax_shipping, tax_job, buyer_exempt from sales_tax where job_id = " + jobId;
ResultSet rs3 = st.executeQuery(taxQuery);
if (rs3.next()) {
	rehash.put("taxEntity", rs3.getString("entity"));
	rehash.put("taxRate", rs3.getString("rate"));
	rehash.put("taxShipping", rs3.getString("tax_shipping"));
	rehash.put("taxJob", rs3.getString("tax_job"));
	rehash.put("buyerExempt", rs3.getString("buyer_exempt"));
}else{
	rehash.put("taxEntity", "0");
	rehash.put("taxRate", "0");
	rehash.put("taxShipping", "0");
	rehash.put("taxJob", "0");
	rehash.put("buyerExempt", "0");
}

try { st.close(); } catch (Exception e) {}
try { conn.close(); } catch (Exception e) {}
%>
<html>
<head>
  <title>Interim Invoice</title>
  <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
  <link rel="stylesheet" href="<%=(String)session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css">
</head>

<jsp:getProperty name="validator" property="javaScripts" />
<script language="JavaScript" src="/javascripts/mainlib.js"></script>

<body class="body" onLoad="MM_preloadImages('/images/buttons/continueover.gif','/images/buttons/cancelbtover.gif')">
<form method="post" action="/minders/workflowforms/ConfirmInterimInvoice.jsp">
  <p class="Title">Interim Invoice </p>
 
<jsp:include page="/includes/JobDetailHeader.jsp" flush="true"><jsp:param  name="jobId" value="<%=request.getParameter("jobId")%>" /></jsp:include>
<p>
  <b>Instructions:</b> Complete this form to initiate an interim billing to your customer.  You may use 
  this opportunity to review the sales tax calculations as they are currently estimated.  You will have 
  the opportunity to finally confirm those calculations at final billing.
</p>
<p>
  <span class="label">Sender's Message:</span><br>
  <textarea cols="60" rows="3" name="message"></textarea><br>
</p>
  <table width="30%">
    <tr> 
      <td class="label">Sales Tax:</td>
      <td class="body">&nbsp;</td>
    </tr>
    <tr> 
      <td class="minderheaderleft">Tax Entity</td>
      <td class="body"> <taglib:LUDropDownTag dropDownName="taxEntity" table="lu_abreviated_states" selected="<%= (String)rehash.get("taxEntity")%>" /> 
      </td>
    </tr>
    <tr> 
      <td class="minderheaderleft">Tax Rate</td>
      <td class="body"> 
        <input type="text" size="4" name="taxRate" value="<%= (String)rehash.get("taxRate") %>" >
      </td>
    </tr>
    <tr> 
      <td class="minderheaderleft">Tax Shipping</td>
      <td class="body"> 
        <select name="taxShipping">
          <% if (Integer.parseInt((String)rehash.get("taxShipping")) == 1) { %>
          <option selected value="1">yes</option>
          <option value="0">no</option>
          <% } else { %>
          <option value="1">yes</option>
          <option selected value="0">no</option>
          <% } %>
        </select>
      </td>
    </tr>
    <tr> 
      <td class="minderheaderleft">Tax Job</td>
      <td class="body"> 
        <select name="taxJob">
          <% if (Integer.parseInt((String)rehash.get("taxJob")) == 1) { %>
          <option selected value="1">yes</option>
          <option value="0">no</option>
          <% } else { %>
          <option value="1">yes</option>
          <option selected value="0">no</option>
          <% } %>
        </select>
      </td>
    </tr>
    <tr> 
      <td class="minderheaderleft">Buyer Exempt</td>
      <td class="body"> 
        <select name="buyerExempt">
          <% if (Integer.parseInt((String)rehash.get("buyerExempt")) == 1) { %>
          <option selected value="1">yes</option>
          <option value="0">no</option>
          <% } else { %>
          <option value="1">yes</option>
          <option selected value="0">no</option>
          <% } %>
        </select>
      </td>
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
