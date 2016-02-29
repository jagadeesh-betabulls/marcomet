<%@ page import="java.sql.*,java.util.*,java.text.*,com.marcomet.users.security.*, com.marcomet.jdbc.*, com.marcomet.environment.*,com.marcomet.tools.*;" %>
<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<%@ taglib uri="/WEB-INF/tld/formTagLib.tld" prefix="formtaglib" %>
<%
NumberFormat decFormatter = NumberFormat.getCurrencyInstance(Locale.US);
StringTool str=new StringTool();

Connection conn = DBConnect.getConnection();
Statement st = conn.createStatement();
String query="";
String query1="";
String rootProdCode="";
String variantCode="";
String release="";
int rCount=0;
String jobId=((request.getParameter("jobId")==null)?"":request.getParameter("jobId"));
String newQuantity=((request.getParameter("newQuantity")==null)?"":request.getParameter("newQuantity"));
String oldQuantity=((request.getParameter("oldQuantity")==null)?"":request.getParameter("oldQuantity"));
String oldUnitCost=((request.getParameter("oldUnitCost")==null)?"":request.getParameter("oldUnitCost"));
String newUnitCost=((request.getParameter("newUnitCost")==null)?"":request.getParameter("newUnitCost"));
String newCost=((newUnitCost.equals(""))? "("+newQuantity+"/"+oldQuantity +") " :newUnitCost+"*"+newQuantity);
int changed=0;
int x=1;
int y=1;
boolean closeThis=false;
boolean posted=false;
boolean submitted=((request.getParameter("submitted")!=null && request.getParameter("submitted").equals("true"))?true:false);
String invPricePer="0";
ResultSet rsPosted = st.executeQuery("select id from jobs where post_date is not null and id="+jobId);
if (rsPosted.next()){
	posted=true;
}

if (submitted && !(jobId.equals("")) && !(newQuantity.equals(""))){

	ResultSet rsInv = st.executeQuery("select if(j.accrued_inventory_cost=0,max(pp.inventory_cost/pp.quantity),0) as invPricePer  from jobs j left join products p on j.product_id=p.id left join product_prices pp on pp.prod_price_code=p. prod_price_code where  pp.inventory_cost>0 and  j.id="+jobId); 
	if (rsInv.next()){
		invPricePer=rsInv.getString("invPricePer");
	}
	
	query = "update jobs j set quantity="+newQuantity+", cost=round((cost*(("+newQuantity+"/"+oldQuantity+"))),2),price=round((price*(("+newQuantity+"/"+oldQuantity+"))),2),sales_tax=round((sales_tax*(("+newQuantity+" /"+oldQuantity+"))),2),billable=round((billable*(("+newQuantity+" /"+oldQuantity+"))) ,2),vendor_job_share=round((("+newQuantity+" /"+oldQuantity+")* vendor_job_share),2),accrued_po_cost=round(("+((newUnitCost.equals(""))? "("+newQuantity+"/"+oldQuantity +")* accrued_po_cost" :newUnitCost+"*"+newQuantity)+"),2),accrued_inventory_cost=if(accrued_inventory_cost<>0,round( ("+newQuantity+"/"+oldQuantity +")*accrued_inventory_cost),"+newQuantity+"*"+invPricePer+"),est_material_cost=round(("+((newUnitCost.equals(""))? "("+newQuantity+"/"+oldQuantity +")* accrued_po_cost" :newUnitCost+"*"+newQuantity)+"),2)+if(accrued_inventory_cost<>0,round(("+((newUnitCost.equals(""))? "("+newQuantity+"/"+oldQuantity +")*accrued_inventory_cost " :newUnitCost+"*"+newQuantity)+"),2),0)where id="+jobId;
	st.executeUpdate(query); 
	query = "update jobs j,po_transactions po set po.purchase_cost_adj_amt=round(("+((newUnitCost.equals(""))? "("+newQuantity+"/"+oldQuantity +")*po.purchase_cost_adj_amt " :newUnitCost+"*"+newQuantity)+"),2), po.adjustment_amount=round(("+((newUnitCost.equals(""))? "("+newQuantity+"/"+oldQuantity +")*po.adjustment_amount " :newUnitCost+"*"+newQuantity)+"),2) where po.job_id=j.id and j.id="+jobId;
	st.executeUpdate(query); 	
	query = "update jobs j, job_specs js set js.value="+newQuantity+" where js.job_id=j.id and js.cat_spec_id=999 and j.id="+jobId;
	st.executeUpdate(query); 	
	query = "update jobs j, job_specs js set js.cost=round(js.cost*("+newQuantity+"/"+oldQuantity+"),2),js.price=round(js.price*("+newQuantity+"/"+oldQuantity+"),2) where js.job_id=j.id and js.cat_spec_id=88888 and j.id="+jobId;
	st.executeUpdate(query); 
	changed++;
	//closeThis=true;
}else{
	submitted=false;
}

%><html>
<head>
  <title>Change Job Quantity/Price</title>
  <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link rel="stylesheet" type="text/css" href="/styles/master.css" title="Style" >
<link rel="stylesheet" type="text/css" href="/sitehosts/lms/styles/vendor_styles.css" title="Style" >
</head>
<script lanugage="JavaScript" src="/javascripts/mainlib.js"></script>
<body onLoad="<%=((jobId.equals(""))?"document.forms[0].jobId.select()":"document.forms[0].newquantity.select()")%>"><div class="title">Change quantities on Job/Job Spec/PO Records</div><%=((changed>0)?"<div class=subtitle>Job #"+jobId+", New Quantity:"+newQuantity+"</div>":"")%><%if (jobId.equals("")){%>
<form method="post" action="/popups/QuickChangeUpdateQuantities.jsp"><p class=subtitle>JobId: <input type=text name="jobId" class=lineitems></p><%}else{%>
<form method="post" action="/popups/QuickChangeUpdateQuantities.jsp">
<table border="0" cellpadding="5" cellspacing="0" align="center" width="100%"><% 

String sqlJobInfo = "select j.id 'Job Number', j.quantity 'R:Current Quantity',round((j.accrued_po_cost/if(j.quantity=0,if(jsq.value=0,1, jsq.value),j.quantity)),3)  as 'R:Current Unit Cost', j.cost 'F:R:Job Cost',j.price 'F:R:Job Price',j.sales_tax 'F:R:Sales Tax' ,j.billable 'F:R:Billable' ,j.vendor_job_share 'F:R:Vendor Job Share' ,j.accrued_po_cost 'F:R:Accrued PO Cost',j.accrued_inventory_cost 'F:R:Accrued Inventory Cost' ,j.est_material_cost 'F:R:Est Materials Cost',sum(po.purchase_cost_adj_amt) 'F:R:PO Cost', sum(po.adjustment_amount) 'F:PO Amount',  jsq.value 'Job Spec Quantity' , jsq.cat_spec_id 'Cat Spec ' ,jsc.cost as 'F:R:Job Cost on Spec' ,jsc.price as  'F:R:Job Price on Spec' from jobs j left join  job_specs jsq on jsq.job_id=j.id  and jsq.cat_spec_id=999 left join job_specs jsc on jsc.job_id=j.id  and jsc.cat_spec_id=88888, po_transactions po where po.job_id=j.id and j.id="+jobId+" group by j.id";

ResultSet rsAdj = st.executeQuery(sqlJobInfo);
ResultSetMetaData rsmdAdj = rsAdj.getMetaData();
int numberOfAdjColumns = rsmdAdj.getColumnCount();
String tempString = null;
ArrayList headersAdj  = new ArrayList(15);
ArrayList vTotals  = new ArrayList(15);
ArrayList stTotals  = new ArrayList(15);
int hiddenCols=0;
String headerStr="<tr>";
for (int i=1 ;i <= numberOfAdjColumns; i++){
	tempString = new String ((String) rsmdAdj.getColumnLabel(i));
	String tempString2 = new String ((String) rsmdAdj.getColumnLabel(i));
	headersAdj.add(tempString);
	vTotals.add("0");
	stTotals.add("0");	
	tempString=str.replaceSubstring(str.replaceSubstring(str.replaceSubstring(str.replaceSubstring(str.replaceSubstring(str.replaceSubstring(str.replaceSubstring(str.replaceSubstring(str.replaceSubstring(str.replaceSubstring(tempString,"H:", ""),"S:", ""),"R:", ""),"F:", ""),"Po:", ""),"Pr:", ""),"K:", ""),"L:", ""),"~", "&nbsp;"),"C:", "");
	x++;
	if(tempString2.indexOf("H:")==(-1)){headerStr+="<td  class='text-row1' ><p>"+tempString+"</p></td>";}else{hiddenCols++;}
}
headerStr+="</tr>";
String subTotStr="";
boolean openBalances=true;
boolean subtotals=false;
int c=0;
int totHeadCol=1;
int stRowCount=0;
boolean showRow=true;
boolean totalsOnly=false;
String addParams="";
//If Subtotals are chosen output the subtotal row and header row 
%><%=headerStr%><%
while (rsAdj.next()){
	String keyStr="";
	for (int i=0;i < numberOfAdjColumns; i++){
	   String columnName = (String) headersAdj.get(i);
	   showRow=true;//not filtering this report for open balances
	   if (showRow){
	   	rCount++;
	   	if (columnName.equals("R:Current Quantity") && !(rsAdj.getString(columnName).equals(""))){oldQuantity=rsAdj.getString(columnName);}
	   	if (columnName.equals("R:Current Unit Cost") && !(rsAdj.getString(columnName).equals(""))){oldUnitCost=rsAdj.getString(columnName);}	   	
	    if(columnName.indexOf("H:")==-1){
		if (i==0){%><tr><%}
		String linkStr="";
			%><td class='lineitems' align='<%=((columnName.indexOf("R:")>-1)?"right":((columnName.indexOf("C:")>-1)?"center":"left"))%>'><%=((rsAdj.getString(columnName)==null)?"":((columnName.indexOf("F:")>-1)?( (rsAdj.getString(columnName).equals(""))?rsAdj.getString(columnName):decFormatter.format(Double.parseDouble(rsAdj.getString(columnName)))):rsAdj.getString(columnName)))%></td><%
	  }//hidden column
	  submitted=true;
	 } //showrow
	} //for... columns
	x++;
	%></tr><%
} //while

%></table><%if (rCount==0){
jobId="";
%><script>document.forms[0].action="/popups/QuickChangeUpdateQuantities.jsp"</script><p class=subtitle>No jobs found, please reenter job number.<br>JobId: <input type=text name="jobId" class=lineitems></p><%}else{
if (posted){
%><div class=subtitle>This job has already been posted, no change to quantity amounts may be made through this form.</div><%
}else{
%>
<table border=0><%if(changed>0){%><tr><td class=class='text-row1' align=right>Original Quantity:</td><td class=class='text-row2'><b><%=request.getParameter("oldQuantity")%></b></td></tr><tr><td class=class='text-row1' align=right>Original Unit Cost:</td><td class=class='text-row2'><b><%=request.getParameter("oldUnitCost")%></b></td></tr><%}%><tr><td class=class='text-row1' align=right>Current Quantity:</td><td class=class='text-row2'><b><%=oldQuantity%></b></td></tr>
<tr><td class=class='text-row1' align=right>New Quantity:</td><td class=class='text-row2'><input type=text name='newQuantity' size=20 class=lineitems></td></tr>
<tr><td class=class='text-row1' align=right>Current Unit Cost:</td><td class=class='text-row2'><b><%=oldUnitCost%></b></td></tr>
<tr><td class=class='text-row1' align=right>New Unit Cost<br>(or leave blank for pro-rated):</td><td class=class='text-row2'><input type=text name='newUnitCost' size=20 class=lineitems value=""></td></tr></table><%
}
}
}%><table>
  <tr>
  	<td align="center"><%
  	if (posted){
  		%><input type="button" value="Continue" onClick="self.close()"><%
  	}else{
  		%><input type="button" value="Update" onClick="submit()">&nbsp;&nbsp;&nbsp;&nbsp;<input type='button' value='Cancel' onClick='self.close()'><%
  	}
  	%></td>
  </tr>
</table>
<input type="hidden" name="jobId" value="<%=request.getParameter("jobId")%>">
<input type="hidden" name="submitted" value="<%=((submitted)?"true":"false")%>">
<input type="hidden" name="oldQuantity" value="<%=oldQuantity%>">
<input type="hidden" name="originalQuantity" value="<%=((request.getParameter("oldQuantity")==null)?"":request.getParameter("oldQuantity"))%>">
<input type="hidden" name="oldUnitCost" value="<%=oldUnitCost%>">
<input type="hidden" name="originalUnitCost" value="<%=((request.getParameter("oldUnitCost")==null)?"":request.getParameter("oldUnitCost"))%>">
<%if (submitted && !(jobId.equals("")) && !(newQuantity.equals(""))){%><script>parent.window.opener.location.reload();setTimeout('close()',500);</script><%}%>
</form>
</body>
</html><%
	st.close();
	conn.close();
	%><%=((closeThis)?"<script>parent.window.opener.location.reload();setTimeout('close()',500);</script>":"")%>
