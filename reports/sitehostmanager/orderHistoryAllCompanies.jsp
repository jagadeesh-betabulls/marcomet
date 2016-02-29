<%@ page import="java.sql.*,com.marcomet.tools.*;import java.text.*;" %>
<%@ taglib uri="/WEB-INF/tld/iterationTagLib.tld" prefix="iterate" %>
<%@ include file="/includes/SessionChecker.jsp" %>
<jsp:useBean id="formatter" class="com.marcomet.tools.FormaterTool" scope="page" />
<jsp:useBean id="sl" class="com.marcomet.tools.SimpleLookups" scope="page" />
<jsp:useBean id="cB" class="com.marcomet.beans.SBPContactBean" scope="page" />
<%	Connection conn = com.marcomet.jdbc.DBConnect.getConnection();
Statement st = conn.createStatement();	
Statement st2 = conn.createStatement();

String loginId = ((session.getAttribute("contactId")==null)?"":(String)session.getAttribute("contactId")); 
String vendorId = ((session.getAttribute("vendorId")==null)?"":(String)session.getAttribute("vendorId")); 
	loginId = ((request.getParameter("userId")==null)?loginId:request.getParameter("userId"));
	cB.setContactId(loginId);
	String sortBy=((request.getParameter("sortBy")==null || request.getParameter("sortBy").equals(""))?"c.id":request.getParameter("sortBy"));
	String sortByStr=sortBy+", o.date_created desc";
%><html>
<head>
  <title>Order History Report</title><div align='right' style="float:right;"><a href='/reports/sitehosts/orderHistoryFilters2.jsp' class='menuLINK'>&laquo;&nbsp;Return to Filters</a></div>
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
	var oldClass='minderheaderleft';
	function sortSubmit(id){
		document.getElementById('loading').innerHTML="<div align='center'> S O R T I N G&nbsp;&nbsp;&nbsp;R E P O R T . . .<br><br><img src='/images/loading.gif'></div>";
		document.forms[0].sortBy.value=id;
		document.forms[0].submit();
	}
</script>
</head>
<script language="JavaScript" src="/javascripts/mainlib.js"></script>
<body background="<%=(String)session.getAttribute("siteHostRoot")%>/images/back3.jpg">
<form method='post' action='/reports/sitehosts/orderHistoryAllCompanies.jsp'>
<%String reportTitle=((request.getParameter("reportType").equals("2"))?"Order History Report by Product":"Order History Report by Date");
DecimalFormat df = new DecimalFormat("###,###,###");
%><div class="Title"><%=reportTitle%></div>
<div class="subtitle">Site: <%=request.getParameter("siteHost")%></div><br />
<span id='loading'><div align='center'> L O A D I N G . . .<br><br><img src='/images/loading.gif'></div></span><%
//Select all customers registered on a given site (later use the 'brand' field')
%><br /><br /><%
//<!--------------------End Header------------------------------------------>
String companyId=((request.getParameter("companyId")==null)?"":request.getParameter("companyId"));
String reportType=((request.getParameter("reportType")==null)?"":request.getParameter("reportType"));
String sqlOrders = "";
String sqlRoot = "";
String rootProduct = "";
String siteHostT = session.getAttribute("siteHostRoot").toString();
String siteHost = siteHostT.substring(11,siteHostT.length());
double totalPrice = 0;
double customerPrice = 0;
double rTotalPrice = 0;
double rTotalTotal = 0;
double customerTotal = 0;
double rCustomerTotalPrice=0;
int orderFlag=1;
String alt="alt";
String lastContactId="";
String msAct="onMouseOver=\"oldClass=this.className;this.className=oldClass+'Selected'\" onMouseOut=\"this.className=oldClass\" onClick=\"sortSubmit(this.id)\"";
String headerRow="<tr><td class='minderheadercenter' width='5%' "+msAct+" id='c.id'>Buyer ID #</td><td class='minderheadercenter' width='7%' "+msAct+" id='sitenumber'>Wyndham Site #</td><td class='minderheaderleft' width='17%' "+msAct+" id='company_name'>&nbsp;&nbsp;Company Name</td><td class=\"minderheadercenter\" width='8%' "+msAct+" id='city'>City</td><td class=\"minderheadercenter\" width='4%' "+msAct+" id='lo.state'>State</td><td class=\"minderheadercenter\" width='5%' "+msAct+" id='zip'>Zip</td><td class=\"minderheadercenter\" width='8%' "+msAct+" id='o.date_created'>Order Date</td><td class=\"minderheadercenter\" width='8%'  "+msAct+" id='j.id'>Job #</td><td class=\"minderheadercenter\" width='8%'  "+msAct+" id='j.product_code'>Product Code</td><td class=\"minderheaderleft\" width='16%' "+msAct+" id='prod.prod_name'>Product Name</td><td class=\"minderheaderright\" width='7%'>Quantity</td><td class=\"minderheaderright\" width='7%'>Price</td></tr>";

sqlOrders = "select distinct lo.city,lu.value 'state',lo.zip, co.company_name 'company_name', c.lastname, c.firstname,c.id contactid,c.default_site_number sitenumber,j.root_prod_code, j.product_code, prod.prod_name, o.date_created, date_format(o.date_created,'%m/%d/%y') as order_date, j.id, quantity, price, shipping_price, sales_tax, billable from companies co,contact_roles l,site_hosts sh,contacts c left join locations lo on (lo.contactid=c.id and lo.locationtypeid=1) left join lu_abreviated_states lu on lo.state=lu.id left join orders o on (o.buyer_contact_id=c.id and o.date_created>='" + request.getParameter("dateFrom") + "' and o.date_created<='" + request.getParameter("dateTo") + "'  and o.site_host_id=sh.id ) left join projects pr on pr.order_id=o.id left join jobs j on j.project_id=pr.id left join products prod on j.product_id=prod.id where l.contact_id=c.id and l.site_host_id=sh.id and sh.site_host_name = '"+siteHost+"'  and c.companyid=co.id order by "+sortByStr;

ResultSet orders = st.executeQuery(sqlOrders);

int lastId=0;
int i=0;
    if(orders.next()){
      do{
		if(i==0){
			%><table border="0" cellpadding="1" cellspacing="0" width="100%"><%=headerRow%><%
		}
		i++;	
		if (orders.getString("j.id")!=null){
        	totalPrice += orders.getDouble("price");
        	customerPrice += orders.getDouble("price");
        	customerTotal += orders.getDouble("quantity");
        	rTotalPrice += orders.getDouble("price");
			rCustomerTotalPrice += orders.getDouble("price");
        	rTotalTotal += orders.getDouble("quantity");
        %><tr>
        <td class="lineitemcenter<%=alt%>" ><%=orders.getString("contactid")%></td>
        <td class="lineitemcenter<%=alt%>" ><%=((orders.getString("sitenumber")==null)?"-": orders.getString("sitenumber"))%></td>
        <td class="lineitemleft<%=alt%>" style='padding-left:5px'><%=orders.getString("company_name")%></td>
        <td class="lineitemleft<%=alt%>" style='padding-left:5px'><%=orders.getString("lo.city")%></td>
        <td class="lineitemleft<%=alt%>" style='padding-left:5px'><%=orders.getString("state")%></td>
        <td class="lineitemleft<%=alt%>" style='padding-left:5px'><%=orders.getString("lo.zip")%></td>
        <td class="lineitemcenter<%=alt%>" ><%=orders.getString("order_date")%></td>
        <td class="lineitemcenter<%=alt%>" ><a href="javascript:pop('/popups/JobDetailsPage.jsp?jobId=<%=orders.getString("j.id")%>','700','300')"><%=orders.getString("j.id")%></a></td>
        <td class="lineitemcenter<%=alt%>" ><%=((orders.getString("j.product_code")==null)?"":orders.getString("j.product_code"))%></td>
        <td class="lineitemleft<%=alt%>" style='padding-left:5px'><%=((orders.getString("prod.prod_name")==null)?"":orders.getString("prod.prod_name"))%></td>
        <td class="lineitemright<%=alt%>" ><%=((orders.getString("quantity")==null)?"":df.format(orders.getDouble("quantity")))%></td>
        <td class="lineitemright<%=alt%>" ><%=((orders.getString("price")==null)?"":formatter.getCurrency(orders.getDouble("price")))%></td>
        </tr><%
	}else{
		%><tr>
        <td class="lineitemcenter<%=alt%>" ><%=orders.getString("contactid")%></td>
        <td class="lineitemcenter<%=alt%>" ><%=((orders.getString("sitenumber")==null)?"-": orders.getString("sitenumber"))%></td>
        <td class="lineitemleft<%=alt%>"style='padding-left:5px'><%=orders.getString("company_name")%></td>
        <td class="lineitemleft<%=alt%>" style='padding-left:5px'><%=orders.getString("lo.city")%></td>
        <td class="lineitemleft<%=alt%>" style='padding-left:5px'><%=orders.getString("state")%></td>
        <td class="lineitemleft<%=alt%>" style='padding-left:5px'><%=orders.getString("lo.zip")%></td>
        <td class="lineitemcenter<%=alt%>" > - </td>
        <td class="lineitemcenter<%=alt%>" > NO JOBS </td>
        <td class="lineitemcenter<%=alt%>" > - </td>
        <td class="lineitemcenter<%=alt%>" > - </td>
        <td class="lineitemright<%=alt%>" >0</td>
        <td class="lineitemright<%=alt%>" >0</td>
        </tr><%
	}
		alt=((alt.equals(""))?"alt":"");
      }while(orders.next());
      %><tr>				
      <td class="minderheaderright" colspan=11><br />Report Totals:</td>
      <td class="lineitemsright"  valign='bottom'><strong><%=formatter.getCurrency(totalPrice)%></strong></td>
    </tr><%
}else{
 %>No Orders Found<%
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
	
</form>
<script>
	document.getElementById('loading').innerHTML="<table border=0><tr><td class='minderheaderleft' style=\"width:70px;\">&nbsp;&nbsp;Date From:&nbsp;</td><td class='lineitemsright'  style=\"width:70px;\"><%=((request.getParameter("dateFrom").equals("0000-00-00"))?"All":formatter.formatMysqlDate(request.getParameter("dateFrom")))%>&nbsp;</td></tr><td class='minderheaderleft' style=\"width:70px;\">&nbsp;&nbsp;Date To:&nbsp;</td><td class='lineitemsright'  style=\"width:70px;\"> <%=((request.getParameter("dateTo").equals("2029-12-31"))?"All":formatter.formatMysqlDate(request.getParameter("dateTo")))%>&nbsp;</td></tr></table>";
	document.getElementById('<%=sortBy%>').className=document.getElementById('<%=sortBy%>').className+'Selected';
</script>
</body>
</html><%st2.close();st.close();conn.close();%>