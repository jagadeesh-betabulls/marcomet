<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<%@ page import="java.sql.*,com.marcomet.tools.*,com.marcomet.environment.*;" %>
<%@ taglib uri="/WEB-INF/tld/iterationTagLib.tld" prefix="iterate" %>
<jsp:useBean id="formatter" class="com.marcomet.tools.FormaterTool" scope="page" /><jsp:useBean id="str" class="com.marcomet.tools.StringTool" scope="page" /><%

SiteHostSettings shs = (SiteHostSettings)session.getAttribute("siteHostSettings");
String sitehostId=((request.getParameter("sitehostId")==null)?shs.getSiteHostId():request.getParameter("sitehostId"));
String backorderaction="";
String backorderText="";
String invSQL="";
int invAmount=0;
int onOrderAmount=0;
int prodNum=0;
boolean showChoiceFl=((request.getParameter("showChoiceFl")==null || request.getParameter("showChoiceFl").equals(""))?false:true);
String prodLineId=((request.getParameter("prodLineId")==null)?"":request.getParameter("prodLineId"));
String campaignId=((request.getParameter("campaignId")==null)?"":request.getParameter("campaignId"));
String companyId=((request.getParameter("companyId")==null)?"":request.getParameter("companyId"));
String ShowInactive=((request.getParameter("ShowInactive")==null || request.getParameter("ShowInactive").equals(""))?" AND p.status_id=2 ":""); 
String ShowRelease=((request.getParameter("ShowRelease")==null || request.getParameter("ShowRelease").equals(""))?"":" AND p.release='"+request.getParameter("ShowRelease")+"' ");
%><html>
<head>
<title>Choose Items Page</title>
<link rel="stylesheet" href="<%=(String)session.getAttribute("siteHostRoot")%>/styles/vendor_styles2.css" type="text/css">
<script language="JavaScript" src="/javascripts/mainlib.js"></script>
</head>
<body topmargin="0"><%=((showChoiceFl)?"<form method=post action='/app-admin/EmailCampaign3.jsp'><br><div class=Title>STEP 2: PRODUCT CHOICE<br>Check box next to products to be included, Click Next at bottom of page.</div>":"") %><%if (!showChoiceFl){%><div align="right" width=90%><a href="javascript:history.go(-1)" class="menuLINK">&laquo;&nbsp;Back&nbsp;</a> <a href="mailto:marketingsvcs@marcomet.com" class="menuLINK">&nbsp;Email Support&nbsp;</a></div><%
}

String sql = ((prodLineId.equals(""))?"SELECT pl.* FROM product_lines pl, products p, site_hosts sh WHERE sh.id= " + sitehostId + " AND sh.company_id=pl.company_id AND pl.id = p.prod_line_id "+ShowRelease+" AND pl.status_id=2 GROUP BY pl.id ORDER BY pl.id":"SELECT * FROM product_lines where  id="+prodLineId);
Connection conn = com.marcomet.jdbc.DBConnect.getConnection();
Statement st = conn.createStatement();
Statement st2 = conn.createStatement();
Statement st3 = conn.createStatement();
ResultSet rsProdLine = st.executeQuery(sql);

while(rsProdLine.next()){

String sql2 = "SELECT p.on_order_amount,p.backorder_action,p.inventory_product_flag,if(p.root_inv_prod_id=0,p.id,p.root_inv_prod_id) root_inv_id, pr.display_title,p.sequence sequence, if(p.backorder_notes is null,'',p.backorder_notes) backorder_notes, p.headline,p.company_id,p.root_prod_code, lbs.presentation_language brand_standard,round(min(pp.price/pp.quantity),2) priceper,p.id,p.prod_name,p.product_features,p.prod_code,p.small_picurl,p.offering_id,p.price_list,p.spec_diagram_picurl,p.full_picurl,p.detailed_description FROM lu_brand_std_cat lbs,products p left join product_releases pr on p.release=pr.release_code and p.company_id=pr.company_id  left join product_prices pp on pp.prod_price_code=p.prod_price_code where (prod_line_id="+rsProdLine.getString("id")+" or prod_line_id="+rsProdLine.getString("top_level_prod_line_id")+") and lbs.id=p.brand_std_cat "+ShowRelease+ShowInactive+" group by p.id union SELECT p.on_order_amount,p.backorder_action,p.inventory_product_flag,if(p.root_inv_prod_id=0,p.id,p.root_inv_prod_id) root_inv_id, pr.display_title,pb.sequence sequence, if(p.backorder_notes is null,'',p.backorder_notes) backorder_notes, pb.headline headline,p.company_id company_id,p.root_prod_code root_prod_code, lbs.presentation_language brand_standard,round(min(pp.price/pp.quantity),2) priceper,p.id id,p.prod_name prod_name,pb.product_features product_features,p.prod_code prod_code,p.small_picurl small_picurl,p.offering_id offering_id,p.price_list price_list,p.spec_diagram_picurl spec_diagram_picurl,p.full_picurl full_picurl,pb.detailed_description detailed_description FROM lu_brand_std_cat lbs,product_line_bridge pb,products p left join product_releases pr on p.release=pr.release_code and p.company_id=pr.company_id  left join product_prices pp on pp.prod_price_code=p.prod_price_code where pb.prod_id=p.id AND (pb.prod_line_id="+rsProdLine.getString("id")+" or pb.prod_line_id="+rsProdLine.getString("top_level_prod_line_id")+") and lbs.id=pb.brand_std_cat "+ShowRelease+ShowInactive+" group by p.id ORDER BY p.sequence";

ResultSet rsProds = st2.executeQuery(sql2);
%><table width="95%" border="0" cellspacing="0" cellpadding="0" align="center" dwcopytype="CopyTableRow">
<tr>
    <td width="61%" height="35" valign="middle"><p class="Title" align="left"><%=((ShowRelease.equals(""))?"":rsProds.getString("pr.display_title")+": <br>")%><%=rsProdLine.getString("prod_line_name")%></p></td>
  </tr>
</table>
<table width="95%" cellspacing="0" cellpadding="0" height="40" align="center">
  <tr>
    <td class="body" height="17"><%=((rsProdLine.getString("description")==null || rsProdLine.getString("description").equals(""))?"":rsProdLine.getString("description"))%></td>
  </tr>
  <tr>
    <td class="body" height="7"><%=((rsProdLine.getString("usp")==null || rsProdLine.getString("usp").equals(""))?"":rsProdLine.getString("usp"))%></td>
  </tr>
</table>
<table border=1 cellpadding=5 cellspacing=0 width=90% align="center">
  <tr>
    <td valign="top" colspan="2" class="menuLINKText" height="30">
		<div align="left" ><strong>&nbsp;&nbsp;<%=rsProdLine.getString("mainfeatures")%></strong></div>
	</td>
  </tr><%
 while (rsProds.next()){ 
	backorderaction="0";
	backorderText="";
	invAmount=0;
	onOrderAmount=Integer.parseInt(rsProds.getString("p.on_order_amount"));
	if (rsProds.getString("inventory_product_flag").equals("1")){
		invSQL="Select sum(amount) inv_amount,sum(adjustment_action) inv_action from inventory where product_id="+rsProds.getString("root_inv_id")+" group by product_id";
		ResultSet rsInv = st3.executeQuery(invSQL);
		if (rsInv.next()){
			invAmount=Integer.parseInt(rsInv.getString("inv_amount"));
			if(Integer.parseInt(rsInv.getString("inv_amount"))>0){ //if there was an 'increment' transaction to manually update the inventory amount
				if (invAmount < onOrderAmount){ //if product is on backorder
					backorderaction=rsProds.getString("p.backorder_action"); //1=show notes and allow order, 2=disable order and show prod not available
					if (rsProds.getString("backorder_action").equals("2")){
						backorderText="Product Not Currently Available";						
					}else{
						backorderText=((rsProds.getString("backorder_notes").equals(""))?"Product On Backorder":rsProds.getString("backorder_notes"));
					}
				}
			};
		}
	}
	%><tr>
    <td valign="top" width=3%>
		<a href="javascript:pop('<%=((rsProds.getString("full_picurl")==null || rsProds.getString("full_picurl").equals(""))?"":""+(String)session.getAttribute("siteHostRoot")+"/fileuploads/product_images/"+ str.replaceSubstring(rsProds.getString("full_picurl")," ","%20"))%>','800','600')" >
		<%=((rsProds.getString("small_picurl")==null || rsProds.getString("small_picurl").equals(""))?"":"<img src='"+(String)session.getAttribute("siteHostRoot")+"/fileuploads/product_images/"+ str.replaceSubstring(rsProds.getString("small_picurl")," ","%20") +"' border=0>")%>
		</a></td>
    <td valign="top" width="73%" align="left"><%
	
	String sql3 = "SELECT * FROM offerings o, offering_sequences os where o.id=os.offering_id and os.sequence=0 and o.id="+(rsProds.getString("offering_id"));
	ResultSet rsOfferings = st3.executeQuery(sql3);

%><div align='left' class="catalogLABEL"><%=((showChoiceFl)?"<input type='checkbox' name='prodId_"+ prodNum++ +"' value='"+rsProds.getString("id")+"' >&nbsp;":"")%><%=rsProds.getString("prod_name")%>&nbsp;-&nbsp;<%=rsProds.getString("prod_code")%></div>
<div class="subtitle">
	<em><%=((rsProds.getString("brand_standard")!=null && !rsProds.getString("brand_standard").equals(""))?rsProds.getString("brand_standard")+"<br>":"")%></em>			
	<%=((rsProds.getString("headline")!=null && !rsProds.getString("headline").equals(""))?rsProds.getString("headline")+"<br>":"")%> 
	<%=((rsProds.getString("product_features")!=null && !rsProds.getString("product_features").equals(""))?rsProds.getString("product_features")+"<br>":"")%>
	<%=((rsProds.getString("backorder_notes") !=null && !rsProds.getString("backorder_notes").equals(""))?rsProds.getString("backorder_notes")+"<br>":"")%>
</div>
<div class="bodyBlack">
	<%=((rsProds.getString("detailed_description")!=null)?rsProds.getString("detailed_description"):"")%>
</div><br />
<table width=100% cellpadding=0 cellspacing=0 border=0><tr><td align='left'>
<a href="javascript:pop('<%=((rsProds.getString("full_picurl")==null || rsProds.getString("full_picurl").equals(""))?"":""+(String)session.getAttribute("siteHostRoot")+"/fileuploads/product_images/"+ str.replaceSubstring(rsProds.getString("full_picurl")," ","%20"))%>','800','600')" class='menuLINK'>
<%=((rsProds.getString("small_picurl")==null || rsProds.getString("small_picurl").equals(""))?"":"Enlarge&nbsp;Product&nbsp;Image")%></a>
<%=((rsProds.getString("spec_diagram_picurl")==null || rsProds.getString("spec_diagram_picurl").equals(""))?"":"<a class='menuLINK' href=\"javascript:pop('"+(String)session.getAttribute("siteHostRoot")+"/fileuploads/product_images/"+ str.replaceSubstring(rsProds.getString("spec_diagram_picurl")," ","%20") +"','800','600')\" >"+((rsProds.getString("spec_diagram_picurl")==null || rsProds.getString("spec_diagram_picurl").equals(""))?"":"View&nsbp;Back") + "</a>")%>
</td><td align='right'><%
String priceList=((rsProds.getString("price_list")==null || rsProds.getString("price_list").equals(""))?"":((rsProds.getString("price_list").indexOf("<a")>-1)?"<a class='menuLINK' "+rsProds.getString("price_list").substring(3,rsProds.getString("price_list").length()):"<a href=\"javascript:pop('/images/pricing/"+rsProds.getString("price_list")+"','550','400')\"  class='menuLINK'>Price List</a>"));%><%=priceList%><%=((backorderText.equals(""))?"":"<span class='subTitle'>"+backorderText+"</span>&nbsp;")%><%
if (Integer.parseInt(backorderaction)<2 && !showChoiceFl){
%><a href= "/frames/InnerFrameset.jsp?contents=/servlet/com.marcomet.catalog.CatalogNavigationServlet?offeringId=<%=rsProds.getString("offering_id")%>&jobTypeId=<%=rsOfferings.getString("job_type_id")%>&serviceTypeId=<%=rsOfferings.getString("service_type_id")%>&productId=<%=rsProds.getString("id")%>" target="_top" class="menuLINK">Order&nbsp;&raquo;</a><%}%></td></tr></table>
	</td></tr><%
 } %></table><% } 
if (showChoiceFl){
	%><input type='hidden' name='campaignId' value='<%=campaignId%>'>
	<input type='hidden' name='companyId' value='<%=companyId%>'>
	<input type='hidden' name='pagename' value='<%=campaignId%>'>
	<input type='hidden' name='numProds' value='<%=prodNum%>'><br>
	<div align='right'><input type="submit" name="Submit" value=" Next >> "></div>
	</form><%
	}else{%><hr width="82%" size="1">
<div align="center"><font size="1">Need help? We are here 9am-5pm, M-F, EST to
    help. Marketing Specialists<b>:</b> email <a href="mailto:marketingsvcs@marcomet.com"><u>marketingsvcs@marcomet.com</u></a> or
    leave a Voice Message Alert: at 1-888-777-9832, option 2.<br>
  To Order by Phone call a Customer Service Representative at 1-888-777-9832,
  option 3.<br>
  Technical Support? <a href="mailto:techsupport@marcomet.com"><u>techsupport@marcomet.com</u></a> or
  1-888-777-9832 option 4 Comments? Please e-mail us <a href="mailto:comments@marcomet.com"><u>comments@marcomet.com</u></a></font></div>
<%}%></body>
</html><%conn.close();%>