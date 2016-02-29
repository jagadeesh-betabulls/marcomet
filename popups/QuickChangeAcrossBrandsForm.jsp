<%@ page import="java.sql.*,java.util.*,java.text.*,com.marcomet.users.security.*, com.marcomet.jdbc.*, com.marcomet.environment.*,com.marcomet.tools.*;" %>
<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<%@ taglib uri="/WEB-INF/tld/taglib.tld" prefix="taglib" %>
<%
//SiteHostSettings shs = (SiteHostSettings)session.getAttribute("siteHostSettings"); 
StringTool str = new StringTool();
String tableName=((request.getParameter("tableName")==null ||  request.getParameter("tableName").equals(""))?"jobs":request.getParameter("tableName"));
String productCode="";
String rootProdCode="";
String prodLineId="";
String variantCode="";
String release="";
String productId=((request.getParameter("productId")==null || request.getParameter("productId").equals(""))?"":request.getParameter("productId"));
String companyId=((request.getParameter("companyId")==null ||  request.getParameter("companyId").equals(""))?"0":request.getParameter("companyId"));
String prodLineFilter=((request.getParameter("noPL")==null ||  request.getParameter("noPL").equals(""))?" AND left(prod_line_id,6)='"+prodLineId+"'":"");
String companyFilter="";
boolean closeThis=false;
;
Connection conn = DBConnect.getConnection();
Statement st = conn.createStatement();
Statement st1 = conn.createStatement();
String query="";
String query1="";
String query2="";
String query3="";
String newValue="";
String oldValue="";

int changed=0;

if (request.getParameter("submitted")!=null && request.getParameter("submitted").equals("true")){
	newValue=request.getParameter("newValue");
	if (request.getParameter("tableName")!= null && request.getParameter("tableName").equals("products")){
		query1="Select id prodId, root_prod_code,prod_code,variant_code,products.release releaseStr,company_id,left(prod_line_id,6) prodLineId from products where id="+request.getParameter("primaryKeyValue");
	}else{
		query1="Select p.id prodId, p.prod_code,p.root_prod_code,p.variant_code,p.release releaseStr,p.company_id,p.prod_code,left(pb.prod_line_id,4) company_id,left(pb.prod_line_id,6) prodLineId from products p,product_line_bridge pb where pb.prod_id=p.id and pb.id="+request.getParameter("primaryKeyValue");
	}
	ResultSet rsId=st.executeQuery(query1);
	if (rsId.next()){
		productId=rsId.getString("prodId");
		productCode=rsId.getString("prod_code");
		companyId=rsId.getString("company_id");
		companyFilter=((request.getParameter("noCID")==null ||  request.getParameter("noCID").equals(""))?" AND company_id='"+rsId.getString("company_id")+"' ":"");
		prodLineId=rsId.getString("prodLineId");
		rootProdCode=rsId.getString("root_prod_code");
		variantCode=rsId.getString("variant_code");
		release=rsId.getString("releaseStr");
	}

	if (request.getParameter("tableName")!= null && request.getParameter("tableName").equals("products")){
		if (request.getParameter("columnName").equals("prod_line_id")){
			query2="select id,brand_code from products where root_prod_code='"+rootProdCode+"' and variant_code='"+variantCode+"' "+companyFilter+" and products.release ='"+release+"' ";
		}else{
			query2="select id,brand_code from products where root_prod_code='"+rootProdCode+"' and variant_code='"+variantCode+"' "+companyFilter+" and products.release ='"+release+"' ";
		}
	}else{
		query2="select pb.id,'' as 'brand_code' from products p,product_line_bridge pb where p.root_prod_code='"+rootProdCode+"' and p.variant_code='"+variantCode+"' and p.company_id='"+companyId+"' and pb.prod_line_id like '"+prodLineId+"%' and p.id=pb.prod_id";
	}

	ResultSet rsProds=st1.executeQuery(query2);
	while (rsProds.next()){
		companyId=rsId.getString("company_id");
		prodLineId=rsId.getString("prodLineId");
		rootProdCode=rsId.getString("root_prod_code");
		variantCode=rsId.getString("variant_code");
		release=rsId.getString("releaseStr");
		query3 = "update "+request.getParameter("tableName")+" set "+request.getParameter("columnName")+" = ?  where id=?";
		PreparedStatement inventory = conn.prepareStatement(query3);
		inventory.clearParameters();
		inventory.setString(2, rsProds.getString("id"));
		inventory.setString(1, str.replaceSubstring(newValue, "^^", rsProds.getString("brand_code")));
		inventory.executeUpdate();
		changed++;
	}
	closeThis=true;
}else{
	%><html>
<head>
  <title><%= request.getParameter("question") %></title>
  <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
  <link rel="stylesheet" href="<%=(String)session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css">
</head>
<script src="/javascripts/mainlib.js"></script>
<body>
<form method="post" action="/popups/QuickChangeAcrossBrandsForm.jsp?submitted=true">
<table border="0" cellpadding="5" cellspacing="0" align="center" width="100%">
  <tr><td class="tableheader"><span style="font-size:13"><%= request.getParameter("question") %><BR><u>Across Brand Tiers</u></span></td></tr>
  <tr><td class="lineitems" align="center"><%
      if (request.getParameter("valueFieldVal")==null || request.getParameter("valueFieldVal").equals("")){
	      java.sql.ResultSet rs = st1.executeQuery("SELECT " + request.getParameter("columnName") + " FROM "+request.getParameter("tableName")+" j WHERE j.id = " + request.getParameter("primaryKeyValue"));
      	if (rs.next()) {
      		%><textarea name="newValue" cols="<%=request.getParameter("cols")%>" rows="<%=request.getParameter("rows")%>"><%=rs.getString(1)%></textarea><%
      	}
      }else{
      	%><input type="hidden" name="newValue" value="<%=request.getParameter("valueFieldVal")%>"><%
      }
 %></td></tr>
<tr><td align="center"><input type="submit" value="Update Across Tiers">&nbsp;&nbsp;&nbsp;&nbsp;<input type="button" value="Cancel" onClick="self.close()"></td></tr>
</table>
<input type="hidden" name="tableName" value="<%=tableName%>">
<input type="hidden" name="columnName" value="<%=request.getParameter("columnName")%>">
<input type="hidden" name="valueType" value="<%=request.getParameter("valueType")%>">
<input type="hidden" name="primaryKeyValue" value="<%=request.getParameter("primaryKeyValue")%>">
<input type="hidden" name="tableName" value="<%=request.getParameter("tableName")%>">
<input type="hidden" name="$$Return" value="<script>parent.window.opener.location.reload();setTimeout('close()',500);</script>">
<script>document.forms[0].newValue.focus();document.forms[0].newValue.select();</script>
</form>
</body>
</html><%}
	st.close();
	st1.close();
	conn.close();
if (closeThis){
%><script>parent.window.opener.location.reload();setTimeout('close()',500);</script><%
}%>
