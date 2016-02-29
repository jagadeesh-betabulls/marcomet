<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<%@ include file="/includes/SessionChecker.jsp" %>
<%@ page import="java.util.*,java.sql.*,com.marcomet.tools.*,com.marcomet.environment.*,com.marcomet.users.admin.*,com.marcomet.users.security.*;" %>
<%@ taglib uri="/WEB-INF/tld/iterationTagLib.tld" prefix="iterate" %>
<jsp:useBean id="sl" class="com.marcomet.tools.SimpleLookups" scope="page" />
<jsp:useBean id="formatter" class="com.marcomet.tools.FormaterTool" scope="page" />
<jsp:useBean id="str" class="com.marcomet.tools.StringTool" scope="page" /><%
SiteHostSettings shs = (SiteHostSettings)session.getAttribute("siteHostSettings");

Connection conn = com.marcomet.jdbc.DBConnect.getConnection();
Statement st = conn.createStatement();

String siteHostRoot=((request.getParameter("siteHostRoot")==null)?((session.getAttribute("tmpSHRoot")==null || session.getAttribute("tmpSHRoot").toString().equals(""))?(String)session.getAttribute("siteHostRoot"):(String)session.getAttribute("tmpSHRoot")):request.getParameter("siteHostRoot"));
String siteHostId=((request.getParameter("siteHostId")==null)?shs.getSiteHostId():request.getParameter("siteHostId"));
String productId=((request.getParameter("productId")==null)?"":request.getParameter("productId"));
String prodName=sl.getValue("products","id",productId, "prod_name");
String prodPriceCode=sl.getValue("products","id",productId, "prod_price_code");
%><html>
<head>
<title>Suggested Retail Prices for <%=prodName%></title>
<link rel="stylesheet" href="/styles/marcomet.css" type="text/css">
<link rel="stylesheet" href="<%=(String)session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css">
<script language="JavaScript" src="/javascripts/mainlib.js"></script>
<link rel="stylesheet" href="/styles/misc_styles.css" type="text/css">

</head>
<body topmargin="0" bgcolor=white id='mainBody'><br><br>
<div class="catalogLABEL">Standard Retail Price List for <%=prodName%></div>
<table border="0" cellpadding="0" cellspacing="0" width="98%">
  <tr>
      <td class="tableheader" colspan="6">Quantity (<%=sl.getValue("product_price_codes","prod_price_code","'"+prodPriceCode+"'","unit")%>)</td>
  </tr>
  <tr>
<%
ResultSet rsCount = st.executeQuery("Select count(id) from product_prices where prod_price_code='"+prodPriceCode+"' and site_id="+siteHostId);
Integer shRows=0;
while (rsCount.next()){
	shRows=rsCount.getInt(1);
}
Hashtable hPreProp=new Hashtable<String,String>();

String SQL="";
if(shRows>0){
    SQL="Select quantity,if(rfq=0,concat('$',format(standard_retail_price,2)),'Request&nbsp;Price') as 'price' from product_prices pp left join product_price_codes ppc on pp.prod_price_code=ppc.prod_price_code where pp.site_id="+siteHostId+" and pp.prod_price_code='"+prodPriceCode+"' order by quantity asc";
}else{
	SQL="Select quantity,if(rfq=0,concat('$',format(standard_retail_price,2)),'Request&nbsp;Price') as 'price' from product_prices pp left join product_price_codes ppc on pp.prod_price_code=ppc.prod_price_code where pp.site_id=0 and pp.prod_price_code='"+prodPriceCode+"' order by quantity asc";

}
Integer cols=0;
ResultSet rsAdj = st.executeQuery(SQL);
while(rsAdj.next()){
%>		<td class="planheader2" align="center"><%=rsAdj.getString("quantity")%></td>
		<% hPreProp.put(Integer.toString(cols),rsAdj.getString("price"));cols=cols+1;%><%
}
%>	</tr>
	<tr>
<%for (int i=0 ;i < cols; i++){
%>		<td class="lineitems" align="center"><%=hPreProp.get(Integer.toString(i))%></td><%
}	
	
%></tr>
 </table>
 <br><div align="center"><a href="javascript:window.close();" class="menuLINK">CLOSE</a></div>
</body>
</html><%

st.close();
conn.close();%>
