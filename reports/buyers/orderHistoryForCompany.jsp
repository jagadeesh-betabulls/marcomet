<%@ page import="java.sql.*,com.marcomet.tools.*;import java.text.*;" %>
<%@ taglib uri="/WEB-INF/tld/iterationTagLib.tld" prefix="iterate" %>
<%@ include file="/includes/SessionChecker.jsp" %>
<jsp:useBean id="formatter" class="com.marcomet.tools.FormaterTool" scope="page" />
<jsp:useBean id="sl" class="com.marcomet.tools.SimpleLookups" scope="page" />
<jsp:useBean id="cB" class="com.marcomet.beans.SBPContactBean" scope="page" />
<%		Connection conn = com.marcomet.jdbc.DBConnect.getConnection();
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
%><p class="Title"><%=reportTitle%></p>
<table  border=0 cellpadding=0 cellspacing=0 width=100%>
  <tr>
    <td width="25%" class="label">Name:</td>
    <td width="50%" class=bodyBlack><%= cB.getFirstName() %> <%= cB.getLastName() %></td>
    <td width="25%" align="right"><a onClick="history.go(-1)" href="#" class="greybutton">Exit</a></td>
  </tr>
  <tr>
    <td width="25%" class="label">Company:</td>
    <td width="50%" class="bodyBlack"><%= cB.getCompanyName() %></td>
  </tr>
  <tr> 
    <td class="label">Date From:</td>
    <td class="bodyBlack"><%=((request.getParameter("dateFrom").equals("0000-00-00"))?"All":request.getParameter("dateFrom"))%></td>
    <td class="label"></td>
  </tr>
  <tr> 
    <td class="label">Date To:</td>
    <td class="bodyBlack"><%=((request.getParameter("dateTo").equals("2029-12-31"))?"All":request.getParameter("dateTo"))%></td>
    <td class="label"></td>
  </tr>
  <tr> 
    <td  colspan=3>&nbsp;</td>
  </tr>
</table>
<table border="0" cellpadding="1" cellspacing="0" width="100%"><%
String companyId=request.getParameter("companyId");
String reportType=request.getParameter("reportType");
String sqlOrders = "";
String sqlRoot = "";
String rootProduct = "";
double totalPrice = 0;
double rTotalPrice = 0;
double rTotalTotal = 0;

String alt="alt";

String headerRow="<tr><td class=\"minderheadercenter\" >Order Date</td><td class=\"minderheadercenter\" >Job #</td><td class=\"minderheadercenter\" >Product Code</td><td class=\"minderheadercenter\" >Product Name</td><td class=\"minderheadercenter\" >Quantity</td><td class=\"minderheadercenter\" >Price</td>";



if (reportType.equals("2")){

  sqlRoot = "select distinct j.root_prod_code, proot.description from orders o, projects pr, jobs j, site_hosts sh, products prod, product_roots proot where j.project_id=pr.id and pr.order_id=o.id  and o.site_host_id=sh.id  and j.product_code=prod.prod_code  and j.root_prod_code=proot.root_prod_code  and o.date_created>='" + request.getParameter("dateFrom") + "'  and o.date_created<='" + request.getParameter("dateTo") + "' and o.buyer_company_id = "+companyId+" order by j.root_prod_code";

} else {

  sqlRoot = "select distinct 'All' as root_prod_code from jobs j";

}

ResultSet root = st.executeQuery(sqlRoot);

if(root.next()){

  do{

    if (reportType.equals("2")){

      rootProduct = root.getString("j.root_prod_code");%><tr>
        <td class="label" colspan="7">Product: <%=rootProduct%>  <%=root.getString("proot.description")%></td>
        </tr><%

      rTotalPrice = 0;

      rTotalTotal = 0;

      sqlOrders = "select j.root_prod_code, j.product_code, prod.prod_name, o.date_created, j.id, quantity, price from orders o, projects pr, site_hosts sh,jobs j left join products prod on j.product_id=prod.id where j.project_id=pr.id and pr.order_id=o.id  and o.site_host_id=sh.id and o.date_created>='" + request.getParameter("dateFrom") + "'  and o.date_created<='" + request.getParameter("dateTo") + "' and o.buyer_company_id = "+companyId+" and j.root_prod_code = '"+rootProduct+"' order by o.date_created desc";

    }else{

      sqlOrders = "select j.root_prod_code, j.product_code, prod.prod_name, o.date_created, j.id, quantity, price from orders o, projects pr, site_hosts sh,jobs j left join products prod on j.product_id=prod.id where j.project_id=pr.id and pr.order_id=o.id  and o.site_host_id=sh.id and o.date_created>='" + request.getParameter("dateFrom") + "'  and o.date_created<='" + request.getParameter("dateTo") + "' and o.buyer_company_id = "+companyId+" order by o.date_created desc";

    }

    ResultSet orders = st.executeQuery(sqlOrders);

    if(orders.next()){

    %><%=headerRow%><%

      do{

        totalPrice += orders.getDouble("price");

        rTotalPrice += orders.getDouble("price");

        rTotalTotal += orders.getDouble("quantity");

        alt=((alt.equals(""))?"alt":"");

        %><tr>
        <td class="lineitemcenter<%=alt%>" ><%=formatter.formatTimeStamp(orders.getString("o.date_created"))%></td>
        <td class="lineitemcenter<%=alt%>" ><a href="javascript:pop('/popups/JobDetailsPage.jsp?jobId=<%=orders.getString("j.id")%>','700','300')"><%=orders.getString("j.id")%></a></td>
        <td class="lineitemcenter<%=alt%>" ><%=orders.getString("j.product_code")%></td>
        <td class="lineitemcenter<%=alt%>" ><%=orders.getString("prod.prod_name")%></td>
        <td class="lineitemright<%=alt%>" ><%=df.format(orders.getDouble("quantity"))%></td>
        <td class="lineitemright<%=alt%>" ><%=formatter.getCurrency(orders.getDouble("price"))%></td>
        </tr><%

      }while(orders.next());

    }

    if (reportType.equals("2")){%><tr>				
        <td class="label" colspan=4><%=rootProduct%> Totals:</td>
        <td class="lineitemsright" ><%=df.format(rTotalTotal)%></td>
        <td class="lineitemsright" ><%=formatter.getCurrency(rTotalPrice)%></td>
      </tr>
      <tr><td colspan=7>&nbsp;</td></tr><%
    }
  }while(root.next());
      %><tr>				
      <td class="label" colspan=5>Report Totals:</td>
      <td class="lineitemsright" ><%=formatter.getCurrency(totalPrice)%></td>
    </tr><%
}else{

 %>"No Orders Found"<%

}

  %></table>
</body>
</html><%st.close();conn.close();%>