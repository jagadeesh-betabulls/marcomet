<%@ page import="java.sql.*,com.marcomet.users.security.*;" %>
<%@ taglib uri="/WEB-INF/tld/iterationTagLib.tld" prefix="iterate" %>
<jsp:useBean id="connection" class="com.marcomet.jdbc.ConnectionBean" scope="session" />
<%String prod_thumb_pre="/sitehosts/";
boolean print=((request.getParameter("print")==null || request.getParameter("print").equals("false"))?false:true);
boolean editor= (((RoleResolver)session.getAttribute("roles")).roleCheck("editor") && !print);
String prod_thumb="";
boolean showImages = ((request.getParameter("showImages")!=null && request.getParameter("showImages").equals("false"))?false:true);
String headerQuery = "SELECT v2.order_method as order_method,v2.terms as terms,sh.site_host_name as sitehost_name, j.product_id, j.quantity as quantity, w.warehouse_name as 'warehouse_name',prd.default_warehouse_id as 'warehouse_id', prd.prod_name as product_name, if(ppc.unit!='',ppc.unit,' ') as unit, j.id AS job_id, ljt.value AS job_type, lst.value AS service_type, j.project_id, p.order_id AS order_id, com1.company_name AS vendor_name, com2.company_name AS customer_name, com2.id AS customer_id, com3.company_name AS subvendor_name, v2.id as subvendor_id, DATE_FORMAT(o.date_created,'%m/%d/%y') AS order_date,concat(l.brand_name,' [', l.brand_code,']') brand,l.logo_image  FROM site_hosts sh,projects p, orders o, companies com1, companies com2, companies com3, lu_service_types lst, lu_job_types ljt, vendors v, vendors v2,jobs j LEFT JOIN products prd on j.product_id=prd.id LEFT JOIN logos l on prd.brand_code=l.brand_code and prd.release=l.release_code LEFT JOIN warehouses w on prd.default_warehouse_id=w.id LEFT JOIN product_price_codes ppc on ppc.prod_price_code=prd.prod_price_code WHERE  j.jsite_host_id=sh.id AND j.project_id = p.id AND p.order_id = o.id AND v.id = j.vendor_id AND com1.id = v.company_id AND com2.id = o.buyer_company_id AND v2.id = j.dropship_vendor AND com3.id = v2.company_id AND j.service_type_id = lst.id AND j.job_type_id = ljt.id AND j.id = " + request.getParameter("jobId");
Connection conn = com.marcomet.jdbc.DBConnect.getConnection();
Statement st = conn.createStatement();
Statement st1 = conn.createStatement();
ResultSet headerRS = st.executeQuery(headerQuery); 
   request.setAttribute("headerRS", headerRS); %>
<iterate:dbiterate name="headerRS" id="i">
<table border="0" cellpadding="5" cellspacing="0" width="100%">
  <tr>
    <td class="tableheader">Purchased by:</td>
    <td class="tableheader">On behalf of its Client:</td>
	<td class="tableheader">From Supplier:</td>
	<td class="tableheader">Ship from Warehouse</td>
    <td class="tableheader">Order Date:</td>
    <td class="tableheader">Purchasor Job #:</td>
    <td class="tableheader">Purchasor PO #:</td>
  </tr>
  <tr>
    <td class="lineitems" align="center"><$ vendor_name $></td>
    <td class="lineitems" align="center"><$ customer_name $></td>
	<td class="lineitems" align="center"><%if (editor){%><a href='javascript:popw("/popups/QuickChangeUpdateVendor.jsp?jobId=<%=request.getParameter("jobId")%>&vid=<$ subvendor_id $>",300,150)' class=offeringITEM>&raquo;</a><%}%><$ subvendor_id $> - <$ subvendor_name $></td>
    <td class="lineitems"><$ warehouse_name $></td>
    <td class="lineitems" align="center"><%=headerRS.getString("order_date")%></td>

    <td class="lineitems" align="center"><$ job_id $></td>
    <td class="lineitems" align="center">DS-<$ job_id $></td>
  </tr>
</table>
<table border="0" cellpadding="5" cellspacing="0" width="100%">
 <tr>
    <td class="tableheader" colspan=2>Job Description </td>
 </tr>
  <tr>
    <td class="lineitems" align="center" colspan=2><%
	prod_thumb_pre+=headerRS.getString("sitehost_name")+"/fileuploads/product_images/";
	String pQuery = "Select p.full_picurl as full_picurl,p.small_picurl as prod_thumb,j.product_id, p.prod_name, p.prod_code, ppc.unit,j.quantity from jobs j LEFT JOIN products p on p.id=j.product_id LEFT JOIN product_price_codes ppc on p.prod_price_code=ppc.prod_price_code where j.id="+ request.getParameter("jobId");
       ResultSet qtyRS = st1.executeQuery(pQuery.toString());
       while (qtyRS.next()) { 
	String preStr=( (qtyRS.getString("full_picurl")==null || qtyRS.getString("full_picurl").equals("") )?"":"<a href="+prod_thumb_pre+ qtyRS.getString("full_picurl") + " >" );
	String postStr=((qtyRS.getString("full_picurl")==null || qtyRS.getString("full_picurl").equals(""))?"":"</a>");
				prod_thumb=((qtyRS.getString("prod_thumb")==null || qtyRS.getString("prod_thumb").equals(""))?"":"<tr><td colspan=7>"+preStr+"<img src='"+prod_thumb_pre+qtyRS.getString("prod_thumb")+"' border=1  height='110'>"+postStr+"</td></tr>");
		   if (qtyRS.getString("j.product_id")!=null && !qtyRS.getString("j.product_id").equals("")){
		   %><%=qtyRS.getString("p.prod_code")%>: <%=qtyRS.getString("p.prod_name")%><%
		   if (qtyRS.getString("j.quantity")!=null && !qtyRS.getString("j.quantity").equals("")){
		   %>(<%=qtyRS.getString("j.quantity")%>&nbsp;<%=((qtyRS.getString("ppc.unit")!=null && !qtyRS.getString("ppc.unit").equals(""))?qtyRS.getString("ppc.unit"):"")%>)<%
		   }
			}else{
			%><$ job_type $>:<$ service_type $><%
			}
		}%></td>
  </tr><%if (editor){
	%><tr><td class="tableheader" width=20% >Terms</td><td class="tableheader" width=80%>Order &amp; Fulfillment Process</td></tr>
	  <tr><td class="lineitems" align="center" ><$ terms $></td><td class="lineitems" align="center" ><$ order_method $></td></tr><%}
if (showImages){	  
	 if (headerRS.getString("logo_image")!=null){%>
	  <tr><td class="tableheader" width=20% >Brand Tier</td><td class="tableheader" width=80%>Brand Tier Logo</td></tr>
	  <tr><td class="lineitems" align="center" ><%=headerRS.getString("brand")%></td><td class="lineitems" align="center" ><img src='/sitehosts/<%=headerRS.getString("sitehost_name")+"/images/"+headerRS.getString("logo_image")%>' height='50'></td></tr>
<%}%></table><%=prod_thumb%><%}%>
</iterate:dbiterate>
