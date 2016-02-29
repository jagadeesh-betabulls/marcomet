<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<%@ page import="java.text.*,java.io.*,java.sql.*,java.util.*,com.marcomet.jdbc.*,com.marcomet.users.security.*,com.marcomet.workflow.actions.*;" %>
<%@ taglib uri="/WEB-INF/tld/taglib.tld" prefix="taglib" %>
<%
CalculateJobCosts cjc = new CalculateJobCosts();
Connection conn = DBConnect.getConnection();
Statement st = conn.createStatement();
boolean closeOnExit=((request.getParameter("closeOnExit")!=null && request.getParameter("closeOnExit").equals("true"))?true:false);
NumberFormat decFormatter = NumberFormat.getCurrencyInstance(Locale.US);

String jobId=((request.getParameter("jobId")==null)?"0":request.getParameter("jobId"));
String vendorId=((request.getParameter("vendorId")==null)?"0":request.getParameter("vendorId"));
String accruedPOCost=((request.getParameter("accruedPOCost")==null)?"0":request.getParameter("accruedPOCost"));
String adjustToPOCost=((request.getParameter("adjustToPOCost")==null)?"0":request.getParameter("adjustToPOCost"));
String notes=((request.getParameter("notes")==null)?"":request.getParameter("notes"));
String adjDate=((request.getParameter("adjDate")==null)?"Now()":"'"+request.getParameter("adjDate")+" 00:00:00'");
String amountApplied=((request.getParameter("amountApplied")==null)?"0":request.getParameter("amountApplied"));
String accrued_date="";

if(request.getParameter("submitted")!=null && request.getParameter("submitted").equals("true")){
	ResultSet rsAdj = st.executeQuery("Select post_date from jobs where id="+jobId);
	if (rsAdj.next()){
		accrued_date=((rsAdj.getString("post_date")==null)?"":rsAdj.getString("post_date"));
	}

	String insertAdj="insert into po_transactions ( job_id, vendor_id, adjustment_code, purchase_cost_adj_amt, adjustment_amount, adjustment_date, adjustment_notes"+((accrued_date.equals(""))?"":",accrued_date")+") values ( '"+jobId+"', '"+vendorId+"', '1', "+adjustToPOCost+", "+adjustToPOCost+", "+adjDate+", ?"+((accrued_date.equals(""))?"":",Now()")+")";
	PreparedStatement stAdj = conn.prepareStatement(insertAdj);
	stAdj.clearParameters();
	stAdj.setString(1, notes);
	stAdj.executeUpdate();
	cjc.calculate(jobId);

}

String adjSQL="Select if(api.id is null,'0' ,format( sum(api.ap_purchase_amount+api.ap_sales_tax_amount),2 ))  'amountApplied', sum(api.ap_purchase_amount+api.ap_sales_tax_amount) as 'dblAmountApplied', '0' as 'accruedPO','0' as 'dblAccruedPO', j.dropship_vendor from jobs j  left join ap_invoice_details api on j.id=api.jobid where j.id="+jobId+" group by j.id union Select '0' as'amountApplied','0' as 'dblAmountApplied', if(po.id is null,'0',format(sum(po.purchase_cost_adj_amt),2)) 'accruedPO',sum(po.purchase_cost_adj_amt) as 'dblAccruedPO',j.dropship_vendor from jobs j left join po_transactions po on po.job_id=j.id where j.id="+jobId+" group by j.id";

ResultSet rsAdj = st.executeQuery(adjSQL);
double iAccruedPOCost=0;
double iAmountApplied=0;
while (rsAdj.next()){
	vendorId=((rsAdj.getString("dropship_vendor")==null)?"0":rsAdj.getString("dropship_vendor"));
	iAccruedPOCost+=rsAdj.getDouble("dblAccruedPO");
	iAmountApplied+=rsAdj.getDouble("dblAmountApplied");
}

accruedPOCost=((iAccruedPOCost!=0)?decFormatter.format(iAccruedPOCost):accruedPOCost);
amountApplied=((iAmountApplied!=0)?decFormatter.format(iAmountApplied):amountApplied);

%><html>
<head>
<title>PO Adjustment</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link rel="stylesheet" href="<%=(String)session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css">
<script language="JavaScript" src="/javascripts/mainlib.js"></script>
<script>
	function submitThis(){
		document.forms[0].submit();
		window.opener.refresh();
		self.close();	
	}
</script>
</head>
<body bgcolor="#FFFFFF" text="#000000">
<form method="post" action="/popups/POAdjustment.jsp?submitted=true">
  <table class="body">
    <tr><td colspan=2><b>PO Adjustments:</b></td>
          </tr><tr><td class="minderHeaderright" width="93">Adjustment Date</td><td class=lineitems><jsp:include page="/includes/DatePicker.jsp?fieldNum=1&fieldName=adjDate&class=lineitems&defaultDate=today" /></td>
    </tr><tr><td  class="minderHeaderright">Job #</td><td class=lineitems><input type='hidden' name='jobId' value='<%=jobId%>'><%=jobId%></td>
    </tr><tr><td class="minderHeaderright" width="93">Vendor ID</td><td class=lineitems><input type='hidden' name='vendorId' value='<%=vendorId%>'><%=vendorId%></td>
    </tr><tr><td class="minderHeaderright" width="63">Amount Applied</td><td class=lineitemsright><input type='hidden' name='amountApplied' value='<%=amountApplied%>'><%=amountApplied%></td>
    </tr><tr><td class="minderHeaderright" width="63">Accrued PO Cost</td><td class=lineitemsright><input type='hidden' name='accruedPOCost' value='<%=accruedPOCost%>'><%=accruedPOCost%></td>
    </tr><tr><td class="minderHeaderright" width="101">Change to PO Cost</td><td class=lineitemsright><input class=lineitemsright type='text' size=10 name='adjustToPOCost' value='<%=adjustToPOCost%>'></td>
       </tr></table><br><table border=0><tr><td class="minderHeader" width="76" colspan=2>Reason/Description</td></tr><tr><td class=lineitems colspan=2><textarea class=lineitems name='notes' cols=60 rows=3><%=notes%></textArea></td></tr>
   <tr>
  	<td align="center">
  		<input type="button" value="Update" onClick="submitThis();">
	</td>
	<td align="center">
		<input type="button" value="Cancel" onClick="self.close()">
	</td>	
  </tr>
</table>
</form>
</body>
</html><%
	st.close();
	conn.close();
%>
