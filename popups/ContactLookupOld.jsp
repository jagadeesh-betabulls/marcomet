<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<%@ page import="java.sql.*,java.util.*,com.marcomet.users.security.*, com.marcomet.jdbc.*, com.marcomet.environment.*;" %>
<%@ taglib uri="/WEB-INF/tld/taglib.tld" prefix="taglib" %>
<%@ include file="/includes/SessionChecker.jsp" %>
<jsp:useBean id="connection" class="com.marcomet.jdbc.ConnectionBean" scope="session" />
<%
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
SiteHostSettings shs = (SiteHostSettings)session.getAttribute("siteHostSettings");
String sitehostid=shs.getSiteHostId();
String siteHostDomain=shs.getDomainName();
String query = "";
	int foundSet=0;
	int phonecount=0;
%><html>
<head>
<title>Contact Lookup</title>
  <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
  <link rel="stylesheet" href="/sitehosts/lms/styles/vendor_styles.css" type="text/css">
<script language="JavaScript" src="/javascripts/mainlib.js"></script>
<script language="JavaScript">
	function submitSortForm(strAll,sortOrder){
		var queryStr=document.forms[0].contactId.value+document.forms[0].companyId.value+document.forms[0].lastName.value+document.forms[0].areaCode.value+document.forms[0].phone1.value+document.forms[0].phone2.value+document.forms[0].zip.value+document.forms[0].companyName.value+document.forms[0].email.value;
		if (queryStr==""){
			alert("You must enter criteria for the Search.");
		}else{
			document.forms[0].showAll.value=strAll;
			document.forms[0].orderBy.value=sortOrder;
			document.forms[0].submit();
		}
	}
	function submitForm(strAll){
		var queryStr=document.forms[0].contactId.value+document.forms[0].lastName.value+document.forms[0].companyId.value+document.forms[0].areaCode.value+document.forms[0].phone1.value+document.forms[0].phone2.value+document.forms[0].zip.value+document.forms[0].companyName.value+document.forms[0].email.value;
		if (queryStr==""){
			alert("You must enter criteria for the Search.");
		}else{
			document.forms[0].showAll.value=strAll;
			document.forms[0].submit();
		}
	}
	function startProxy(cid){
		window.opener.submitProxy(cid);
		window.close();
	}
</script>
</head>
<body class="body" onLoad="MM_preloadImages('/images/buttons/submitover.gif','/images/buttons/cancelbtover.gif')" background="<%=((SiteHostSettings)session.getAttribute("siteHostSettings")).getSiteHostRoot()%>/images/back3.jpg">
<form method="post" action="ContactLookup.jsp?submitted=Y">
       <p class="Title">Contact Lookup </p>
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
        <td class="minderheaderright" >Site # (Company Name): </td>
        <td class="lineitems"><input name="companyName" class="lineitems" size=20 value="<%=companyName%>"></td></tr>
      <tr>
		<td class="minderheaderright" >Email Address: </td>
		<td class="lineitems"><input name="email" class="lineitems" size=20 value="<%=email%>"></td></tr>
<tr><td colspan="2">
	<table border="0" width="100%">
	  <tr>
	      <td> 
	        <div align="center"><a href="#" onClick="window.close();" class="greybutton">Cancel</a></div>	      </td>
	    <td>&nbsp;</td>
	      <td> 
	        <div align="center"><a href="javascript:submitForm('')"class="greybutton">Search</a>	        </div>	      </td>
	  </tr>
	</table>
</tr><tr><td colspan="2"></td>
</table>
        </blockquote>
	    </blockquote>
	  </blockquote>
  </blockquote><%
if (!(request.getParameter("submitted")==null) && request.getParameter("submitted").equals("Y")){
 query = "select c.id contactid, concat(c.firstname,' ',c.lastname) contactname,c.jobtitle title,l.user_name loginname, sh.id sitehostid, sh.domain_name sitehost, co.id companyid, co.company_name companyname, concat(sa.address1,if(sa.address2='','',', '),sa.address2,'<br />',sa.city,', ',sas.value,'  ',sa.zip) shippingaddress, concat(ba.address1,if(ba.address2='','',', '),ba.address2 ,'<br />',ba.city,', ',bas.value,'  ',ba.zip) billingaddress, email, if(p.phonetype is not null,concat('(',p.areacode,')&nbsp;',p.phone1,'&nbsp;-&nbsp;',p.phone2),'') phone, if(fp.phonetype is not null,concat('(',fp.areacode,')&nbsp;',fp.phone1,'&nbsp;-&nbsp;',fp.phone2),'') faxphone, if(bp.phonetype is not null,concat('(',bp.areacode,')&nbsp;',bp.phone1,'&nbsp;-&nbsp;',bp.phone2),'') beeperphone, if(mp.phonetype is not null,concat('(',mp.areacode,')&nbsp;',mp.phone1,'&nbsp;-&nbsp;',mp.phone2),'') mobilephone from lu_abreviated_states sas, lu_abreviated_states bas, logins l, contacts c, companies co, locations sa,locations ba, site_hosts sh, contact_roles cr  left join phones p on c.id = p.contactid and p.phonetype=1 left join phones fp on c.id = fp.contactid and fp.phonetype=2 left join phones bp on c.id = bp.contactid and bp.phonetype=3 left join phones mp on c.id = mp.contactid and mp.phonetype=4 where cr.contact_id=c.id and  l.contact_id=c.id  and cr.site_host_id=sh.id and c.companyid=co.id  and (c.id=sa.contactid and sa.locationtypeid=1) and (c.id=ba.contactid and ba.locationtypeid=2) and sas.id=sa.state and bas.id=ba.state ";
	query+=((contactId.equals(""))?"":" AND c.id = "+contactId);
	query+=((companyId.equals(""))?"":" AND co.id = "+companyId);
	query+=((lastName.equals(""))?"":" AND lastname like '%"+lastName+"%' ");
	query+=((areaCode.equals(""))?"":" AND (p.areacode = '"+areaCode+"' or bp.areacode='"+areaCode+"' or fp.areacode='"+areaCode+"' or mp.areacode='"+areaCode+"') ");
	query+=((phone1.equals(""))?"":" AND (p.phone1 = '"+phone1+"' or bp.phone1='"+phone1+"' or fp.phone1='"+phone1+"' or mp.phone1='"+phone1+"') ");
	query+=((phone2.equals(""))?"":" AND (p.phone2 = '"+phone2+"' or bp.phone2='"+phone2+"' or fp.phone2='"+phone2+"' or mp.phone2='"+phone2+"') ");
	query+=((zip.equals(""))?"":" AND (sa.zip like '%"+zip+"%' or ba.zip like'%"+zip+"%') ");
	query+=((companyName.equals(""))?"":" AND company_name like '%"+companyName+"%' ");
	query+=((email.equals(""))?"":" AND email like '%"+email+"%' ");
	query+=((proxy.equals("Y") && showAll.equals(""))?" AND sh.id="+sitehostid:"");
	query+=((proxy.equals("Y"))?" group by c.id order by sh.id, c.lastname, c.firstname":" group by c.id order by "+orderBy+"c.lastname, c.firstname");
	
	
	SimpleConnection sc = new SimpleConnection();
	Connection conn = sc.getConnection();
	Statement st = conn.createStatement();
	ResultSet rs = st.executeQuery(query);
	sc.close();
	while (rs.next()) {
		foundSet++;
		if (foundSet==1){
			if(proxy.equals("Y")){
				if(showAll.equals("")){
				%><span class='subTitle'>For Contacts Registered on: <%=siteHostDomain%></span> <a href="javascript:submitForm('all')"class="greybutton">Show All</a><%
				}else{
					%><a href="javascript:submitForm('')"class="greybutton">Filter for site: <%=siteHostDomain%></a><%
				}
			}
			%><hr><span id='counter' class='subtitle'></span><table border="0" cellpadding="5" cellspacing="0" width=100%>
      <tr>
        <td class="minderheaderleft" ><a class='<%=((orderBy.equals(""))?"minderheaderlinkselected":"minderheaderlink")%>' href="javascript:submitSortForm('','')">Contact ID / Name / Title</a></td>
		<td class="minderheaderleft" width="50px"><a class='<%=((orderBy.equals(" l.user_name,"))?"minderheaderlinkselected":"minderheaderlink")%>' href="javascript:submitSortForm('',' l.user_name,')">Login Name</a></td><%
		if(!(proxy.equals("Y") && showAll.equals(""))){
		%><td class="minderheaderleft" ><a class='<%=((orderBy.equals(" sh.domain_name,"))?"minderheaderlinkselected":"minderheaderlink")%>' href="javascript:submitSortForm('',' sh.domain_name,')">Registered
          On</a></td><%}%>
        <td class="minderheaderleft" ><a class='<%=((orderBy.equals(" co.company_name,"))?"minderheaderlinkselected":"minderheaderlink")%>' href="javascript:submitSortForm('',' co.company_name,')">Company</a></td>
		<td class="minderheaderleft" >Shipping Address</td>
		<td class="minderheaderleft" >Billing Address</td>
		<td class="minderheaderleft" width='80px'>Email</td>
		<td class="minderheaderleft" width="130px" >Phone</td>
	</tr><%
		}
	%><tr>
        <td class="lineitems" ><%
		if ( proxy.equals("Y") && rs.getString("sitehostid").equals(sitehostid) ){
			%><a class='greybutton' href="javascript:startProxy('<%=rs.getString("contactid")%>:<%=rs.getString("companyid")%>')">Place Proxy Order</a><br><br><%}%> <%=rs.getString("contactid")%> / <%=rs.getString("contactname")%> / <%=rs.getString("title")%></td>
		<td class="lineitems" ><%=rs.getString("loginname")%></td><%
		if(!(proxy.equals("Y") && showAll.equals(""))){
		%><td class="lineitems" ><%=rs.getString("sitehost")%></td><%}%>
        <td class="lineitems" ><%=rs.getString("companyname")%></td>
		<td class="lineitems" ><%=rs.getString("shippingaddress")%></td>
		<td class="lineitems" ><%=rs.getString("billingaddress")%></td>
		<td class="lineitems" ><%=rs.getString("email")%></td>
		<td class="lineitems" align='right' ><%phonecount=0;
	if (rs.getString("phone").equals("")){%>&nbsp;<%}else{phonecount++;%>Work:&nbsp;<%=rs.getString("phone")%><%	}
	if (!rs.getString("faxphone").equals("")){phonecount++;%><%=((phonecount>0)?"<br>":"")%>Fax:&nbsp;<%=rs.getString("faxphone")%><%	}
	if (!rs.getString("beeperphone").equals("")){phonecount++;%><%=((phonecount>0)?"<br>":"")%>Beeper:&nbsp;<%=rs.getString("beeperphone")%><%	}
	if (!rs.getString("mobilephone").equals("")){phonecount++;%><%=((phonecount>0)?"<br>":"")%>Mobile:&nbsp;<%=rs.getString("mobilephone")%><%	}%></td>
	</tr><%
	}
	if (foundSet==0){
		%><hr><table border="0" cellpadding="5" cellspacing="0" width='100%'>
     	<tr>
       		<td class="subTitle" >No records were found with this search criteria.
       		  Please modify the search terms and Search again or click Cancel to
       		  close this window and return to the Console.</td>
		</tr><%
	}
	%></table><%
}  
%><script>
	document.getElementById("counter").innerHTML="<%=((foundSet>0)?"Records Found: "+foundSet:"")%>";
</script>
<!--<%=((foundSet>0)?"Records Found: "+foundSet:"")%>-->
<input type="hidden" name="submitted">
<input type="hidden" name="proxy" value="<%=proxy%>">
<input type="hidden" name="showAll" value="<%=showAll%>">
<input type="hidden" name="orderBy" value="<%=orderBy%>">
</form>
</body>
</html>