<%@ page import="java.text.*,java.io.*,java.sql.*,java.util.*,com.marcomet.users.security.*, com.marcomet.jdbc.*,com.marcomet.tools.*,com.marcomet.environment.*;" %>
<%
StringTool str=new StringTool();
boolean byProdLine=((request.getParameter("reportType")!=null && request.getParameter("reportType").equals("By Product Line"))?true:false);
String companyFilter = ((request.getParameter("CID")==null || request.getParameter("CID").equals(""))?"":" AND p.company_id='"+request.getParameter("CID")+"'");
String brandFilter=((request.getParameter("brand")==null || request.getParameter("brand").equals(""))?"":" AND p.brand_code='"+request.getParameter("brand")+"'");
String releaseFilter=((request.getParameter("ShowRelease")==null || request.getParameter("ShowRelease").equals(""))?"":" AND p.release='"+request.getParameter("ShowRelease")+"'");
String activeFilter=((request.getParameter("ShowActive")==null || request.getParameter("ShowActive").equals("") || request.getParameter("ShowActive").equals("ALL"))?"":((request.getParameter("ShowActive").equals("Non-Retired"))?" AND p.status_id<>3 and p.status_id<>4 ":" AND p.status_id=2 "));
String paramStr=((activeFilter.equals(""))?"":"  |  Status = "+request.getParameter("ShowActive"));
paramStr+=((companyFilter.equals(""))?"":"  |  Company ID = "+request.getParameter("CID"));
paramStr+=((releaseFilter.equals(""))?"":"  |  Release = "+request.getParameter("ShowRelease"));
paramStr+=((brandFilter.equals(""))?"":"  |  Brand = "+request.getParameter("brand"));
String defSort=((byProdLine)?"'Product Line ID','Product ID','Bridged','Brand Code'":"'Product ID','Product Line ID','Bridged','Brand Code'");
String sortBy= ((request.getParameter("sortBy")==null || request.getParameter("sortBy").equals(""))?" order by "+defSort:" order by "+request.getParameter("sortBy")+defSort);
String filters=companyFilter+activeFilter+brandFilter+releaseFilter;
SimpleDateFormat df = new SimpleDateFormat("MM/dd/yyyy");
int x=0;
boolean excel=((request.getParameter("excel")!=null && request.getParameter("excel").equals("true"))?true:false);	
String extraFields=((excel)?",concat(right(p.prod_line_id,4),root_prod_code,variant_code) 'ProdLineProd',mid(pl.id,5,2) 'Product Segment',concat(p.root_prod_code,p.variant_code) 'RootVariant Code',p.web_graphic_uploaded 'Web Graphic Uploaded',p.print_status 'Print Status',p.small_picurl 'Thumbnail Image',p.full_picurl 'Full Image',p.build_type 'Build Type',p.default_subvendor 'Subvendor ID',if(inventory_product_flag=0,'NO','YES') 'Inventory Product Flag',if(inventory_initialized>0,concat('Yes / ',inventory_init_date),'No') 'Inventory Initialized / Date',root_inv_prod_id 'Root Inv ID',inv_on_order_amount 'Amount of Root on Order',on_order_amount 'Amount on Order',inventory_amount 'Amount On Hand',(inventory_amount-inv_on_order_amount) 'Amount Available', backorder_action 'Backorder Flag',backorder_notes 'Backorder Text'":"");
if (excel){
response.reset();
response.setHeader("Content-type","application/xls");
response.setHeader("Content-disposition","inline; filename=productsWithLines.xls");
}
String headerClass=((excel)?"minderheaderleft":"text-row1");
%><html>
	<head>
		<title>Products With Product Lines <%=request.getParameter("reportType")%></title>
<%if (excel){%><style>
	<style>
		.Title {
			font-family: Helvetica, Arial, sans-serif;
			font-size: 12pt;
			color: black;
			font-weight: bold;
			border-bottom: thin solid;
			font-variant: normal;
		}
		.grid {
			border: thin solid;
			cellspacing:0;
			cellpadding:3;
		}
		.minderheaderleft {
			font-family: Arial;
			font-size: 10pt;
			font-weight: bolder;
			color: White;
			background-color: #A5A5A5;
			text-decoration: none;
			text-align: left;
			margin-top: 0px;
			margin-right: 0;
			margin-bottom: 0px;
			margin-left: 0px;
			letter-spacing: 0px;
		}
		.minderheadercenter {
			font-family: Arial;
			font-size: 10pt;
			font-weight: bolder;
			color: White;
			background-color: #A5A5A5;
			text-decoration: none;
			text-align: center;
			margin-top: 0px;
			margin-right: 0;
			margin-bottom: 0px;
			margin-left: 0px;
			letter-spacing: 0px;
		}
		.minderheaderright {
			font-family: Arial;
			font-size: 10pt;
			font-weight: bolder;
			color: White;
			background-color: #A5A5A5;
			text-decoration: none;
			text-align: right;
			margin-top: 0px;
			margin-right: 0;
			margin-bottom: 0px;
			margin-left: 0px;
			letter-spacing: 0px;
		}

		.lineitem {
			color: black;
			font-size: 10pt;
			font-weight: normal;
			font-family: Arial, Verdana, Geneva;
			text-align: left;
						border: thin solid;
		}
		.lineitemcenter {
			color: black;
			font-size: 10pt;
			font-weight: normal;
			font-family: Arial, Verdana, Geneva;
			text-align: center;
						border: thin solid;
		}

		.lineitemright {
			color: black;
			font-size: 10pt;
			font-weight: normal;
			font-family: Arial, Verdana, Geneva;
			text-align: right;
		}

		.lineitemleftalt {
			color: black;
			font-size: 10pt;
			font-weight: normal;
			font-family: Arial, Verdana, Geneva;
			background: #CCCCCC;
			text-align: left;
						border: thin solid;
		}

		A.lineitemleftalt:hover {
			color: Red;
		}

		A.lineitemleftalt:link {
			color: black;
		}

		A.lineitemleftalt:active {
			color: black;
						border: thin solid;
		}

		.lineitemcenteralt {
			color: black;
			font-size: 10pt;
			font-weight: normal;
			font-family: Arial, Verdana, Geneva;
			background: #CCCCCC;
			text-align: center;
						border: thin solid;
		}

		.lineitemrightalt {
			color: black;
			font-size: 10pt;
			font-weight: normal;
			font-family: Arial, Verdana, Geneva;
			text-align: right;
						border: thin solid;
		}

</style><%}else{%>
<link rel="stylesheet" type="text/css" href="/styles/master.css" title="Style" >
<link rel="stylesheet" type="text/css" href="/sitehosts/lms/styles/vendor_styles.css" title="Style" >
<script type="text/javascript" src="/javascripts/sorttable.js"></script>
<%}%>
	</head>
<body><%
if(!excel){
			%><div align=right><a class=greybutton href='javascript:history.go(-1)'>&laquo&nbsp;FILTERS&nbsp;</a><a class=greybutton href='javascript:location.href=location.href+"?CID=<%=request.getParameter("CID")%>&brand=<%=request.getParameter("brand")%>&ShowRelease=<%=request.getParameter("ShowRelease")%>&ShowActive=<%=request.getParameter("ShowActive")%>&excel=true"'>&nbsp;EXPORT TO EXCEL&nbsp;&raquo&nbsp;</a></div>
			<table border=0><tr><td colspan=13>&nbsp;</td></tr>
	<tr><td class='Title' colspan=13>Product List for Product Lines <%=request.getParameter("reportType")%> as of <%=df.format(new java.util.Date())%><br><%=paramStr%></td></tr>
		<tr><td colspan=13>&nbsp;</td></tr></table>
	<%}%><table <%=((excel)?"class=grid":"id='invoices' class='sortable' width='100%' cellpadding=2")%> ><tr><%
	String adjSQL=((byProdLine)?"SELECT  pl.id as 'Product Line Id',pl.prod_line_name as 'L:Product Line','NO' as 'L:Bridged',p.id as 'L:Product ID',p.prod_code 'Product Code',p.prod_name 'Product Name',lu.value as 'Status',p.release 'Release',p.brand_code 'Brand Code',p.company_id 'Company ID' "+extraFields+" from lu_product_status lu,product_lines pl  left join products p on  pl.id=p.prod_line_id  WHERE lu.id=p.status_id "+filters+" union SELECT plb.prod_line_id as 'Product Line Id',pl.prod_line_name as 'Product Line','yes' as 'Bridged' ,p.id as 'Product ID',p.prod_code 'Product Code',p.prod_name 'Product Name',lu.value as 'Status',p.release 'Release',p.brand_code 'Brand Code',p.company_id 'Company ID' "+extraFields+" from product_line_bridge plb left join lu_product_status lu on lu.id=p.status_id left join products p on plb.prod_id=p.id   left join product_lines pl on plb.prod_line_id=pl.id WHERE plb.status_id=2 and plb.id=plb.id "+filters+sortBy:"SELECT  p.id as 'Product ID',p.prod_code 'Product Code',p.prod_name 'Product Name',lu.value as 'Status',p.release 'Release',p.brand_code 'Brand Code',p.company_id 'Company ID',pl.id as 'Product Line Id',pl.prod_line_name as 'Product Line','no' as 'Bridged' "+extraFields+" from product_lines pl,lu_product_status lu  left join products p on  pl.id=p.prod_line_id  WHERE lu.id=p.status_id "+filters+" union SELECT p.id as 'Product ID',p.prod_code 'Product Code',p.prod_name 'Product Name',lu.value as 'Status',p.release 'Release',p.brand_code 'Brand Code',p.company_id 'Company ID',plb.prod_line_id as 'Product Line Id',pl.prod_line_name as 'Product Line','yes' as 'Bridged' "+extraFields+" from product_line_bridge plb left join products p on plb.prod_id=p.id left join lu_product_status lu on lu.id=p.status_id  left join product_lines pl on plb.prod_line_id=pl.id WHERE  plb.status_id=2 AND plb.id=plb.id "+filters+sortBy);



//Display products 

SimpleConnection sc = new SimpleConnection();

Connection conn = sc.getConnection();

Statement st = conn.createStatement();
Statement st2 = conn.createStatement();

%><table id='invoice' class='sortable' width='100%' cellpadding=2><tr><%

ResultSet rsAdj = st2.executeQuery(adjSQL);
ResultSetMetaData rsmdAdj = rsAdj.getMetaData();
int numberOfAdjColumns = rsmdAdj.getColumnCount();
String tempString = null;
Vector headersAdj  = new Vector(15);
for (int i=1 ;i <= numberOfAdjColumns; i++){
	tempString = new String ((String) rsmdAdj.getColumnLabel(i));
	headersAdj.add(tempString);
	tempString=str.replaceSubstring(str.replaceSubstring(str.replaceSubstring(tempString,"L:", ""),"~", "&nbsp;"),"C:", "");
	x++;
	%><td  class="text-row1" ><p><%=tempString%></p></td><%
}%></tr><%
while (rsAdj.next()){
	%><tr><%
	for (int i=0;i < numberOfAdjColumns; i++){
		String columnName = (String) headersAdj.get(i);
		%><td class='text-row<%=(((x % 2) == 0)?1:2)%>' align='<%=((columnName.indexOf("R:")>-1)?"right":((columnName.indexOf("C:")>-1)?"center":"left"))%>'><%=((rsAdj.getString(columnName)==null)?"":rsAdj.getString(columnName))%></td><%
	}
	x++;

	%></tr><%
}


sc.close();
%></tr></table></body></html>