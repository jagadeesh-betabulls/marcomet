<%@ page import="java.sql.*,java.util.*,java.text.*,com.marcomet.users.security.*, com.marcomet.jdbc.*, com.marcomet.environment.*;" %>
<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<%@ taglib uri="/WEB-INF/tld/formTagLib.tld" prefix="formtaglib" %>
<%

Connection conn = DBConnect.getConnection();
Statement st = conn.createStatement();
Statement st1 = conn.createStatement();
Statement st2 = conn.createStatement();
String query="";
String query1="";
String rootProdCode="";
String variantCode="";
String release="";

int changed=0;
int x=1;
int y=1;
boolean closeThis=false;

if (request.getParameter("submitted")!=null && request.getParameter("submitted").equals("true")){
	//find all product lines with the current company/segment
	try{
	query="Select * from products where id="+request.getParameter("newValue");
	ResultSet rsProd=st.executeQuery(query);
	if (rsProd.next()){
		rootProdCode=rsProd.getString("root_prod_code");
		variantCode=rsProd.getString("variant_code");
		release=rsProd.getString("release");
	}
	
	query="Select pl.id,pl.company_id,pl.brand_code from product_lines pl, brands b where (status_id=2) and left(prod_line_id,6) = left('"+request.getParameter("primaryKeyValue")+"',6)  and right(prod_line_id,2) =b.prod_line_segment and pl.company_id=b.company_id";
	//session.setAttribute("plquery",query);
	ResultSet rsProdLines=st.executeQuery(query);
	while (rsProdLines.next()){
			//Find the appropriate product for the brand associated with this product line, else use the current product.
			query="Select distinct p.id,prod_code,sequence from products p,brands b where ((right('"+rsProdLines.getString("id")+"',2)=b.prod_line_segment and b.brand_code=p.brand_code) or p.brand_code='') and `release`='"+release+"' and p.root_prod_code='"+rootProdCode+"' and p.variant_code='"+variantCode+"'  and (p.company_id="+rsProdLines.getString("company_id") + " or p.company_id='1066')";
	//		session.setAttribute("sql"+(y++),query);
			ResultSet rsProds = st1.executeQuery(query);
			if (rsProds.next()){
				x=1;
				query = "insert into product_line_bridge (prod_id, prod_line_id, prod_code, sequence, prod_name, summary, detailed_description, product_features, brand_std_cat, headline) values ("+rsProds.getString("id")+","+rsProdLines.getString("id")+",'"+rsProds.getString("prod_code")+"'," + rsProds.getInt("sequence")+",'','','','',0,'')";
				st2.executeUpdate(query); 
				changed++;
			}
	}
	closeThis=true;
	}catch (Exception e){
	%><br><%=query%><br><%
	}
}else{


%><html>
<head>
  <title>Add Product To Line</title>
  <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
  <link rel="stylesheet" href="<%=(String)session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css">
</head>
<script lanugage="JavaScript" src="/javascripts/mainlib.js"></script>
<body>
<form method="post" action="/popups/QuickChangeAddProductToLine.jsp?submitted=true">
<table border="0" cellpadding="5" cellspacing="0" align="center" width="100%">
  <tr>
    <td class="tableheader"><%= request.getParameter("question") %><br><u>Across Brand Tiers</u></td>
  </tr>
  <tr>
    <td class="lineitems"><a href='javascript:window.location.replace(window.location.href+"&active=true");' class=menuLINK>Show Active Only</a></td>
  </tr>
  <tr>
      <td class="lineitemscenter"><% 
String activeFilter=((request.getParameter("active")==null || !(request.getParameter("active").equals("true")))?"":" p.status_id=2 AND ");
String sqlContactDD = "SELECT p.id 'value', CONCAT(prod_code,':',left(prod_name,25),if(length(prod_name)>25,'...',''),' [',p.brand_code,'] '"+((activeFilter.equals(""))?",'[',if(p.status_id=1,'Draft',if(p.status_id=2,'Active','On Hold')),']'":"")+") 'text' FROM products p,product_lines pl WHERE "+activeFilter+" (p.company_id = left('" + request.getParameter("primaryKeyValue") + "',4) or p.company_id = '1066') AND (p.brand_code=pl.brand_code or p.brand_code='') and pl.id like '"+request.getParameter("primaryKeyValue")+"%' group by p.id ORDER BY prod_code, p.brand_code"; 
%><formtaglib:SQLDropDownTag dropDownName="newValue" sql="<%= sqlContactDD %>" selected="" extraCode="" />
      </td>
  </tr>
  <tr>
  	<td align="center">
  	<input type="button" value="Update" onClick="submit()">
	&nbsp;&nbsp;&nbsp;&nbsp;
	<input type="button" value="Cancel" onClick="self.close()">
	</td>
  </tr>
</table>
<input type="hidden" name="primaryKeyValue" value="<%=request.getParameter("primaryKeyValue")%>">
<input type="hidden" name="$$Return" value="<script>parent.window.opener.location.reload();setTimeout('close()',500);</script>">
</form>
</body>
</html><%}
	st.close();
	st1.close();
	st2.close();
	conn.close();

%><%=((closeThis)?"<script>parent.window.opener.location.reload();setTimeout('close()',500);</script>":"")%>
