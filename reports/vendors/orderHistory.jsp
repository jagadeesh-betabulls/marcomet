<%@ page import="java.sql.*,com.marcomet.users.security.*,com.marcomet.tools.*;import java.text.*;" %>
<%@ taglib uri="/WEB-INF/tld/iterationTagLib.tld" prefix="iterate" %>
<%@ include file="/includes/SessionChecker.jsp" %>
<jsp:useBean id="connection" class="com.marcomet.jdbc.ConnectionBean" scope="session" />
<jsp:useBean id="formatter" class="com.marcomet.tools.FormaterTool" scope="page" />
<jsp:useBean id="sl" class="com.marcomet.tools.SimpleLookups" scope="page" />
<jsp:useBean id="cB" class="com.marcomet.beans.SBPContactBean" scope="page" /><%
Connection conn = com.marcomet.jdbc.DBConnect.getConnection();
Statement st = conn.createStatement();
Statement st2 = conn.createStatement();
	boolean editor= (((RoleResolver)session.getAttribute("roles")).roleCheck("editor"));

	String loginId = (session.getAttribute("contactId")==null)?"":(String)session.getAttribute("contactId"); 
	loginId = ((request.getParameter("userId")==null)?loginId:request.getParameter("userId"));
	cB.setContactId(loginId);
	DecimalFormat decFormatter = new DecimalFormat("##.##");
	int c=0;
%><html>
<head>
  <title>Order History Report</title>
  <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
  <link rel="stylesheet" href="<%=(String)session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css">
<style>div#filters{margin: 0px 20px 0px 20px;display: none;}</style><script>
<script src="/javascripts/mainlib.js"></script>
</head>
<body background="<%=(String)session.getAttribute("siteHostRoot")%>/images/back3.jpg">
<%String reportTitle=((request.getParameter("reportType").equals("2"))?"Order History Report by Product":"Order History Report by Date");
DecimalFormat df = new DecimalFormat("###,###,###");
%>
<!----------------------Report Header------------------------------->
<p class="Title"><%=reportTitle%></p>
<table  border=0 cellpadding=0 cellspacing=0 width=90%>
  <tr> 
    <td class="label" width="13%">Date From:</td>
    <td class="bodyBlack" width="16%"><%=((request.getParameter("dateFrom").equals("0000-00-00"))?"All":request.getParameter("dateFrom"))%></td>
    <td width="71%" align="right"><a onClick="history.go(-1)" href="#" class="greybutton">Exit</a></td>
  </tr>
  <tr> 
    <td class="label" width="13%">Date To:</td>
    <td class="bodyBlack" width="16%"><%=((request.getParameter("dateTo").equals("2029-12-31"))?"All":request.getParameter("dateTo"))%></td>
    <td class="label" width="1%"></td>
  </tr>
  <tr> 
    <td class="label" width="13%">Source Site:</td>
    <td class="bodyBlack" width="16%"><%=request.getParameter("siteHostCompanyText")%></td>
    <td class="label" width="1%"></td>
  </tr>
  <tr> 
    <td class="label" width="13%">Buyer Company:</td>
    <td class="bodyBlack" width="16%"><%=request.getParameter("buyerCompanyText")%></td>
    <td class="label" width="1%"></td>
  </tr>
  <tr> 
    <td  colspan=3>&nbsp;</td>
  </tr>
</table>
<table border="0" cellpadding="1" cellspacing="0" width="100%">

<!--------------------End Header------------------------------------------>
<%
String companyId=request.getParameter("companyId");
String reportType=request.getParameter("reportType");
String sqlOrders = "";
String sqlRoot = "";
String rootProduct = "";
double totalPrice = 0;
double rTotalPrice = 0;
double rTotalTotal = 0;
double rTotalCost = 0;
double totalCost = 0;

String alt="alt";
String headerRow="<tr><td class=\"minderheadercenter\" >Order Date</td><td class=\"minderheadercenter\" >Job #</td><td class=\"minderheadercenter\" >Product Code</td><td class=\"minderheadercenter\" >Product Name</td><td class=\"minderheadercenter\" >Quantity</td><td class=\"minderheadercenter\" >Price</td>"+((editor)?"<td class=\"minderheadercenter\" >Cost</td><td class=\"minderheadercenter\" >Margin</td><td class=\"minderheadercenter\" >Margin %</td>":"");

if (reportType.equals("2")){
  sqlRoot = "select distinct j.root_prod_code, proot.description from jobs j, site_hosts sh, products prod, product_roots proot where j.jsite_host_id=sh.id  and j.product_code=prod.prod_code  and j.root_prod_code=proot.root_prod_code  and j.order_date>='" + request.getParameter("dateFrom") + " 00:00:00'  and j.order_date<='" + request.getParameter("dateTo") + " 23:59:59' and (j.jbuyer_company_id = "+request.getParameter("buyerCompany")+" or "+request.getParameter("buyerCompany")+" = 0) and (j.jsite_host_id = "+request.getParameter("siteHostCompany")+" or "+request.getParameter("siteHostCompany")+" = 0 ) order by j.root_prod_code";
} else {
	sqlRoot = "select distinct 'All' as root_prod_code from jobs j";
}
ResultSet root = st.executeQuery(sqlRoot);
if(root.next()){
  do{
  String jobCost="(j.accrued_po_cost+j.accrued_inventory_cost+j.accrued_shipping+j.est_labor_cost)";
  String jobPrice="(j.price+j.shipping_price)";
    if (reportType.equals("2")){
      rootProduct = root.getString("j.root_prod_code");%>
        <tr>
        <td class="label" colspan="7">Product: <%=rootProduct%>  <%=root.getString("proot.description")%></td>
        </tr><%
      rTotalPrice = 0;
      rTotalCost = 0; 
      rTotalTotal = 0;
      sqlOrders = "select "+jobCost+" 'job_cost',"+jobPrice+" - "+jobCost+" 'job_margin', if(("+jobPrice+")<=0,0,((("+jobPrice+" - "+jobCost+")/"+jobPrice+")*100))  'job_margin_percentage',j.root_prod_code, j.product_code, prod.prod_name, date_format(j.order_date,'%m/%d/%y') as order_date, j.id, quantity, "+jobPrice+" price from jobs j, site_hosts sh left join products prod on j.product_id=prod.id where j.jsite_host_id=sh.id and j.order_date>='" + request.getParameter("dateFrom") + " 00:00:00'  and j.order_date<='" + request.getParameter("dateTo") + " 23:59:59' and (j.jbuyer_company_id = "+request.getParameter("buyerCompany")+" or "+request.getParameter("buyerCompany")+" = 0) and (j.jsite_host_id = "+request.getParameter("siteHostCompany")+" or "+request.getParameter("siteHostCompany")+" = 0 ) and j.root_prod_code = '"+rootProduct+"'  and j.status_id<>9 order by j.order_date desc";
    }else{
      sqlOrders = "select "+jobCost+" 'job_cost',"+jobPrice+" - "+jobCost+" 'job_margin',if(("+jobPrice+")<=0,0,((("+jobPrice+" - "+jobCost+")/"+jobPrice+")*100))  'job_margin_percentage',j.root_prod_code, j.product_code, prod.prod_name, date_format(j.order_date,'%m/%d/%y') as order_date, j.id, quantity,"+jobPrice+" price from jobs j, site_hosts sh left join products prod on j.product_id=prod.id where j.jsite_host_id=sh.id and j.order_date>='" + request.getParameter("dateFrom") + "  00:00:00'  and j.order_date<='" + request.getParameter("dateTo") + " 23:59:59' and (j.jbuyer_company_id = "+request.getParameter("buyerCompany")+" or "+request.getParameter("buyerCompany")+" = 0) and (j.jsite_host_id = "+request.getParameter("siteHostCompany")+" or "+request.getParameter("siteHostCompany")+" = 0 ) and j.status_id<>9 order by j.order_date desc";
    }

    ResultSet orders = st2.executeQuery(sqlOrders);
    if(orders.next()){
    %><%=headerRow%><%
      do{
        totalPrice += orders.getDouble("price");
        rTotalPrice += orders.getDouble("price");
        rTotalTotal += orders.getDouble("quantity");
        rTotalCost += orders.getDouble("job_cost");        
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
			%><td class="lineitemright<%=alt%>" ><%=formatter.getCurrency(orders.getDouble("job_cost"))%></td>
          <td class="lineitemright<%=alt%>" ><%=formatter.getCurrency(orders.getDouble("job_margin"))%></td>
          <td class="lineitemright<%=alt%>" ><%=orders.getDouble("job_margin_percentage")%>%</td><%              
        }%></tr><%
      }while(orders.next());
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
      %><tr>				
      <td class="lineitemsright" colspan=5><b>Report Totals:</b></td>
      <td class="lineitemsright" ><%=formatter.getCurrency(totalPrice)%></td><%
      if(editor){
      	%><td class="lineitemsright" ><%=formatter.getCurrency(totalCost)%></td>
      	<td class="lineitemsright" ><%=formatter.getCurrency(totalPrice-totalCost)%></td>
      	<td class="lineitemsright" ><%=decFormatter.format(((totalPrice-totalCost)/totalPrice)*100)%>%</td><%      	
      }
      %></tr>
    <%
}else{
 %>"No Orders Found"<%
}
  %></table>
</body>
</html><%st2.close();st.close();conn.close();%>