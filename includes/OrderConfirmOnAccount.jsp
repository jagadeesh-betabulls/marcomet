<%@ page import="com.marcomet.environment.*,com.marcomet.users.security.*, java.util.*,java.sql.*" %>
<%@ taglib uri="/WEB-INF/tld/iterationTagLib.tld" prefix="iterate" %>
<jsp:useBean id="sl" class="com.marcomet.tools.SimpleLookups" scope="page" />
<jsp:useBean id="formater" class="com.marcomet.tools.FormaterTool" scope="page" />
<% 
String prod_thumb_pre="/sitehosts/";
SiteHostSettings shs = (SiteHostSettings) session.getAttribute("siteHostSettings");
UserProfile up = (UserProfile)session.getAttribute("userProfile");
String orderDate="";
String prod_thumb="";
String orderId=((request.getParameter("orderId")==null)?"0":request.getParameter("orderId"));
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

double costSubtotal = 0.00;
double discountSubtotal = 0.00;
double priceSubtotal = 0.00;
double shipSubtotal = 0.00;
double taxSubtotal = 0.00;
double orderTotal=0.00;
boolean shipTBD=false;
boolean discountApplied=false;

String orderQuery = "Select concat(if(l.ship_to_name is null or l.ship_to_name='',co.company_name,l.ship_to_name),'<br>',l.address1,if(l.address2='','','<br>'),l.address2,'<br>',l.city,', ',st.state_name,'  ',l.zip) as shipaddress,date_format(o.date_created,'%m/%d/%y')  as 'orderdate' from orders o left join projects p on p.order_id=o.id left join jobs j on j.project_id=p.id left join shipping_locations l on l.id=j.ship_location_id left join lu_states st on st.state_number=l.state left join companies co on co.id=l.companyid where o.id="+orderId;

String jobQuery = "Select *,if(ship_price_policy=0 and shipping_price=0,'TBD *',shipping_price) as 'shippingPrice' from jobs j left join projects p on j.project_id=p.id left join orders o on o.id=p.order_id where o.id="+orderId;

Connection conn = com.marcomet.jdbc.DBConnect.getConnection();
Statement st = conn.createStatement();
Statement st2 = conn.createStatement();  
Statement st3 = conn.createStatement();   
ResultSet orderRS = st2.executeQuery(orderQuery); 
ResultSet jobsRS = st.executeQuery(jobQuery); 
request.setAttribute("jobsRS", jobsRS); 
orderRS.next();
%>
<div style="margin-left:30px;margin-right:50px;"><%
if(payType.equals("account")){

%><div class="Title">PURCHASE ORDER RECORD FOR ORDER PLACED ON <%=shs.getSiteName().toUpperCase()%></div><br><br><br>
<div class="bodyBlack">We have processed your order which will be fulfilled under the terms of service for this website and you will be billed on account.<br>This form is being provided to you as a convenience by <%=shs.getSiteName()%> to facilitate your approval for payment for this order, detailed as follows:<%
} else if(payType.equals("cc")){

%><div class="Title">CREDIT CARD RECEIPT FOR ORDER PLACED ON <%=shs.getSiteName().toUpperCase()%></div><br><br><br>
<div class="bodyBlack">We have processed your order which will be fulfilled under the terms of service for this website.  This form is being provided to you as a receipt of this credit card payment for this order, detailed as follows:<br><br>
<table border="0" cellspacing="5">
	<tr>
		<td class="catalogLabel" valign="top">Credit Card: </td><td valign="top" class="bodyBlack"><%
		
		if(pastref.equals("") || pastref.equals("NEW")){
			String ccString=((ccType==null)?"Other Card":((ccType.equals("1"))?"Visa":((ccType.equals("2"))?"Mastercard":((ccType.equals("3"))?"American Express":((ccType.equals("4"))?"Discover":"Other Card")))));

			%><%=ccString%>:  ***************<%=ccNumberMasked%> - Exp. Date: <%=ccMonth%>/20<%=ccYear%><%
		}else{
			String cSQL="select id,concat(acct_type,': ',masked_num,' - Exp Date:',left(exp_date,2),'/',right(exp_date,2),if(to_days(date_expires)>to_days(now()),'',' ****EXPIRED*****')) as 'display' from cred_tx where lastref='"+pastref+"'";

			ResultSet rsCardInfo = st3.executeQuery(cSQL);
			String cardInfoStr="Credit Card on File Used.";
			if(rsCardInfo.next()){
				if(rsCardInfo.getString("id")!=null){
					cardInfoStr=rsCardInfo.getString("display");
				}
			}
			%><%=cardInfoStr%><%
		}
		%></td></tr>
		<tr><td class="catalogLabel" valign="top">Amount Billed: </td><td valign="top" class="bodyBlack">$<%=totalDollarAmount%></td></tr>
	</table>
<%
} else if(payType.equals("ach")){

%><div class="Title">ACH / ELECTRONIC CHECK RECEIPT FOR ORDER PLACED ON <%=shs.getSiteName().toUpperCase()%></div><br><br><br>
<div class="bodyBlack">We have processed your order which will be fulfilled under the terms of service for this website.  This form is being provided to you as a receipt of this ACH debit payment for this order, detailed as follows:<br>
<table border="0" cellspacing="5">
	<tr>
		<td class="catalogLabel" valign="top">Bank / Acct: </td><td valign="top" class="bodyBlack"><%
	if(pastACref==null || pastACref.equals("") || pastACref.equals("NEW")){
		%><%=bankName%> - ****<%=accountNumber.substring(accountNumber.length()-4,accountNumber.length())%><%
		}else{
			String cSQL="select id,concat(bank_name,', ',if(acct_type='s','Savings Account: ','Checking Account: '),': ',masked_num) as 'display' from cred_tx where lastref='"+pastACref+"'";

			ResultSet rsCardInfo = st3.executeQuery(cSQL);
			String cardInfoStr="Credit Card on File Used.";
			if(rsCardInfo.next()){
				if(rsCardInfo.getString("id")!=null){
					cardInfoStr=rsCardInfo.getString("display");
				}
			}
			%><%=cardInfoStr%><%

		}
		%></td></tr>
		<tr><td class="catalogLabel" valign="top">Amount Billed: </td><td valign="top" class="bodyBlack">$<%=totalDollarAmount%></td></tr>
	</table>
<br>
<%

} else if(payType.equals("check")){
%><div class="Title">RECEIPT / CHECK REQUEST FOR ORDER PLACED ON <%=shs.getSiteName().toUpperCase()%></div><br><br><br>
<div class="bodyBlack">We have processed your order and await your payment prior to releasing your order for production/shipping.  This form is being provided to you as a convenience to facilitate your request for a payment for this order, detailed as follows:<br><br>

<table border="0" cellspacing="5">
	<tr>
		<td class="catalogLabel" valign="top">Payment Reference: </td><td valign="top" class="bodyBlack"><%=up.getContactId()%> - <%=orderId%></td></tr>
	</table>

<%

}
%><br><br><br>
	<table border="0" cellspacing="5">
	<tr>
		<td class="catalogLabel" valign="top">Customer Number:</td><td valign="top" class="bodyBlack"><%=up.getContactId()%></td>
		<td class="catalogLabel" valign="top">Order Number:<br>Order Date:</td><td valign="top" class="bodyBlack"><%=orderId%><br><%=orderRS.getString("orderdate")%></td>
		<td>
			<table border="0"  cellpadding="0" cellspacing="0"><tr><td class="catalogLabel" valign="top">Ship To:&nbsp;</td><td class="bodyBlack"><%=orderRS.getString("shipaddress")%></td></tr></table>
		</td>
	</tr>
	</table><br>
<br><br>
<div class="catalogLabel">Order Details</div>
<table border="0" cellpadding="5" cellspacing="0" width="90%">
<% while(jobsRS.next()){
 discountApplied=(!(jobsRS.getString("discount").equals("0"))?true:discountApplied);
 } %> 
  <tr>
            <td class="planheader1" width="40%" height="9">Item / Job Name (Click to view Details)</td>
            <td class="planheader1" width="8%" height="9">Quantity</td>
            <td class="planheader1" width="8%" height="9">Price</td>
            <td class="planheader1" width="9%" height="9">Shipping</td>
            <!--<td class="planheader1" width="9%" height="8"><div align="right">Deposit/Payment&nbsp;</div></td>
            <td class="planheader1" width="9%" height="9"><div align="right">Discount</div></td>-->
<% if (discountApplied == true) { %>
            <td class="planheader1" width="9%" height="9"><div align="right">Discount</div></td>
<% } %> 
            <td class="planheader1" width="9%" height="9"><div align="right">Sales Tax</div></td>
            <td class="planheader1" width="9%" height="9">Total</td>
  </tr>
 <% jobsRS.beforeFirst(); %>
 <% while(jobsRS.next()){%>
  <tr>
    <td class="lineitems" align="left"><a href="javascript:popw('/popups/JobDetailsPage.jsp?jobId=<$ id $>','700','600')"><%=jobsRS.getString("job_name")%></a></td>
    <td class="lineitems" align="right"><%=jobsRS.getString("quantity")%></td>
    <td class="lineitems" align="right"><%=jobsRS.getString("cost")%></td>
    <td class="lineitems" align="right"><%=jobsRS.getString("shippingPrice")%></td>
<% if (discountApplied == true) { %>
   <td class="lineitems" align="right">(<%=jobsRS.getString("discount")%>)</td>
<% } %> 
    <td class="lineitems" align="right"><%=jobsRS.getString("sales_tax")%></td>
    <td class="lineitems" align="right"><%=jobsRS.getString("billable")%></td>
  </tr>
  <%
 costSubtotal += jobsRS.getDouble("cost");
 shipSubtotal += jobsRS.getDouble("shipping_price");
 discountSubtotal += jobsRS.getDouble("discount");
 taxSubtotal += jobsRS.getDouble("sales_tax");
 orderTotal+= jobsRS.getDouble("billable");
 shipTBD=((jobsRS.getString("shippingPrice").equals("TBD *"))?true:shipTBD);
 
 }%>
    <tr>

    <td class="lineitems" align="right" colspan=2>TOTAL</td>
    <td class="lineitems" align="right"><%=formater.getCurrency(costSubtotal)%></td>
    <td class="lineitems" align="right"><%=formater.getCurrency(shipSubtotal) + ((shipTBD)?" *":"")%></td>
<% if (discountApplied == true) { %>
    <td class="lineitems" align="right" color="red">(<%=formater.getCurrency(discountSubtotal)%>)</td>
<% } %>
    <td class="lineitems" align="right"><%=formater.getCurrency(taxSubtotal)%></td>
    <td class="lineitems" align="right"><%=formater.getCurrency(orderTotal)+ ((shipTBD)?" *":"")%></td>
  </tr>
</table>
<br><br>
<div class="bodyBlack">
<%
if(payType.equals("account")){

%>* Charges listed as TBD (to be determined) or RFQ (Request for Quote), such as those for international shipping or custom orders, may be separately billed on this account when approved and/or determinable according to the terms of service for this website. <br><br>

<b>Payment instructions:</b>  To expedite our application of your payment when it is received, please reference our invoice numbers on your check.<%

} else if(payType.equals("cc")){

%>This order has been charged in full and any charge for services yet to be rendered or shipped in the future are considered a deposit payment for such products and services.  <br>* Charges listed as TBD (to be determined) or RFQ (Request for Quote), such as those for international shipping or custom orders, may be charged against this credit card or billed on account when approved and/or determinable according to the terms of service for this website. (Note: charge will appear on your credit card statement as MarComet.com, Inc.)<%

} else if(payType.equals("ach")){

%>This order has been charged in full and any charge for services yet to be rendered or shipped in the future are considered a deposit payment for such products and services.  <br>* Charges listed as TBD (to be determined) or RFQ (Request for Quote), such as those for international shipping or custom orders, may be charged against this credit card or billed on account when approved and/or determinable according to the terms of service for this website. (Note: charge will appear on your bank account statement as MarComet.com, Inc.)
<br><br>
This transaction was processed with the understanding that because this is an electronic transaction, these funds may be withdrawn from my account as soon as the current order transaction date or thereafter. In the case of the payment being rejected for Non Sufficient Funds (NSF) It was understood that MarComet may at its discretion attempt to process the charge again within 30 days with an additional $20.00 charge for each attempt returned NSF, which will be initiated as a separate transaction from the authorized payment. It was acknowledged that the origination of ACH transactions to this account must comply with the provisions of U.S. law.  It was acknowledged that you will not dispute MarComet’s billing with your bank so long as the transaction corresponds to the terms indicated in this agreement and the website terms of service.
<%

} else if(payType.equals("check")){
%><b>Payment instructions:</b>  To expedite our application of your payment when it is received and releasing your order, please reference the “Payment Reference” number listed above on your check.
<br><br>
Please note that product will not be reserved while awaiting payment, and future availability cannot be guaranteed.  Orders not paid and released within a reasonable timeframe may be cancelled.
<br>* Charges listed as TBD (to be determined) or RFQ (Request for Quote), such as those for international shipping or custom orders, may be separately billed on account when approved and/or determinable according to the terms of service for this website.
<%

}
%>
</div>
</div><%
st.close();
st2.close();
st3.close();
conn.close();%>