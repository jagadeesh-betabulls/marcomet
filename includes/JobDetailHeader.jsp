<%@ page import="com.marcomet.users.security.*, java.util.*,java.sql.*" %>
<%@ taglib uri="/WEB-INF/tld/iterationTagLib.tld" prefix="iterate" %>
<% String prod_thumb_pre="/sitehosts/";
boolean print=((request.getParameter("print")==null || request.getParameter("print").equals("false"))?false:true);		
boolean editor= (((RoleResolver)session.getAttribute("roles")).roleCheck("editor") && !print);

String prod_thumb="";
String headerQuery = "SELECT if(thumbnail_file is not null,thumbnail_file,'') thumb,if(thumbnail_file is not null,replace(thumbnail_file,'jpg','pdf'),'') pdfPreview, concat('Site # ',con.default_site_number) as siteNumber,j.ordered_by_id,if(j.ordered_by_id=j.jbuyer_contact_id,'',concat('Ordered By: ',prxy.firstname,' ',prxy.lastname,' [',prxy.id,'] ')) as 'proxy_name',j.product_id as prodid,sh.site_host_name as sitehost_name, j.id AS job_id, ljt.value AS job_type, lst.value AS service_type, j.project_id, p.order_id AS order_id, com1.company_name AS vendor_name, com2.company_name AS customer_name, com2.id AS customer_id, DATE_FORMAT(o.date_created,'%m/%d/%y') AS order_date,concat(l.brand_name,' [', l.brand_code,']') brand,l.logo_image FROM projects p, orders o, companies com1, companies com2, lu_service_types lst, lu_job_types ljt, vendors v,site_hosts sh,jobs j left join contacts con on con.id=jbuyer_contact_id LEFT JOIN products prd on j.product_id=prd.id LEFT JOIN logos l on if(j.brand_code='DOL',j.site_number=l.property_code,prd.brand_code=l.brand_code) and prd.release=l.release_code left join contacts prxy on j.ordered_by_id=prxy.id WHERE j.jsite_host_id=sh.id AND j.project_id = p.id AND p.order_id = o.id AND v.id = j.vendor_id AND com1.id = v.company_id AND com2.id = o.buyer_company_id AND j.service_type_id = lst.id AND j.job_type_id = ljt.id AND j.id =" + request.getParameter("jobId");
   Connection conn = com.marcomet.jdbc.DBConnect.getConnection();
   Statement st = conn.createStatement();
   Statement st2 = conn.createStatement();   
   ResultSet headerRS = st.executeQuery(headerQuery); 
   request.setAttribute("headerRS", headerRS); 
   
   %>
<table border="0" cellpadding="5" cellspacing="0" width="100%">
  <tr>
    <td class="tableheader">Customer</td>
    <td class="tableheader">Vendor</td>
    <td class="tableheader">Order #</td>
    <td class="tableheader">Order Date</td>
    <td class="tableheader">Job #</td>
    <td class="tableheader">Job Description</td>
  </tr>
  <iterate:dbiterate name="headerRS" id="i">
  <tr>
    <td class="lineitems" align="center"><%=headerRS.getString("siteNumber")%><br><$ customer_name $><%=((editor)?((headerRS.getString("proxy_name")==null || headerRS.getString("proxy_name").equals(""))?"":"<br>"+headerRS.getString("proxy_name")):"")%></td>
    <td class="lineitems" align="center"><$ vendor_name $></td>
    <td class="lineitems" align="center"><$ order_id $></td>
    <td class="lineitems" align="center"><%=headerRS.getString("order_date")%></td>
    <td class="lineitems" align="center"><$ job_id $></td>
    <td class="lineitems" align="center"><%
    prod_thumb=headerRS.getString("thumb");
	prod_thumb_pre+=headerRS.getString("sitehost_name")+"/fileuploads/product_images/";
	String pQuery = "Select p.full_picurl as full_picurl,p.small_picurl as prod_thumb,j.product_id, p.prod_name, p.prod_code, ppc.unit,j.quantity from jobs j LEFT JOIN products p on p.id=j.product_id LEFT JOIN product_price_codes ppc on p.prod_price_code=ppc.prod_price_code where j.id="+ request.getParameter("jobId");
       ResultSet qtyRS = st2.executeQuery(pQuery.toString());
       while (qtyRS.next()) { 
		String preStr=((headerRS.getString("pdfPreview").equals(""))?"":"<a href='"+headerRS.getString("pdfPreview")+"' target='_blank'>");
		if (preStr.equals("")){
			preStr=( (qtyRS.getString("full_picurl")==null || qtyRS.getString("full_picurl").equals("") )?"":"<a href="+prod_thumb_pre+ qtyRS.getString("full_picurl") + " target='_blank' >" );
		}
		String postStr=((qtyRS.getString("full_picurl")==null || qtyRS.getString("full_picurl").equals(""))?"":"</a>");
					prod_thumb=((headerRS.getString("thumb").equals(""))?prod_thumb_pre+qtyRS.getString("prod_thumb"):headerRS.getString("thumb"));
					prod_thumb=((prod_thumb==null || prod_thumb.equals(""))?"":"<tr><td colspan=7>"+preStr+"<img src='"+prod_thumb+"' border=1 height='110' >"+postStr+"</td></tr>");
		   if (qtyRS.getString("j.product_id")!=null && !qtyRS.getString("j.product_id").equals("")){
		   %><%=qtyRS.getString("p.prod_code")%>: <%=qtyRS.getString("p.prod_name")%><%
		   if (qtyRS.getString("j.quantity")!=null && !qtyRS.getString("j.quantity").equals("")){
		   %>(<%if (editor){%><a href="javascript:popw('/popups/QuickChangeUpdateQuantities.jsp?jobId=<%= request.getParameter("jobId")%>', '950', '300')" class="minderACTION">&raquo;&nbsp;<%=qtyRS.getString("j.quantity")%></a><%}else{%><%=qtyRS.getString("j.quantity")%><%}%>&nbsp;<%=((qtyRS.getString("ppc.unit")!=null && !qtyRS.getString("ppc.unit").equals(""))?qtyRS.getString("ppc.unit"):"")%>)<%
		   }
			}else{
			%><$ job_type $>:<$ service_type $><%
			}
		}%></td>
  </tr><%
  	 if (headerRS.getString("logo_image")!=null && !(headerRS.getString("logo_image").equals(""))){%>
	  <tr><td class="tableheader" colspan=4 >Brand Tier</td><td class="tableheader" colspan=2>Brand Tier Logo</td></tr>
	  <tr><td class="lineitems" align="center" colspan=4><%=headerRS.getString("brand")%></td><td class="lineitems" align="center" colspan=2><img src='/sitehosts/<%=headerRS.getString("sitehost_name")+"/images/"+headerRS.getString("logo_image")%>' ></td></tr>
<%}
  if (  ((com.marcomet.users.security.RoleResolver)session.getAttribute("roles")).isVendor() || ((com.marcomet.users.security.RoleResolver)session.getAttribute("roles")).isSiteHost() ){%><%=prod_thumb%><%}%>
  </iterate:dbiterate>
</table>