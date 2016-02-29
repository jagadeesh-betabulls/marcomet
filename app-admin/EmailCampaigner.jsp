<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<%@ page import="java.sql.*,java.util.*,com.marcomet.users.security.*, com.marcomet.jdbc.*, com.marcomet.environment.*;" %>
<%@ taglib uri="/WEB-INF/tld/taglib.tld" prefix="taglib" %>

<%
Connection conn = DBConnect.getConnection();
int step=((request.getParameter("step")==null)?1:Integer.parseInt(request.getParameter("step")));
int campaignId=((request.getParameter("campaignId")==null || request.getParameter("campaignId").equals(""))?0:Integer.parseInt(request.getParameter("campaignId")));
int i=0;

String numProds = ( (request.getParameter("numProds")==null)?"0":request.getParameter("numProds")); 	
String title = ( (request.getParameter("title")==null)?"":request.getParameter("title")); 
String brand_id = ( (request.getParameter("brand_id")==null)?"":request.getParameter("brand_id")); 
String brandCode = ( (request.getParameter("brandCode")==null)?"":request.getParameter("brandCode")); 
String propertyCode = ( (request.getParameter("propertyCode")==null)?"":request.getParameter("propertyCode")); 
String brandChoice = ( (request.getParameter("brandChoice")==null)?"":request.getParameter("brandChoice")); 
String site_host_name = ( (request.getParameter("site_host_name")==null)?"":request.getParameter("site_host_name")); 
String submitter_id = ( (request.getParameter("submitter_id")==null)?"":request.getParameter("submitter_id")); 
String date_created = ( (request.getParameter("date_created")==null)?"":request.getParameter("date_created")); 
String date_to_send = ( (request.getParameter("date_to_send")==null)?"":request.getParameter("date_to_send")); 
String summary = ( (request.getParameter("summary")==null)?"":request.getParameter("summary")); 
String plain_text = ( (request.getParameter("plain_text")==null)?"":request.getParameter("plain_text")); 
String html = ( (request.getParameter("html_area")==null)?"":request.getParameter("html_area")); 
String stylesheet1_url = ( (request.getParameter("stylesheet1_url")==null)?"":request.getParameter("stylesheet1_url")); 
String stylesheet2_url = ( (request.getParameter("stylesheet2_url")==null)?"":request.getParameter("stylesheet2_url")); 
String thumbnail_url = ( (request.getParameter("thumbnail_url")==null)?"":request.getParameter("thumbnail_url")); 
String status_id = ( (request.getParameter("status_id")==null)?"1":request.getParameter("status_id")); 
String domain_name = ( (request.getParameter("domain_name")==null)?"":request.getParameter("domain_name")); 
String companyId = ( (request.getParameter("companyId")==null)?"":request.getParameter("companyId")); 
String siteHostId = ( (request.getParameter("siteHostId")==null)?"":request.getParameter("siteHostId")); 
String brandChoiceStr="";

String sql="select b.id,l.primary_brand_code,l.brand_name,concat('/sitehosts/',sh.site_host_name,'/images/',l.logo_image) logo,sh.id site_host_id,sh.site_host_name,sh.domain_name,l.property_code from brands b left join logos l on b.brand_code=l.primary_brand_code left join site_hosts sh on b.company_id=sh.company_id where b.active=1 and sh.active=1 and l.brand_name is not null group by l.brand_code order by l.brand_code";
String slBrands="<select name='brandChoice' onChange='popfields(this)'><option value='0'>--Choose Brand</option>";
PreparedStatement campaign1 = conn.prepareStatement(sql);
ResultSet rs = campaign1.executeQuery();
while (rs.next()){
	brandChoiceStr=rs.getString("b.id")+"|"+rs.getString("logo")+"|"+rs.getString("sh.site_host_name")+"|"+rs.getString("sh.domain_name")+"|"+rs.getString("site_host_id")+"|"+rs.getString("l.primary_brand_code")+"|"+rs.getString("l.property_code");
	slBrands+="<option value='"+brandChoiceStr+"' "+((brandChoiceStr.equals(brandChoice))?"Selected":"")+">"+rs.getString("l.brand_name")+"</option>";
}
slBrands+="</select>";

if (step==2){
	sql="select max(id) from email_campaigns";
	PreparedStatement campaign2 = conn.prepareStatement(sql);
	rs = campaign2.executeQuery(sql);
	if (rs.next()){
		campaignId=Integer.parseInt(rs.getString(1))+1;
	}
	
//Create a new record in the email campaign table for the shell
	sql="insert into email_campaigns (id,title,misc_keywords,brand_id,submitter_id,date_created,date_to_send,summary,plain_text,html,stylesheet1_url,stylesheet2_url,thumbnail_url,status_id,site_host_name,domain_name) values (?,?,'',?,?,Now(),?,?,?,?,?,?,?,?,?,?)";
	int x=1;
		PreparedStatement campaign = conn.prepareStatement(sql);
		campaign.clearParameters();
		campaign.setString(x++,  Integer.toString(campaignId));
		campaign.setString(x++, title);
//		campaign.setString(x++, "");
		campaign.setString(x++, brand_id);
		campaign.setString(x++, submitter_id);
		campaign.setString(x++, date_to_send);
		campaign.setString(x++, summary);
		campaign.setString(x++, plain_text);
		campaign.setString(x++, html);
		campaign.setString(x++, stylesheet1_url);
		campaign.setString(x++, stylesheet2_url);
		campaign.setString(x++, thumbnail_url);
		campaign.setString(x++, status_id);
		campaign.setString(x++, site_host_name);
		campaign.setString(x++, domain_name);
		campaign.execute();
} else if (step==3){
	PreparedStatement clearCampaign = conn.prepareStatement("delete from email_featured_products where pagename="+Integer.toString(campaignId));
	clearCampaign.execute();
	for ( i=0; i<Integer.parseInt(numProds); i++ ) { 
		String productId=request.getParameter("prodId_"+i);
		if (productId != null && !(productId.equals(""))){
			sql="insert into email_featured_products (product_id,sitehost_id,pagename,sequence) values (?,?,?,?)";
			int x=1;
				PreparedStatement campaign = conn.prepareStatement(sql);
				campaign.clearParameters();
				campaign.setString(x++, productId);
			//	campaign.setString(x++, Integer.toString(campaignId));
				campaign.setString(x++, siteHostId);
				campaign.setString(x++,  Integer.toString(campaignId));
				campaign.setString(x++, ((request.getParameter("sequence_"+i)==null)?"0":request.getParameter("sequence_"+i)));
				campaign.execute();	
		}
	}
	//Add to 'featured products' table, pagename as campaign page id
	//Send to 'Edit Presentation' page
} else if (step==4){
	//Save HTML in HTML field
	sql="update email_campaigns set title=?,brand_id=?,date_to_send=?,summary=?,plain_text=?,html=?,stylesheet1_url=?,thumbnail_url=?,site_host_name=? where id=?";
		int x=1;
					
			PreparedStatement campaign = conn.prepareStatement(sql);
		try {
			campaign.clearParameters();
			campaign.setString(x++, title);
			campaign.setString(x++, brand_id);
			campaign.setString(x++, date_to_send);
			campaign.setString(x++, summary);
			campaign.setString(x++, plain_text);
			campaign.setString(x++, html);
			campaign.setString(x++, stylesheet1_url);
			campaign.setString(x++, thumbnail_url);
			campaign.setString(x++, site_host_name);
			campaign.setString(x++, Integer.toString(campaignId));			
			campaign.execute();	
		} finally {
			campaign.close();
		}
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
		var el=choice.value;	
		if (choice.value!='0'){
			var fm=document.forms[0];
			var elA=el.split("|");
			fm.brand_id.value=elA[0];
			fm.thumbnail_url.value='http://'+elA[3]+elA[1];
			fm.site_host_name.value=elA[2];
			fm.domain_name.value=elA[3];
			fm.siteHostId.value=elA[4];
			fm.brandCode.value=elA[5];
			fm.propertyCode.value=elA[6];
			fm.stylesheet1_url.value='http://'+elA[3]+'/sitehosts/'+elA[2]+'/styles/vendor_styles.css';
		}
	}
	function popTest(){
		document.getElementById("testarea").innerHTML=document.forms[0].html_area.value;
	}
	function goBack(){
<%if (step==3){%>if (confirm("This will remove any edits you've made to the page so far. Continue?")){window.history.back();}<%}else{%>window.history.back();<%}%>
	}
</script>
<body text="#000000" onLoad="MM_preloadImages('/images/buttons/submitover.gif')" leftmargin="10" topmargin="10">
<form method="post" action="/app-admin/EmailCampaigner.jsp">
  <p class="MainTitle">Marcomet Account Services</p>
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
  <br><br><%
		if (step==2){
			%><jsp:include page='/contents/items.jsp' flush="false">
				<jsp:param name="siteHostId" value="<%=siteHostId%>" />
				<jsp:param name="brandId" value="<%=brand_id%>" />
				<jsp:param name="brandCode" value="<%=brandCode%>" />
				<jsp:param name="defaultPropId" value="<%=propertyCode%>" />
				<jsp:param name="campaignId" value="<%=campaignId%>" />
				<jsp:param name="companyId" value="<%=companyId%>" />
				<jsp:param name="siteHostRoot" value="<%="/sitehosts/"+site_host_name%>" />
				<jsp:param name="showChoice" value="yes" />
			</jsp:include><%
		}else if (step==3){
			%>
			<script language="javascript" type="text/javascript" src="/javascripts/tiny_mce/tiny_mce.js"></script>
			<script language="javascript" type="text/javascript">
				tinyMCE.init({
					theme : "advanced",
					mode : "exact",
					elements : "html_area",
					submit_patch : false,
					content_css : "<%=domain_name%>/sitehosts/<%=site_host_name%>/styles/vendor_styles.css",
					extended_valid_elements : "link[rel|href|type]",
					plugins : "table,visualchars",
					theme_advanced_buttons3_add_before : "tablecontrols,separator,visualchars",
					//invalid_elements : "a",
					theme_advanced_styles : "Title=title;Subtitle=subtitle;", // Theme specific setting CSS classes
					//execcommand_callback : "myCustomExecCommandHandler",
					debug : false
				});

				// Custom event handler
				function myCustomExecCommandHandler(editor_id, elm, command, user_interface, value) {
					var linkElm, imageElm, inst;

					switch (command) {
							case "mceLink":
							inst = tinyMCE.getInstanceById(editor_id);
							linkElm = tinyMCE.getParentElement(inst.selection.getFocusElement(), "a");

							if (linkElm)
								alert("Link dialog has been overriden. Found link href: " + tinyMCE.getAttrib(linkElm, "href"));
							else
								alert("Link dialog has been overriden.");

							return true;

						case "mceImage":
							inst = tinyMCE.getInstanceById(editor_id);
							imageElm = tinyMCE.getParentElement(inst.selection.getFocusElement(), "img");

							if (imageElm)
								alert("Image dialog has been overriden. Found image src: " + tinyMCE.getAttrib(imageElm, "src"));
							else
								alert("Image dialog has been overriden.");

							return true;
					}
					return false; // Pass to next handler in chain
				}

			</script><%
			String currentSiteHostRoot=(String)session.getAttribute("siteHostRoot");
			session.setAttribute("siteHostRoot","/sitehosts/"+site_host_name);
			%><table width='768'><tr><td class="minderheader" colspan=2>EDIT HTML EMAIL MESSAGE</td></tr>
				<tr><td class=lineitem colspan=2><link rel="stylesheet" href="<%=(String)session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css"><textarea name="html_area" cols='100' rows="35" ><jsp:include page="/includes/EmailFeaturedProducts.jsp" >
					<jsp:param name="title" value="<%=title%>" />
					<jsp:param name="summary" value="<%=summary%>" />
					<jsp:param name="pageName" value="<%=campaignId%>" />
					<jsp:param name="domainName" value="<%="http://"+domain_name%>" />
					<jsp:param name="siteHostId" value="<%=siteHostId%>" />
					<jsp:param name="siteHostName" value="<%=site_host_name%>" />
				</jsp:include>
				</textarea></td></tr><tr><td><br><div class='subtitle'>Make any necessary changes in the edit area above and click 'NEXT' to continue. See initial preview below...<br><br>
				<table style="border: thin solid #000;padding: 0px;" cellpadding=0 cellspacing=0><tr><td><link rel="stylesheet" href="<%=(String)session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css"><jsp:include page="<%="/includes/topmast_email.jsp"%>" ><jsp:param name="siteHostName" value="<%=site_host_name%>" /><jsp:param name="sitehostroot" value="<%="http://"+domain_name+"/sitehosts/"+site_host_name%>" /></jsp:include></td></tr><tr><td><table border=0 cellspacing=0 cellpadding=8><tr><td><span id='testarea'></span></td></tr><tr><td class='lineitems'>To view this offer and explore all your marketing options go to: <a href='<%="http://"+domain_name+"/index.jsp?contents=/contents/Promopage.jsp?cId1="+campaignId%>'><%="http://"+domain_name+"/index.jsp?contents=/contents/Promopage.jsp?cId1="+campaignId%></a></td></tr></table></td></tr></table><script>popTest();</script><%
				session.setAttribute("siteHostRoot",currentSiteHostRoot);
		}else if (step==4){
			%><table border="0" cellspacing="0" cellpadding="0">
			<tr><td class='subtitle'>HTML Message: Copy the text below for the html email messaage:<br></td></tr>
				<tr><td>
						<table border="1" cellspacing="0" cellpadding="0">
				      	<tr><td valign="top"><textarea cols='60' rows='25'><html><head><title><%=title%></title></head><body><table style="border: thin solid #000;padding: 0px;" cellpadding=0 cellspacing=0><tr><td><jsp:include page="<%="/includes/topmast_email.jsp"%>" ><jsp:param name="siteHostName" value="<%=site_host_name%>" /><jsp:param name="sitehostroot" value="<%="http://"+domain_name+"/sitehosts/"+site_host_name%>" /></jsp:include></td></tr><tr><td><table border=0 cellspacing=0 cellpadding=8><tr><td><%=html%></td></tr><tr><td class='lineitems'>To view this offer and explore all your marketing options go to: <a href='<%="http://"+domain_name+"/index.jsp?contents=/contents/Promopage.jsp?cId1="+campaignId%>'><%="http://"+domain_name+"/index.jsp?contents=/contents/Promopage.jsp?cId1="+campaignId%></a></td></tr></table></td></tr></table></body></html></textarea></td></tr>
				    	</table>
					</td></tr>
					<tr><td class='subtitle'><br><br><br>HTML Message Preview / Plain Text: Copy the contents of the box below and paste into a text editor for the plain text email message - some clean up may be necessary:<br></td></tr>
						<tr><td>
								<table border="1" cellspacing="0" cellpadding="10">
						      	<tr><td  valign="top"><table style="border: thin solid #000;padding: 0px;" cellpadding=0 cellspacing=0><tr><td><jsp:include page="<%="/includes/topmast_email.jsp"%>" ><jsp:param name="siteHostName" value="<%=site_host_name%>" /><jsp:param name="sitehostroot" value="<%="http://"+domain_name+"/sitehosts/"+site_host_name%>" /></jsp:include></td></tr><tr><td><table border=0 cellspacing=0 cellpadding=8><tr><td><%=html%></td></tr><tr><td class='lineitems'>To view this offer and explore all your marketing options go to: <a href='<%="http://"+domain_name+"/index.jsp?contents=/contents/Promopage.jsp?cId1="+campaignId%>'><%="http://"+domain_name+"/index.jsp?contents=/contents/Promopage.jsp?cId1="+campaignId%></a></td></tr></table></td></tr></table>
						</td></tr>
						    	</table>
							</td></tr></table><%
		}
		step=step+1;
%><input type='hidden' name='step' value='<%=step%>'>
<input type='hidden' name='campaignId' value='<%=campaignId%>'>
<input type='hidden' name='brandCode' value='<%=brandCode%>'>
<input type='hidden' name='propertyCode' value='<%=propertyCode%>'>
<input type='hidden' name='siteHostId' value='<%=siteHostId%>'>
<input type='hidden' name='companyId' value='<%=companyId%>'>
<input type='hidden' name='numProds' value='<%=numProds%>'>
<input type='hidden' name='domain_name' value='<%=domain_name%>'>
<input type='hidden' name='brand_id' value='<%=brand_id%>'>
<input type='hidden' name='site_host_name' value='<%=site_host_name%>'>
<input type='hidden' name='thumbnail_url' value='<%=thumbnail_url%>'>
<input type='hidden' name='stylesheet1_url' value='<%=stylesheet1_url%>'>
<input type='hidden' name='stylesheet2_url' value='<%=stylesheet2_url%>'>
<div align='center'><%
if (step>2){
	%><input type="button" name="back" value=" << Back  " onClick="goBack();"><%
}
if (step==4){
		%><input type="button" name="save" value="  Next >>  " onclick="tinyMCE.triggerSave();document.forms[0].submit();" /><%
	}else if (step<5){
		%><input type="submit" name="Submit" value=" Next >> "><%}else{%><div align=center class='title'><br><hr>Email Campaign Creation Complete</div><%}%></div>
</form>
</body>
</html><%
conn.close();
%>
