<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<%@ page import="java.util.*,java.sql.*,com.marcomet.tools.*,com.marcomet.environment.*,com.marcomet.users.admin.*,com.marcomet.users.security.*;" %>
<%@ taglib uri="/WEB-INF/tld/iterationTagLib.tld" prefix="iterate" %>
<jsp:useBean id="sl" class="com.marcomet.tools.SimpleLookups" scope="page" /><jsp:useBean id="formatter" class="com.marcomet.tools.FormaterTool" scope="page" /><jsp:useBean id="str" class="com.marcomet.tools.StringTool" scope="page" /><%
	SiteHostSettings shs = (SiteHostSettings)session.getAttribute("siteHostSettings"); 
	
	String site_host_name = shs.getDomainName(); 
	String domain_name = shs.getDomainName(); 

	Connection conn = com.marcomet.jdbc.DBConnect.getConnection();
	Statement st = conn.createStatement();
	Statement st2 = conn.createStatement();
	Statement st3 = conn.createStatement();
	int prodNum=0;
	boolean editor= ((((RoleResolver)session.getAttribute("roles")).roleCheck("editor")) && (request.getParameter("editor")!=null && request.getParameter("editor").equals("true")));
	boolean showInfo=((session.getAttribute("proxyId")!=null || (((RoleResolver)session.getAttribute("roles")).roleCheck("editor")) )?true:false);
	boolean sitehost= ((((RoleResolver)session.getAttribute("roles")).isSiteHost()) || (((RoleResolver)session.getAttribute("roles")).roleCheck("editor")));
	
	String perItemPrice="";
	
	String downloadText="Download";
	String ioNumber=((request.getParameter("ioNumber")==null)?"":request.getParameter("ioNumber"));
	String paramSpecId=((request.getParameter("specId")==null)?"":request.getParameter("specId"));
	String paramSpecValue=((paramSpecId.equals(""))?"":"&"+paramSpecId+"="+request.getParameter(paramSpecId));
	
	String paramSpecId1=((request.getParameter("specId1")==null)?"":request.getParameter("specId1"));
	String paramSpecValue1=((paramSpecId1.equals(""))?"":"&"+paramSpecId1+"="+request.getParameter(paramSpecId1));
	
	String paramSpecId2=((request.getParameter("specId2")==null)?"":request.getParameter("specId2"));
	String paramSpecValue2=((paramSpecId2.equals(""))?"":"&"+paramSpecId2+"="+request.getParameter(paramSpecId2));
	
	String paramSpecId3=((request.getParameter("specId3")==null)?"":request.getParameter("specId3"));
	String paramSpecValue3=((paramSpecId3.equals(""))?"":"&"+paramSpecId3+"="+request.getParameter(paramSpecId3));
	
	String siteHostRoot=((request.getParameter("siteHostRoot")==null)?(String)session.getAttribute("siteHostRoot"):request.getParameter("siteHostRoot"));
	String campaignId=((request.getParameter("campaignId")==null)?"delete":request.getParameter("campaignId"));
	String companyId=((request.getParameter("companyId")==null)?(String)session.getAttribute("companyId"):request.getParameter("companyId"));
	String siteHostId=((request.getParameter("siteHostId")==null)?shs.getSiteHostId():request.getParameter("siteHostId"));
	String prePopId=((request.getParameter("prePopId")==null)?"":request.getParameter("prePopId"));
	String prePopTable=((request.getParameter("prePopTable")==null || request.getParameter("prePopTable").equals("null"))?"":request.getParameter("prePopTable"));
	String prePopParams=paramSpecValue+paramSpecValue1+paramSpecValue2+paramSpecValue3+((!(prePopId.equals("")) && !(prePopTable.equals("")))?"&prePopTable="+prePopTable+"&prePopId="+prePopId:"");
	boolean showChoice=((request.getParameter("showChoice")==null || request.getParameter("showChoice").equals(""))?false:true);
	String prodLineId=((request.getParameter("prodLineId")==null)?"":request.getParameter("prodLineId"));
	String ShowInactive=( ( (request.getParameter("ShowInactive")==null || request.getParameter("ShowInactive").equals("")) && !(editor) )?" AND p.status_id=2 ":((editor)?" AND (p.status_id<>3 and p.status_id<>4) ":" AND (p.status_id=2 OR p.status_id=9)") ); 
	String SuppressFilter=((editor)?"":" show_in_primary_prod_line=1 and "); 
	String ShowBrand=((request.getParameter("brandCode")==null || request.getParameter("brandCode").equals(""))?"":" AND p.brand_code= '"+request.getParameter("brandCode")+"'"); 
	String ShowRelease=((request.getParameter("ShowRelease")==null || request.getParameter("ShowRelease").equals(""))?"":" AND (p.release='"+request.getParameter("ShowRelease")+"' or p.release='') ");
	
String ShowReleasePB=((request.getParameter("ShowRelease")==null || request.getParameter("ShowRelease").equals(""))?"":" AND (p.release='"+request.getParameter("ShowRelease")+"' or p.release='' or pb.pb_release_code='"+request.getParameter("ShowRelease")+"') ");

	String orderText="Order";
	String defaultPropId=((request.getParameter("defaultPropId")==null)?"":request.getParameter("defaultPropId"));
	String tempPropId="";
	boolean useProdProps=(!(showChoice) && (sl.getValue("site_hosts","id",siteHostId, "use_property_product_filter").equals("1"))?true:false);
	
	%>
<html>
<head>
<title>Products Catalog</title>
<link rel="stylesheet" href="/styles/marcomet.css" type="text/css">
<link rel="stylesheet" href="<%=siteHostRoot%>/styles/vendor_styles.css" type="text/css">
<script language="JavaScript" src="/javascripts/mainlib.js"></script>
<link rel="stylesheet" href="/styles/misc_styles.css" type="text/css">
<style>
.shipPolicy {
	font-weight: bold;
	font-size: 9pt;
	font-family: Arial, Verdana, Geneva;
	text-decoration: none;
	color:red;
}
.pricePerItem {
	font-style: italic;
	font-weight: bold;
	font-size: 8pt;
	font-family: Arial, Verdana, Geneva;
	text-decoration: none;
	text-align: center;
	color: #5b6966;
}
</style><%
	
	Hashtable hProperties=new Hashtable<String,String>();
	Hashtable hCProperties=new Hashtable<String,String>();

	String sql = ((prodLineId.equals(""))?"SELECT pl.* FROM product_lines pl, products p, site_hosts sh WHERE pl.status_id=2 and sh.id= " + siteHostId + " AND sh.company_id=pl.company_id AND pl.id = p.prod_line_id "+ShowRelease+ShowInactive+ShowBrand+" GROUP BY pl.id ORDER BY pl.id":"SELECT * FROM product_lines where  id="+prodLineId);
	ResultSet rsProdLine = st2.executeQuery(sql);
	int p=0;
		%></head>
<body topmargin="0" bgcolor=white>
<table style="border: 0 solid #000;padding: 0px;" cellpadding=0 cellspacing=0 width=100%><tr><td>
<jsp:include page="<%="/includes/topmast_email.jsp"%>" ><jsp:param name="siteHostName" value="<%=site_host_name%>" /><jsp:param name="sitehostroot" value="<%="http://"+domain_name+siteHostRoot%>" /></jsp:include>
</td><td align="right"><img src='<%="http://"+domain_name+siteHostRoot+"/images/header_left.jpg"%>' ></td></tr></table><br>
<div class="title">Product Catalog</div>
<%
	while(rsProdLine.next()){
			int colNum=1;
	  if (useProdProps){
		String contPropSQL="Select * from v_contact_properties where property_code<>0 and contact_id="+(String)session.getAttribute("contactId")+" order by property_code";
		ResultSet rsContProds = st.executeQuery(contPropSQL);
		int cnt=0;
		while(rsContProds.next()){
			hCProperties.put(rsContProds.getString("title"),rsContProds.getString("property_code"));
			cnt++;
		}
	
		boolean useFullList=(hCProperties.size()==0 && sitehost);
	
		String prodpropSQL="SELECT distinct property_id,property_code,title FROM v_product_properties p  left join product_line_bridge pb on pb.prod_id=p.prod_id where company_id="+sl.getValue("site_hosts","id",siteHostId, "company_id")+" AND (("+SuppressFilter+" (p.prod_line_id="+rsProdLine.getString("id")+" or p.prod_line_id="+rsProdLine.getString("top_level_prod_line_id")+")) or pb.prod_line_id="+rsProdLine.getString("id")+") "+ShowRelease+ShowInactive+" ORDER BY property_code desc";
		ResultSet rsPropProds = st.executeQuery(prodpropSQL);
		while(rsPropProds.next()){
			hProperties.put(rsPropProds.getString("title"),rsPropProds.getString("property_code")+"|"+rsPropProds.getString("title"));
		}
		useProdProps=(useProdProps && hProperties.size()>0);
	}
	String prod_line_name=rsProdLine.getString("prod_line_name");

if (p>0){%><br><hr><br><%}p++;%>
  <table border=1 cellpadding=5 cellspacing=0 width=90% align="center">
    <tr>
      <td valign="top" colspan='2' class="menuLINKText" height="30" ><div style="font-size:12pt;text-align:left;"><%=prod_line_name%></div>
        <%=((rsProdLine.getString("description")==null || rsProdLine.getString("description").equals(""))?"":"<div style='font-size:9pt;text-align:left;'>"+rsProdLine.getString("description"))%></td>
    </tr><%
			String sql2 = "SELECT if(pp.ship_price_policy is null,'',pp.ship_price_policy) as ship_policy,pbr.property_code,p.csr_notes csr_notes, p.std_lead_time std_lead_time, p.internal_notes internal_notes,ppb.property_code, vp.title 'sale_title',vp.sale_id 'sale_id', show_in_primary_prod_line,p.prod_line_id prod_line_id,p.status_id,p.id lineId, 'products' lineTable, p.inventory_amount,p.inventory_initialized,p.inv_on_order_amount,p.backorder_action,p.hide_order_button,p.inventory_product_flag,if(p.root_inv_prod_id=0,p.id,p.root_inv_prod_id) root_inv_id, pr.display_title,p.sequence sequence, if(p.backorder_notes is null,'',p.backorder_notes) backorder_notes, p.headline,p.company_id,p.root_prod_code, lbs.presentation_language brand_standard,round(min(pp.price/pp.quantity),2) priceper, p.id,p.prod_name,p.product_features,p.prod_code,if(p.image_coming_soon=1,concat(p.brand_code,'coming_soon.jpg'),p.small_picurl) 'small_picurl',p.offering_id,p.price_list,p.spec_diagram_picurl,if(p.image_coming_soon=1,concat(p.brand_code,'coming_soon.jpg'),p.full_picurl) 'full_picurl',p.download_url,p.detailed_description FROM products p  left join product_property_bridge pbr on p.id=pbr.product_id left join product_property_bridge ppb on ppb.product_id=p.id and ppb.property_company_id=p.company_id left join v_promo_prods vp on p.id=vp.prod_id and vp.start_date<=now() and vp.end_date>=now() left join lu_brand_std_cat lbs on lbs.id=p.brand_std_cat left join product_releases pr on p.release=pr.release_code and p.company_id=pr.company_id  left join product_prices pp on pp.prod_price_code=p.prod_price_code where "+SuppressFilter+" (prod_line_id="+rsProdLine.getString("id")+" or prod_line_id="+rsProdLine.getString("top_level_prod_line_id")+") "+ShowRelease+ShowInactive+" and (pbr.property_code='"+defaultPropId+"' or pbr.property_code is null) group by p.id union SELECT if(pp.ship_price_policy is null,'',pp.ship_price_policy) as ship_policy,pbr.property_code,p.csr_notes csr_notes, p.std_lead_time std_lead_time, p.internal_notes internal_notes, ppb.property_code, vp.title 'sale_title',vp.sale_id 'sale_id', show_in_primary_prod_line,p.prod_line_id prod_line_id,p.status_id,pb.id lineId, 'product_line_bridge' lineTable, p.inventory_amount,p.inventory_initialized,p.inv_on_order_amount,p.backorder_action,p.hide_order_button,p.inventory_product_flag,if(p.root_inv_prod_id=0,p.id,p.root_inv_prod_id) root_inv_id, pr.display_title,pb.sequence sequence, if(p.backorder_notes is null,'',p.backorder_notes) backorder_notes, if(pb.headline='',p.headline,pb.headline) headline,p.company_id company_id,p.root_prod_code root_prod_code, lbs.presentation_language brand_standard,round(min(pp.price/pp.quantity),2) priceper,p.id id,p.prod_name prod_name,if(pb.product_features='',p.product_features,pb.product_features) product_features,p.prod_code prod_code,if(p.image_coming_soon=1,concat(p.brand_code,'coming_soon.jpg'),p.small_picurl) 'small_picurl',p.offering_id offering_id,p.price_list price_list,p.spec_diagram_picurl spec_diagram_picurl,if(p.image_coming_soon=1,concat(p.brand_code,'coming_soon.jpg'),p.full_picurl) 'full_picurl',p.download_url,if(pb.detailed_description='',p.detailed_description,pb.detailed_description) detailed_description FROM product_line_bridge pb,products p  left join product_property_bridge pbr on p.id=pbr.product_id left join product_property_bridge ppb on ppb.product_id=p.id and ppb.property_company_id=p.company_id left join v_promo_prods vp on p.id=vp.prod_id and vp.start_date<=now() and vp.end_date>=now() left join lu_brand_std_cat lbs on lbs.id=p.brand_std_cat left join product_releases pr on p.release=pr.release_code and p.company_id=pr.company_id  left join product_prices pp on pp.prod_price_code=p.prod_price_code where pb.prod_id=p.id AND pb.status_id=2 AND (pb.prod_line_id="+rsProdLine.getString("id")+" or pb.prod_line_id="+rsProdLine.getString("top_level_prod_line_id")+")  "+ShowReleasePB+ShowInactive+" and ( pbr.property_code='"+defaultPropId+"' or pbr.property_code is null) group by p.id ORDER BY sequence";
	
	ResultSet rsProds = st.executeQuery(sql2);
	int x=0;
	 while (rsProds.next()){ 
		if (x==0){
			%><script>document.getElementById("release").innerHTML='<%=((rsProds.getString("display_title")==null || rsProds.getString("display_title").equals(""))?"":rsProds.getString("display_title")+": <br>")%><%=prod_line_name%>';</script><%
		}
		x++;
		
		//Calculate the 'as low as' per item price
		ResultSet rsPerItem = st3.executeQuery("Select concat('As low as $',min(round(pp.price/pp.quantity,3)),' each') as perItem from product_prices pp,products p where pp.prod_price_code=p.prod_price_code and  p.id="+rsProds.getString("id"));
		if (rsPerItem.next()){
			perItemPrice=( (rsPerItem.getString("perItem")!=null && !(rsPerItem.getString("perItem").equals("")))?"&nbsp;<span class='pricePerItem'>"+rsPerItem.getString("perItem")+"</span>&nbsp;":"");
		}else{
			perItemPrice="";
		}
		rsPerItem.close();
	if (colNum==1){
	%><tr class='<%=((rsProds.getString("property_code")==null)?"":rsProds.getString("property_code"))%>' style='display:visible' >
    <%}%>
      <td valign="top" width="50%" align="left">
      <table border="0"><tr><td colspan=2>
      <span align='left' class="catalogLABEL"><%=rsProds.getString("prod_name")%>&nbsp;-&nbsp;<%=rsProds.getString("prod_code")%><%=((rsProds.getString("property_code")==null)?"":" | For Property #"+rsProds.getString("property_code"))%></span>
        <div class="subtitle"> <%=((rsProds.getString("brand_standard")!=null && !rsProds.getString("brand_standard").equals(""))?"<em><span style='color:red'>"+rsProds.getString("brand_standard")+"</em></span><br>":"")%> <%=((rsProds.getString("headline")!=null && !rsProds.getString("headline").equals(""))?rsProds.getString("headline")+"<br>":"")%> <%=((rsProds.getString("product_features")!=null && !rsProds.getString("product_features").equals(""))?rsProds.getString("product_features")+"<br>":"")%> </div>
        <div class="bodyBlack"><%=((rsProds.getString("detailed_description")!=null)?rsProds.getString("detailed_description"):"")%></div>
        <%=((rsProds.getString("ship_policy").equals("1"))?"<div class='shipPolicy'>NOTE: Shipping included in purchase price.</div>":"")%> <%=((rsProds.getString("ship_policy").equals("2"))?"<div class='shipPolicy'>NOTE: Flat Rate shipping on this product, to be applied at invoicing.</div>":"")%><%=perItemPrice%></div>
       </td></tr><tr>
       <td valign="top" ><%=((rsProds.getString("small_picurl")==null || rsProds.getString("small_picurl").equals(""))?"":"<img  width=155 src='"+siteHostRoot+"/fileuploads/product_images/"+ str.replaceSubstring(rsProds.getString("small_picurl")," ","%20") +"' border=0>")%> </td>
          <td valign="top"><%
        //Create the pricing grid
        int y=0;
		ResultSet rsPrices = st3.executeQuery("Select format(quantity,0) as quantity,format(price,2) as price,format(price/quantity,3) as perItem  from product_prices pp,products p where pp.prod_price_code=p.prod_price_code and quantity>0 and price >.009 and p.id="+rsProds.getString("id"));
		while (rsPrices.next()){
		  if(rsPrices.getString("quantity")!=null){
			if (y==0){
				y++;
			%><table style="border: #7f8180 1px solid;" cellpadding="2" cellspacing="0">
          		<tr><td class='tableHeader'>Quantity</td><td class='tableHeader'>Price</td><td class='tableHeader'>Price Each</td></tr><%
			}
			%><tr><td class='lineitemsright'><%=rsPrices.getString("quantity")%></td><td class='lineitemsright'>$<%=rsPrices.getString("price")%></td><td class='lineitemsright'>$<%=rsPrices.getString("perItem")%></td></tr><%
		  }
		}
		if (y==0){%><table style="border: #7f8180 1px solid;" cellpadding="2" cellspacing="0">
          		<tr><td class='tableHeader'>Price Quoted at Time of Order</td></tr></table><%}else{%></table><%}
		rsPrices.close();
          %>
       </td></tr></table></td>
     <%if (colNum++==2){%></tr><%colNum=1;}
	}
	%></td>
	</tr>
   </table>
  </td>
 </tr><%
} 
%></table>
  <hr width="82%" size="1">
  <div align="center"><font size="1">Need help? We are here 9am-5pm, M-F, EST.
      Marketing Specialists<b>:</b> email <a href="mailto:marketingsvcs@marcomet.com"><u>marketingsvcs@marcomet.com</u></a> or
      leave a Voice Message Alert: at 1-888-777-9832, option 2.<br>
    To order by phone call a Customer Service Representative at 1-888-777-9832,option 3.<br>
    Technical Support? <u>techsupport@marcomet.com</u> or call 1-888-777-9832
    option 4. Comments? Please email us at <u>comments@marcomet.com</u> </font></div>
</body>
</html>
<%
	
	st.close();
	st2.close();
	st3.close();
	conn.close();%>
