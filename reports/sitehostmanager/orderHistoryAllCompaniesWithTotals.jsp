<%@ page import="java.sql.*,com.marcomet.tools.*;import java.text.*;" %>
<%@ taglib uri="/WEB-INF/tld/iterationTagLib.tld" prefix="iterate" %>
<%@ include file="/includes/SessionChecker.jsp" %>
<jsp:useBean id="formatter" class="com.marcomet.tools.FormaterTool" scope="page" />
<jsp:useBean id="sl" class="com.marcomet.tools.SimpleLookups" scope="page" />
<jsp:useBean id="cB" class="com.marcomet.beans.SBPContactBean" scope="page" />
<%	Connection conn = com.marcomet.jdbc.DBConnect.getConnection();
Statement st = conn.createStatement();	

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
%><div class="Title"><%=reportTitle%></div><div align='right' style="float:right;"><a href='/reports/sitehosts/orderHistoryFilters2.jsp' class='menuLINK'>&laquo;&nbsp;Return to Filters</a></div>
<div class="subtitle">Site: <%=request.getParameter("siteHost")%></div><br />
<span id='loading'><div align='center'> L O A D I N G . . .<br><br><img src='/images/loading.gif'></div></span><%
//Select all customers registered on a given site (later use the 'brand' field')
%><br /><br /><%
//<!--------------------End Header------------------------------------------>
String companyId=request.getParameter("companyId");
String reportType=request.getParameter("reportType");
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
String headerRow="<tr><td class=\"minderheadercenter\" width='12%'>Order Date</td><td class=\"minderheadercenter\" width='12%'>Job #</td><td class=\"minderheadercenter\" width='12%'>Product Code</td><td class=\"minderheaderleft\" width='40%'>Product Name</td><td class=\"minderheadercenter\" width='12%'>Quantity</td><td class=\"minderheadercenter\" width='12%'>Price</td></tr>";

sqlOrders = "select if(c.default_site_number is null or c.default_site_number=0,co.company_name,concat('Site:',c.default_site_number,(if(co.company_name=c.default_site_number,'',concat(' - ',co.company_name))))) 'company_name'  ,c.id contactid,c.default_site_number sitenumber,j.root_prod_code, j.product_code, prod.prod_name, o.date_created, date_format(o.date_created,'%m/%d/%y') as order_date, j.id, quantity, price  from contacts c,contact_roles l,site_hosts sh,companies co left join orders o on (o.buyer_company_id=co.id and o.date_created>='" + request.getParameter("dateFrom") + "' and o.date_created<='" + request.getParameter("dateTo") + "'  and o.site_host_id=sh.id ) left join projects pr on pr.order_id=o.id left join jobs j on j.project_id=pr.id  left join products prod on j.product_id=prod.id where l.contact_id=c.id and l.site_host_id=sh.id and sh.site_host_name = '"+siteHost+"'  and c.companyid=co.id order by c.id, o.date_created desc";

ResultSet orders = st.executeQuery(sqlOrders);

int lastId=0;
int i=0;
    if(orders.next()){
      do{
		if (!(lastId==orders.getInt("contactid"))){
			alt="";
			lastId=orders.getInt("contactid");
			if (i>0){
				if (orderFlag==1){
				%><tr><td></td><td></td><td></td><td class="lineitemsright" colspan=2><strong>Total for Customer #<%=lastContactId%>:</strong></td><td class="lineitemsright" ><strong><%=formatter.getCurrency(customerPrice)%></strong></td></tr></table><%
					customerPrice=0;
			}else{
				%>No Orders for this Customer<br /><br /><%
			}
			}
			i++;
			%><br /><table border=0><tr><td class='minderheaderleft' >&nbsp;&nbsp;Buyer ID # / Site # / Company:&nbsp;</td><td class='lineitems'>&nbsp;&nbsp;<em><%=orders.getString("contactid")%> / <%=orders.getString("sitenumber")%> / <%=orders.getString("company_name")%></em></td>
						</tr></table><%
			if (orders.getString("j.id")!=null){
				%><table border="0" cellpadding="1" cellspacing="0" width="100%"><%=headerRow%><%	
			}
		}
		if (orders.getString("j.id")!=null){
        	totalPrice += orders.getDouble("price");
        	customerPrice += orders.getDouble("price");
        	customerTotal += orders.getDouble("quantity");
        	rTotalPrice += orders.getDouble("price");
			rCustomerTotalPrice += orders.getDouble("price");
        	rTotalTotal += orders.getDouble("quantity");
        	alt=((alt.equals(""))?"alt":"");
        	%><tr>
        <td class="lineitemcenter<%=alt%>" ><%=orders.getString("order_date")%></td>
        <td class="lineitemcenter<%=alt%>" ><a href="javascript:pop('/popups/JobDetailsPage.jsp?jobId=<%=orders.getString("j.id")%>','700','300')"><%=orders.getString("j.id")%></a></td>
        <td class="lineitemcenter<%=alt%>" ><%=orders.getString("j.product_code")%></td>
        <td class="lineitemleft<%=alt%>" ><%=orders.getString("prod.prod_name")%></td>
        <td class="lineitemright<%=alt%>" ><%=df.format(orders.getDouble("quantity"))%></td>
        <td class="lineitemright<%=alt%>" ><%=formatter.getCurrency(orders.getDouble("price"))%></td>
        </tr><%
		orderFlag=1;
		lastContactId=orders.getString("contactid");
		}else{
			orderFlag=0;			
		}
      }while(orders.next());
	if (orderFlag==1){
		%><tr><td class="lineitemsright" colspan=5><strong>Total for Customer #<%=orders.getString("contactid")%>:</strong></td><td class="lineitemsright" > <strong><%=formatter.getCurrency(customerPrice)%></strong></td></tr><%
		customerPrice=0;
      %><tr>				
      <td class="minderheaderright" colspan=5><br />Report Totals:</td>
      <td class="lineitemsright"  valign='bottom'><strong><%=formatter.getCurrency(totalPrice)%></strong></td>
    </tr><%
	}
}else{
 %>"No Orders Found"<%
}
  %></table>
<script>
	document.getElementById('loading').innerHTML="<table border=0><tr><td class='minderheaderleft' style=\"width:70px;\">&nbsp;&nbsp;Date From:&nbsp;</td><td class='lineitemsright'  style=\"width:70px;\"><%=((request.getParameter("dateFrom").equals("0000-00-00"))?"All":formatter.formatMysqlDate(request.getParameter("dateFrom")))%>&nbsp;</td></tr><td class='minderheaderleft' style=\"width:70px;\">&nbsp;&nbsp;Date To:&nbsp;</td><td class='lineitemsright'  style=\"width:70px;\"> <%=((request.getParameter("dateTo").equals("2029-12-31"))?"All":formatter.formatMysqlDate(request.getParameter("dateTo")))%>&nbsp;</td></tr></table>";
</script>
</body>
</html><%st.close();conn.close();%>