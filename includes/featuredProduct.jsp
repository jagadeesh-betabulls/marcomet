<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<%@ page import="java.sql.*,com.marcomet.tools.*,com.marcomet.environment.*,com.marcomet.jdbc.*,com.marcomet.users.security.*;" %>
<jsp:useBean id="formatter" class="com.marcomet.tools.FormaterTool" scope="page" />
<jsp:useBean id="str" class="com.marcomet.tools.StringTool" scope="page" />
<link rel="stylesheet" href="<%=(String)session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css">
<table width="100%" border="0" cellspacing="0" cellpadding="0"><%
Connection conn = DBConnect.getConnection();
Statement stD = conn.createStatement();
boolean editor= ((((RoleResolver)session.getAttribute("roles")).roleCheck("editor")) && request.getParameter("editor")==null);

String ShowInactive=((request.getParameter("ShowInactive")==null || request.getParameter("ShowInactive").equals(""))?"":"&ShowInactive="+request.getParameter("ShowInactive")); 

String pageName=((request.getParameter("pageName")==null || request.getParameter("pageName").equals(""))?" AND pagename='home' ":" AND pagename= '"+request.getParameter("pageName")+"' "); 

String ShowRelease=((request.getParameter("ShowRelease")==null || request.getParameter("ShowRelease").equals(""))?"":"&ShowRelease="+request.getParameter("ShowRelease"));

String sitehostId=((SiteHostSettings)session.getAttribute("siteHostSettings")).getSiteHostId();

String sql = "SELECT  'text' as type,fp.target 'target',demo_url as backorder_notes,p.company_id, demo_url as  root_prod_code,demo_url as  variant_code,demo_url as  brand_standard,demo_url as priceper, fp.sequence, print_file_url as orderlink,p.id,p.title prod_name,demo_url as  product_features,demo_url as  prod_code,p.small_picurl,p.body summary FROM  featured_products fp,pages p  where fp.page_id=p.id and sitehost_id="+sitehostId+pageName+"  group by p.id UNION SELECT 'prod' as type, fp.target 'target', p.backorder_notes,p.company_id,p.root_prod_code,p.variant_code, lbs.presentation_language brand_standard,round(min(pp.price/pp.quantity),2) priceper,fp.sequence,p.id as orderlink,p.id,p.prod_name,p.product_features,p.prod_code,p.small_picurl, p.detailed_description summary FROM lu_brand_std_cat lbs,featured_products fp,products p left join product_prices pp on pp.prod_price_code=p.prod_price_code where fp.product_id=p.id and sitehost_id="+sitehostId+pageName+" and lbs.id=p.brand_std_cat group by p.id  ORDER BY sequence";

ResultSet rsProds = stD.executeQuery(sql);

int x=0;
int y=0;
while(rsProds.next()){
	x++;
	String orderLink="";
	String target=((rsProds.getString("target")==null)?"":rsProds.getString("target"));
	String smallPicURL="";
	String order="";
	if (rsProds.getString("type").equals("prod")){

		orderLink="\"/contents/logos.jsp?pcompanyId="+((rsProds.getString("company_id")!=null)?rsProds.getString("company_id"):"")+ShowRelease+ShowInactive+"&rootProdCode="+((rsProds.getString("root_prod_code")!=null)?rsProds.getString("root_prod_code"):"")+"&variant="+((rsProds.getString("variant_code")!=null)?rsProds.getString("variant_code"):"")+"\"";
		
	smallPicURL=((rsProds.getString("small_picurl")==null || rsProds.getString("small_picurl").equals(""))?"&nbsp;":"<a href="+orderLink+"><img src='"+(String)session.getAttribute("siteHostRoot")+"/fileuploads/product_images/"+ str.replaceSubstring(str.replaceSubstring(rsProds.getString("small_picurl"),".jpg","_TH.jpg")," ","%20") +"' border=0 style='border-color: gray'></a>");
	
		order=((orderLink.equals(""))?"":"<br><br><div align=right><a href="+orderLink+" class='menuLINK'>ORDER&nbsp;&raquo;</a></div>");
		
	}else{
		orderLink=((rsProds.getString("orderlink")==null || rsProds.getString("orderlink").equals(""))?"":"\""+rsProds.getString("orderlink")+"\"");

		smallPicURL=((rsProds.getString("small_picurl")==null || rsProds.getString("small_picurl").equals(""))?"":"<a href="+orderLink+" target='mainFr'><img src='"+(String)session.getAttribute("siteHostRoot")+"/fileuploads/product_images/"+ str.replaceSubstring(str.replaceSubstring(rsProds.getString("small_picurl"),".jpg","_TH.jpg")," ","%20") +"' border=0 style='border-color: gray'></a>");

		order=((orderLink.equals(""))?"":"<br><a href="+orderLink+" class='menuLINK' target='"+target+"'>ORDER&nbsp;&raquo;</a>");
	}
	
	String summary=((rsProds.getString("summary")!=null)?"<span class='body'>"+rsProds.getString("summary")+"</span>":"");

	String prodName="<span class='catalogLABEL'>"+rsProds.getString("prod_name")+((rsProds.getString("prod_code").equals(""))?"":"&nbsp;-&nbsp;"+rsProds.getString("prod_code"))+"</span>";

	String brandStandard=((rsProds.getString("brand_standard")!=null)?"<span class='subtitle'>"+rsProds.getString("brand_standard")+"</span><br />":"");

	String features="";
		//((rsProds.getString("product_features")!=null)?"<span class='subtitle'>"+rsProds.getString("product_features")+"</span><br />":"");
	String pricePer=((rsProds.getString("priceper")==null)?"&nbsp;":"<span class='catalogPRICE'>As low as $"+rsProds.getString("priceper")+" each.</span>");
	%><tr><td valign="top" class='borderAboveLeft<%=((y==0)?"Intro":"")%>'><img src='/images/spacer.gif' width='50'><%=smallPicURL%></td></tr><tr><td valign=top><%if (editor && rsProds.getString("type").equals("text")){%><a href='javascript:pop("/popups/QuickChangeForm.jsp?cols=60&rows=6&question=Change%20Title&primaryKeyValue=<%=rsProds.getString("id")%>&columnName=title&tableName=pages&valueType=string",500,200)'>&raquo;</a>&nbsp;<%}%><%=prodName%></td></tr>
	  <tr><td><%=brandStandard%><%=features%><%if (editor && rsProds.getString("type").equals("text")){%><a href='javascript:pop("/popups/QuickChangeForm.jsp?cols=60&rows=6&question=Change%20Text&primaryKeyValue=<%=rsProds.getString("id")%>&columnName=body&tableName=pages&valueType=string",500,200)'>&raquo;</a>&nbsp;<%}%><%=summary%><%=order%></td></tr><%
		y++;
		x=0;
}
	stD.close();
	conn.close();
%></table>