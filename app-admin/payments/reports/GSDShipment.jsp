<%@ page import="java.text.*,java.io.*,java.sql.*,java.util.*,com.marcomet.users.security.*, com.marcomet.jdbc.*,com.marcomet.tools.*,com.marcomet.environment.*;" %>
<jsp:useBean id="formatter" class="com.marcomet.tools.FormaterTool" scope="page" />
<jsp:useBean id="sl" class="com.marcomet.tools.SimpleLookups" scope="page" />

<%
StringTool str=new StringTool();
String reportTitle="GSD Shipping Report";
SimpleDateFormat df = new SimpleDateFormat("MM/dd/yyyy");
boolean excel=((request.getParameter("excel")!=null && request.getParameter("excel").equals("true"))?true:false);	
if (excel){
response.reset();
response.setHeader("Content-type","application/xls");
response.setHeader("Content-disposition","inline; filename=accrualreport.xls");
}
String headerClass=((excel)?"minderheaderleft":"text-row1");
%><html>
	<head>
		<title><%=reportTitle%></title>
<%if (excel){%><style>
	<style>
	.Title {font-family: Helvetica, Arial, sans-serif;font-size: 12pt;color: black;font-weight: bold;border-bottom: thin solid;font-variant: normal;}
	.grid {	border: thin solid;cellspacing:0;cellpadding:3;}
	.minderheaderleft {	font-family: Arial;font-size: 10pt;font-weight: bolder;color: White;background-color: #A5A5A5;
		text-decoration: none;text-align: left;margin-top: 0px;margin-right: 0;margin-bottom: 0px;margin-left: 0px;letter-spacing: 0px;}
	.minderheadercenter {font-family: Arial;font-size: 10pt;font-weight: bolder;color: White;background-color: #A5A5A5;text-decoration: none;text-align: center;margin-top: 0px;margin-right: 0;margin-bottom: 0px;margin-left: 0px;letter-spacing: 0px;}
	.minderheaderright {font-family: Arial;font-size: 10pt;font-weight: bolder;color: White;background-color: #A5A5A5;text-decoration: none;text-align: right;margin-top: 0px;margin-right: 0;margin-bottom: 0px;margin-left: 0px;letter-spacing: 0px;}
	.lineitem {color: black;font-size: 10pt;font-weight: normal;font-family: Arial, Verdana, Geneva;text-align: left;			border: thin solid;}
	.lineitemcenter {color: black;font-size: 10pt;font-weight: normal;font-family: Arial, Verdana, Geneva;text-align: center;			border: thin solid;}
	.lineitemright {color: black;font-size: 10pt;font-weight: normal;font-family: Arial, Verdana, Geneva;text-align: right;}
	.lineitemleftalt {color: black;font-size: 10pt;font-weight: normal;font-family: Arial, Verdana, Geneva;background: #CCCCCC;text-align: left;			border: thin solid;}
	A.lineitemleftalt:hover {color: Red;}
	A.lineitemleftalt:link {color: black;}
	A.lineitemleftalt:active {color: black;border: thin solid;}
	.lineitemcenteralt {color: black;font-size: 10pt;font-weight: normal;font-family: Arial, Verdana, Geneva;background: #CCCCCC;text-align: center;border: thin solid;}
	.lineitemrightalt {color: black;font-size: 10pt;font-weight: normal;font-family: Arial, Verdana, Geneva;text-align: right;border: thin solid;}
	</style><%
}else{
%><link rel="stylesheet" type="text/css" href="/styles/master.css" title="Style" >
<link rel="stylesheet" type="text/css" href="/sitehosts/lms/styles/vendor_styles.css" title="Style" >
<script type="text/javascript" src="/javascripts/sorttable.js"></script>
<script type="text/javascript" src="/javascripts/mainlib.js"></script><%
}
%></head>
<body>
	<div class='Title'><%=reportTitle%> as of <%=df.format(new java.util.Date())%></div><br><br>
<%
boolean showPreAccrual=((request.getParameter("preaccrual")!=null && request.getParameter("preaccrual").equals(""))?false:true);
%><table <%=((excel)?"class=grid":"id='invoices' class='sortable' width='100%' cellpadding=2")%> ><tr><%

boolean totalsOnly=(request.getParameter("totalsonly")!=null && request.getParameter("totalsonly").equals("true"));

Connection conn = DBConnect.getConnection();
Statement st = conn.createStatement();
Statement st2 = conn.createStatement();
NumberFormat decFormatter = NumberFormat.getCurrencyInstance(Locale.US);

int x=0;
String stt=((request.getParameter("subtotal")==null || request.getParameter("subtotal").equals("None"))?"":request.getParameter("subtotal"));
String adjSQL="";
boolean subtotals=(stt.equals("")?false:true);

//INSERT SQL HERE, use 'T:' for any columns to be formatted as currency and totalled
adjSQL="select distinct s.shipped_from 'S:Shipped From',s.id,s.shipping_vendor_id 'Shipping Vendor', s.shipping_account_vendor_id 'Shipping Account Vendor',j.dropship_vendor 'DS Vendor On Job',DATE_FORMAT(s.date,'%m/%d/%Y')  'Ship Date',DATE_FORMAT(s.accrued_date,'%m/%d/%Y') 'Accrued Date',s.cost 'T:Shipping Cost',s.subvendor_handling 'T:Subvendor Handling',s.handling 'T:MC Handling',s.reference 'Tracking #',j.id 'Job Id',p.brand_code 'Brand',p.prod_name 'Product',s.pre_accrual 'pre_accrual',s.adjustment_flag 'Adj Flag',s.product_id 'Ship Product Id' from shipping_data s, jobs j left join products p on j.product_id=p.id  where s.job_id=j.id and prod_name like 'Guest Service%' and pre_accrual<>1 order by j.id,s.reference,s.date";

%><table id='invoice' class='sortable' width='100%' cellpadding=2><%
ResultSet rsAdj = st2.executeQuery(adjSQL);
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
	tempString=str.replaceSubstring(str.replaceSubstring(str.replaceSubstring(str.replaceSubstring(str.replaceSubstring(str.replaceSubstring(str.replaceSubstring(str.replaceSubstring(str.replaceSubstring(str.replaceSubstring(tempString,"H:", ""),"S:", ""),"R:", ""),"T:", ""),"Po:", ""),"Pr:", ""),"K:", ""),"L:", ""),"~", "&nbsp;"),"C:", "");
	x++;
	if(tempString2.indexOf("H:")==(-1)){headerStr+="<td  class='text-row1' ><p>"+tempString+"</p></td>";}else{hiddenCols++;}
}
headerStr+="</tr>";
String subTotStr="";
boolean openBalances=true;
int c=0;
int totHeadCol=1;
int stRowCount=0;
boolean showRow=true;

//If Subtotals are chosen output the subtotal row and header row 
%><%=headerStr%><%
while (rsAdj.next()){
	String keyStr="";
	for (int i=0;i < numberOfAdjColumns; i++){
	   String columnName = (String) headersAdj.get(i);
	   showRow=true;//not filtering this report for open balances
	   if (showRow){
	    if(columnName.indexOf("H:")==-1){
		 if(stt.equals("v") && subtotals && columnName.indexOf("S:")>-1 && !subTotStr.equals(((rsAdj.getString(columnName)==null)?"0":rsAdj.getString(columnName))) ){
			if(stRowCount>0){
				%><tr><%
				for (int j=0;j < numberOfAdjColumns; j++){
					String columnNameST = (String) headersAdj.get(j);
					String totalStrSt=((columnNameST.indexOf("T:")>-1)?decFormatter.format(Double.parseDouble((String)stTotals.get(j))):"&nbsp;");
					if (j==0){
						%><td class='minderheaderright' align='right' colspan=<%=totHeadCol-hiddenCols%>>TOTALS FOR LOCATION <%=subTotStr%></td><%
					}else if (j>(totHeadCol-1)){
						%><td class='<%=((columnNameST.indexOf("T:")>-1)?"lineitemsright":"minderheaderright")%>' align='right'><b><%=totalStrSt%></b></td><%		
					}
				}
				for (int m=0; m < numberOfAdjColumns; m++) {
					stTotals.set(m,"0");
				}
				%></tr><%
			
			} //if(stRowCount)
			subTotStr=((rsAdj.getString(columnName)==null)?"0":rsAdj.getString(columnName));
			stRowCount++;
			if (i==0){%><%=headerStr%><%}
		}else if (i==0 && !totalsOnly){%><tr><%}
		String linkStr="";
		if (columnName.indexOf("T:")>-1){
			totHeadCol=((totHeadCol==1)?i:totHeadCol);
			double tempD=rsAdj.getDouble(columnName)+Double.parseDouble((String)vTotals.get(i));
			double tempDST=rsAdj.getDouble(columnName)+Double.parseDouble((String)stTotals.get(i));				
			vTotals.set(i, Double.toString(tempD));
			stTotals.set(i, Double.toString(tempDST));
		}
		keyStr=((columnName.indexOf("K:")>-1)?rsAdj.getString(columnName):keyStr);
		if(!excel){
			linkStr=((columnName.indexOf("K:")>-1)?"<a href=\"javascript:pop('/popups/JobDetailsPage.jsp?jobId="+rsAdj.getString(columnName)+"','700','600')\" class='minderACTION'>":   ((columnName.indexOf("Pr:")>-1)?"<a href=\"javascript:pop('/popups/ProductInfo.jsp?productId="+rsAdj.getString(columnName)+"','900','800')\" class='minderACTION'>":   ((columnName.indexOf("Po:")>-1)?"<a href=\"javascript:pop('/popups/PurchaseOrder.jsp?actingRole=vendor&jobId="+keyStr+"','900','800')\" class='minderACTION'>":"")));
		}
		if(!totalsOnly){
			%><td class='text-row<%=(((x % 2) == 0)?1:2)%>' align='<%=((columnName.indexOf("R:")>-1)?"right":((columnName.indexOf("C:")>-1)?"center":"left"))%>'><%=linkStr+((rsAdj.getString(columnName)==null)?"":((columnName.indexOf("T:")>-1)?decFormatter.format(Double.parseDouble(rsAdj.getString(columnName))):rsAdj.getString(columnName)) ) +((linkStr.equals(""))?"":"</a>")%></td><%
		}		
	  }//hidden column
	 } //showrow
	} //for... columns
	x++;
	if(!totalsOnly){%></tr><%}
} //while

if(stt.equals("v") && subtotals){
	%><tr><%
	for (int j=0;j < numberOfAdjColumns; j++){
		String columnNameST = (String) headersAdj.get(j);
		String totalStrSt=((columnNameST.indexOf("T:")>-1)?decFormatter.format(Double.parseDouble((String)stTotals.get(j))):"&nbsp;");
		if (j==0){
			%><td class='minderheaderright' align='right' colspan=<%=totHeadCol-hiddenCols%> >TOTALS FOR <%=subTotStr%> </td><%
		}else if (j>(totHeadCol-1)){
			%><td class='<%=((columnNameST.indexOf("T:")>-1)?"lineitemsright":"minderheaderright")%>' align='right'><b><%=totalStrSt%></b></td><%		
		}
	}%></tr><%
}

	%><tr><%
	for (int i=0;i < numberOfAdjColumns; i++){
		String columnName = (String) headersAdj.get(i);
		String totalStr=((columnName.indexOf("T:")>-1)?decFormatter.format(Double.parseDouble((String)vTotals.get(i))):"&nbsp;");
		if (i==0){
			%><td class='minderheaderright' align='right' colspan=<%=totHeadCol-hiddenCols%>>TOTALS:</td><%
		}else if (i>(totHeadCol-1)){
			%><td class='<%=((columnName.indexOf("T:")>-1)?"lineitemsright":"minderheaderright")%>' align='right'><b><%=totalStr%></b></td><%		
		}
	}
	%></tr><%=headerStr%><%
	st.close();
	st2.close();
	conn.close();
%></table> query: <%=adjSQL%></body></html>