<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<%@ page import="java.sql.*,com.marcomet.tools.*,com.marcomet.environment.*;" %>
<%@ taglib uri="/WEB-INF/tld/iterationTagLib.tld" prefix="iterate" %>

<jsp:useBean id="connection" class="com.marcomet.jdbc.ConnectionBean" scope="session" />
<jsp:useBean id="formatter" class="com.marcomet.tools.FormaterTool" scope="page" />
<jsp:useBean id="str" class="com.marcomet.tools.StringTool" scope="page" />

<% SiteHostSettings shs = (SiteHostSettings)session.getAttribute("siteHostSettings"); %>

<script language="JavaScript" src="/javascripts/mainlib.js"></script>

<% String ShowInactive=((request.getParameter("ShowInactive")==null)?"":request.getParameter("ShowInactive")); %>
<% String ShowRelease=((request.getParameter("ShowRelease")==null)?"":request.getParameter("ShowRelease")); %>
<% String sql = ""; %>
<% String sql2 = ""; %>

<html>
<head>
<title>Cataloged Items Page</title>
<link rel="stylesheet" href="<%=(String)session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css">
</head>
<body topmargin="0">

<% if (ShowInactive.equals("Y") && !ShowRelease.equals("")) { 
sql = "SELECT * FROM product_lines pl, products prd, site_hosts sh WHERE prd.release='"+ShowRelease+"' AND sh.id= " + shs.getSiteHostId() + " AND sh.company_id=pl.company_id AND pl.id = prd.prod_line_id GROUP BY pl.id ORDER BY pl.id";

 } else if (ShowInactive.equals("Y") && ShowRelease.equals("")) {
sql = "SELECT * FROM product_lines pl, products prd, site_hosts sh WHERE sh.id= " + shs.getSiteHostId() + " AND sh.company_id=pl.company_id AND pl.id = prd.prod_line_id GROUP BY pl.id ORDER BY pl.id";

 } else if (!ShowRelease.equals("")) { 
 
sql = "SELECT * FROM product_lines pl, products prd, site_hosts sh WHERE prd.release='"+ShowRelease+"' AND sh.id = " + shs.getSiteHostId() + " AND sh.company_id=pl.company_id AND pl.id = prd.prod_line_id AND prd.status_id=2 GROUP BY pl.id ORDER BY pl.id";

 } else { 

sql = "SELECT * FROM product_lines pl, products prd, site_hosts sh WHERE sh.id= " + shs.getSiteHostId() + " AND sh.company_id=pl.company_id AND pl.id = prd.prod_line_id AND prd.status_id=2 GROUP BY pl.id ORDER BY pl.id";
 } %>

<% Connection conn = com.marcomet.jdbc.DBConnect.getConnection();
Statement st = conn.createStatement();
Statement st2 = conn.createStatement();
ResultSet rsProdLine = st.executeQuery(sql); %>

<% while(rsProdLine.next()){
 if (ShowInactive.equals("Y") && !ShowRelease.equals("")) { 
	sql2 = "SELECT * FROM products where release='"+ShowRelease+"' AND prod_line_id=" + rsProdLine.getInt("pl.id") + " ORDER BY sequence";
 } else if (ShowInactive.equals("Y") && ShowRelease.equals("")) {
	sql2 = "SELECT * FROM products where prod_line_id=" + rsProdLine.getInt("pl.id") + " ORDER BY sequence";
 } else if (!ShowRelease.equals("")) { 
	sql2 = "SELECT * FROM products where release='"+ShowRelease+"' AND status_id=2 and prod_line_id=" + rsProdLine.getInt("pl.id") + " ORDER BY sequence";
 } else { 
	sql2 = "SELECT * FROM products where status_id=2 and prod_line_id=" + rsProdLine.getInt("pl.id") + " ORDER BY sequence";
} 
ResultSet rsProds = st2.executeQuery(sql2); 
%><table width="95%" border="0" cellspacing="0" cellpadding="0" align="center" dwcopytype="CopyTableRow">
  <tr> 
    <td width="61%" height="35" valign="middle"> 
      <p class="subtitle" align="left"><font size="4"><%=rsProdLine.getString("prod_line_name")%>&nbsp; 
        ( &nbsp;<%=rsProdLine.getString("pl.id")%> &nbsp; : &nbsp; <%=rsProdLine.getString("pl.status_id")%> ) </font></p>
    </td>
   <td height="35" colspan="2" width="39%" valign="middle"> 
      <div align="right"><a href="javascript:window.history.back()" class="minderACTION">[Back]</a> 
        <a href="mailto:marketingservices@marcomet.com" class="minderACTION">[email Support]</a></div>
    </td>
  </tr></table>
<table width="95%" cellspacing="0" cellpadding="0" height="40" align="center">
  <tr> 
    <td class="body" height="17"><%=((rsProdLine.getString("description")==null || rsProdLine.getString("description").equals(""))?"":rsProdLine.getString("description"))%></td>
  </tr>
  <tr> 
    <td class="body" height="7"><%=((rsProdLine.getString("usp")==null || rsProdLine.getString("usp").equals(""))?"":rsProdLine.getString("usp"))%></td>
  </tr>
</table>
<table border=1 cellpadding=1 cellspacing=1 width=90% align="center">
  <tr> 
    <td valign="top" colspan="4" class="footer" height="30"> 
      <div align="left">&nbsp;&nbsp;<font size="4"><b><%=rsProdLine.getString("mainfeatures")%></b></font></div>
    </td>
  </tr>
  <% while (rsProds.next()){ %>
  <tr background="<%=(String)session.getAttribute("siteHostRoot")%>/images/back3.jpg"> 

    <td valign="top" width=3% rowspan="2"> <a href="javascript:pop('<%=((rsProds.getString("full_picurl")==null || rsProds.getString("full_picurl").equals(""))?"":""+(String)session.getAttribute("siteHostRoot")+"/fileuploads/product_images/"+ str.replaceSubstring(rsProds.getString("full_picurl")," ","%20") +"'")%>,'800','600')" ><%=((rsProds.getString("small_picurl")==null || rsProds.getString("small_picurl").equals(""))?"":"<img src='"+(String)session.getAttribute("siteHostRoot")+"/fileuploads/product_images/"+ str.replaceSubstring(rsProds.getString("small_picurl")," ","%20") +"'>")%></a></td>

    <td valign="middle" width=15% class="minderACTION" align="center" > <a href="javascript:pop('<%=((rsProds.getString("full_picurl")==null || rsProds.getString("full_picurl").equals(""))?"":""+(String)session.getAttribute("siteHostRoot")+"/fileuploads/product_images/"+ str.replaceSubstring(rsProds.getString("full_picurl")," ","%20") +"'")%>,'800','600')" ><%=((rsProds.getString("small_picurl")==null || rsProds.getString("small_picurl").equals(""))?"":"Enlarge<br>Image")%></a></td>

    <td valign="middle" width="73%" align="left" rowspan="2"> 
      <!-- TO DO -- SUPPRESS THIS LINK IF NO LINK EXISTS -->
      <!-- TO DO -- MAKE SITEHOST LINK VARIABLE -->
      <%String sql3 = "SELECT * FROM offerings o, offering_sequences os where o.id=os.offering_id and os.sequence=0 and o.id="+(rsProds.getString("offering_id"));
ResultSet rsOfferings = st2.executeQuery(sql3);
%>     <div align="center"> 
        <p> <span class="catalogLABEL"><%=rsProds.getString("prod_name")%></span>&nbsp;-&nbsp;<span class="catalogLABEL"><%=rsProds.getString("prod_code")%>&nbsp; ( &nbsp;<%=rsProds.getString("id")%>&nbsp; : &nbsp;<%=rsProds.getString("status_id")%> ) </span><br>
          <span class="bodyBlack"><%=(rsProds.getString("headline")!=null)?(rsProds.getString("headline")+"<br>"):("")%></span>
          <span class="bodyBlack"><%=(rsProds.getString("product_features")!=null)?(rsProds.getString("product_features")+"<br>"):("")%></span>
          <span class="bodyBlack"><%=(rsProds.getString("summary")!=null)?(rsProds.getString("summary")):("")%><br></span></p>
          <span class="bodyBlack"><%=(rsProds.getString("detailed_description")!=null)?(rsProds.getString("detailed_description")):("")%></span>
      </div>
    </td>
    <td width="15%"> 
      <div align="center"><!--<a href="javascript:pop('/images/pricing/<%=rsProds.getString("price_list")%>','450','750')" class="minderACTION"><u>Price 
        List</u></a>--><font class="minderACTION"><%=(rsProds.getString("price_list")!=null)?(rsProds.getString("price_list")):("")%></font></div>
    </td>
  </tr>
  <tr background="<%=(String)session.getAttribute("siteHostRoot")%>/images/back3.jpg">
    <td valign="middle" width=15% class="minderACTION" align="center" > <a href="javascript:pop('<%=((rsProds.getString("spec_diagram_picurl")==null || rsProds.getString("spec_diagram_picurl").equals(""))?"":""+(String)session.getAttribute("siteHostRoot")+"/fileuploads/product_images/"+ str.replaceSubstring(rsProds.getString("spec_diagram_picurl")," ","%20") +"'")%>,'800','600')" ><%=((rsProds.getString("spec_diagram_picurl")==null || rsProds.getString("spec_diagram_picurl").equals(""))?"":"View<br>Back")%></a></td>
    <td valign="middle" width="15%" class="offeringITEM" align="left"> 
      <div align="center"><a href="/frames/InnerFrameset.jsp?contents=/servlet/com.marcomet.catalog.CatalogNavigationServlet?offeringId=<%=rsProds.getString("offering_id")%>&jobTypeId=<%=rsOfferings.getString("job_type_id")%>&serviceTypeId=<%=rsOfferings.getString("service_type_id")%>&productId=<%=rsProds.getString("id")%>" target="_top" class="menuLINK">Continue</a></div>
    </td>
  </tr><%
  } 
  %></table>
<hr>
<% } %>

<hr width="82%" size="1">
<div align="center"><font size="1">Need help? We are here 9am-5pm, M-F, EST to 
  help. Marketing Specialists<b>:</b> email <a href="mailto:marketingsvcs@marcomet.com"><u>marketingsvcs@marcomet.com</u></a> 
  or leave a Voice Message Alert: at 1-888-777-9832, option 2.<br>
  To Order by Phone call a Customer Service Representative at 1-888-777-9832, 
  option 3.<br>
  Technical Support? <a href="mailto:techsupport@marcomet.com"><u>techsupport@marcomet.com</u></a> 
  or 1-888-777-9832 option 4 Comments? Please e-mail us <a href="mailto:comments@marcomet.com"><u>comments@marcomet.com</u></a></font></div>

</body>

</html><%conn.close();%>