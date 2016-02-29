<%@ page import="java.sql.*,com.marcomet.tools.*,com.marcomet.environment.*,com.marcomet.users.security.*;" %>
<%@ taglib uri="/WEB-INF/tld/iterationTagLib.tld" prefix="iterate" %>
<jsp:useBean id="str" class="com.marcomet.tools.StringTool" scope="page" /><%
SiteHostSettings shs = (SiteHostSettings)session.getAttribute("siteHostSettings"); 
String stage="0";
boolean editor= ((((RoleResolver)session.getAttribute("roles")).roleCheck("editor")) && request.getParameter("editor")==null);
int continueFl=0;
String pagemid="";
String releaseStr1="";
String goToStr="";

String title=((request.getParameter("title")==null)?"Logo Choices":request.getParameter("title"));
String rootProdCodeFilter=((request.getParameter("rootProdCode")==null)?"":" and root_prod_code='"+request.getParameter("rootProdCode")+"' ");
String variantFilter=((request.getParameter("variant")==null)?"":" and variant_code='"+request.getParameter("variant")+"' ");
String prodLineId=((request.getParameter("prodLineId")==null)?"":request.getParameter("prodLineId"));
String pcompanyId=((request.getParameter("pcompanyId")==null)?shs.getSiteHostCompanyId():request.getParameter("pcompanyId"));
String ShowInactive=( ( (request.getParameter("ShowInactive")==null || request.getParameter("ShowInactive").equals("")) && !(editor) )?" AND p.status_id=2 ":((editor)?" AND (p.status_id<>3 and p.status_id<>4) ":" AND (p.status_id=2 OR p.status_id=9)") ); 
String ShowRelease=((request.getParameter("ShowRelease")==null || request.getParameter("ShowRelease").equals(""))?" AND p.release<>'' ":" AND p.release='"+request.getParameter("ShowRelease")+"' ");
String showInactiveStr=((request.getParameter("ShowInactive")==null || request.getParameter("ShowInactive").equals(""))?"":request.getParameter("ShowInactive")); 
String showReleaseStr=((request.getParameter("ShowRelease")==null || request.getParameter("ShowRelease").equals(""))?"":request.getParameter("ShowRelease"));

//Get the product release codes from all active products

int releasecount=0;

String sql = "";
if(prodLineId.equals("")){
	sql="SELECT count(distinct(pr.display_title)) releasecount FROM logos l, products p left join product_releases pr on (pr.release_code=p.release AND pr.company_id=p.company_id) where p.brand_code=l.brand_code and p.company_id=l.company_id and l.release_code=p.release and l.active=1 "+rootProdCodeFilter+variantFilter+" and p.company_id="+pcompanyId+ShowRelease+ShowInactive+" group by prod_code";
}else{
	sql="SELECT count(distinct(pr.display_title)) releasecount FROM brands b,products p,product_lines pl, logos l,product_releases pr where pl.status_id=2 and p.company_id="+pcompanyId+" AND pr.release_code=p.release AND pr.company_id=p.company_id AND ( pl.id like '"+prodLineId+"%' OR pl.top_level_prod_line_id='"+prodLineId+"') and  p.prod_line_id=pl.id and    right(pl.id,2)=b.prod_line_segment and b.company_id=p.company_id and  b.brand_code=l.brand_code and p.company_id=l.company_id and p.release=l.release_code and l.active=1  "+ShowInactive+ShowRelease+"  union SELECT count(distinct(pr.display_title)) releasecount FROM brands b,products p,product_line_bridge pl, logos l,product_releases pr where (p.company_id="+pcompanyId+" or p.company_id=1066) AND pr.company_id=left(pl.prod_line_id,4)  and b.company_id=left(pl.prod_line_id,4) and l.company_id=left(pl.prod_line_id,4) AND pr.release_code=p.release AND pl.status_id=2 and pl.prod_line_id like '"+prodLineId+"%'  and  p.id=pl.prod_id and right(pl.prod_line_id,2)=b.prod_line_segment and b.brand_code=l.brand_code and p.release=l.release_code and l.active=1  "+ShowInactive+ShowRelease+"    group by p.id";
}

//"SELECT  count(distinct(pr.display_title))  releasecount FROM products p,product_lines pl, logos l,product_releases pr where p.company_id="+pcompanyId+" AND pr.release_code=p.release AND pr.company_id=p.company_id AND (pl.id like '"+prodLineId+"%' OR pl.top_level_prod_line_id='"+prodLineId+"') and  p.prod_line_id=pl.id and  p.brand_code=l.brand_code and p.company_id=l.company_id and l.active=1  ORDER BY pr.release_date desc,l.sequence";

Connection conn = com.marcomet.jdbc.DBConnect.getConnection();
Statement st = conn.createStatement();
Statement st2 = conn.createStatement();
Statement st3 = conn.createStatement();

ResultSet rsLogoCount = st.executeQuery(sql);

while (rsLogoCount.next()){
	releasecount+=rsLogoCount.getInt("releasecount");
}

if(prodLineId.equals("")){
	sql="SELECT distinct if(pr.display_title is null,'',pr.display_title) display_title,p.release release_code,p.small_picurl, p.prod_code,p.id as pid, prod_name, offering_id, logo_image, brand_name FROM logos l,products p left join product_releases pr on (pr.release_code=p.release AND pr.company_id=p.company_id) where p.brand_code=l.brand_code and p.company_id=l.company_id and l.release_code=p.release and l.active=1 "+rootProdCodeFilter+variantFilter+" and p.company_id="+pcompanyId+ShowRelease+ShowInactive+" group by prod_code ORDER BY pr.release_date desc,l.sequence";
}else{
	sql="SELECT distinct l.sequence,if(pr.release_date is null,'',pr.release_date) release_date,pr.display_title,pr.release_code release_code,pl.id pid,logo_image, b.brand_name FROM brands b,products p,product_lines pl, logos l,product_releases pr where pl.status_id=2 and p.company_id="+pcompanyId+" AND pr.release_code=p.release AND pr.company_id=p.company_id AND ( pl.id like '"+prodLineId+"%' OR pl.top_level_prod_line_id='"+prodLineId+"') and  p.prod_line_id=pl.id and    right(pl.id,2)=b.prod_line_segment and b.company_id=p.company_id and  b.brand_code=l.brand_code and p.company_id=l.company_id and p.release=l.release_code and l.active=1  "+ShowInactive+ShowRelease+"  union SELECT distinct l.sequence,if(pr.release_date is null,'',pr.release_date) release_date, pr.display_title,pr.release_code release_code,pl.prod_line_id pid, logo_image, b.brand_name FROM brands b,products p,product_line_bridge pl, logos l,product_releases pr where (p.company_id="+pcompanyId+" or p.company_id=1066) AND pr.company_id=left(pl.prod_line_id,4)  and b.company_id=left(pl.prod_line_id,4) and l.company_id=left(pl.prod_line_id,4) AND pr.release_code=p.release AND pl.status_id=2 and pl.prod_line_id like '"+prodLineId+"%'  and  p.id=pl.prod_id and right(pl.prod_line_id,2)=b.prod_line_segment and b.brand_code=l.brand_code and p.release=l.release_code and l.active=1  "+ShowInactive+ShowRelease+"    group by pid ORDER BY release_date desc,sequence";
}
%><!--TEST
<%=sql%><%
//session.setAttribute("tempsql",sql);
%>--><%
try{
	ResultSet rsProdLogos = st.executeQuery(sql);
	String pageheader="<html><head><title>Logos Page</title><link rel='stylesheet' href='"+(String)session.getAttribute("siteHostRoot")+"/styles/vendor_styles.css' type='text/css'><script src='/javascripts/mainlib.js'></script></head><body leftmargin='50'><div align='right'><a href='javascript:history.go(-1)' class='menuLINK'>&laquo;&nbsp;BACK&nbsp;</a><br></div><table cellspacing='7' align='center' width='75%' border=0><div class='Title'>"+((editor)?"<a href='javascript:location.href=location.href + \"&editor=false\"' class=greybutton> Review Page </a>":"")+"Choose the appropriate logo to continue...<br><br></div>";
	String pLink="";
	String tget="_top";
	String releaseStr="";
	int y=0;
	int z=0;
	int plCount=0;
	String offeringId="";
	while (rsProdLogos.next()){
		plCount++;
		if(prodLineId.equals("")){
			sql="SELECT distinct if(pr.display_title is null,'',pr.display_title) display_title,p.release release_code,p.small_picurl, p.prod_code,p.id as pid, prod_name, offering_id, logo_image, brand_name FROM logos l,products p left join product_releases pr on (pr.release_code=p.release AND pr.company_id=p.company_id) where p.brand_code=l.brand_code and p.company_id=l.company_id and l.release_code=p.release and l.active=1 "+rootProdCodeFilter+variantFilter+" and p.company_id="+pcompanyId+ShowRelease+ShowInactive+" group by prod_code ORDER BY pr.release_date desc,l.sequence";
		}else{
			sql="SELECT distinct l.sequence,if(pr.release_date is null,'',pr.release_date) release_date,if(pr.display_title is null,'',pr.display_title) display_title,pr.release_code release_code,pl.id pid,logo_image, b.brand_name FROM brands b,products p,product_lines pl, logos l,product_releases pr where pl.status_id=2 and p.company_id="+pcompanyId+" AND pr.release_code=p.release AND pr.company_id=p.company_id AND ( pl.id like '"+prodLineId+"%' OR pl.top_level_prod_line_id='"+prodLineId+"') and  p.prod_line_id=pl.id and    right(pl.id,2)=b.prod_line_segment and b.company_id=p.company_id and  b.brand_code=l.brand_code and p.company_id=l.company_id and p.release=l.release_code and l.active=1  "+ShowInactive+ShowRelease+"  union SELECT distinct l.sequence,if(pr.release_date is null,'',pr.release_date) release_date, if(pr.display_title is null,'',pr.display_title) display_title,pr.release_code release_code,pl.prod_line_id pid, logo_image, b.brand_name FROM brands b,products p,product_line_bridge pl, logos l,product_releases pr where (p.company_id="+pcompanyId+" or p.company_id=1066) AND pr.company_id=left(pl.prod_line_id,4)  and b.company_id=left(pl.prod_line_id,4) and l.company_id=left(pl.prod_line_id,4) AND pr.release_code=p.release AND pl.status_id=2 and pl.prod_line_id like '"+prodLineId+"%'  and  p.id=pl.prod_id and right(pl.prod_line_id,2)=b.prod_line_segment and b.brand_code=l.brand_code and p.release=l.release_code and l.active=1  "+ShowInactive+ShowRelease+"    group by pid ORDER BY release_date desc,sequence";
		}

		continueFl=0;
		ResultSet rsLogoCountQ = st2.executeQuery(sql);
		while (rsLogoCountQ.next()){
			continueFl+=1;
		}
		stage="1";%><!--CF:<%=continueFl%>--><%
		if (!(releaseStr.equals(((rsProdLogos.getString("display_title")==null)?"":rsProdLogos.getString("display_title"))))){
			showReleaseStr=((rsProdLogos.getString("release_code")==null)?"":rsProdLogos.getString("release_code"));
			releaseStr=rsProdLogos.getString("display_title");
			releaseStr1=((z==0)?releaseStr:releaseStr1);
			y=0;
		}else{
			pagemid="";	
		}
		stage="1abb";
		if(prodLineId.equals("")){
			String sql2 = "SELECT * FROM offerings o, offering_sequences os where o.id=os.offering_id and os.sequence=0 and o.id="+(rsProdLogos.getString("offering_id"));
			ResultSet rsOfferings = st3.executeQuery(sql2);
			if(rsOfferings.next()){;
				pLink="/frames/InnerFrameset.jsp?contents=/servlet/com.marcomet.catalog.CatalogNavigationServlet?offeringId="+offeringId+"&jobTypeId="+rsOfferings.getString("job_type_id")+"&serviceTypeId="+rsOfferings.getString("service_type_id")+"&productId="+rsProdLogos.getString("pid");
				title=rsProdLogos.getString("prod_name");
				goToStr="top.";
			}else{
				pLink="/contents/items.jsp?prodLineId="+rsProdLogos.getString("pid")+"&ShowInactive="+showInactiveStr+"&ShowRelease="+showReleaseStr;
				tget="main";
				goToStr="";
			}
		}else{
			pLink="/contents/items.jsp?prodLineId="+rsProdLogos.getString("pid")+"&ShowInactive="+showInactiveStr+"&ShowRelease="+showReleaseStr;
			tget="main";
			goToStr="";
		}
		stage="1b";
		z++;
		if (continueFl<=2){
			%><script><%=goToStr%>location.href='<%=pLink%>';</script><%
		}else{
			if (z==1){
			%><%=pageheader%><%
	}
%><%=pagemid%><%

	if (y==0){
		%><%=((z>1)?"</tr></table>":"")%><tr><td valign="middle" align="center" class='TitleStr' HEIGHT='30' colspan='4'><div id="titleStr"><%=releaseStr+": "+title%></div></td></tr>
		<tr valign="middle" align="center"><td align="center"><table width=100% border=0 cellpadding=0 cellspacing=0><tr valign="middle" align="center"><%
		y++;
	}
	
%><td width=33% height='31'  valign=middle  class='logobox' onMouseOver="this.className='logoboxselected'" onMouseOut="this.className='logobox'">
<a href="<%=pLink%>" target="<%=tget%>"> <%=((rsProdLogos.getString("logo_image")==null || rsProdLogos.getString("logo_image").equals(""))?"":"<img src='"+(String)session.getAttribute("siteHostRoot")+"/images/"+ str.replaceSubstring(rsProdLogos.getString("logo_image")," "," ") +"' border='0'>")%></a>
</td><%
	}
}
stage="2";

if (plCount==0){
	%><html><head><title>Productsssss Page</title><link rel='stylesheet' href='<%=(String)session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css' type='text/css'><script src='/javascripts/mainlib.js'></script></head><body leftmargin='50' topmargin='50'><div class=title><%=title%></div><div class=subtitle>There are currently no products available for this choice.</div><br><a href='javascript:history.go(-1)' class='menuLINK'>&laquo;&nbsp;BACK&nbsp;</a> <%if(editor){%><a href='javascript:pop("/popups/QuickChangeAddProductToLine.jsp?question=Add%20Product%20To%20Line&primaryKeyValue=<%=prodLineId%>",700,150)' class=greybutton> + Add Product to this Line </a><%}%></body><%
	continueFl=2;
}
if (continueFl>1){
	%></tr></table>
<p></p><hr width="82%" size="1"><div align="center"><font size="1">Need help? We are here 9am-5pm, M-F, EST to 
  help. Marketing Specialists<b>:</b> email <a href="mailto:marketingsvcs@marcomet.com"><u>marketingsvcs@marcomet.com</u></a> 
  or leave a Voice Message Alert: at 1-888-777-9832, option 2.<br>
  To Order by Phone call a Customer Service Representative at 1-888-777-9832, 
  option 3.<br>Technical Support? <a href="mailto:techsupport@marcomet.com"><u>techsupport@marcomet.com</u></a> 
  or 1-888-777-9832 option 4 Comments? Please email us <a href="mailto:comments@marcomet.com"><u>comments@marcomet.com</u></a></font></div>
<script>
	document.getElementById('titleStr').innerHTML='<%=releaseStr1+": "+title%>';
</script><%
}
}catch (Exception e){
	%><%=e+"<br>"+stage%><%
}finally{
	conn.close();
}
%></body></html>