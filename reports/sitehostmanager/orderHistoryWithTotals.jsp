<%@ page import="java.sql.*,com.marcomet.tools.*;import java.text.*;" %>
<%@ taglib uri="/WEB-INF/tld/iterationTagLib.tld" prefix="iterate" %>
<%@ include file="/includes/SessionChecker.jsp" %>
<jsp:useBean id="formatter" class="com.marcomet.tools.FormaterTool" scope="page" />
<jsp:useBean id="sl" class="com.marcomet.tools.SimpleLookups" scope="page" />
<jsp:useBean id="cB" class="com.marcomet.beans.SBPContactBean" scope="page" />
<%	Connection conn = com.marcomet.jdbc.DBConnect.getConnection();
Statement st = conn.createStatement();
Statement st2 = conn.createStatement();
String siteHostId = ((request.getParameter("siteHostId")==null)?"37":request.getParameter("siteHostId"));
String invoiceChoice=((request.getParameter("showInvoices")!=null && request.getParameter("showInvoices").equals("1"))?" AND j.billed>0 ":"");
String sitehostChoice = ((request.getParameter("sitehostChoiceId")==null || request.getParameter("sitehostChoiceId").equals(""))?" AND sh.sitehost_client_id="+siteHostId+" ":" AND sh.id="+request.getParameter("sitehostChoiceId") ); 
String loginId = (session.getAttribute("contactId")==null)?"":(String)session.getAttribute("contactId"); 
loginId = ((request.getParameter("userId")==null)?loginId:request.getParameter("userId"));
cB.setContactId(loginId);
%><html>
<head>
  <title>Order History Report</title>
  <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
  <link rel="stylesheet" href="<%=(String)session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css">
</head>
<script language="JavaScript" src="/javascripts/mainlib.js"></script>
<body background="<%=(String)session.getAttribute("siteHostRoot")%>/images/back3.jpg">
<%String reportTitle=((request.getParameter("reportType").equals("2"))?"Order History Report by Product":"Order History Report by Date");
DecimalFormat df = new DecimalFormat("###,###,###");
%>
<!----------------------Report Header------------------------------->
<div class="Title"><%=reportTitle%></div><div align='right' style="float:right;"><a href='/reports/sitehostmanager/orderHistoryFilters2.jsp' class='menuLINK'>&laquo;&nbsp;Return to Filters</a></div>
<div class="subtitle">Site: <%=request.getParameter("siteHost")%></div><br />
<div class="subtitle"><%=((invoiceChoice.equals(""))?"Show Billed and Unbilled":"Show Billed Only")%></div>
<span class='minderheaderleft' style="width:70px;position:absolute;">&nbsp;&nbsp;Date From:&nbsp;</span><span class='lineitemsright'  style="width:70px;position:absolute;left:80px"> <%=((request.getParameter("dateFrom").equals("0000-00-00"))?"All":formatter.formatMysqlDate(request.getParameter("dateFrom")))%>&nbsp;</span><br />
<span class='minderheaderleft' style="width:70px;position:absolute;">&nbsp;&nbsp;Date To:&nbsp;</span><span class='lineitemsright'  style="width:70px;position:absolute;left:80px"> <%=((request.getParameter("dateTo").equals("2029-12-31"))?"All":formatter.formatMysqlDate(request.getParameter("dateTo")))%>&nbsp;</span><%
//Select all customers registered on a given site (later use the 'brand' field')
//String sql="select c.id customer_id, co.company_name company_name, l.city customer_city, lu.text customer_state";
%><br />*Invoiced amount shown is the commissionable amount, exclusive of shipping or sales tax.<br /><%
//<!--------------------End Header------------------------------------------>
String companyId=request.getParameter("companyId");
String reportType=request.getParameter("reportType");
String sqlOrders = "";
String sqlRoot = "";
String rootProduct = "";
String siteHostT = session.getAttribute("siteHostRoot").toString();
String siteHost = siteHostT.substring(11,siteHostT.length());
double totalPrice = 0;
double totalBilled = 0;
double cTotalBilled=0;
double customerPrice = 0;
double rTotalPrice = 0;
double rTotalBilled = 0;
double rTotalTotal = 0;
double sTotalPrice = 0;
double customerTotal = 0;
double rCustomerTotal = 0;
double rCustomerTotalPrice=0;
double wssi=0;
double wssiTotal=0;
double sWssiTotal = 0;
double rWssiTotal = 0;
double cWssiTotal = 0;
String alt="alt";
String siteName="";
String headerRow="<tr><td class=\"minderheadercenter\" width='12%'>Order Date</td><td class=\"minderheadercenter\" width='12%'>Job #</td><td class=\"minderheadercenter\" width='12%'>Product Code</td><td class=\"minderheadercenter\" width='35%'>Product Name</td><td class=\"minderheadercenter\" width='12%'>Quantity</td><td class=\"minderheadercenter\" width='10%'>Price</td><td class=\"minderheaderright\" width='3%'>Invoiced&nbsp;*</td><td class=\"minderheaderright\" width='3%'>WSSI&nbsp;%</td><td class=\"minderheaderright\" width='3%'>WSSI&nbsp;Comm</td></tr>";

if (reportType.equals("2")){
  sqlRoot = "select distinct j.root_prod_code, proot.description from orders o, projects pr, jobs j, site_hosts sh, products prod, product_roots proot where j.project_id=pr.id and pr.order_id=o.id  and o.site_host_id=sh.id  and j.product_code=prod.prod_code  and j.root_prod_code=proot.root_prod_code  and o.date_created>='" + request.getParameter("dateFrom") + "'  and o.date_created<='" + request.getParameter("dateTo") + "' and (o.buyer_company_id = "+request.getParameter("buyerCompany")+" or "+request.getParameter("buyerCompany")+" = 0) and o.site_host_id = sh.id "+sitehostChoice+" order by j.root_prod_code";
} else {
  sqlRoot = "select distinct 'All' as root_prod_code from jobs j";
}
ResultSet root = st.executeQuery(sqlRoot);
if(root.next()){
  do{
    if (reportType.equals("2")){
      rootProduct = root.getString("j.root_prod_code");%>
        <tr>
        <td class="label" colspan="7">Product: <%=rootProduct%>  <%=root.getString("proot.description")%></td>
        </tr><%
      rTotalPrice = 0;
      rTotalTotal = 0;
	rWssiTotal=0;
      sqlOrders = "select  (if(j.billed>(j.shipping_price+j.sales_tax),j.billed-j.shipping_price-j.sales_tax,0)) as billedAmt,prod.WSSI_commission_percent,c.WSSI_Commissionable_Exclude,sh.WSSI_commissionable,sh.site_name,co.company_name,c.id contactid,c.default_site_number sitenumber,j.root_prod_code, j.product_code, prod.prod_name, o.date_created, date_format(o.date_created,'%m/%d/%y') as order_date, j.id, quantity, price from orders o, projects pr, site_hosts sh ,companies co,contacts c, jobs j  left join products prod on j.product_id=prod.id where j.project_id=pr.id and pr.order_id=o.id  and o.site_host_id=sh.id and j.product_code=prod.prod_code and o.date_created>='" + request.getParameter("dateFrom") + "'  and o.date_created<='" + request.getParameter("dateTo") + "' and (o.buyer_company_id = "+request.getParameter("buyerCompany")+" or "+request.getParameter("buyerCompany")+" = 0) and  o.site_host_id = sh.id and j.root_prod_code = '"+rootProduct+"' and o.buyer_company_id=co.id and c.companyid=co.id "+sitehostChoice+invoiceChoice+" order by sh.id, c.id,  o.date_created desc";
    }else{
      sqlOrders = "select  (if(j.billed>(j.shipping_price+j.sales_tax),j.billed-j.shipping_price-j.sales_tax,0)) as billedAmt,prod.WSSI_commission_percent,c.WSSI_Commissionable_Exclude,sh.WSSI_commissionable,sh.site_name,co.company_name,c.id contactid,c.default_site_number sitenumber,j.root_prod_code, j.product_code, prod.prod_name, o.date_created, date_format(o.date_created,'%m/%d/%y') as order_date, j.id, quantity, price from orders o, projects pr, site_hosts sh,companies co,contacts c, jobs j left join products prod on j.product_id=prod.id where j.project_id=pr.id and pr.order_id=o.id  and o.site_host_id=sh.id and j.product_code=prod.prod_code and o.date_created>='" + request.getParameter("dateFrom") + "'  and o.date_created<='" + request.getParameter("dateTo") + "' and (o.buyer_company_id = "+request.getParameter("buyerCompany")+" or "+request.getParameter("buyerCompany")+" = 0) and  o.site_host_id = sh.id and o.buyer_company_id=co.id and c.companyid=co.id "+sitehostChoice+invoiceChoice+" order by sh.id, c.id, o.date_created desc";
    }
    ResultSet orders = st2.executeQuery(sqlOrders);
 siteName="";
int lastId=0;
int i=0;
    if(orders.next()){
      do{
		wssi=0;
		if ((orders.getString("c.WSSI_Commissionable_Exclude").equals("0")) && !(orders.getString("sh.WSSI_commissionable").equals("0")) ){
			wssi=orders.getDouble("prod.WSSI_commission_percent") * orders.getDouble("billedAmt");
		}
if (!(lastId==orders.getInt("contactid"))){
					alt="";
					if (i>0){
						if (reportType.equals("2")){%><tr>				
					        <td class="lineitemsright" colspan=4><strong><%=orders.getString("sh.site_name")%>: <%=rootProduct%> Totals for Property Site #<%=orders.getString("contactid")%>:</strong></td><td class="lineitemsright" ><strong><%=df.format(customerTotal)%></strong></td><td class="lineitemsright" ><strong><%=formatter.getCurrency(rCustomerTotalPrice)%></strong></td><td class="lineitemsright" ><strong><%=formatter.getCurrency(cWssiTotal)%></strong></td>
					      </tr>
					      <tr><td colspan=7>&nbsp;</td></tr></table><%
							rCustomerTotalPrice=0;
							customerTotal=0;
							rCustomerTotal=0;	
							cTotalBilled=0;
							cWssiTotal=0;
					    }else{%><tr><td></td><td></td><td></td><td class="lineitemsright" colspan=2><strong>Total for Customer #<%=lastId%>:</strong></td><td class="lineitemsright" ><strong><%=formatter.getCurrency(customerPrice)%></strong></td><td class="lineitemsright" ><strong><%=formatter.getCurrency(cTotalBilled)%></strong></td><td class="minderheader" >&nbsp;</td><td class="lineitemsright" ><strong><%=formatter.getCurrency(cWssiTotal)%></strong></td></tr></table><%
						customerPrice=0;
						customerTotal=0;
						cTotalBilled=0;
						cWssiTotal=0;
						}
					}
					lastId=orders.getInt("contactid");
					i++;
				%><br /><table border=0><%if (reportType.equals("1") && !(siteName.equals(orders.getString("sh.site_name"))) ){%><tr><td colspan=2><hr><br><br></td></tr><TR><td  colspan=2 class='menuLINK' align='left'>SITE: <%=orders.getString("sh.site_name")%></td></TR><%siteName=orders.getString("sh.site_name");}%><tr><td class='minderheaderleft' width=20%>&nbsp;&nbsp;Buyer ID # / Site # / Company:&nbsp;</td><td width=80% class='lineitems'>&nbsp;&nbsp;<em><%=orders.getString("contactid")%> / <%=orders.getString("sitenumber")%> / <%=orders.getString("company_name")%></em></td>
						</tr></table>
		<table border="0" cellpadding="1" cellspacing="0" width="100%"><%=headerRow%><%	
				}
        totalPrice += orders.getDouble("price");
		sTotalPrice+=orders.getDouble("price");
        customerPrice += orders.getDouble("price");
        customerTotal += orders.getDouble("quantity");
		cTotalBilled+=orders.getDouble("billedAmt");
		totalBilled+=orders.getDouble("billedAmt");
		cWssiTotal +=wssi;
        rTotalPrice += orders.getDouble("price");
		rCustomerTotalPrice += orders.getDouble("price");
        rTotalTotal += orders.getDouble("quantity");
		rWssiTotal += wssi;
		wssiTotal +=wssi;
        alt=((alt.equals(""))?"alt":"");
        %><tr>
        <td class="lineitemcenter<%=alt%>" ><%=orders.getString("order_date")%></td>
        <td class="lineitemcenter<%=alt%>" ><a href="javascript:pop('/popups/JobDetailsPage.jsp?jobId=<%=orders.getString("j.id")%>','700','300')"><%=orders.getString("j.id")%></a></td>
        <td class="lineitemcenter<%=alt%>" ><%=orders.getString("j.product_code")%></td>
        <td class="lineitemcenter<%=alt%>" ><%=orders.getString("prod.prod_name")%></td>
        <td class="lineitemright<%=alt%>" ><%=df.format(orders.getDouble("quantity"))%></td>
        <td class="lineitemright<%=alt%>" ><%=formatter.getCurrency(orders.getDouble("price"))%></td>
        <td class="lineitemright<%=alt%>" ><%=formatter.getCurrency(orders.getDouble("billedAmt"))%></td>
        <td class="lineitemright<%=alt%>" ><script>document.write(formatPercent('<%=orders.getDouble("prod.WSSI_commission_percent")%>'))</script></td>
        <td class="lineitemright<%=alt%>" ><%=formatter.getCurrency(wssi)%></td>
        </tr><%
      }while(orders.next());
    }
		if (reportType.equals("2")){%><tr>				
	        <td class="lineitemsright" colspan=4><strong><%=rootProduct%> Totals for Customer #<%=orders.getString("contactid")%>:</strong></td><td class="lineitemsright" ><strong><%=formatter.getCurrency(customerPrice)%></strong></td><td class="lineitemsright" ><strong><%=formatter.getCurrency(cTotalBilled)%></strong></td><td class="minderheader" >&nbsp;</td><td class="lineitemsright" ><strong><%=formatter.getCurrency(cWssiTotal)%></strong></td>
	      </tr>
	      <tr><td colspan=7>&nbsp;</td></tr><%
			rCustomerTotalPrice=0;
			rCustomerTotal=0;
			rTotalTotal=0;
			cTotalBilled=0;
			rWssiTotal=0;
			customerTotal=0;
			cWssiTotal=0;
	    }else{%><tr><td class="lineitemsright" colspan=5><strong>Total for Customer #<%=orders.getString("contactid")%>:</strong></td><td class="lineitemsright" ><strong><%=formatter.getCurrency(customerPrice)%></strong></td><td class="lineitemsright" ><strong><%=formatter.getCurrency(cTotalBilled)%></strong></td><td class="minderheader" >&nbsp;</td><td class="lineitemsright" ><strong><%=formatter.getCurrency(cWssiTotal)%></strong></td></tr><%
		customerPrice=0;
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
      %><tr>				
      <td class="minderheaderright" colspan=5><br />Report Totals:</td<name />
    <td class="lineitemsright" ><%=formatter.getCurrency(totalPrice)%></td>
    <td class="lineitemsright" ><%=formatter.getCurrency(totalBilled)%></td>
    <td class="minderheader" >&nbsp;</td>
    <td class="lineitemsright" ><%=formatter.getCurrency(wssiTotal)%></td>
    </tr><%
}else{
 %>"No Orders Found"<%
}
  %></table>
</body>
</html><%st2.close();st.close();conn.close();%>