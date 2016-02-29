<%@ page import="java.sql.*,com.marcomet.tools.*;import java.text.*;" %>
<%@ taglib uri="/WEB-INF/tld/iterationTagLib.tld" prefix="iterate" %>
<%@ include file="/includes/SessionChecker.jsp" %>
<jsp:useBean id="formatter" class="com.marcomet.tools.FormaterTool" scope="page" />
<jsp:useBean id="sl" class="com.marcomet.tools.SimpleLookups" scope="page" />
<jsp:useBean id="cB" class="com.marcomet.beans.SBPContactBean" scope="page" />
<%	
Connection conn = com.marcomet.jdbc.DBConnect.getConnection();
Statement st = conn.createStatement();
Statement st2 = conn.createStatement();
Statement st3 = conn.createStatement();
String siteName="";	
String invoiceChoice=((request.getParameter("showInvoices")!=null && request.getParameter("showInvoices").equals("1"))?" AND j.billed>0 ":"");
String loginId = ((session.getAttribute("contactId")==null)?"":(String)session.getAttribute("contactId")); 
String siteHostId = ((request.getParameter("siteHostId")==null)?"37":request.getParameter("siteHostId"));
String sitehostChoice = ((request.getParameter("sitehostChoiceId")==null || request.getParameter("sitehostChoiceId").equals(""))?" AND sh.sitehost_client_id="+siteHostId+" ":" AND sh.id="+request.getParameter("sitehostChoiceId") ); 

	String vendorId = ((session.getAttribute("vendorId")==null)?"":(String)session.getAttribute("vendorId")); 
	loginId = ((request.getParameter("userId")==null)?loginId:request.getParameter("userId"));
	cB.setContactId(loginId);
	String sortBy=((request.getParameter("sortBy")==null || request.getParameter("sortBy").equals(""))?"c.id":request.getParameter("sortBy"));
	String sortByStr=sortBy+", o.date_created desc";
%><html>
<head>
  <title>Order History Report: Sitehost Managers</title>
  <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
  <link rel="stylesheet" href="<%=(String)session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css">
<style>
	.minderheaderSelected {font-family: Arial; font-size: 8pt; font-weight: bolder; color: Black; background-color: #71b4a7; text-decoration: none; text-align: center; margin-top: 0px; margin-right: 0; margin-bottom: 0px; margin-left: 0; letter-spacing : 0px; border-right : 1px solid #3C6BB1; border-bottom-color : #3C6BB1; border-bottom-style : solid; border-bottom-width : 3px; cursor: url(pointer);}
	.minderheaderleftSelected {font-family: Arial; font-size: 8pt; font-weight: bolder; color: Black; background-color: #71b4a7; border: thin none #FFFFFF; text-decoration: none; text-align: left; margin-top: 0px; margin-right: 0; margin-bottom: 0px; margin-left: 0px; letter-spacing : 0px; border-right : 1px solid #3C6BB1; border-bottom-color : #3C6BB1; border-bottom-style : solid; border-bottom-width : 3px; cursor: url(pointer);}
	.minderheadercenterSelected {font-family: Arial; font-size: 8pt; font-weight: bolder; color: Black; background-color: #71b4a7; border: thin none #FFFFFF; text-decoration: none; text-align: center; margin-top: 0px; margin-right: 0; margin-bottom: 0px; margin-left: 0px; letter-spacing : 0px; border-right : 1px solid #3C6BB1; border-bottom-color : #3C6BB1; border-bottom-style : solid; border-bottom-width : 3px; cursor: url(pointer);}
	.minderheaderrightSelected {font-family: Arial; font-size: 8pt; font-weight: bolder; color: Black; background-color: #71b4a7; border: thin none Black; text-decoration: none; text-align: right; margin-top: 0px; margin-right: 0; margin-bottom: 0px; margin-left: 0px; letter-spacing : 0px; border-right : 1px solid #3C6BB1; border-bottom-color : #3C6BB1; border-bottom-style : solid; border-bottom-width : 3px; cursor: url(pointer);}
	.minderheaderSelectedSelected {font-family: Arial; font-size: 8pt; font-weight: bolder; color: Black; background-color: #71b4a7; text-decoration: none; text-align: center; margin-top: 0px; margin-right: 0; margin-bottom: 0px; margin-left: 0; letter-spacing : 0px; border-right : 1px solid #3C6BB1; border-bottom-color : #3C6BB1; border-bottom-style : solid; border-bottom-width : 3px; cursor: url(pointer);}
	.minderheaderleftSelectedSelected {font-family: Arial; font-size: 8pt; font-weight: bolder; color: Black; background-color: #71b4a7; border: thin none #FFFFFF; text-decoration: none; text-align: left; margin-top: 0px; margin-right: 0; margin-bottom: 0px; margin-left: 0px; letter-spacing : 0px; border-right : 1px solid #3C6BB1; border-bottom-color : #3C6BB1; border-bottom-style : solid; border-bottom-width : 3px; cursor: url(pointer);}
	.minderheadercenterSelectedSelected {font-family: Arial; font-size: 8pt; font-weight: bolder; color: Black; background-color: #71b4a7; border: thin none #FFFFFF; text-decoration: none; text-align: center; margin-top: 0px; margin-right: 0; margin-bottom: 0px; margin-left: 0px; letter-spacing : 0px; border-right : 1px solid #3C6BB1; border-bottom-color : #3C6BB1; border-bottom-style : solid; border-bottom-width : 3px; cursor: url(pointer);}
	.minderheaderrightSelectedSelected {font-family: Arial; font-size: 8pt; font-weight: bolder; color: Black; background-color: #71b4a7; border: thin none Black; text-decoration: none; text-align: right; margin-top: 0px; margin-right: 0; margin-bottom: 0px; margin-left: 0px; letter-spacing : 0px; border-right : 1px solid #3C6BB1; border-bottom-color : #3C6BB1; border-bottom-style : solid; border-bottom-width : 3px; cursor: url(pointer);}	
</style>
<script>
	var x=1;
	var oldClass='minderheaderleft';
	function sortSubmit(id){
		document.getElementById('loading').innerHTML="<div align='center'> S O R T I N G&nbsp;&nbsp;&nbsp;R E P O R T . . .<br><br><img src='/images/loading.gif'></div>";
		document.forms[0].sortBy.value=id;
		document.forms[0].submit();
	}
</script>
</head>
<script language="JavaScript" src="/javascripts/mainlib.js"></script>
<body >
<form method='post' action='orderHistory.jsp'>
<%String reportTitle=((request.getParameter("reportType").equals("2"))?"Order History Report by Product":"Order History Report by Date");
DecimalFormat df = new DecimalFormat("###,###,###");
%><div align='right' style="float:right;"><a href='/reports/sitehostmanager/orderHistoryFilters2.jsp' class='menuLINK'>&laquo;&nbsp;Return to Filters</a></div><div class="Title"><%=reportTitle%></div>
<div class="subtitle">Site: <%=request.getParameter("sitehostText")%></div><br />
<span id='loading'><div align='center'> L O A D I N G . . .<br><br><img src='/images/loading.gif'></div></span>
<span class='minderheaderleft' style="width:100px;position:absolute;">&nbsp;&nbsp;Buyer Company:</span>
<span class='lineitems'  style="width:200px;position:absolute;left:110px">&nbsp;&nbsp;<%=((request.getParameter("buyerCompanyText")==null || request.getParameter("buyerCompanyText").equals(""))?"ALL":request.getParameter("buyerCompanyText"))%><br></span>
<br />*Invoiced amount shown is the commissionable amount, exclusive of shipping or sales tax.<br />
<table border="0" cellpadding="1" cellspacing="0" width="100%"><%
//<!--------------------End Header------------------------------------------>

String companyId=((request.getParameter("companyId")==null)?"":request.getParameter("companyId"));
String reportType=((request.getParameter("reportType")==null)?"":request.getParameter("reportType"));
String sqlOrders = "";
String sqlRoot = "";
String rootProduct = "";
String siteHostT = session.getAttribute("siteHostRoot").toString();
String siteHost = siteHostT.substring(11,siteHostT.length());
double totalPrice = 0;
double rTotalPrice = 0;
double rTotalTotal = 0;
double totalBilled = 0;
double rTotalBilled = 0;
double sTotalBilled = 0;
double sTotalPrice = 0;
double sTotalTotal = 0;
double wssi=0;
double wssiTotal=0;
double sWssiTotal = 0;
double rWssiTotal = 0;
int x=0;
String alt="alt";
String msAct="onMouseOver=\"oldClass=this.className;this.className=oldClass+'Selected'\" onMouseOut=\"this.className=oldClass\" onClick=\"sortSubmit(this.id)\"";
String headerRow="<tr><td class='minderheadercenter' width='5%' "+msAct+" id='c.id'>Buyer ID #</td><td class='minderheadercenter' width='7%' "+msAct+" id='sitenumber'>Wyndham Site #</td><td class='minderheaderleft' width='17%' "+msAct+" id='company_name'>&nbsp;&nbsp;Company Name</td><td class=\"minderheadercenter\" width='8%' "+msAct+" id='city'>City</td><td class=\"minderheadercenter\" width='4%' "+msAct+" id='lo.state'>State</td><td class=\"minderheadercenter\" width='5%' "+msAct+" id='zip'>Zip</td><td class=\"minderheadercenter\" width='7%' "+msAct+" id='o.date_created'>Order Date</td><td class=\"minderheadercenter\" width='3%'  "+msAct+" id='j.id'>Job #</td><td class=\"minderheadercenter\" width='7%'  "+msAct+" id='j.product_code'>Product Code</td><td class=\"minderheaderleft\" width='14%' "+msAct+" id='prod.prod_name'>Product Name</td><td class=\"minderheaderright\" width='6%'>Quantity</td><td class=\"minderheaderright\" width='6%'>Price</td><td class=\"minderheaderright\" width='3%'>Invoiced&nbsp;*</td><td class=\"minderheaderright\" width='3%'>WSSI&nbsp;%</td><td class=\"minderheaderright\" width='3%'>WSSI&nbsp;Comm</td></tr>";

if (reportType.equals("2")){
  sqlRoot = "select distinct j.root_prod_code, proot.description from orders o, projects pr, jobs j, site_hosts sh, products prod, product_roots proot where j.project_id=pr.id and pr.order_id=o.id  and o.site_host_id=sh.id  and j.product_code=prod.prod_code  and j.root_prod_code=proot.root_prod_code  and o.date_created>='" + request.getParameter("dateFrom") + "'  and o.date_created<='" + request.getParameter("dateTo") + "' and (o.buyer_company_id = "+request.getParameter("buyerCompany")+" or "+request.getParameter("buyerCompany")+" = 0) and o.site_host_id = sh.id "+sitehostChoice+" order by j.root_prod_code";
} else {
  sqlRoot = "select distinct 'All' as root_prod_code from jobs j";
}
ResultSet root = st.executeQuery(sqlRoot);
if(root.next()){
  do{
    if (reportType.equals("2")){
      rootProduct = root.getString("j.root_prod_code");%><%
		if (x>0) {%><TR>
		<td class="minderheaderright" colspan=10><%=siteName%> Totals:</td>
		<td class="lineitemsright" ><%=df.format(sTotalTotal)%></td>
		<td class="lineitemsright" ><%=formatter.getCurrency(sTotalPrice)%></td>
		<td class="lineitemsright" ><%=formatter.getCurrency(sTotalBilled)%></td>
		<td class="lineitemsright" ><%=formatter.getCurrency(sWssiTotal)%></td>
		<td colspan=12 class='title'></TR><%
		sTotalTotal=0;
		sTotalPrice=0;
		sTotalBilled=0;
		sWssiTotal=0;
		}
        %><tr>
        <td class="label" colspan="7">Product: <%=rootProduct%>  <%=root.getString("proot.description")%></td>
        </tr><%
      	rTotalPrice = 0;
      	rTotalTotal = 0;
		rTotalBilled=0;
		rWssiTotal=0;
      sqlOrders = "select distinct (if(j.billed>(j.shipping_price+j.sales_tax),j.billed-j.shipping_price-j.sales_tax,0)) as billedAmt,prod.WSSI_commission_percent,c.WSSI_Commissionable_Exclude,sh.WSSI_commissionable,sh.site_name, lo.city,lu.value 'state',lo.zip, c.id,c.default_site_number sitenumber,co.company_name,j.root_prod_code, j.product_code, prod.prod_name, date_format(o.date_created,'%m/%d/%y') as order_date, o.buyer_contact_id, j.id, quantity, price from orders o, projects pr, jobs j left join products prod on j.product_id=prod.id, site_hosts sh,contacts c,companies co left join locations lo on (lo.contactid=c.id and lo.locationtypeid=1) left join lu_abreviated_states lu on lo.state=lu.id where j.project_id=pr.id and pr.order_id=o.id  and o.site_host_id=sh.id and j.product_code=prod.prod_code and o.date_created>='" + request.getParameter("dateFrom") + "'  and o.date_created<='" + request.getParameter("dateTo") + "' and (o.buyer_company_id = "+request.getParameter("buyerCompany")+" or "+request.getParameter("buyerCompany")+" = 0) and co.id=o.buyer_company_id and c.companyid=co.id and  o.site_host_id = sh.id  AND j.root_prod_code = '"+rootProduct+"' "+sitehostChoice+invoiceChoice+" order by site_name, "+sortByStr;
    }else{
      sqlOrders = "select distinct (if(j.billed>(j.shipping_price+j.sales_tax),j.billed-j.shipping_price-j.sales_tax,0)) as billedAmt,prod.WSSI_commission_percent,c.WSSI_Commissionable_Exclude,sh.WSSI_commissionable,sh.site_name, lo.city,lu.value 'state',lo.zip, c.id,c.default_site_number sitenumber,co.company_name,j.root_prod_code, j.product_code, prod.prod_name, o.date_created,date_format(o.date_created,'%m/%d/%y') as order_date, o.buyer_contact_id, j.id, quantity, price from orders o, projects pr, jobs j  left join products prod on j.product_id=prod.id, site_hosts sh,companies co,contacts c left join locations lo on (lo.contactid=c.id and lo.locationtypeid=1) left join lu_abreviated_states lu on lo.state=lu.id where j.project_id=pr.id and pr.order_id=o.id  and o.site_host_id=sh.id and j.product_code=prod.prod_code and o.date_created>='" + request.getParameter("dateFrom") + "'  and o.date_created<='" + request.getParameter("dateTo") + "' and (o.buyer_company_id = "+request.getParameter("buyerCompany")+" or "+request.getParameter("buyerCompany")+" = 0) and co.id=o.buyer_company_id and c.companyid=co.id and  o.site_host_id = sh.id "+sitehostChoice+invoiceChoice+" order by site_name,  "+sortByStr;
    }
    ResultSet orders = st2.executeQuery(sqlOrders);
    if(orders.next()){
      do{
		wssi=0;
		if ((orders.getString("c.WSSI_Commissionable_Exclude").equals("0")) && !(orders.getString("sh.WSSI_commissionable").equals("0")) ){
			wssi=orders.getDouble("prod.WSSI_commission_percent") * orders.getDouble("billedAmt");
		}

	if (!(siteName.equals(orders.getString("sh.site_name"))) ){
		if (x>0) {%><TR>
		<td class="minderheaderright" colspan=10><%=siteName%> Totals:</td>
		<td class="lineitemsright" ><%=df.format(sTotalTotal)%></td>
		<td class="lineitemsright" ><%=formatter.getCurrency(sTotalPrice)%></td>
		<td class="lineitemsright" ><%=formatter.getCurrency(sTotalBilled)%></td>
		<td class="minderheader" >&nbsp;</td>
		<td class="lineitemsright" ><%=formatter.getCurrency(sWssiTotal)%></td>
		<td colspan=12 class='title'></TR><%
		sTotalTotal=0;
		sTotalPrice=0;
		sTotalBilled=0;
		sWssiTotal=0;
		}
		%><tr><td><hr><br><br></td></tr><TR><td colspan=15 class='menuLINK' align='left'>BRAND SITE: <%=orders.getString("site_name")%> <%=((orders.getString("c.WSSI_Commissionable_Exclude").equals("0"))?"":" (Non-WSSI Commissionable)")%></td></TR><%=headerRow%><%
		siteName=orders.getString("sh.site_name");
		}
        totalPrice += orders.getDouble("price");
        totalBilled += orders.getDouble("billedAmt");
        wssiTotal += wssi;
        rTotalPrice += orders.getDouble("price");
        rTotalBilled += orders.getDouble("billedAmt");
        sTotalBilled += orders.getDouble("billedAmt");
        rTotalTotal += orders.getDouble("quantity");
        sWssiTotal += wssi;
        rWssiTotal += wssi;
        sTotalPrice += orders.getDouble("price");
        sTotalTotal += orders.getDouble("quantity");
        alt=((alt.equals(""))?"alt":"");
        %><tr>
        <td class="lineitemcenter<%=alt%>" ><%=orders.getString("o.buyer_contact_id")%></td>
        <td class="lineitemcenter<%=alt%>" ><%=((orders.getString("sitenumber")==null)?"-": orders.getString("sitenumber"))%></td>
        <td class="lineitemleft<%=alt%>" style='padding-left:5px'><%=orders.getString("company_name")%></td>
        <td class="lineitemleft<%=alt%>" style='padding-left:5px'><%=orders.getString("lo.city")%></td>
        <td class="lineitemleft<%=alt%>" style='padding-left:5px'><%=orders.getString("state")%></td>
        <td class="lineitemleft<%=alt%>" style='padding-left:5px'><%=orders.getString("lo.zip")%></td>

        <td class="lineitemcenter<%=alt%>" ><%=orders.getString("order_date")%></td>
        <td class="lineitemcenter<%=alt%>" ><a href="javascript:pop('/popups/JobDetailsPage.jsp?jobId=<%=orders.getString("j.id")%>','700','300')"><%=orders.getString("j.id")%></a></td>
        <td class="lineitemcenter<%=alt%>" ><%=orders.getString("j.product_code")%></td>
        <td class="lineitemcenter<%=alt%>" ><%=orders.getString("prod.prod_name")%></td>
        <td class="lineitemright<%=alt%>" ><%=df.format(orders.getDouble("quantity"))%></td>
        <td class="lineitemright<%=alt%>" ><%=formatter.getCurrency(orders.getDouble("price"))%></td>
        <td class="lineitemright<%=alt%>" ><%=formatter.getCurrency(orders.getDouble("billedAmt"))%></td>
        <td class="lineitemright<%=alt%>" ><script>document.write(formatPercent('<%=orders.getDouble("prod.WSSI_commission_percent")%>'))</script></td>
        <td class="lineitemright<%=alt%>" ><%=(((!(orders.getString("c.WSSI_Commissionable_Exclude").equals("0"))) || orders.getString("sh.WSSI_commissionable").equals("0") || orders.getString("billedAmt").equals("0"))?"NA":formatter.getCurrency(wssi))%></td>
        </tr><%
	x++;
      }while(orders.next());
    }
    if (reportType.equals("2")){%><tr>		
        <td class="minderheaderright" colspan=10><%=rootProduct%> Totals:</td>
        <td class="lineitemsright" ><%=df.format(rTotalTotal)%></td>
        <td class="lineitemsright" ><%=formatter.getCurrency(rTotalPrice)%></td>
        <td class="lineitemsright" ><%=formatter.getCurrency(rTotalBilled)%></td>
        <td class="minderheader" >&nbsp;</td>
        <td class="lineitemsright" ><%=formatter.getCurrency(rWssiTotal)%></td>
      </tr>
      <tr><td colspan=7>&nbsp;</td></tr><%
    }
  }while(root.next());
      %>	<TR>
		<td class="minderheaderright" colspan=10><%=siteName%> Totals:</td>
		        <td class="lineitemsright" ><%=df.format(sTotalTotal)%></td>
      <td class="lineitemsright" ><%=formatter.getCurrency(sTotalPrice)%></td>
      <td class="lineitemsright" ><%=formatter.getCurrency(sTotalBilled)%></td>
      <td class="minderheader" >&nbsp;</td>
      <td class="lineitemsright" ><%=formatter.getCurrency(sWssiTotal)%></td>
		</TR> <tr>				
      <td class="minderheaderright" colspan=11>Report Totals:</td>
      <td class="lineitemsright" ><%=formatter.getCurrency(totalPrice)%></td>
      <td class="lineitemsright" ><%=formatter.getCurrency(totalBilled)%></td>
      <td class="minderheader" >&nbsp;</td>
      <td class="lineitemsright" ><%=formatter.getCurrency(wssiTotal)%></td>
    </tr><%
}else{
 %>"No Orders Found"<%
}
  %></table>
<input type='hidden' name='reportType' value='<%=reportType%>'>
<input type='hidden' name='companyId' value='<%=companyId%>'>
<input type='hidden' name='dateTo' value='<%=request.getParameter("dateTo")%>'>
<input type='hidden' name='loginId' value='<%=loginId%>'>
<input type='hidden' name='dateFrom' value='<%=request.getParameter("dateFrom")%>'>
<input type='hidden' name='siteHost' value='<%=siteHost%>'>
<input type='hidden' name='sortBy' value='<%=sortBy%>'>
<input type='hidden' name='vendorId' value='<%=vendorId%>'>
<input type="hidden" name="buyerCompanyText" value="">
<input type="hidden" name="buyerCompany" value="<%=request.getParameter("buyerCompany")%>">
</form>
<script>
	document.getElementById('loading').innerHTML="<table border=0><tr><td colspan=2 class='lineitemsright'  style=\"width:70px;\">&nbsp;&nbsp;<%=((invoiceChoice.equals(""))?"Show Billed and Unbilled":"Show Billed Only")%></td></tr><tr><td class='minderheaderleft' style=\"width:70px;\">&nbsp;&nbsp;Date From:&nbsp;</td><td class='lineitemsright'  style=\"width:70px;\"><%=((request.getParameter("dateFrom").equals("0000-00-00"))?"All":formatter.formatMysqlDate(request.getParameter("dateFrom")))%>&nbsp;</td></tr><tr><td class='minderheaderleft' style=\"width:70px;\">&nbsp;&nbsp;Date To:&nbsp;</td><td class='lineitemsright'  style=\"width:70px;\"> <%=((request.getParameter("dateTo").equals("2029-12-31"))?"All":formatter.formatMysqlDate(request.getParameter("dateTo")))%>&nbsp;</td></tr></table>";
	document.getElementById('<%=sortBy%>').className=document.getElementById('<%=sortBy%>').className+'Selected';
</script>
</body>
</html><%st.close();
st2.close();
st3.close();
conn.close();%>