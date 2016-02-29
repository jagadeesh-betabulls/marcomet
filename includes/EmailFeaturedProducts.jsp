<%@ page errorPage="/errors/ExceptionPage.jsp" %><%@ page import="java.sql.*,com.marcomet.tools.*,com.marcomet.environment.*;" %>
<jsp:useBean id="formatter" class="com.marcomet.tools.FormaterTool" scope="page" /><jsp:useBean id="str" class="com.marcomet.tools.StringTool" scope="page" /><%
String sitehostId=((request.getParameter("siteHostId")==null || request.getParameter("siteHostId").equals(""))?"":request.getParameter("siteHostId"));
String pageName=((request.getParameter("pageName")==null || request.getParameter("pageName").equals(""))?"":request.getParameter("pageName"));
String domainName=((request.getParameter("domainName")==null || request.getParameter("domainName").equals(""))?"":request.getParameter("domainName"));
String title=((request.getParameter("title")==null || request.getParameter("title").equals(""))?"":request.getParameter("title"));
String description=((request.getParameter("summary")==null || request.getParameter("summary").equals(""))?"":request.getParameter("summary"));

String siteHostName=((request.getParameter("siteHostName")==null || request.getParameter("siteHostName").equals(""))?"":request.getParameter("siteHostName"));%><link rel="stylesheet" href="<%=domainName%>/sitehosts/<%=siteHostName%>/styles/vendor_styles.css" type="text/css"><p class='title'><%=title%></p><p class='subtitle'><%=description%></p><table width="98%" border="0" cellspacing="0" cellpadding="0"><%
String sql = "SELECT  demo_url as variant_code,'00000000' as releaseCode,'text' as type,demo_url as backorder_notes,p.company_id, demo_url as  root_prod_code,demo_url as  brand_standard,demo_url as priceper, fp.sequence, print_file_url as orderlink,p.id,p.title prod_name,demo_url as  product_features,demo_url as  prod_code,p.small_picurl,p.body summary FROM  email_featured_products fp,pages p  where fp.page_id=p.id and sitehost_id="+sitehostId+" and pagename='"+pageName+"'  group by p.id UNION SELECT p.variant_code as 'variant_code',p.release as releaseCode,'prod' as type, p.backorder_notes,p.company_id,p.root_prod_code, lbs.presentation_language brand_standard,round(min(pp.price/pp.quantity),2) priceper,fp.sequence,p.id as orderlink,p.id,p.prod_name,p.product_features,p.prod_code,p.small_picurl,p.detailed_description summary FROM lu_brand_std_cat lbs,email_featured_products fp,products p left join product_prices pp on pp.prod_price_code=p.prod_price_code where fp.product_id=p.id and sitehost_id="+sitehostId+" and pagename='"+pageName+"' and lbs.id=p.brand_std_cat group by p.id  ORDER BY sequence";
Connection conn = com.marcomet.jdbc.DBConnect.getConnection();
Statement st = conn.createStatement();
ResultSet rsProds = st.executeQuery(sql);
int x=0;
int y=0;
while(rsProds.next()){
	x++;
	String orderLink="";
	String smallPicURL="";
	String order="";
	String pricePer=((rsProds.getString("priceper")==null)?"&nbsp;Price based on specifications.":"<span class='catalogPRICE'>As low as $"+rsProds.getString("priceper")+" each.</span>");
	if (rsProds.getString("type").equals("prod")){
	orderLink="\""+domainName+"/index.jsp?contents=/contents/logos.jsp|"+((rsProds.getString("releaseCode")!=null && !(rsProds.getString("releaseCode").equals("")))?"ShowRelease="+rsProds.getString("releaseCode")+"~":"")+"rootProdCode="+((rsProds.getString("root_prod_code")!=null)?rsProds.getString("root_prod_code"):"")+((rsProds.getString("variant_code")!=null)?"~variant="+rsProds.getString("variant_code"):"")+"\"";
	smallPicURL=((rsProds.getString("small_picurl")==null || rsProds.getString("small_picurl").equals(""))?"&nbsp;":"<a href="+orderLink+"><img src='"+domainName+"/sitehosts/"+siteHostName+"/fileuploads/product_images/"+ str.replaceSubstring(str.replaceSubstring(rsProds.getString("small_picurl"),".jpg",".jpg")," ","%20") +"' border=1 style='border-color: gray'></a>");
		order=((orderLink.equals(""))?"":"<br><div class=catalogLABEL>"+pricePer+"</div><br><a href="+orderLink+" class='menuLINK'>ORDER&nbsp;&raquo;</a>");
}else{
	orderLink=((rsProds.getString("orderlink")==null || rsProds.getString("orderlink").equals(""))?"":"\""+rsProds.getString("orderlink")+"\"");
	smallPicURL=((rsProds.getString("small_picurl")==null || rsProds.getString("small_picurl").equals(""))?"":"<a href="+orderLink+" target='mainFr'><img src='"+domainName+"/sitehosts/"+siteHostName+"/fileuploads/product_images/"+ str.replaceSubstring(str.replaceSubstring(rsProds.getString("small_picurl"),".jpg",".jpg")," ","%20") +"' border=1 style='border-color: gray'></a>");
	order=((orderLink.equals(""))?"":"<br><div class=catalogLABEL>"+pricePer+"</div><br><a href="+orderLink+" class='menuLINK' target='mainFr'>ORDER&nbsp;&raquo;</a>");
	}
	String summary=((rsProds.getString("summary")!=null)?"<span class='body'>"+rsProds.getString("summary")+"</span>":"");
	String prodName="<span class='catalogLABEL'>"+rsProds.getString("prod_name")+((rsProds.getString("prod_code").equals(""))?"":"&nbsp;-&nbsp;"+rsProds.getString("prod_code"))+"</span><br />";
	String brandStandard=((rsProds.getString("brand_standard")!=null)?"<span class='subtitle'>"+rsProds.getString("brand_standard")+"</span><br />":"");
	String features="";
		//((rsProds.getString("product_features")!=null)?"<span class='subtitle'>"+rsProds.getString("product_features")+"</span><br />":"");
	if (x==1){
	%><tr><td width="49%" class='borderAboveLeft<%=((y==0)?"Intro":"")%>'><table width="100%" border="0" cellspacing="0" cellpadding="0"><tr><td width="99%" valign="top"><%=prodName%><%=brandStandard%><%=features%><%=summary%><%=order%></td><td width="1%" rowspan="2" valign="top"><img name="" src="" width="8px" height="1" alt="" /></td><td rowspan="2" width="1%" valign="top"><%=smallPicURL%></td></tr></table></td><%
		y++;
	}else if(x==2){
	%><td width="2%" >&nbsp;</td>
    <td width="49%"  class='borderAboveRight'><table width="100%" border="0" cellspacing="0" cellpadding="0" height="100%"><tr><td width="99%" valign="top"><%=prodName%><%=brandStandard%><%=features%><%=summary%><%=order%></td><td width="1%" rowspan="2" valign="top"><img name="" src="" width="8px" height="1" alt="" /></td><td rowspan="2" width="1%"  valign="top"><%=smallPicURL%></td></tr></table></td></tr><%
		} else if (x==3){
		%><tr><td width="49%"  class='borderAboveRight'><table width="100%" border="0" cellspacing="0" cellpadding="0"><tr><td rowspan="2" width="1%"  valign="top" ><%=smallPicURL%></td>
		        <td width="1%" rowspan="2" valign="top"><img name="" src="" width="8px" height="1" alt="" /></td><td width="99%" valign="top"><%=prodName%><%=brandStandard%><%=features%><%=summary%><%=order%></td></tr></table></td><%
		}else if (x==4){
			%><td width="2%" >&nbsp;</td>
		    <td width="48%" class='borderAboveLeft'><table width="100%" border="0" cellspacing="0" cellpadding="0" height="100%"><tr><td rowspan="2" width="1%" valign="top"><%=smallPicURL%></td>
			        <td width="1%" rowspan="2" valign="top"><img name="" src="" width="8px" height="1" alt="" /></td>
			        <td width="99%" valign="top"><%=prodName%><%=brandStandard%><%=features%><%=summary%><%=order%></td></tr></table></td></tr><%
			x=0;
		}
}
if (x==1 || x==3){
	%><td width="2%" >&nbsp;</td><td width="49%" class='borderAboveLeft'><table width="100%" border="0" cellspacing="0" cellpadding="0" height="100%"><tr><td rowspan="2" width="1%">&nbsp;</td><td width="1%" rowspan="2" valign="top"><img name="" src="" width="8px" height="1" alt="" /></td><td width="99%" valign="top">&nbsp;</td></tr><tr><td valign="bottom">&nbsp;</td></tr></table></td></tr><%
}
%></table>