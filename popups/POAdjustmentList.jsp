<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<%@ page import="java.sql.*,com.marcomet.jdbc.*,com.marcomet.users.security.*" %>
<jsp:useBean id="formatter" class="com.marcomet.tools.FormaterTool" scope="page" />
<%@ taglib uri="/WEB-INF/tld/taglib.tld" prefix="taglib" %>
  <link rel="stylesheet" href="<%=(String)session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css">
<script language="JavaScript" src="/javascripts/mainlib.js"></script>
<%
boolean print = ((request.getParameter("print")==null || !(request.getParameter("print").equals("true")))?false:true);
boolean editor= ((((RoleResolver)session.getAttribute("roles")).roleCheck("editor")) && !(print));

Connection conn = DBConnect.getConnection();
Statement st = conn.createStatement();
Statement st1 = conn.createStatement();
Statement st2 = conn.createStatement();
Statement st3 = conn.createStatement();

int x=0;

double totCost=0;
double totShipping=0;
double totShippingCost=0;
double totalShipping=0;
double totHandling=0;
double totProcFee=0;
double totAllowance=0;
double totApplied=0;
double totPApplied=0;
double totSApplied=0;
double totSTApplied=0;
double totAccrued=0;
double totPAccrued=0;
double totSAccrued=0;
double totSTAccrued=0;

String jobId=((request.getParameter("jobId")==null)?"0":request.getParameter("jobId"));
String vendorId=((request.getParameter("vendorId")==null)?"0":request.getParameter("vendorId"));

//Get all adjustments for this PO

String shipCost=((vendorId.equals("0"))?"cost":" if(shipping_account_vendor_id='"+vendorId+"',cost,0) ");
String svHandling=((vendorId.equals("0") )?"subvendor_handling":" if(shipping_vendor_id='"+vendorId+"',subvendor_handling,0) ");
String vendorFilter= ((vendorId.equals("0") )?"":" (shipping_account_vendor_id='"+vendorId+"' or shipping_vendor_id='"+vendorId+"') and ");
String shipSQL="select description,"+shipCost+" 'shipCost',"+svHandling+" 'handling', DATE_FORMAT(date,'%m/%d/%y') 'transDate',DATE_FORMAT(accrued_date,'%m/%d/%y') 'accruedDate',pre_accrual,shipping_vendor_id as 'vendor_id',shipping_account_vendor_id as 'account_vendor_id',subvendor_id,handling as 'procfee',allowance,price,concat(reference,if(vendor_ship_reference='','',', '),vendor_ship_reference) 'ref' from shipping_data where "+vendorFilter+" job_id="+jobId;
ResultSet rsShip=st.executeQuery(shipSQL);

  //Get PO Adjustments
String POSQL="select DATE_FORMAT(adjustment_date,'%m/%d/%y') transDate,vendor_id,adjustment_amount amount,adjustment_notes,DATE_FORMAT(accrued_date,'%m/%d/%y') accruedDate,pre_accrual from po_transactions where "+(((vendorId.equals("0")) )?"":"vendor_id='"+vendorId+"' and ")+" job_id="+jobId;
ResultSet rsAdj = st1.executeQuery(POSQL);

  //Get AP Invoice Applications
ResultSet rsAPI = st2.executeQuery("select DATE_FORMAT(api.ap_invoice_date,'%m/%d/%y') as 'transDate',pre_accrual, DATE_FORMAT(apid.accrual_post_date,'%m/%d/%y') as 'accruedDate',amount,ap_shipping_amount,ap_purchase_amount,ap_sales_tax_amount,apid.vendorid,purchase_description,apid.vendor_invoice_no from ap_invoice_details apid,ap_invoices api where apid.ap_invoiceid=api.id and "+((vendorId.equals("0") )?"":"vendorid='"+vendorId+"' and ")+" jobid="+jobId);

while(rsAdj.next()){;
	if (x==0){
		x++;
%><br><br><div class=lineitems><%if(editor){%><a href='javascript:popw("/popups/POAdjustment.jsp?jobId=<%=jobId%>",450,300)' class=greybutton>+ Adjust</a>&nbsp;&nbsp;<%}%>PO Transactions:</div><table class="body"><tr><td class="minderHeaderleft" width="10%">Transaction Date</td><%if (vendorId.equals("0")){%><td class="minderHeaderleft" width="5%">Vendor ID</td><%}%><td class="minderHeaderright" width="5%">Amount</td><%

if(editor) {
	%><td class="minderHeader">Pre-Accrual</td><td class="minderHeader">Post Date</td><%
}
%><td class="minderHeader" width='80%' >Description</td></tr><%
	}
	totCost+=rsAdj.getDouble("amount");
	totAccrued=totAccrued+(rsAdj.getDouble("amount"));
	%><tr><td class="lineitems" width="10%"><%=rsAdj.getString("transDate")%></td><%if (vendorId.equals("0")){%><td class="lineitems" width="5%"><%=rsAdj.getString("vendor_id")%></td><%}%><td class="lineitemsright" width="5%"><%=formatter.getCurrency(rsAdj.getDouble("amount"))%></td><%

if(editor) {
	%><td class="minderHeader"><%=rsAdj.getString("pre_accrual")%></td><td class="minderHeader"><%=rsAdj.getString("accruedDate")%></td><%}%><td class="lineitems" width='70%' ><%=rsAdj.getString("adjustment_notes")%></td></tr><%
	
}
if (x>0){%><tr><td class='minderheaderright' colspan=2>TOTAL</td><td class='lineitemsright'><b><%=formatter.getCurrency(totCost)%></b></td></tr></table><%x=0;}else{%><div class=lineitems><%if(editor){%><a href='javascript:popw("/popups/POAdjustment.jsp?closeOnExit=true&jobId=<%=jobId%>",450,300)' class=greybutton>+ Adjust</a>&nbsp;&nbsp;<%}%>PO Transactions:</div><%}

while(rsShip.next()){;
	if (x==0){
		x++;
%><br><br><div class=lineitems><%if(editor){%><a href='javascript:popw("/minders/workflowforms/InterimShipment2.jsp?closeOnExit=true&actionId=80&jobId=<%=jobId%>",700,700)' class=greybutton>+ Adjust</a>&nbsp;&nbsp;<%}%>Shipping Transactions:<%
if(editor){

String shSQL="Select pp.value as shipPricePolicy, cp.value as shipCostPolicy,ship_price_policy,ship_cost_policy,format(j.std_ship_cost,2) as shipCost,format(std_ship_price,2) as shipPrice from jobs j left join lu_ship_policy pp on pp.id=ship_price_policy left join lu_ship_policy cp on ship_cost_policy=cp.id where j.id="+jobId;
String shipPricePolicy="";
String shipCostPolicy="";
String stdShipPrice="";
String stdShipCost="";
int shipPP=0;
int shipCP=0;

ResultSet rsShp=st3.executeQuery(shSQL);

if(rsShp.next()){
	shipPricePolicy=rsShp.getString("shipPricePolicy");
	shipCostPolicy=rsShp.getString("shipCostPolicy");
	stdShipPrice=rsShp.getString("shipPrice");
	stdShipCost=rsShp.getString("shipCost");
	shipPP=rsShp.getInt("ship_price_policy");
	shipCP=rsShp.getInt("ship_cost_policy");
}

%><br>
Shipping Cost Policy:<a href='javascript:popw("/popups/QuickChangeForm.jsp?cols=10&rows=1&question=Change%20Job%20ShipCostPolicy&primaryKeyValue=<%=jobId%>&columnName=ship_cost_policy&tableName=jobs&valueType=string",400,150)'> &raquo;&nbsp;</a><%=shipCostPolicy%>; 
Standard Shipping Cost: <a href='javascript:popw("/popups/QuickChangeForm.jsp?cols=10&rows=1&question=Change%20Job%20ShipCost&primaryKeyValue=<%=jobId%>&columnName=std_ship_cost&tableName=jobs&valueType=string",400,150)'> &raquo;&nbsp;</a>$<%=stdShipCost%><br>Shipping Price Policy: <a href="javascript:popw('/popups/QuickChangeForm.jsp?cols=10&rows=1&question=Change%20Job%20ShipPricePolicy&primaryKeyValue=<%=jobId%>&columnName=ship_price_policy&tableName=jobs&valueType=string',400,150)"> &raquo;&nbsp;</a><%=shipPricePolicy%>;  Standard Shipping Price:<a href="javascript:popw('/popups/QuickChangeForm.jsp?cols=10&rows=1&question=Change%20Job%20ShipPrice&primaryKeyValue=<%=jobId%>&columnName=std_ship_price&tableName=jobs&valueType=string',400,150)"> &raquo;&nbsp;</a>$<%=stdShipPrice%><%

}%></div><table class="body"><tr><td class="minderHeaderleft" >Transaction<br>Date</td><%if (vendorId.equals("0")){%><td class="minderHeaderright" >Shipping Account<br>Vendor ID</td><%}%><td class="minderHeaderright" >Shipping<br>Cost</td><%if (vendorId.equals("0")){%><td class="minderHeaderright" >Shipping<br>Vendor ID</td><%}%><td class="minderHeaderright">Handling</td><td class="minderHeaderright">TOTAL</td><%if(editor) {%><td class="minderHeader">Proc Fee</td><td class="minderHeader">Allowance</td><td class="minderHeader">TOTAL</td><td class="minderHeader">Pre-Accrual</td><td class="minderHeader">Post Date</td><td class="minderHeader">Reference / Tracking #</td><%}%><td class="minderHeader" width='25%'>Notes</td></tr><%
	}
	totShipping+=rsShip.getDouble("shipCost");
	totHandling+=rsShip.getDouble("handling");
	totProcFee+=rsShip.getDouble("procfee");
	totAllowance+=rsShip.getDouble("allowance");
	totShippingCost+=(rsShip.getDouble("shipCost")+rsShip.getDouble("handling"));
	totalShipping+=rsShip.getDouble("price");	
	totAccrued=totAccrued+(rsShip.getDouble("shipCost")+rsShip.getDouble("handling"));
	%><tr><td class="lineitems" ><%=rsShip.getString("transDate")%></td><%if (vendorId.equals("0")){%><td class="lineitems" ><%=rsShip.getString("account_vendor_id")%></td><%}%><td class="lineitemsright" ><%=formatter.getCurrency(rsShip.getDouble("shipCost"))%></td><%if (vendorId.equals("0")){%><td class="lineitems" ><%=rsShip.getString("vendor_id")%></td><%}%><td class="lineitemsright" ><%=formatter.getCurrency(rsShip.getDouble("handling"))%></td><td class="lineitemsright" ><%=formatter.getCurrency((rsShip.getDouble("shipCost")+rsShip.getDouble("handling")))%></td><%if(editor) {%><td class="minderheaderright"><%=formatter.getCurrency(rsShip.getDouble("procfee"))%></td><td class="minderheaderright"><%=formatter.getCurrency((rsShip.getDouble("allowance")))%></td><td class="minderheaderright"><%=formatter.getCurrency((rsShip.getDouble("price")))%></td><td class="minderheaderright"><%=rsShip.getString("pre_accrual")%></td><td class="minderheaderright"><%=rsShip.getString("accruedDate")%></td><td class="lineitems"><%=rsShip.getString("ref")%></td><%}%><td class="lineitems" ><%=rsShip.getString("description")%></td></tr><%

}
if (x>0){%><tr><td class='minderheaderright' <%=(((vendorId.equals("0")))?"colspan=2":"")%>>TOTAL:</td><td class='lineitemsright'><b><%=formatter.getCurrency(totShipping)%></b></td><%if (vendorId.equals("0")){%><td class="minderheader" >&nbsp;</td><%}%><td class='lineitemsright'><b><%=formatter.getCurrency(totHandling)%></b></td><td class='lineitemsright'><b><%=formatter.getCurrency(totShippingCost)%></b></td><%
if(editor){
%><td class='minderheaderright'><b><%=formatter.getCurrency(totProcFee)%></b></td><td class='minderheaderright'><b><%=formatter.getCurrency(totAllowance)%></b></td>
<td class='minderheaderright'><b><%=formatter.getCurrency(totalShipping)%></b></td>
<td class='minderHeader' colspan='4'>&nbsp;</td><%}
%></tr></table><%x=0;}else{%><div class=lineitems><%if(editor){%><a href='javascript:popw("/minders/workflowforms/InterimShipment2.jsp?closeOnExit=true&actionId=80&jobId=<%=jobId%>",700,700)' class=greybutton>+ Adjust</a>&nbsp;&nbsp;<%}%>Shipping Transactions:<%
if(editor){

String shSQL="Select pp.value as shipPricePolicy, cp.value as shipCostPolicy,ship_price_policy,ship_cost_policy,format(j.std_ship_cost,2) as shipCost,format(std_ship_price,2) as shipPrice from jobs j left join lu_ship_policy pp on pp.id=ship_price_policy left join lu_ship_policy cp on ship_cost_policy=cp.id where j.id="+jobId;
String shipPricePolicy="";
String shipCostPolicy="";
String stdShipPrice="";
String stdShipCost="";
int shipPP=0;
int shipCP=0;

ResultSet rsShp=st3.executeQuery(shSQL);

if(rsShp.next()){
	shipPricePolicy=rsShp.getString("shipPricePolicy");
	shipCostPolicy=rsShp.getString("shipCostPolicy");
	stdShipPrice=rsShp.getString("shipPrice");
	stdShipCost=rsShp.getString("shipCost");
	shipPP=rsShp.getInt("ship_price_policy");
	shipCP=rsShp.getInt("ship_cost_policy");
}

%><br>
Shipping Cost Policy:<a href='javascript:popw("/popups/QuickChangeForm.jsp?cols=10&rows=1&question=Change%20Job%20ShipCostPolicy&primaryKeyValue=<%=jobId%>&columnName=ship_cost_policy&tableName=jobs&valueType=string",400,150)'> &raquo;&nbsp;</a><%=shipCostPolicy%>; 
Standard Shipping Cost: <a href='javascript:popw("/popups/QuickChangeForm.jsp?cols=10&rows=1&question=Change%20Job%20ShipCost&primaryKeyValue=<%=jobId%>&columnName=std_ship_cost&tableName=jobs&valueType=string",400,150)'> &raquo;&nbsp;</a>$<%=stdShipCost%><br>Shipping Price Policy: <a href="javascript:popw('/popups/QuickChangeForm.jsp?cols=10&rows=1&question=Change%20Job%20ShipPricePolicy&primaryKeyValue=<%=jobId%>&columnName=ship_price_policy&tableName=jobs&valueType=string',400,150)"> &raquo;&nbsp;</a><%=shipPricePolicy%>;  Standard Shipping Price:<a href="javascript:popw('/popups/QuickChangeForm.jsp?cols=10&rows=1&question=Change%20Job%20ShipPrice&primaryKeyValue=<%=jobId%>&columnName=std_ship_price&tableName=jobs&valueType=string',400,150)"> &raquo;&nbsp;</a>$<%=stdShipPrice%><%

}%></div><%}

while(rsAPI.next()){;
	if (x==0){
		x++;
%><br><br><div class=lineitems>Subvendor Invoices:</div>
<table class="body"><tr><td class="minderHeaderleft" width="10%">Invoice Date</td><td class="minderHeaderleft" width="10%">Invoice Number</td><%if (vendorId.equals("0")){%><td class="minderHeaderleft" width="10%">Vendor ID</td><%}%><td class="minderHeaderright" width="5%">Purchase Amount</td><td class="minderHeaderright" width="5%">Shipping Amount</td><td class="minderHeaderright" width="5%">Total Amount</td><%

if(editor) {
	%><td class="minderHeader">Pre-Accrual</td><td class="minderHeader">Post Date</td><%
}
%><td class="minderHeader" width='75%' >Description</td></tr><%
	}
	%><tr><td class="lineitems" width="10%"><%=rsAPI.getString("transDate")%></td><td class="lineitems" width="10%"><%=rsAPI.getString("vendor_invoice_no")%></td><%if (vendorId.equals("0")){%><td class="lineitems" width="5%"><%=rsAPI.getString("vendorid")%></td><%}%><td class="lineitemsright" width="5%"><%=formatter.getCurrency(rsAPI.getDouble("ap_purchase_amount")+rsAPI.getDouble("ap_sales_tax_amount"))%>
	<td class="lineitemsright" width="5%"><%=formatter.getCurrency(rsAPI.getDouble("ap_shipping_amount"))%>
	<td class="lineitemsright" width="5%"><%=formatter.getCurrency(rsAPI.getDouble("amount"))%>
	</td><%

if(editor) {
	%><td class="minderHeader"><%=rsAPI.getString("pre_accrual")%></td><td class="minderHeader"><%=rsAPI.getString("accruedDate")%></td><%}%><td class="lineitems" width='70%' ><%=rsAPI.getString("purchase_description")%></td></tr><%
	totPApplied+=rsAPI.getDouble("ap_purchase_amount");	
	totSApplied+=rsAPI.getDouble("ap_shipping_amount");	
	totSTApplied+=rsAPI.getDouble("ap_sales_tax_amount");	
	totApplied+=rsAPI.getDouble("amount");	
}
if (x>0){%><tr><td class='minderheaderright' <%=(((vendorId.equals("0")))?"colspan=3":"colspan=2")%> >TOTAL APPLIED:</td><td class='lineitemsright'><b><%=formatter.getCurrency(totPApplied)%></b></td><td class='lineitemsright'><b><%=formatter.getCurrency(totSApplied)%></b></td><td class='lineitemsright'><b><%=formatter.getCurrency(totApplied)%></b></td></tr>

<tr><td class='minderheaderright' <%=(((vendorId.equals("0")))?"colspan=3":"colspan=2")%> >TOTAL ACCRUED:</td>
<td class='lineitemsright'><b><%=formatter.getCurrency(totCost)%></b></td>
<td class='lineitemsright'><b><%=formatter.getCurrency(totShippingCost)%></b></td>
<td class='lineitemsright'><b><%=formatter.getCurrency(totAccrued)%></b></td></tr>
<tr><td class='minderheaderright' <%=(((vendorId.equals("0")))?"colspan=3":"colspan=2")%> >BALANCE:</td><td class='lineitemsright'><b><%=formatter.getCurrency((totCost-totPApplied))%></b></td><td class='lineitemsright'><b><%=formatter.getCurrency((totShippingCost-totSApplied))%></b></td><td class='lineitemsright'><b><%=formatter.getCurrency((totAccrued-totApplied))%></b></td></tr></table><%x=0;}

	st.close();
	st1.close();
	st2.close();
	st3.close();
	conn.close();
	%>