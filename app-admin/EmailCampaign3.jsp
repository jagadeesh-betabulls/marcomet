<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<%@ include file="/includes/SessionChecker.jsp" %>
<%@ page import="java.sql.*,java.util.*,com.marcomet.users.security.*, com.marcomet.jdbc.*, com.marcomet.environment.*;" %>
<%@ taglib uri="/WEB-INF/tld/taglib.tld" prefix="taglib" %>

<%

Connection conn = DBConnect.getConnection();
int step=((request.getParameter("step")==null)?0:Integer.parseInt(request.getParameter("step")));

String numProds = ( (request.getParameter("numProds")==null)?"":request.getParameter("numProds")); 	
String title = ( (request.getParameter("title")==null)?"":request.getParameter("title")); 
String brand_id = ( (request.getParameter("brand_id")==null)?"":request.getParameter("brand_id")); 
String site_host_name = ( (request.getParameter("site_host_name")==null)?"":request.getParameter("site_host_name")); 
String submitter_id = ( (request.getParameter("submitter_id")==null)?"":request.getParameter("submitter_id")); 
String date_created = ( (request.getParameter("date_created")==null)?"":request.getParameter("date_created")); 
String date_to_send = ( (request.getParameter("date_to_send")==null)?"":request.getParameter("date_to_send")); 
String summary = ( (request.getParameter("summary")==null)?"":request.getParameter("summary")); 
String plain_text = ( (request.getParameter("plain_text")==null)?"":request.getParameter("plain_text")); 
String html = ( (request.getParameter("html")==null)?"":request.getParameter("html")); 
String stylesheet1_url = ( (request.getParameter("stylesheet1_url")==null)?"":request.getParameter("stylesheet1_url")); 
String stylesheet2_url = ( (request.getParameter("stylesheet2_url")==null)?"":request.getParameter("stylesheet2_url")); 
String thumbnail_url = ( (request.getParameter("thumbnail_url")==null)?"":request.getParameter("thumbnail_url")); 
String status_id = ( (request.getParameter("status_id")==null)?"1":request.getParameter("status_id")); 
String domain_name = ( (request.getParameter("domain_name")==null)?"":request.getParameter("domain_name")); 
String campaignId = ( (request.getParameter("domain_name")==null)?"":request.getParameter("domain_name")); 

String sql="select b.id,b.brand_name,concat('/sitehosts/',sh.site_host_name,'/images/',l.logo_image) logo,sh.site_host_name,sh.domain_name from brands b left join logos l on b.brand_code=l.brand_code left join site_hosts sh on b.company_id=sh.company_id where b.active=1 group by b.brand_code order by b.brand_code";
String slBrands="<select name='brandChoice' onChange='popfields(this)'><option value='0'>--Choose Brand</option>";
Statement st = conn.createStatement();
ResultSet rs = st.executeQuery(sql);
while (rs.next()){
	slBrands+="<option value='"+rs.getString("b.id")+"|"+rs.getString("logo")+"|"+rs.getString("sh.site_host_name")+"|"+rs.getString("sh.domain_name")+"'>"+rs.getString("b.brand_name")+"</option>";
}
slBrands+="</select>";

if (step==2){
	sql="select max(id) from email_campaigns";
	rs = st.executeQuery(sql);
	if (rs.next()){
		campaignId=rs.getString(1);
	}

	sql="insert into email_campaigns (id,title,misc_keywords,brand_id,submitter_id,date_created,date_to_send,summary,plain_text,html,stylesheet1_url,stylesheet2_url,thumbnail_url,status_id,site_host_name) values (?,?,?,?,?,Now(),?,?,?,?,?,?,?,?,?)";
	int x=0;
		PreparedStatement campaign = conn.prepareStatement(sql);
		campaign.clearParameters();
		campaign.setString(x++, campaignId);
		campaign.setString(x++, title);
		campaign.setString(x++, "");
		campaign.setString(x++, brand_id);
		campaign.setString(x++, submitter_id);
		campaign.setString(x++, date_to_send);
		campaign.setString(x++, summary);
		campaign.setString(x++, plain_text);
		campaign.setString(x++, html);
		campaign.setString(x++, stylesheet1_url);
		campaign.setString(x++, stylesheet1_url);
		campaign.setString(x++, thumbnail_url);
		campaign.setString(x++, status_id);
		campaign.setString(x++, site_host_name);
		campaign.execute();
		campaign.close();
}else if (step==3){
	//Add to 'featured products' table, pagename as campaign page id
	//Send to 'Edit Presentation' page
}else if (step==4){
	//Save HTML in HTML field
	//Convert HTML to plain text, save in Body field
	//Present in 'Summary Page' with HTML in one text field, Plain Text in another
}%><html>
<head>
<title>Create Email Blast Campaign</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link rel="stylesheet" href="<%=(String)session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css">
</head>
<script src="/javascripts/mainlib.js"></script>
<script>
	function popfields(choice){
		if (choice.value<>'0'){
			var el=choice.value;
			var fm=document.forms[0];
			var elA=el.split("|");
			rs.getString("b.id")+"|"+rs.getString("logo")+"|"+rs.getString("sh.site_host_name")+"|"+rs.getString("sh.domain_name")
			fm.brand_id.value=elA[0];
			fm.thumbnail_url.value=elA[1];
			fm.site_host_name.value=elA[2];
			fm.domain_name.value=elA[3];
		}
	}
</script>
<body text="#000000" onLoad="MM_preloadImages('/images/buttons/submitover.gif')" leftmargin="10" topmargin="10">
<form method="post" action="/app-admin/EmailCampaign3.jsp">
  <p class="MainTitle">Marcomet Admin</p>
  <p class="Title">Edit Email Campaign Step <%=step%></p>

<table cellpadding=0 cellspacing=0 border=0>
<tr><td class="minderheader" colspan=2>Title for Campaign / Description</td>
<tr><td class=lineitem valign='top' colspan=2><input type='text' name='title' value='<%=title%>' size=73>
<br><textarea name='summary' cols=70 rows=4><%=summary%></textarea></td></tr>

<tr><td class="minderheader">Target Date for Sending Mail</td>
	<td class="minderheader">Brand for Campaign</td></tr>
	<tr><td class=lineitem><input type='text' name='date_to_send' value='<%=date_to_send%>'>(format yyyy-mm-dd)</td>
	<td class=lineitem><%=slBrands%></td></tr>
</table>
  <br><br>
<input type='hidden' name='step' value='<%=step++%>'>
<input type='hidden' name='campaignId' value='<%=campaignId%>'>
<input type='hidden' name='numProds' value='<%=numProds%>'>
<input type='hidden' name='domain_name' value='<%=domain_name%>'>
<input type='hidden' name='brand_id' value='<%=brand_id%>'>
<input type='hidden' name='site_host_name' value='<%=site_host_name%>'>
<input type='hidden' name='thumbnail_url' value='<%=thumbnail_url%>'>
<input type='hidden' name='stylesheet1_url' value='<%=stylesheet1_url%>'>
<input type='hidden' name='stylesheet2_url' value='<%=stylesheet2_url%>'>
<div align='center'><input type="button" name="Cancel" value="Cancel" onClick="window.history.back()"> <input type="submit" name="Submit" value=" Next >> "></div>
</form>
</body>
</html><%		
st.close();
conn.close();%>
