<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<%@ page import="java.sql.*,java.util.*,java.text.*,com.marcomet.jdbc.*,com.marcomet.workflow.*,com.marcomet.users.security.*" %>
<%@ taglib uri="/WEB-INF/tld/taglib.tld" prefix="taglib" %>
<%@ include file="/includes/SessionChecker.jsp" %>
<jsp:useBean id="validator" class="com.marcomet.tools.FieldValidationBean" scope="page" />
<jsp:useBean id="formater" class="com.marcomet.tools.FormaterTool" scope="page" />
<html>
<head>
  <title>Confirm Final Invoice</title>
  <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
  <link rel="stylesheet" href="<%=(String)session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css">
</head>
<jsp:getProperty name="validator" property="javaScripts" />
<script language="JavaScript" src="/javascripts/mainlib.js"></script>
<body class="contentstitle" >
<form method="post" action="/servlet/com.marcomet.sbpprocesses.ProcessJobSubmit">
  <p class="Title">Confirm Final Invoice
    <%
    Connection conn = com.marcomet.jdbc.DBConnect.getConnection();
Statement st = conn.createStatement();
String jobId = request.getParameter("jobId");

String query = "SELECT escrow_amount, shipping_price AS shipping FROM jobs WHERE id = " + jobId;
ResultSet rs = st.executeQuery(query);

Hashtable rehash = new Hashtable();

if(rs.next()) {
	rehash.put("escrow", (new Double(rs.getDouble("escrow_amount"))).toString());
	rehash.put("shipping", (new Double(rs.getDouble("shipping"))).toString());
}

String queryJSPrice = "SELECT SUM(js.price) 'price' FROM job_specs js WHERE js.job_id = " + jobId;
ResultSet rsPrice = st.executeQuery(queryJSPrice);
if(rsPrice.next()){
	String price = rsPrice.getString("price");
	if (price == null)
		price = "0";
	rehash.put("price", price);
}else{
	rehash.put("price", "0");
}


int counter = 0;
double sum = 0;
String changesQuery = "SELECT jc.price 'price' FROM jobchanges jc WHERE jc.statusid = 2 AND jc.jobid = " + jobId;
ResultSet rs2 = st.executeQuery(changesQuery);
while (rs2.next()) {
	rehash.put("change" + counter, (new Double(rs2.getDouble("price"))).toString());
	sum = sum + rs2.getDouble("price");
	counter++;
}
rehash.put("sum", (new Double(sum)).toString());

try { st.close(); } catch (Exception e) {}
try { conn.close(); } catch (Exception e) {}
%>
  </p>
  <jsp:include page="/includes/JobDetailHeader.jsp" flush="true"><jsp:param  name="jobId" value="<%=request.getParameter("jobId")%>" /></jsp:include>
  <p> <b>Instructions:</b> <span class="body">Please verify the following information 
    and confirm the remaining chargeable amount to be invoiced. You have an option 
    to submit this invoice either &quot;Payment Required&quot; for final delivery 
    of work or Payment Not Required&quot;. If Payment is not required you will 
    be able to submit your final work materials to your client prior to their 
    payment. Payment will be released from escrow upon client final acceptance 
    of the work and payment is made in full.</span></p>
<p>
  <span class=label>Sender's Message:</span><br>
  <textarea cols="60" rows=3 name="message"><%= request.getParameter("message") %> </textarea>
  </p>

  <hr width="100%" align="left" size="1">
  <p>Sales Tax Information</p>
  <table width="25%">
    <tr> 
      <td class='tableheader'> 
        <div align="left">Tax Entity</div>
      </td>
      <td class="body"> <taglib:LUTableValueTag table="lu_abreviated_states" selected="<%= request.getParameter("taxEntity") %>"/> 
        <input type="hidden" name='taxEntity' value="<%= request.getParameter("taxEntity") %>" >
      </td>
    </tr>
    <tr> 
      <td class='tableheader'> 
        <div align="left">Tax Rate</div>
      </td>
      <td class="body"> <%= request.getParameter("taxRate") %> % 
        <input type="hidden" name='taxRate' value=<%= request.getParameter("taxRate") %> >
      </td>
    </tr>
    <tr> 
      <td class='tableheader'> 
        <div align="left">Tax Shipping</div>
      </td>
      <td class="body"> <%= request.getParameter("taxShipping").equals("1") ? "Yes":"No" %> 
        <input type="hidden" name='taxShipping' value=<%= request.getParameter("taxShipping") %> >
      </td>
    </tr>
    <tr> 
      <td class='tableheader'> 
        <div align="left">Tax Job</div>
      </td>
      <td class="body"> <%= request.getParameter("taxJob").equals("1") ? "Yes":"No" %> 
        <input type="hidden" name='taxJob' value=<%= request.getParameter("taxJob") %> >
      </td>
    </tr>
    <tr> 
      <td class='tableheader'> 
        <div align="left">Buyer Exempt</div>
      </td>
      <td class="body"> <%= request.getParameter("buyerExempt").equals("1") ? "Yes":"No" %> 
        <input type="hidden" name='buyerExempt' value=<%= request.getParameter("buyerExempt") %> >
      </td>
    </tr>
  </table>  <hr width="100%" align="left" size="1">
  <p><br>
    Job Totals </p>
  <table width="25%">
    <tr> 
      <td class='label' width="80%"> 
        <div align="left"></div>
      </td>
    </tr>
    <tr valign="bottom"> 
      <td class='tableheader' width="80%"> 
        <div align="left">Original Order</div>
      </td>
      <td align='right' class="body" width="20%"><%= formater.getCurrency((String)rehash.get("price")) %> 
        <div align="right"></div>
      </td>
    </tr>
    <% for (int i=0; i<counter; i++) { %>
    <tr valign="bottom"> 
      <td class='tableheader' width="80%"> 
        <div align="left">Change Order</div>
      </td>
      <td align='right' class="body" width="20%"><%= formater.getCurrency((String)rehash.get("change" + i)) %> 
        <div align="right"></div>
      </td>
    </tr>
    <% } %>
    <tr valign="bottom"> 
      <td class='tableheader' width="80%"> 
        <div align="left">Subtotal</div>
      </td>
      <td align='right' class="TopborderText" width="20%"> 
        <% double subtotal = Double.parseDouble((String)rehash.get("sum")) + Double.parseDouble((String)rehash.get("price")); %>
        <%= formater.getCurrency( subtotal ) %> 
        <div align="right"> 
               <input type="hidden" name='subtotal' value=<%= subtotal %> >
        </div>
      </td>
    </tr>
    <tr valign="bottom"> 
      <td class='tableheader' width="80%"> 
        <div align="left">Shipping</div>
      </td>
      <td align='right' class="body" width="20%"> 
        <% double shipping = Double.parseDouble((String)rehash.get("shipping")) + Double.parseDouble((String)request.getParameter("price")); %>
        <%= formater.getCurrency(shipping) %> 
        <div align="right"> 
          <input type="hidden" name='shipping' value="<%= shipping %>" >
        </div>
      </td>
    </tr>
    <tr valign="bottom"> 
      <td class='tableheader' width="80%"> 
        <div align="left">Sales Tax</div>
      </td>
      <td align='right' class="body" width="20%"> 
        <% double salesTax;
	     if (request.getParameter("buyerExempt").equals("1")) {
            salesTax = 0;
		 } else {
            double tempShipping = shipping;
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
        <div align="right"> 
          <input type="hidden" name='salesTax' value=<%= salesTax %> >
        </div>
    <tr> 
    <tr valign="bottom"> 
      <td class='tableheader' width="80%"> 
        <div align="left">Total Invoice</div>
      </td>
      <td align='right' class="TopborderText" width="20%"> 
        <% double total = subtotal + shipping + salesTax; %>
        <%= formater.getCurrency( total ) %> 
        <div align="right">
                  </div>
      </td>
    </tr>
    <tr valign="bottom"> 
      <td class='tableheader' width="80%"> 
        <div align="left">Escrow Charged to Date</div>
      </td>
      <td align='right' class="body" width="20%"><%= formater.getCurrency((String)rehash.get("escrow")) %> 
        <div align="right"></div>
      </td>
    </tr>
    <tr valign="bottom"> 
      <td class='tableheader' width="80%"> 
        <div align="left">Remainder Chargeable</div>
      </td>
      <td align='right' class="TopborderLable" width="20%"> 
        <% double remainder = total - Double.parseDouble((String)rehash.get("escrow")); %>
        <%= formater.getCurrency(remainder) %> 
        <div align="right"> 
           <input type="hidden" name='remainder' value=<%= remainder %> >
          
        </div>
      </td>
    </tr>
    <tr> 
      <td width="80%"> 
        <div align="left"></div>
      </td>
    </tr>
  </table>

  <hr width="100%" align="left" size="1">
  <table border="0" width="65%" align="center">
	  <tr><td width=3%>&nbsp;</td>
<%
	ResultSet rsJobActions = st.executeQuery("SELECT a.id 'id', a.actionperform 'actionperform', j.id 'jobId' FROM jobflowactions a, jobs j WHERE a.currentstatus = j.status_id AND a.fromstatus = j.last_status_id AND a.whosaction = "+ ((((RoleResolver)session.getAttribute("roles")).isVendor())?"2":"1") +" AND j.id = " + request.getParameter("jobId")+" ORDER BY actionorder");
	while(rsJobActions.next()) { %>			
	    <td class="graybutton"><a href="javascript:moveWorkFlow('<%=rsJobActions.getString("id")%>')"><%= rsJobActions.getString("actionperform")%></a></td>
		<td width=3%>&nbsp;</td>
<% } %>
</tr>
</table>

<input type="hidden" name="shipdate" value="<%= request.getParameter("shipdate") %>">
<input type="hidden" name="method" value="<%= request.getParameter("method") %>">
<input type="hidden" name="reference" value="<%= request.getParameter("reference") %>">
<input type="hidden" name="cost" value="<%= request.getParameter("cost") %>">
<input type="hidden" name="mu" value="<%= request.getParameter("mu") %>">
<input type="hidden" name="fee" value="<%= request.getParameter("fee") %>">
<input type="hidden" name="price" value="<%= request.getParameter("price") %>">
<input type="hidden" name="shippedTo" value="buyer">
<input type="hidden" name="shippedFrom" value="seller">
<input type="hidden" name="description" value="n/a">
<input type="hidden" name="shippingStatus" value="final">

<input type="hidden" name="jobId" value="<%= request.getParameter("jobId") %>" >
<input type="hidden" name="$$Return" value="[/minders/JobMinderSwitcher.jsp]">
<input type="hidden" name="nextStepActionId" value="">  

</form>
</body>
</html><%st.close();conn.close();%>
