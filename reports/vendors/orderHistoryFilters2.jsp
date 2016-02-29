<%@ page import="java.sql.*,com.marcomet.users.security.*,com.marcomet.tools.*;import java.text.*;" %>
<%@ include file="/includes/SessionChecker.jsp" %>
<%@ taglib uri="/WEB-INF/tld/formTagLib.tld" prefix="formtaglib" %>
<%@ taglib uri="/WEB-INF/tld/taglib.tld" prefix="taglib" %>
<jsp:useBean id="formatter" class="com.marcomet.tools.FormaterTool" scope="page" />
<jsp:useBean id="sl" class="com.marcomet.tools.SimpleLookups" scope="page" />
<jsp:useBean id="cB" class="com.marcomet.beans.SBPContactBean" scope="page" /><%
Connection conn = com.marcomet.jdbc.DBConnect.getConnection();
Statement st = conn.createStatement();
Statement st2 = conn.createStatement();
String companyId=((request.getParameter("companyId")==null)?"":request.getParameter("companyId"));
String reportType=((request.getParameter("reportType")==null)?"1":request.getParameter("reportType"));
String siteHostCompany=((request.getParameter("siteHostCompany")==null)?"0":request.getParameter("siteHostCompany"));
String buyerCompany=((request.getParameter("buyerCompany")==null)?"0":request.getParameter("buyerCompany"));
String dateFrom=((request.getParameter("dateFrom")==null)?"":request.getParameter("dateFrom"));
String dateTo=((request.getParameter("dateTo")==null)?"":request.getParameter("dateTo"));
String prodCode=((request.getParameter("prodCode")==null)?"":request.getParameter("prodCode"));
boolean subByProd=((request.getParameter("subByProd")!=null && request.getParameter("subByProd").equals("yes"))?true:false); 
String vendorId=session.getAttribute("companyId").toString();
String tempProd="";
String sql="SELECT distinct c.id 'value', c.company_name 'text' FROM projects p,orders o,jobs j,companies c where c.id is not null and c.company_name is not null and c.company_name<>'' and buyer_company_id=c.id and j.vendor_company_id="+vendorId+"  and j.project_id=p.id and p.order_id=o.id ORDER BY company_name";
String shSQL="SELECT distinct sh.id 'value', c.company_name 'text' FROM site_hosts sh, companies c,orders o,jobs j,projects p WHERE j.vendor_company_id="+vendorId+" and j.project_id=p.id and o.id=p.order_id and o.site_host_id=sh.id and sh.company_id = c.id ORDER BY company_name";
String noinvoice="yes";
boolean editor= (((RoleResolver)session.getAttribute("roles")).roleCheck("editor"));
String loginId = (session.getAttribute("contactId")==null)?"":(String)session.getAttribute("contactId"); 
loginId = ((request.getParameter("userId")==null)?loginId:request.getParameter("userId"));
cB.setContactId(loginId);
DecimalFormat decFormatter = new DecimalFormat("##.##");
int c=0;
String reportTitle=((request.getParameter("reportType")==null)?"Order History Report":((request.getParameter("reportType").equals("1"))?"Order History Report by Date":"Order History Report by Product"));
DecimalFormat df = new DecimalFormat("###,###,###");
%><html>
<head>
<META HTTP-EQUIV="pragma" CONTENT="no-cache">
<META HTTP-EQUIV="Pragma-directive" CONTENT="no-cache">
<META HTTP-EQUIV="cache-directive" CONTENT="no-cache">
<title>Order History Report</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link rel="stylesheet" href="<%=(String)session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css">
<style>div#filters{margin: 0px 20px 0px 20px;display: none;}</style><script>
<script language="JavaScript">
function popHiddenDateField2(fieldName){
	var month = document.forms[0].dateMonth2[document.forms[0].dateMonth2.selectedIndex].value;
	var day = document.forms[0].dateDay2[document.forms[0].dateDay2.selectedIndex].value;
	var year = document.forms[0].dateYear2[document.forms[0].dateYear2.selectedIndex].value;
	eval("document.forms[0]."+ fieldName + ".value = '" + year + "-" + month + "-" + day+"'");
}
</script>
<link rel="stylesheet" href="/javascripts/jscalendar/calendar-win2k-1.css" type="text/css">
<script type="text/javascript" src="/javascripts/jscalendar/calendar.js"></script>
<script type="text/javascript" src="/javascripts/jscalendar/lang/calendar-en.js"></script>
<script type="text/javascript" src="/javascripts/jscalendar/calendar-setup.js"></script>
<script type="text/javascript" src="/javascripts/mainlib.js"></script>
</head>
<body bgcolor="#FFFFFF" text="#000000" background="<%=(String)session.getAttribute("siteHostRoot")%>/images/back3.jpg">
<p class="TITLE"><%=reportTitle%></p>
<span id='loading'><div align='center'> L O A D I N G . . . <br><br><img src='/images/loading.gif'><br></div></span><div id='filtertoggle' ></div><div id='filters'>
<form method="post" action="/reports/vendors/orderHistoryFilters2.jsp?submitted=true">
<input type="hidden" name="vendorId" value="<%=vendorId%>">
<table>
	<tr> <td class="minderHeader" style="text-align:right">Report Type:</td><td class=lineitems> <input type='radio' name="reportType" value="1" <%=((reportType.equals("1"))?"checked":"")%>>By Date&nbsp;&nbsp;<input type='radio' name="reportType"  value="2" <%=((reportType.equals("2"))?"checked":"")%> >By Root Product<br><input type='checkbox' name='subByProd' value='yes' <%=((subByProd)?"checked":"")%>><span class=lineitems>Subtotal By Product</span></td></tr>
	<tr><td class="minderHeader" style="text-align:right">Date From:</td>
 	<td>&nbsp;&nbsp;<input type="hidden" name="dateFrom" id="f_datefrom_d"><span class="lineitemsselected" id="show_d"></span>&nbsp;<img src="/javascripts/jscalendar/img.gif" align="absmiddle" id="f_trigger_c" style="cursor: pointer; border: 1px solid red;" title="Date selector" onmouseover="this.style.background='red';" onmouseout="this.style.background=''" />
<script type="text/javascript">
 Calendar.setup({
 inputField: "f_datefrom_d", ifFormat: "%Y-%m-%d",displayArea: "show_d",daFormat: "%m-%d-%Y", button:"f_trigger_c", align: "BR", singleClick: true}); var d=new Date();
 document.forms[0].dateFrom.value=<%=((dateFrom.equals(""))?"d.getFullYear()+'-'+(d.getMonth()+1)+'-01'":"'"+dateFrom+"'")%>; 
 document.getElementById('show_d').innerHTML=<%=((dateFrom.equals(""))?"(d.getMonth()+1)+'-01-'+d.getFullYear()":"'"+dateFrom+"'")%>;
</script></td></tr><tr><td class="minderHeader" style="text-align:right">&nbsp;Date To:&nbsp;<u>&nbsp;</td>
<td>&nbsp;&nbsp;<input type="hidden" name="dateTo" id="f_dateto_d"><span class="lineitemsselected" id="show_d2"></span>&nbsp;<img src="/javascripts/jscalendar/img.gif" align="absmiddle" id="f_trigger_c2" style="cursor: pointer; border: 1px solid red;" title="Date selector" onmouseover="this.style.background='red';" onmouseout="this.style.background=''" />
<script type="text/javascript">
Calendar.setup({
	inputField: "f_dateto_d", ifFormat : "%Y-%m-%d", displayArea : "show_d2", daFormat : "%m-%d-%Y", button : "f_trigger_c2", align: "BR", singleClick : true });
	var d=new Date();
	document.forms[0].dateTo.value=<%=((dateTo.equals(""))?"d.getFullYear()+'-'+(d.getMonth()+1)+'-'+d.getDate()":"'"+dateTo+"'")%>; document.getElementById('show_d2').innerHTML=<%=((dateTo.equals(""))?"(d.getMonth()+1)+'-'+d.getDate()+'-'+d.getFullYear()":"'"+dateTo+"'")%>;
</script></td></tr>
<tr>
 <td class="minderHeader" style="text-align:right">Source Site:</td>
 <td><formtaglib:SQLDropDownTag extraCode=" class='lineitem' onChange=\"document.forms[0].siteHostCompanyText.value=document.forms[0].siteHostCompany.options[this.selectedIndex].text\"" dropDownName="siteHostCompany" sql="<%=shSQL%>" selected="<%=siteHostCompany%>" extraFirstOption="<option value=\"0\">All</option>" /></td>
</tr>
<tr>
 <td class="minderHeader" style="text-align:right">Product Code (or Partial):</td>
 <td ><input type=text class=lineitems name="prodCode" size=30 value='<%=prodCode%>'></td>
</tr>
<tr><td class="minderHeader" style="text-align:right">Buyer Company:</td>
<td><formtaglib:SQLDropDownTag dropDownName="buyerCompany" sql="<%=sql%>" extraCode="  class='lineitem' onChange=\"document.forms[0].buyerCompanyText.value=this.options[this.selectedIndex].text\"" selected="<%=buyerCompany%>" extraFirstOption="<option value=\"0\">All</option>" /></td>
 </tr>
 <tr> 
 <td colspan="2" class="label" style="text-align:right"> 
 <div align="center"> 
	 <input type="button"  class=greybutton value="Cancel" onClick="history.go(-1)">
	 <input type="button" class=greybutton value="Generate Report" onClick="submit()">
 </div>
 </td>
 </tr>
  </table>
<input type="hidden" name="siteHostCompanyText" value="">
<input type="hidden" name="buyerCompanyText" value="">
</form>
<hr></div><%
if (request.getParameter("submitted")!=null && request.getParameter("submitted").equals("true")){
%><!----------------------Report Header------------------------------->
<table  border=0 cellpadding=4 cellspacing=0 width=90%>
  <tr> 
    <td class="minderHeader" style="text-align:right" width="13%">Date&nbsp;From:</td>
    <td class="lineitems" width="16%"><%=((request.getParameter("dateFrom").equals("0000-00-00"))?"All":formatter.formatMysqlDate(request.getParameter("dateFrom")))%></td>
    <td width="71%" align="right">&nbsp;</td>
  </tr>
  <tr> 
    <td class="minderHeader" style="text-align:right" width="13%">Date&nbsp;To:</td>
    <td class="lineitems" width="16%"><%=((request.getParameter("dateTo").equals("2029-12-31"))?"All":formatter.formatMysqlDate(request.getParameter("dateTo")))%></td>
  </tr>
  <tr> 
    <td class="minderHeader" style="text-align:right" width="13%">Source&nbsp;Site:</td>
    <td class="lineitems" width="16%"><%=((request.getParameter("siteHostCompanyText")==null || request.getParameter("siteHostCompanyText").equals(""))?"All":request.getParameter("siteHostCompanyText"))%></td>
    <td class="label" style="text-align:right" width="1%"></td>
  </tr>
  <tr> 
    <td class="minderHeader" style="text-align:right" width="13%">Buyer&nbsp;Company:</td>
    <td class="lineitems" width="16%"><%=((request.getParameter("buyerCompanyText")==null || request.getParameter("buyerCompanyText").equals(""))?"All":request.getParameter("buyerCompanyText"))%></td>
    <td class="label" style="text-align:right" width="1%"></td>
  </tr><td class="minderHeaderRight"><b>Report Totals:</b></td><td class=lineitems><span id='totals'></span></td></tr>
</table>
<br><br>
<table border="0" cellpadding="1" cellspacing="0" width="100%"><%
String sqlOrders = "";
String sqlRoot = "";
String rootProduct = "";
double totalPrice = 0;
double rTotalPrice = 0;
double rTotalTotal = 0;
double rTotalCost = 0;
double prTotalPrice = 0;
double prTotalTotal = 0;
double prTotalCost = 0;
double totalCost = 0;
int rTotalQuantity=0;
int totalQuantity=0;

String alt="alt";
String headerRow="<tr><td class=\"minderheadercenter\" >Order Date</td><td class=\"minderheadercenter\" >Job #</td><td class=\"minderheadercenter\" >Product Code</td><td class=\"minderheadercenter\" >Product Name</td><td class=\"minderheadercenter\" >Quantity</td><td class=\"minderheadercenter\" >Price</td>"+((editor)?"<td class=\"minderheadercenter\" >Cost</td><td class=\"minderheadercenter\" >Margin</td><td class=\"minderheadercenter\" >Margin %</td><td class=\"minderheadercenter\" >Date Shipped</td>":"");

if (reportType.equals("2")){
  sqlRoot = "select distinct j.root_prod_code, proot.description from jobs j, site_hosts sh, products prod, product_roots proot where j.jsite_host_id=sh.id  and j.product_code=prod.prod_code  and j.root_prod_code=proot.root_prod_code and j.product_code like '%"+prodCode+"%'  and j.order_date>='" + request.getParameter("dateFrom") + " 00:00:00'  and j.order_date<='" + request.getParameter("dateTo") + " 23:59:59' and (j.jbuyer_company_id = "+request.getParameter("buyerCompany")+" or "+request.getParameter("buyerCompany")+" = 0) and (j.jsite_host_id = "+request.getParameter("siteHostCompany")+" or "+request.getParameter("siteHostCompany")+" = 0 ) order by "+((subByProd)?"j.root_prod_code,j.product_code":"j.root_prod_code");
} else {
	sqlRoot = "select distinct 'All' as root_prod_code from jobs j";
}
try{
ResultSet root = st.executeQuery(sqlRoot);
if(root.next()){
  do{
  /*
  	If post_date not null, use j.accrued_shipping (as it is now)
	If post_date is null and j.shipping_price <>0, use j.shipping price
	If post_date is null and j.shipping_price =0, use j.std_ship_cost
  */

  String jobCost="(j.accrued_po_cost+j.accrued_inventory_cost+if(j.post_date is null,if(j.shipping_price=0,j.std_ship_cost,j.shipping_price),j.accrued_shipping))";
  // Remove Labor Cost: String jobCost="(j.accrued_po_cost+j.accrued_inventory_cost+j.accrued_shipping+j.est_labor_cost)";
  String jobPrice="(j.price+j.shipping_price)";
    if (reportType.equals("2")){ //if report is by product
      rootProduct = root.getString("j.root_prod_code");%>
        <tr>
        <td class="label" style="text-align:right" colspan="7">Product: <%=rootProduct%>  <%=root.getString("proot.description")%></td>
        </tr><%
      rTotalPrice = 0;
      rTotalCost = 0; 
      rTotalTotal = 0;
      prTotalPrice = 0;
      prTotalCost = 0; 
      prTotalTotal = 0;
      sqlOrders = "select if(max(sd.`date`) is null,'',DATE_FORMAT(max(sd.`date`),'%m-%d-%y')) 'shipping_date',"+jobCost+" 'job_cost',"+jobPrice+" - "+jobCost+" 'job_margin',if(("+jobPrice+")<=0,0,((("+jobPrice+" - "+jobCost+")/"+jobPrice+")*100))  'job_margin_percentage',j.root_prod_code, j.product_code, prod.prod_name, date_format(j.order_date,'%m/%d/%y') as order_date, j.id, quantity, "+jobPrice+" price from site_hosts sh,jobs j left join products prod on j.product_id=prod.id left join shipping_data sd on sd.job_id=j.id where j.jsite_host_id=sh.id and j.order_date>='" + request.getParameter("dateFrom") + " 00:00:00'  and j.order_date<='" + request.getParameter("dateTo") + " 23:59:59' and (j.jbuyer_company_id = "+request.getParameter("buyerCompany")+" or "+request.getParameter("buyerCompany")+" = 0) and (j.jsite_host_id = "+request.getParameter("siteHostCompany")+" or "+request.getParameter("siteHostCompany")+" = 0 ) and j.root_prod_code = '"+rootProduct+"'  and j.status_id<>9 and j.product_code like '%"+prodCode+"%' group by j.id order by "+((subByProd)?"j.root_prod_code,j.product_code,j.order_date desc":"j.order_date desc,j.root_prod_code,j.product_code");
    }else{ //if report is not by product
      sqlOrders = "select if(max(sd.`date`) is null,'',DATE_FORMAT(max(sd.`date`),'%m-%d-%y')) 'shipping_date', "+jobCost+" 'job_cost',"+jobPrice+" - "+jobCost+" 'job_margin',if(("+jobPrice+")<=0,0,((("+jobPrice+" - "+jobCost+")/"+jobPrice+")*100))  'job_margin_percentage',j.root_prod_code, j.product_code, prod.prod_name, date_format(j.order_date,'%m/%d/%y') as order_date, j.id, quantity,"+jobPrice+" price from site_hosts sh,jobs j left join products prod on j.product_id=prod.id left join shipping_data sd on sd.job_id=j.id where j.jsite_host_id=sh.id and j.order_date>='" + request.getParameter("dateFrom") + "  00:00:00'  and j.order_date<='" + request.getParameter("dateTo") + " 23:59:59' and (j.jbuyer_company_id = "+request.getParameter("buyerCompany")+" or "+request.getParameter("buyerCompany")+" = 0) and (j.jsite_host_id = "+request.getParameter("siteHostCompany")+" or "+request.getParameter("siteHostCompany")+" = 0 ) and j.status_id<>9 and j.product_code like '%"+prodCode+"%' group by j.id order by "+((subByProd)?"j.root_prod_code,j.product_code,j.order_date desc":"j.order_date desc,j.root_prod_code,j.product_code");
    }
    %><!-- <%=sqlOrders%> --><%
    ResultSet orders = st2.executeQuery(sqlOrders);
    if(orders.next()){
    noinvoice="no";
    %><%=headerRow%><%
    int x=0;
      do{
       if(x > 0 && subByProd && !(tempProd.equals(orders.getString("j.product_code")))){
			%><tr>				
			<td class="lineitemsright" colspan=4><b><%=tempProd%> Totals:</b></td>
			<td class="lineitemsright" ><%=df.format(prTotalTotal)%></td>
			<td class="lineitemsright" ><%=formatter.getCurrency(prTotalPrice)%></td><%
			if(editor){
				%><td class="lineitemsright" ><%=formatter.getCurrency(prTotalCost)%></td>
				<td class="lineitemsright" ><%=formatter.getCurrency(prTotalPrice-prTotalCost)%></td>
				<td class="lineitemsright" ><%=decFormatter.format( ((prTotalPrice-prTotalCost)/prTotalPrice)*100 )%>%</td><%      	
			}
			tempProd=orders.getString("j.product_code");
			prTotalPrice = 0;
			prTotalCost = 0; 
			prTotalTotal = 0;
			%></tr><%
       }

        totalPrice += orders.getDouble("price");
        rTotalPrice += orders.getDouble("price");
        rTotalTotal += orders.getDouble("quantity");
        rTotalCost += orders.getDouble("job_cost"); 
        prTotalPrice += orders.getDouble("price");
        prTotalTotal += orders.getDouble("quantity");
        prTotalCost += orders.getDouble("job_cost");                
        totalCost += orders.getDouble("job_cost");  
        alt=((alt.equals(""))?"alt":"");
        %>
        <tr>
        <td class="lineitemcenter<%=alt%>" ><%=orders.getString("order_date")%></td>
        <td class="lineitemcenter<%=alt%>" ><a href="javascript:pop('/popups/JobDetailsPage.jsp?jobId=<%=orders.getString("j.id")%>','700','300')"><%=orders.getString("j.id")%></a></td>
        <td class="lineitemcenter<%=alt%>" ><%=orders.getString("j.product_code")%></td>
        <td class="lineitemcenter<%=alt%>" ><%=orders.getString("prod.prod_name")%></td>
        <td class="lineitemright<%=alt%>" ><%=df.format(orders.getDouble("quantity"))%></td>
        <td class="lineitemright<%=alt%>" ><%=formatter.getCurrency(orders.getDouble("price"))%></td><%
        if (editor){
%>        <td class="lineitemright<%=alt%>" ><%=formatter.getCurrency(orders.getDouble("job_cost"))%></td>
          <td class="lineitemright<%=alt%>" ><%=formatter.getCurrency(orders.getDouble("job_margin"))%></td>
          <td class="lineitemright<%=alt%>" ><%=df.format(orders.getDouble("job_margin_percentage"))%>%</td>
          <td class="lineitemright<%=alt%>" ><%=orders.getString("shipping_date")%></td><%              
        }%></tr><%
        tempProd=orders.getString("j.product_code");
        x++;
      }while(orders.next());
    }
   if(subByProd){
        %><tr>				
        <td class="lineitemsright" colspan=4><b><%=tempProd%> Totals:</b></td>
        <td class="lineitemsright" ><%=df.format(prTotalTotal)%></td>
        <td class="lineitemsright" ><%=formatter.getCurrency(prTotalPrice)%></td><%
      if(editor){
      	%><td class="lineitemsright" ><%=formatter.getCurrency(prTotalCost)%></td>
      	<td class="lineitemsright" ><%=formatter.getCurrency(prTotalPrice-prTotalCost)%></td>
      	<td class="lineitemsright" ><%=decFormatter.format( ((prTotalPrice-prTotalCost)/prTotalPrice)*100 )%>%</td><%      	
      }
      %></tr><%
    }

    if (reportType.equals("2")){%>
      <tr>				
        <td class="lineitemsright" colspan=4><b><%=rootProduct%> Totals:</b></td>
        <td class="lineitemsright" ><%=df.format(rTotalTotal)%></td>
        <td class="lineitemsright" ><%=formatter.getCurrency(rTotalPrice)%></td><%
      if(editor){
      	%><td class="lineitemsright" ><%=formatter.getCurrency(rTotalCost)%></td>
      	<td class="lineitemsright" ><%=formatter.getCurrency(rTotalPrice-rTotalCost)%></td>
      	<td class="lineitemsright" ><%=decFormatter.format( ((rTotalPrice-rTotalCost)/rTotalPrice)*100 )%>%</td><%      	
      }
      %></tr>
      <tr><td colspan=7>&nbsp;</td></tr><%
    }
  }while(root.next());
      %>
    <tr><td class="lineitemsright" colspan=5><b>Report Totals:</b></td><td class="lineitemsright" ><%=formatter.getCurrency(totalPrice)%></td><%if(editor){%><td class="lineitemsright" ><%=formatter.getCurrency(totalCost)%></td><td class="lineitemsright" ><%=formatter.getCurrency(totalPrice-totalCost)%></td><td class="lineitemsright" ><%=decFormatter.format(((totalPrice-totalCost)/totalPrice)*100)%>%</td><%}%></tr>
     </tr>
  <script>document.getElementById('totals').innerHTML='<b>Price:&nbsp;<u><%=formatter.getCurrency(totalPrice)%></u><%if(editor){%>&nbsp;|&nbsp;Cost:&nbsp;<u><%=formatter.getCurrency(totalCost)%></u>&nbsp;|&nbsp;Margin:&nbsp;<u><%=formatter.getCurrency(totalPrice-totalCost)%></u>&nbsp;|&nbsp;Margin&nbsp;%:&nbsp;<u><%=decFormatter.format(((totalPrice-totalCost)/totalPrice)*100)%>%</u><%}%>'</script>
<%
}else{
 %>"No Orders Found"<%
}
  %>
 </table>
<%
}catch (Exception e){
%>error:<%=e%><br><%=sqlRoot+"<br>"+sqlOrders%><%
}finally{
	st2.close();st.close();conn.close();
}
}%><script>
	document.getElementById('loading').innerHTML='';
	function toggleLayer(whichLayer){
		var style2 = document.getElementById(whichLayer).style;
		style2.display = style2.display=="block"? "none":"block";
	}
	function togglefilters(){
		var style2 = document.getElementById('filters').style;
		if (style2.display=="block"){
			document.getElementById('filtertoggle').innerHTML='<div align=right><div class=menuLink><a href="javascript:togglefilters()">+ Show Filters</a></div></div>';
		}else{
			document.getElementById('filtertoggle').innerHTML=<%=((noinvoice.equals("yes"))?"''":"'<div class=menuLink><a href=\"javascript:togglefilters()\">&raquo; Hide Filters</a></div>'")%>;
		}
		toggleLayer('filters');
	}
	<%=((noinvoice.equals("yes"))?"togglefilters();":"document.getElementById('filtertoggle').innerHTML='<div align=right><div class=menuLink><a href=\"javascript:togglefilters()\">+ Show Filters</a></div></div>'")%>
	</script>
</body>
</html>
