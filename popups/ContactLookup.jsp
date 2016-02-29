<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<%@ page import="java.sql.*,java.util.*,com.marcomet.users.security.*, com.marcomet.jdbc.*,com.marcomet.tools.*, com.marcomet.environment.*;" %>
<%@ taglib uri="/WEB-INF/tld/taglib.tld" prefix="taglib" %>
<%@ taglib uri="/WEB-INF/tld/formTagLib.tld" prefix="ftaglib" %>
<%@ include file="/includes/SessionChecker.jsp" %>
<%
SiteHostSettings shs = (SiteHostSettings)session.getAttribute("siteHostSettings");
String sitehostid=shs.getSiteHostId();
String siteHostDomain=shs.getDomainName();
String siteClient="";
if(session.getAttribute("roles") != null){
	if( ( ((com.marcomet.users.security.RoleResolver)session.getAttribute("roles")).roleCheck("sitehost_manager") || ((com.marcomet.users.security.RoleResolver)session.getAttribute("roles")).isSiteHost() ) && !(((com.marcomet.users.security.RoleResolver)session.getAttribute("roles")).isVendor())  ){
			siteClient=" AND (sh.sitehost_client_id='"+sitehostid+"' or sh.id='"+sitehostid+"') ";
	}
}


String baseURL = HttpUtils.getRequestURL(request).toString();
session.setAttribute("baseurl",baseURL);
int dblslashIndex = baseURL.lastIndexOf("//")+2;
baseURL = dblslashIndex != -1 ? baseURL.substring(dblslashIndex, baseURL.length()) : "";
int slashIndex = baseURL.indexOf("/");
baseURL = slashIndex != -1 ? baseURL.substring(0, slashIndex) : "";
String domain=baseURL.substring(baseURL.indexOf("."),baseURL.length());


String enableCID=((request.getParameter("enableCID")==null)?"":request.getParameter("enableCID"));
String disableCID=((request.getParameter("disableCID")==null)?"":request.getParameter("disableCID"));
Connection conn = DBConnect.getConnection();
Statement st = conn.createStatement();
%><%=enableCID+"|"+disableCID%><%
if (!enableCID.equals("")){
	st.executeUpdate("Update contacts set active_flag='1' where id="+enableCID);	
}

if (!disableCID.equals("")){
	st.executeUpdate("Update contacts set active_flag='0' where id="+disableCID);	
}


String proxy=((request.getParameter("proxy")==null)?"":request.getParameter("proxy"));
String showAll=((request.getParameter("showAll")==null)?"":request.getParameter("showAll"));
String orderBy=((request.getParameter("orderBy")==null)?"":request.getParameter("orderBy"));
String contactId=((request.getParameter("contactId")==null)?"":request.getParameter("contactId"));
String companyId=((request.getParameter("companyId")==null)?"":request.getParameter("companyId"));
String lastName=((request.getParameter("lastName")==null)?"":request.getParameter("lastName"));
String areaCode=((request.getParameter("areaCode")==null)?"":request.getParameter("areaCode"));
String phone1=((request.getParameter("phone1")==null)?"":request.getParameter("phone1"));
String phone2=((request.getParameter("phone2")==null)?"":request.getParameter("phone2"));
String zip=((request.getParameter("zip")==null)?"":request.getParameter("zip"));
String companyName=((request.getParameter("companyName")==null)?"":request.getParameter("companyName"));
String email=((request.getParameter("email")==null)?"":request.getParameter("email"));
String siteNumber=((request.getParameter("siteNumber")==null)?"":request.getParameter("siteNumber"));
String pmSiteNumber=((request.getParameter("pmSiteNumber")==null)?"":request.getParameter("pmSiteNumber"));
String query = "";
	int foundSet=0;
	int phonecount=0;
%><html>
<head>
<title>Contact Lookup<%=((proxy.equals("Y"))?" / Proxy Order":"")%></title>
  <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
  <link rel="stylesheet" href="/sitehosts/lms/styles/vendor_styles.css" type="text/css">
<script language="JavaScript" src="/javascripts/mainlib.js"></script>
<script language="JavaScript">
	function submitSortForm(strAll,sortOrder){
		var queryStr=document.forms[0].contactId.value+document.forms[0].companyId.value+document.forms[0].lastName.value+document.forms[0].areaCode.value+document.forms[0].phone1.value+document.forms[0].phone2.value+document.forms[0].zip.value+document.forms[0].companyName.value+document.forms[0].email.value+document.forms[0].siteNumber.value;
		if (queryStr==""){
			alert("You must enter criteria for the Search.");
		}else{
			if ((document.forms[0].contactId.value!="" && !isNumber(document.forms[0].contactId.value)) || (document.forms[0].companyId.value!="" && !isNumber(document.forms[0].companyId.value))){
				alert("Contact ID and Company ID must be numeric only")
			}else{
				document.forms[0].showAll.value=strAll;
				document.forms[0].orderBy.value=sortOrder;
				document.forms[0].submit();
			}
		}
	}
	
	function submitForm(strAll,proxy){
		document.getElementById('processing').innerHTML = "<img src='/images/loader.gif'/>Processing. . ."; 
		var queryStr=document.forms[0].contactId.value+document.forms[0].lastName.value+document.forms[0].companyId.value+document.forms[0].areaCode.value+document.forms[0].phone1.value+document.forms[0].phone2.value+document.forms[0].zip.value+document.forms[0].companyName.value+document.forms[0].email.value+document.forms[0].siteNumber.value;
		if (queryStr==""){
			alert("You must enter criteria for the Search.");
			document.getElementById('processing').innerHTML = ''; 
		}else{
		if ( (document.forms[0].contactId.value!='' && !isNumber(document.forms[0].contactId.value)) || (document.forms[0].companyId.value!='' && !isNumber(document.forms[0].companyId.value)) ){
			alert("Contact ID and Company ID may only be numeric")
			document.getElementById('processing').innerHTML = ''; 
		}else{
			document.forms[0].showAll.value=strAll;
			document.forms[0].proxy.value=proxy;
			document.forms[0].submit();
			}
		}
	}
	
	function enableUser(cid){
		document.getElementById('processing').innerHTML = "<img src='/images/loader.gif'/> Processing. . ."; 
		document.forms[0].enableCID.value=cid;
		submitForm('','Y');
	}
	
	function disableUser(cid){
		document.forms[0].disableCID.value=cid;
		document.getElementById('processing').innerHTML = "<img src='/images/loader.gif'/> Processing. . ."; 
		submitForm('','Y');
	}
	
	function startProxy(cid){
		window.opener.submitProxy(cid);
		window.close();
	}
	function registerNew(){
		var loc="http://"+document.forms[0].siteHostSelection.value+"/frames/InnerFrameset.jsp?contents=/users/NewUserForm2.jsp"
		window.location.href=loc;
	}
<%if ((request.getParameter("submitted")==null)){
	%>	window.moveTo(0,0);
	window.resizeTo(screen.width,screen.height);<%}%>
</script>
</head>
<body class="body" onLoad="MM_preloadImages('/images/buttons/submitover.gif','/images/buttons/cancelbtover.gif')" background="<%=((SiteHostSettings)session.getAttribute("siteHostSettings")).getSiteHostRoot()%>/images/back3.jpg">
<form method="post" action=""><input type="hidden" name="submitted" value="Y">
       <p class="Title"><%=((((com.marcomet.users.security.RoleResolver)session.getAttribute("roles")).isSiteHost())?"Sitehost ":"")%>Contact Lookup / Proxy Login</p>
       <blockquote>
    <blockquote>
      <blockquote>
        <blockquote>
		 <p class="subTitle">Search for Contacts by: </p>
   <table border="0" cellpadding="5" cellspacing="0" >
      <tr>
        <td class="minderheaderright" >Contact ID: </td>
		<td class="lineitems"><input name="contactId" class="lineitems" size=8 value="<%=contactId%>"></td></tr>
      <tr>
	<tr>
        <td class="minderheaderright" >Company ID: </td>
		<td class="lineitems"><input name="companyId" class="lineitems" size=8 value="<%=companyId%>"></td></tr>
      <tr>
        <td class="minderheaderright" >Last Name(or partial): </td>
        <td class="lineitems" ><input name="lastName" class="lineitems" size=20 value="<%=lastName%>"></td></tr>
      <tr>
		<td class="minderheaderright">Phone: </td>
      	<td class="lineitems">(<input name="areaCode" class="lineitems" size=4 value="<%=areaCode%>">)
        <input name="phone1" class="lineitems" size=4 value="<%=phone1%>"> - <input name="phone2" class="lineitems" size=6 value="<%=phone2%>"></td>
      </tr>
      <tr>
		<td class="minderheaderright" >Zip Code: </td>
		<td class="lineitems"><input name="zip" class="lineitems" size=8 value="<%=zip%>"></td></tr>
      <tr>
        <td class="minderheaderright" >Company Name: </td>
        <td class="lineitems"><input name="companyName" class="lineitems" size=20 value="<%=companyName%>"></td></tr>
      <tr>
	  <tr>
	       <td class="minderheaderright" >Wyndham Site #: </td>
	       <td class="lineitems"><input name="siteNumber" class="lineitems" size=20 value="<%=siteNumber%>"></td></tr>
	   <tr>
		<td class="minderheaderright" >Email Address: </td>
		<td class="lineitems"><input name="email" class="lineitems" size=20 value="<%=email%>"></td></tr>
<tr><td colspan="2"><div align="center" id="processing"></div>
	<table border="0" width="100%">
	  <tr>
	      <td><div align="center"><a href="#" onClick="window.close();" class="greybutton">Cancel</a></div></td>
	    <td>&nbsp;</td>
	      <td> <div align="center"><a href="javascript:submitForm('','Y')"class="greybutton">Search</a></div></td><%
	      System.out.println("siteClient is "+siteClient);
	String sqlDD="select sh.domain_name as 'value',sh.domain_name as 'text' from site_hosts sh where sh.active=1 "+siteClient+" order by sh.domain_name";
	    %></tr>
	</table>
<%if (siteClient.equals("")){%><span class=subtitle>-or-</span> <span align="center"><a href="javascript:registerNew()"class="greybutton"> Register New On: </a><ftaglib:SQLDropDownTag dropDownName="siteHostSelection\" id=\"siteHostSelection" sql="<%=sqlDD%>" selected="" /></span><%}%></td></tr><tr><td colspan="2"></td>
</table>
        </blockquote>
	    </blockquote>
	  </blockquote>
  </blockquote><%
if (!(request.getParameter("submitted")==null) && request.getParameter("submitted").equals("Y")){
 	
	if(!areaCode.equals("")&&!phone1.equals("")&&!phone2.equals("")){
		query = "select c.active_flag,c.default_site_number,c.default_pm_site_number, c.id contactid, concat(c.firstname,' ',c.lastname) contactname,c.jobtitle title,l.user_name loginname, sh.id sitehostid, sh.domain_name sitehost,sh.site_host_name sitehostname, co.id companyid, co.company_name companyname, concat(sa.address1,if(sa.address2='','',', '),sa.address2,'<br />',sa.city,', ',sas.value,'  ',sa.zip) shippingaddress, concat(ba.address1,if(ba.address2='','',', '),ba.address2 ,'<br />',ba.city,', ',bas.value,'  ',ba.zip) billingaddress, email, if(p.phonetype is not null,concat('(',p.areacode,')&nbsp;',p.phone1,'&nbsp;-&nbsp;',p.phone2),'') phone, if(fp.phonetype is not null,concat('(',fp.areacode,')&nbsp;',fp.phone1,'&nbsp;-&nbsp;',fp.phone2),'') faxphone, if(bp.phonetype is not null,concat('(',bp.areacode,')&nbsp;',bp.phone1,'&nbsp;-&nbsp;',bp.phone2),'') beeperphone, if(mp.phonetype is not null,concat('(',mp.areacode,')&nbsp;',mp.phone1,'&nbsp;-&nbsp;',mp.phone2),'') mobilephone, co.credit_status, co.credit_limit, co.tax_exempt, c.contact_notes from lu_abreviated_states sas, lu_abreviated_states bas, logins l, companies co, locations sa,locations ba, site_hosts sh, contact_roles cr,contacts c left join phones p on c.id = p.contactid and p.phonetype=1 right join phones fp on c.id = fp.contactid and fp.phonetype=2 left join phones bp on c.id = bp.contactid and bp.phonetype=3 left join phones mp on c.id = mp.contactid and mp.phonetype=4 where cr.contact_id=c.id and  l.contact_id=c.id  and cr.site_host_id=sh.id and c.companyid=co.id  and (c.id=sa.contactid and sa.locationtypeid=1) and (c.id=ba.contactid and ba.locationtypeid=2) and sas.id=sa.state and bas.id=ba.state ";
		query+=((areaCode.equals(""))?"":" AND (p.areacode = '"+areaCode+"' or bp.areacode='"+areaCode+"' or fp.areacode='"+areaCode+"' or mp.areacode='"+areaCode+"') ");
		query+=((phone1.equals(""))?"":" AND (p.phone1 = '"+phone1+"' or bp.phone1='"+phone1+"' or fp.phone1='"+phone1+"' or mp.phone1='"+phone1+"') ");
		query+=((phone2.equals(""))?"":" AND (p.phone2 = '"+phone2+"' or bp.phone2='"+phone2+"' or fp.phone2='"+phone2+"' or mp.phone2='"+phone2+"') ");
		query+=" group by c.id";	
	}else{
	query = "select c.active_flag,c.default_site_number,c.default_pm_site_number, c.id contactid, concat(c.firstname,' ',c.lastname) contactname,c.jobtitle title,l.user_name loginname, sh.id sitehostid, sh.domain_name sitehost,sh.site_host_name sitehostname, co.id companyid, co.company_name companyname, concat(sa.address1,if(sa.address2='','',', '),sa.address2,'<br />',sa.city,', ',sas.value,'  ',sa.zip) shippingaddress, concat(ba.address1,if(ba.address2='','',', '),ba.address2 ,'<br />',ba.city,', ',bas.value,'  ',ba.zip) billingaddress, email, if(p.phonetype is not null,concat('(',p.areacode,')&nbsp;',p.phone1,'&nbsp;-&nbsp;',p.phone2),'') phone, if(fp.phonetype is not null,concat('(',fp.areacode,')&nbsp;',fp.phone1,'&nbsp;-&nbsp;',fp.phone2),'') faxphone, if(bp.phonetype is not null,concat('(',bp.areacode,')&nbsp;',bp.phone1,'&nbsp;-&nbsp;',bp.phone2),'') beeperphone, if(mp.phonetype is not null,concat('(',mp.areacode,')&nbsp;',mp.phone1,'&nbsp;-&nbsp;',mp.phone2),'') mobilephone, co.credit_status, co.credit_limit, co.tax_exempt, c.contact_notes from lu_abreviated_states sas, lu_abreviated_states bas, logins l, companies co, locations sa,locations ba, site_hosts sh, contact_roles cr,contacts c left join phones p on c.id = p.contactid and p.phonetype=1 left join phones fp on c.id = fp.contactid and fp.phonetype=2 left join phones bp on c.id = bp.contactid and bp.phonetype=3 left join phones mp on c.id = mp.contactid and mp.phonetype=4 where cr.contact_id=c.id and  l.contact_id=c.id  and cr.site_host_id=sh.id and c.companyid=co.id  and (c.id=sa.contactid and sa.locationtypeid=1) and (c.id=ba.contactid and ba.locationtypeid=2) and sas.id=sa.state and bas.id=ba.state ";
	query+=siteClient;
	query+=((contactId.equals(""))?"":" AND c.id = "+contactId);
	query+=((companyId.equals(""))?"":" AND co.id = "+companyId);
	query+=((siteNumber.equals(""))?"":" AND default_site_number = '"+siteNumber+"' ");
	query+=((lastName.equals(""))?"":" AND lastname like '%"+lastName+"%' ");
	query+=((areaCode.equals(""))?"":" AND (p.areacode = '"+areaCode+"' or bp.areacode='"+areaCode+"' or fp.areacode='"+areaCode+"' or mp.areacode='"+areaCode+"') ");
	query+=((phone1.equals(""))?"":" AND (p.phone1 = '"+phone1+"' or bp.phone1='"+phone1+"' or fp.phone1='"+phone1+"' or mp.phone1='"+phone1+"') ");
	query+=((phone2.equals(""))?"":" AND (p.phone2 = '"+phone2+"' or bp.phone2='"+phone2+"' or fp.phone2='"+phone2+"' or mp.phone2='"+phone2+"') ");
	query+=((zip.equals(""))?"":" AND (sa.zip like '%"+zip+"%' or ba.zip like'%"+zip+"%') ");
	query+=((companyName.equals(""))?"":" AND company_name like '%"+companyName+"%' ");
	query+=((email.equals(""))?"":" AND email like '%"+email+"%' ");
	query+=" group by c.id order by "+orderBy+" c.lastname, c.firstname";
	}
	System.out.println("sitehostid is "+sitehostid);
	System.out.println("query is "+query);
	ResultSet rs = st.executeQuery(query);	
	while (rs.next()) {
		foundSet++;
		if (foundSet==1){
			%><hr><span id='counter' class='subtitle'></span><table border="0" cellpadding="5" cellspacing="0" width=100%>
      <tr>
        <td class="minderheaderleft" onMouseOver="this.className='minderlinkselected'" onMouseOut="this.className='minderheaderleft'"><a class='<%=((orderBy.equals(""))?"minderheaderlinkselected":"minderheaderlink")%>' href="javascript:submitSortForm('','')">Contact ID / Name / Title</a></td>
		<td class="minderheaderleft" onMouseOver="this.className='minderlinkselected'" onMouseOut="this.className='minderheaderleft'" width="50px"><a class='<%=((orderBy.equals(" l.user_name,"))?"minderheaderlinkselected":"minderheaderlink")%>' href="javascript:submitSortForm('',' l.user_name,')">Login Name</a></td><%
		%><td class="minderheaderleft" onMouseOver="this.className='minderlinkselected'" onMouseOut="this.className='minderheaderleft'" ><a class='<%=((orderBy.equals(" sh.domain_name,"))?"minderheaderlinkselected":"minderheaderlink")%>' href="javascript:submitSortForm('',' sh.domain_name,')">Registered
          On</a></td>
		<td class="minderheaderleft" onMouseOver="this.className='minderlinkselected'" onMouseOut="this.className='minderheaderleft'"><a class='<%=((orderBy.equals(" co.company_name,"))?"minderheaderlinkselected":"minderheaderlink")%>' href="javascript:submitSortForm('',' co.company_name,')">Company</a></td>
		<td class="minderheaderleft" >Shipping Address</td>
		<td class="minderheaderleft" >Billing Address</td>
		<td class="minderheaderleft" width='80px'>Email</td>
		<td class="minderheaderleft" width="130px" >Phone</td>
		<td class="minderheaderleft" >Credit:<br>Status<br>Limit<br>Tax</td>
		<td class="minderheaderleft" >Contact Notes</td>
	</tr><%
		}
	%><tr>
        <td class="lineitems" ><%
		if ( proxy.equals("Y") && siteClient.equals("")){
			if(rs.getString("active_flag")!=null && rs.getString("active_flag").equals("1")){
			%><a class='greybutton' href="http://<%=rs.getString("sitehost").replace(".marcomet.com",domain)%>/includes/proxy.jsp?cId=<%=rs.getString("contactid")%>&pId=<%=session.getAttribute("contactId")%>" >Login As</a> &nbsp; <a class='greybutton' href="http://<%=rs.getString("sitehostname")%>.marcometdev1.virtual.vps-host.net/includes/proxy.jsp?cId=<%=rs.getString("contactid")%>&pId=<%=session.getAttribute("contactId")%>" >Login to Dev Site As</a> &nbsp; <a class='greybutton' href="javascript:disableUser('<%=rs.getString("contactid")%>')" >Disable User</a><br><br><%}else{%>
			<a href="javascript:enableUser('<%=rs.getString("contactid")%>')" class='greybutton'>Login Disabled, Click Here to Enable it</a>
		<%}}%> <%=rs.getString("contactid")%> / <%=rs.getString("contactname")%> / <%=rs.getString("title")%></td>
		<td class="lineitems" ><%=rs.getString("loginname")%></td>
		<td class="lineitems" ><%=rs.getString("sitehost")%></td>
		<td class="lineitems" ><%=rs.getString("companyname")+((rs.getString("c.default_site_number")==null || rs.getString("c.default_site_number").equals("") || rs.getString("c.default_site_number").equals("0"))?"":"<br>&nbsp;&nbsp;Site&nbsp;#:&nbsp;"+rs.getString("c.default_site_number"))+((rs.getString("c.default_pm_site_number")==null || rs.getString("c.default_pm_site_number").equals("") || rs.getString("c.default_pm_site_number").equals("0"))?"":"<br>&nbsp;&nbsp;PM&nbsp;Site&nbsp;#:&nbsp;"+rs.getString("c.default_pm_site_number"))%></td>
		<td class="lineitems" ><%=rs.getString("shippingaddress")%></td>
		<td class="lineitems" ><%=rs.getString("billingaddress")%></td>
		<td class="lineitems" ><a href="mailto:<%=rs.getString("email")%>" class='lineitems'><%=rs.getString("email")%></a></td>
		<td class="lineitems" align='right' ><%phonecount=0;
	if (rs.getString("phone").equals("")){%>&nbsp;<%}else{phonecount++;%>Work:&nbsp;<%=rs.getString("phone")%><%	}
	if (!rs.getString("faxphone").equals("")){phonecount++;%><%=((phonecount>0)?"<br>":"")%>Fax:&nbsp;<%=rs.getString("faxphone")%><%	}
	if (!rs.getString("beeperphone").equals("")){phonecount++;%><%=((phonecount>0)?"<br>":"")%>Beeper:&nbsp;<%=rs.getString("beeperphone")%><%	}
	if (!rs.getString("mobilephone").equals("")){phonecount++;%><%=((phonecount>0)?"<br>":"")%>Mobile:&nbsp;<%=rs.getString("mobilephone")%><%	}%></td>
	<td class="lineitems" >

<a href='javascript:pop("/popups/QuickChangeForm.jsp?cols=6&rows=1&question=Change%20Credit%20Status%20[0-default,%201-on hold,%202-allow%20all]&primaryKeyValue=<%=rs.getString("companyid")%>&columnName=credit_status&tableName=companies&valueType=string",500,200)'>&raquo;</a>&nbsp;<%=rs.getString("credit_status")%><br>

<a href='javascript:pop("/popups/QuickChangeForm.jsp?cols=10&rows=1&question=Change%20Credit%20Limit&primaryKeyValue=<%=rs.getString("companyid")%>&columnName=credit_limit&tableName=companies&valueType=string",500,200)'>&raquo;</a>&nbsp;<%=rs.getString("credit_limit")%><br>

<a href='javascript:pop("/popups/QuickChangeForm.jsp?cols=6&rows=1&question=Change%20Tax%20Exempt%20[0-default,%201-exempt]&primaryKeyValue=<%=rs.getString("companyid")%>&columnName=tax_exempt&tableName=companies&valueType=string",500,200)'>&raquo;</a>&nbsp;<%=rs.getString("tax_exempt")%>

</td>

<td class="lineitems" >
<a href='javascript:pop("/popups/QuickChangeForm.jsp?cols=60&rows=10&question=Contact%20Notes&primaryKeyValue=<%=rs.getString("contactid")%>&columnName=contact_notes&tableName=contacts&valueType=string",500,200)'>&raquo;</a>&nbsp;<%=rs.getString("contact_notes")%><br>
</td>
	</tr><%
	}
	rs.close();
	st.close();
	conn.close();
	
	if (foundSet==0){
		%><hr><table border="0" cellpadding="5" cellspacing="0" width='100%'>
     	<tr>
       		<td class="subTitle" >No records were found with this search criteria.
       		  Please modify the search terms and Search again or click Cancel to
       		  close this window and return to the Console.</td>
		</tr><%
	}
	%></table><%
		%><script>
			document.getElementById("counter").innerHTML="<%=((foundSet>0)?"Records Found: "+foundSet:"")%>";
		</script><%
}  
%>
<input type="hidden" name="submitted">
<input type="hidden" name="enableCID">
<input type="hidden" name="disableCID">
<input type="hidden" name="proxy" value="<%=proxy%>">
<input type="hidden" name="showAll" value="<%=showAll%>">
<input type="hidden" name="orderBy" value="<%=orderBy%>">
</form>
</body>
</html>