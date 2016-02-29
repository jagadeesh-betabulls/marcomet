<%@ page import="java.sql.*,java.util.*,com.marcomet.jdbc.*,com.marcomet.workflow.*,com.marcomet.users.security.*" %>
<%@ taglib uri="/WEB-INF/tld/taglib.tld" prefix="taglib" %>
<%@ include file="/includes/SessionChecker.jsp" %>
<jsp:useBean id="validator" class="com.marcomet.tools.FieldValidationBean" scope="page" />
<jsp:useBean id="formater" class="com.marcomet.tools.FormaterTool" scope="page" />
<%

String domainName = "";
double price = 0;
double shipprice=0;
double actualShipping=0;
double jobamount=0;
double shippingamount=0;
double salestaxamount=0;
double baseprice=0;
String shipPricePolicy="0";
double discount=0;
String jobId = request.getParameter("jobId");
String query = "select discount,price, escrow_amount, vendor_id,if(ship_price_policy=1, 0,if(ship_price_policy=2,std_ship_price,shipping_price)) as shipping,shipping_price,ship_price_policy,lus.value as ship_policy from jobs left join lu_ship_policy lus on ship_price_policy=lus.id  where jobs.id =" + jobId;


Connection conn = DBConnect.getConnection();
Statement st = conn.createStatement();
ResultSet rs = st.executeQuery(query);

Hashtable rehash = new Hashtable();

if (rs.next()) {
	rehash.put("price", rs.getString("price"));
	price=rs.getDouble("price");
	discount=rs.getDouble("discount");	
	rehash.put("ship_policy", rs.getString("ship_policy"));
	rehash.put("ship_price_policy", rs.getString("ship_price_policy"));
	shipPricePolicy=rs.getString("ship_price_policy");
	rehash.put("vendor", rs.getString("vendor_id"));
	rehash.put("discount", rs.getString("discount"));
	rehash.put("escrow", (new Double(rs.getDouble("escrow_amount"))).toString());
	rehash.put("shipping", (new Double(rs.getDouble("shipping"))).toString());
	rehash.put("actual_shipping", (new Double(rs.getDouble("shipping_price"))).toString());
	shipprice=rs.getDouble("shipping");
	actualShipping=rs.getDouble("shipping");
} else {
	rehash.put("price", "0");
	rehash.put("discount", "0");
	rehash.put("ship_policy", "");
	rehash.put("ship_price_policy", "");
	rehash.put("vendor", "0");
	rehash.put("escrow", "0");
	rehash.put("shipping", "0");
	rehash.put("actual_shipping", "0");
}

String queryJSPrice = "SELECT SUM(js.price) 'price' FROM job_specs js WHERE cost <>1 AND js.job_id = " + jobId;
ResultSet rsPrice = st.executeQuery(queryJSPrice);
if(rsPrice.next()){
	rehash.put("baseprice", rsPrice.getString("price"));
	baseprice=rsPrice.getDouble("price");	
}else{
	rehash.put("baseprice", "0");
}

String queryVendor = "SELECT payment_option FROM vendor_payment_processing WHERE vendor_id = " + (String)rehash.get("vendor");
ResultSet rsVendor = st.executeQuery(queryVendor);
if(rsVendor.next()){
	rehash.put("useCC", rsVendor.getString("payment_option"));
}else{
	rehash.put("useCC", "2");
}


String queryInvoices = "SELECT SUM(ar_purchase_amount) as job_amount,sum(ar_shipping_amount) as shippingamount,sum(ar_sales_tax) as salestaxamount FROM ar_invoice_details WHERE jobid = " + jobId;
ResultSet rsPrice1 = st.executeQuery(queryInvoices);
while(rsPrice1.next()){
	jobamount=jobamount+((rsPrice1.getString("job_amount")==null)?0:rsPrice1.getDouble("job_amount"));
	shippingamount=shippingamount+((rsPrice1.getString("shippingamount")==null)?0:rsPrice1.getDouble("shippingamount"));
 	salestaxamount=salestaxamount+((rsPrice1.getString("salestaxamount")==null)?0:rsPrice1.getDouble("salestaxamount"));
}

int counter = 0;
double sum = 0;
String changesQuery = "select price from jobchanges where statusid=2 and jobid = " + jobId;
ResultSet rs2 = st.executeQuery(changesQuery);
while (rs2.next()) {
	rehash.put("change" + counter, (new Double(rs2.getDouble("price"))).toString());
	sum = sum + rs2.getDouble("price");
	counter++;
}
rehash.put("sum", (new Double(sum)).toString());

String taxQuery = "select st.value entitystring,entity, rate, tax_shipping, tax_job, buyer_exempt from sales_tax,lu_abreviated_states st where st.id=sales_tax.entity and job_id = " + jobId;
ResultSet rs3 = st.executeQuery(taxQuery);
if (rs3.next()) {
	rehash.put("taxEntity", rs3.getString("entity"));
	rehash.put("taxEntityString", rs3.getString("entitystring"));	
	rehash.put("taxRate", rs3.getString("rate"));
	rehash.put("taxShipping", rs3.getString("tax_shipping"));
	rehash.put("taxJob", rs3.getString("tax_job"));
	rehash.put("buyerExempt", rs3.getString("buyer_exempt"));
}else{
	rehash.put("taxEntity", "0");
	rehash.put("taxEntityString", "");	
	rehash.put("taxRate", "0");
	rehash.put("taxShipping", "0");
	rehash.put("taxJob", "0");
	rehash.put("buyerExempt", "0");
}
%><html>
<head>
  <title>Invoice Entry</title>
  <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
  <link rel="stylesheet" href="<%=(String)session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css">
<jsp:getProperty name="validator" property="javaScripts" />
<script language="JavaScript" src="/javascripts/mainlib.js"></script>
<script language="Javascript">
function currency(anynum) {

   //-- Returns passed number as string in $xxx,xxx.xx format.
   anynum=eval(anynum)
   workNum=((Math.round(anynum*100)/100));workStr=""+workNum
   if (workStr.indexOf(".")==-1){workStr+=".00"}
   dStr=workStr.substr(0,workStr.indexOf("."));dNum=dStr-0
   pStr=workStr.substr(workStr.indexOf("."))
   while (pStr.length<3){pStr+="0"}
   retval = dStr + pStr 
   return retval
}
function isNumber(num){
	if (num == null || num=="" || isNaN(num))
	{
		return "0";
	}else{
		return num;
	}
}

function calculateSalesTax(){
<%if (rehash.get("buyerExempt").toString().equals("0")){%>
	var salestax=currency( ( parseFloat(<%=((rehash.get("taxJob").toString().equals("0"))?"0":"isNumber(document.forms[0].billAmount.value)")%>)+parseFloat(<%=((rehash.get("taxShipping").toString().equals("0"))?"0":"isNumber(document.forms[0].shipAmount.value)")%>) )*(<%=(String)rehash.get("taxRate")%>/100));
<%}else{%>
	var salestax=currency(0);
<%}%>
	document.forms[0].salestaxAmount.value=salestax;
	addInvoice();
}
function addInvoice(){
document.forms[0].salestaxAmount.value=isNumber(document.forms[0].salestaxAmount.value);
document.forms[0].billAmount.value=isNumber(document.forms[0].billAmount.value);
document.forms[0].shipAmount.value=isNumber(document.forms[0].shipAmount.value);
var invTotal=currency(parseFloat(isNumber(document.forms[0].billAmount.value))+parseFloat(isNumber(document.forms[0].shipAmount.value))+parseFloat(isNumber(document.forms[0].salestaxAmount.value)) );
document.forms[0].currentInvoiceAmount.value=invTotal;
currentInvoiceAmount.innerHTML=invTotal;
}
</script>
  <script language="javascript" type="text/javascript" src="/javascripts/tiny_mce/tiny_mce.js"></script>
  <script language="javascript" type="text/javascript">
	tinyMCE.init({
		theme : "advanced",
		mode : "exact",
		elements : "message",
		submit_patch : false,
		content_css : "<%=(String)session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css",
		extended_valid_elements : "link[rel|href|type]",
		plugins : "table,visualchars",
		theme_advanced_buttons3_add_before : "tablecontrols,separator,visualchars",
		//invalid_elements : "a",
		theme_advanced_styles : "Title=title;Subtitle=subtitle;", // Theme specific setting CSS classes
		//execcommand_callback : "myCustomExecCommandHandler",
		debug : false
	});
	function myCustomExecCommandHandler(editor_id, elm, command, user_interface, value) {
		var linkElm, imageElm, inst;
		switch (command) {
				case "mceLink":
				inst = tinyMCE.getInstanceById(editor_id);
				linkElm = tinyMCE.getParentElement(inst.selection.getFocusElement(), "a");
				if (linkElm)
					alert("Link dialog has been overriden. Found link href: " + tinyMCE.getAttrib(linkElm, "href"));
				else
					alert("Link dialog has been overriden.");
				return true;
			case "mceImage":
				inst = tinyMCE.getInstanceById(editor_id);
				imageElm = tinyMCE.getParentElement(inst.selection.getFocusElement(), "img");

				if (imageElm)
					alert("Image dialog has been overriden. Found image src: " + tinyMCE.getAttrib(imageElm, "src"));
				else
					alert("Image dialog has been overriden.");
				return true;
		}
		return false; // Pass to next handler in chain
	}
</script>
</head>
<body class="body" onLoad="MM_preloadImages('/images/buttons/continueover.gif','/images/buttons/cancelbtover.gif')" background="<%=(String)session.getAttribute("siteHostRoot")%>/images/back3.jpg">
<form method="post" action="/servlet/com.marcomet.sbpprocesses.ProcessJobSubmit">
  <p class="Title">Create New Invoice</p>
 <jsp:include page="/includes/JobDetailHeader.jsp" flush="true"><jsp:param  name="jobId" value="<%=request.getParameter("jobId")%>" /></jsp:include>
<jsp:include page="/includes/MailingAddressForm.jsp" flush="true"><jsp:param name="displayClass" value="bill" /><jsp:param name="formNeeded" value="false" /><jsp:param name="jobId" value="<%=jobId%>" /><jsp:param name="editor" value="false" /></jsp:include>
  <p> <b>Instructions:</b> Complete this form to initiate an invoice billing to 
    your customer. You may use this opportunity to review the sales tax calculations 
    as they are currently estimated. You will have the opportunity to finally 
    confirm those calculations at final billing.</p>
  <p class="label">Unique Invoice Number: 
    <input type="text" name="invoiceNumber">
    (Leave blank for system assigned)</p>
  <table width="70%" cellpadding=4 cellspacing=0 border="1">
    <tr> 
      <td class="tableheader" width="23%" height="9">&nbsp;</td>
      <td class="tableheader" width="11%" height="9"> 
        <div align="left">Total </div>
      </td>
      <td class="tableheader" width="13%" height="9"> 
        <div align="left">Billed&nbsp;to&nbsp;Date</div>
      </td>
      <td class="tableheader" width="18%" height="9"> 
        <div align="left">Balance</div>
      </td>
      <td class="tableheader" width="35%" height="9"> 
        <div align="left">Current Bill</div>
      </td>
    </tr>
    <tr> 
      <td width="23%" class="lineitems">Original Order</td>
      <td width="11%" class="lineitems"> 
        <div align="right"><%= formater.getCurrency((String)rehash.get("baseprice")) %> 
        </div>
      </td>
      <td width="13%" bgcolor="#CCCCCC" class="lineitems">&nbsp;</td>
      <td width="18%" bgcolor="#CCCCCC" class="lineitems">&nbsp;</td>
      <td width="35%" bgcolor="#CCCCCC" class="lineitems">&nbsp;</td>
    </tr>
    <%for (int x=0;x<counter;x++){
    %>
    <tr> 
      <td width="23%" class="lineitems">Change Order</td>
      <td width="11%" class="lineitems"> 
        <div align="right"><%= formater.getCurrency((String)rehash.get("change"+x)) %> 
        </div>
      </td>
      <td width="13%" bgcolor="#CCCCCC" class="lineitems">&nbsp;</td>
      <td width="18%" bgcolor="#CCCCCC" class="lineitems">&nbsp;</td>
      <td width="35%" bgcolor="#CCCCCC" class="lineitems">&nbsp;</td>
    </tr>
    <%}%>
    <tr> 
      <td width="23%" class="lineitems">&nbsp;</td>
      <td width="11%" class="lineitems"> 
        <div align="right">&nbsp;</div>
      </td>
      <td width="13%" class="lineitems">&nbsp;</td>
      <td width="18%" class="lineitems">&nbsp;</td>
      <td width="35%" class="lineitems">&nbsp;</td>
    </tr>
    <tr> 
      <td width="23%" class="lineitems"> 
        <div align="left"><b>Job Amount</b></div>
      </td>
      <td width="11%" class="lineitems"> 
        <div align="right"><%= formater.getCurrency(((baseprice>0)?Double.toString(baseprice+sum-discount):Double.toString(sum))) %> 
        </div>
      </td>
      <td width="13%" class="lineitems"> 
        <div align="right"><%= formater.getCurrency(Double.toString(jobamount)) %> 
        </div>
      </td>
      <td width="18%" class="lineitems"> 
        <div align="right"><%= formater.getCurrency( (baseprice>0?Double.toString(baseprice+sum-discount-jobamount):Double.toString(sum-jobamount))) %> 
        </div>
      </td>
      <td width="35%" class="lineitems"> 
        <div align="right">$ 
          <input type="text" style="text-align:right" name="billAmount" onChange="calculateSalesTax()" value="<%=Math.round(((baseprice>0?(baseprice+sum-discount-jobamount):(sum-jobamount))) * Math.pow(10, 2)) / Math.pow(10,2)%>" size="15">
        </div>
      </td>
    </tr><%
      if (shipprice==0 && shipPricePolicy.equals("2")){
		%><tr><td class="lineitems" colspan="5"><font color=red>NOTE: The shipping price policy is set to 'fixed amount' however the fixed amount on the job is 0. You may need to alter the job record to include the actual shipping<%=((actualShipping>0)?" of: $"+actualShipping:"")%>.</font></td></tr><%
	}
	
	%>
    <tr> 
      <td width="23%" class="lineitems">Shipping<%=((rehash.get("ship_price_policy").toString().equals("0"))?"":"<br><i>"+(String)rehash.get("ship_policy")+"</i>")%></td>
      <td width="11%" class="lineitems"> 
        <div align="right"><%= formater.getCurrency((String)rehash.get("shipping")) %> 
        </div>
      </td>
      <td width="13%" class="lineitems"> 
        <div align="right"><%= formater.getCurrency(Double.toString(shippingamount)) %> 
        </div>
      </td>
      <td width="18%" class="lineitems"> 
        <div align="right"><%= formater.getCurrency(Double.toString(shipprice-shippingamount)) %> 
        </div>
      </td>
      <td width="35%" class="lineitems"> 
        <div align="right">$ 
          <input type="text" name="shipAmount" style="text-align:right" onChange="calculateSalesTax()" value="<%=Math.round((shipprice-shippingamount) * Math.pow(10, 2)) / Math.pow(10,2)%>" size="15">
        </div>
      </td>
    </tr>
    <tr> 
      <td width="23%" height="22" class="lineitems">Tax Percentage:</td>
      <td width="11%" height="22" class="lineitems"> 
        <div align="right"><%=(String)rehash.get("taxEntityString")%>:<%=(String)rehash.get("taxRate")%>% </div>
      </td>
      <td width="13%" align="right" height="22" class="lineitems">&nbsp;</td>
      <td width="18%" align="right" height="22" class="lineitems">Sales Tax</td>
      <td width="35%" height="22" class="lineitems"> 
        <div align="right">$ 
          <input type="text" style="text-align:right" name="salestaxAmount" onChange="addInvoice()" size="15">
        </div>
      </td>
    </tr>
    <tr> 
      <td width="23%" height="45" class="lineitems">&nbsp;</td>
      <td width="11%" height="45" class="lineitems"> 
        <div align="right">&nbsp;</div>
      </td>
      <td width="13%" height="45" align="right" class="lineitems">&nbsp;</td>
      <td width="18%" height="45" align="right" class="lineitems"><b>Current Invoice</b></td>
      <td width="35%" height="45" class="lineitems"> 
        <div id="currentInvoiceAmount" align="right"></div>
        <div align="right"><b> 
          <input type="hidden" name="currentInvoiceAmount">
          </b></div>
      </td>
    </tr>
  </table>
<%if (rehash.get("useCC").toString().equals("3")){%>
  <p>Payment Option(s): 
    <select name="paymentOption">
      <option value="3">Check or Credit Card</option>
	  <option value="1">Credit Card</option>
	  <option value="2">Check</option>
    </select>
</p>
<%}else if (rehash.get("useCC").toString().equals("2")){%>
<input type="hidden" name="paymentOption" value="2">
<%}else{%>
<input type="hidden" name="paymentOption" value="1">
<%}%>

<%
String queryValueAddProg = "select vac.id as promo_credit_id, j.site_number as property_code, vap.value_add_program_name,vap.prog_end_date, vac.amount_qualified as credit_qualified, if(sum(arc.check_amount) is null,0,sum(arc.check_amount)) as credit_used, vac.amount_qualified - if(sum(arc.check_amount) is null,0,sum(arc.check_amount)) as credit_balance from jobs j inner join value_add_credits vac on vac.property_code=j.site_number inner join value_add_programs vap on vap.value_add_prog_code = vac.value_add_prog_code and vap.prog_end_date >= j.order_date and vap.prog_beg_date <= now() left join ar_collections arc on vac.id = arc.value_add_credit_id where j.id  = " + jobId + " group by vap.value_add_prog_code";
ResultSet rsValueAddProg = st.executeQuery(queryValueAddProg);

while(rsValueAddProg.next()){
%>	<p><B>This property Qualifies for a Promotional Credit: </B> <br><br>
Property Code: <%=rsValueAddProg.getString("property_code")%><br>
Program: <%=rsValueAddProg.getString("vap.value_add_program_name")%><br>
Ending: <%=formater.formatMysqlDate(rsValueAddProg.getString("vap.prog_end_date"))%><br>
Qualified: <%= formater.getCurrency(rsValueAddProg.getString("credit_qualified"))%><br>
Used to Date: <%= formater.getCurrency(rsValueAddProg.getString("credit_used")) %><br>
<hr size=1 width=100>
<b>Balance Avail: <%= formater.getCurrency(rsValueAddProg.getString("credit_balance")) %><br>
Promotional Credit ID: <%=rsValueAddProg.getString("promo_credit_id")%></b></b></p><%
}
%><p><span class="label">Invoice Message:</span><br>
    <textarea name="message" cols="80" rows="20"></textarea><br>
  </p>
  <table border="0" width="25%" align="center">
  <tr>
      <td> 
        <div align="center"><a href="/popups/QuickBillForm.jsp"class="greybutton">Cancel</a> 
        </div>
      </td>
    <td>&nbsp;</td>
      <td> 
        <div align="center"><a href="javascript:tinyMCE.triggerSave();javascript:document.forms[0].submit()"class="greybutton">Submit</a> 
        </div>
      </td>
  </tr>
</table>
<input type="hidden" name="jobId" value="<%= request.getParameter("jobId") %>" >
<input type="hidden" name="vendorId" value="<%= rehash.get("vendor") %>" >
<input type="hidden" name="taxRate" value="<%= rehash.get("taxRate") %>" >
<input type="hidden" name="taxEntity" value="<%= rehash.get("taxEntity") %>" >
<input type="hidden" name="taxShipping" value="<%= rehash.get("taxShipping") %>" >
<input type="hidden" name="taxJob" value="<%= rehash.get("taxJob") %>" >
<input type="hidden" name="buyerExempt" value="<%= rehash.get("buyerExempt") %>" >
<input type="hidden" name="$$Return" value="[/popups/QuickBillForm.jsp]">
<input type="hidden" name="redirect" value="[/popups/QuickBillForm.jsp]">
<input type="hidden" name="nextStepActionId" value="78">  
</form>
<script>calculateSalesTax();</script>
</body>
</html><%st.close(); conn.close(); %>
