<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<%@ page import="java.sql.*,java.text.*,java.util.*,com.marcomet.jdbc.*,com.marcomet.tools.*,com.marcomet.workflow.*,com.marcomet.users.security.*,com.marcomet.environment.*;" %>
<%@ include file="/includes/SessionChecker.jsp" %>
<jsp:useBean id="validator" class="com.marcomet.tools.FieldValidationBean" scope="page" />
<%
UserProfile up = (UserProfile)session.getAttribute("userProfile");
String query = "SELECT j.price 'price', j.last_status_id 'laststatusid', buyer_contact_id, vendor_contact_id, vendor_company_id, site_host_contact_id, c.companyid 'site_host_company_id', site_host_global_markup, marcomet_global_fee FROM jobs j, projects p, orders o, contacts c WHERE o.id = p.order_id AND p.id = j.project_id AND j.id = " + request.getParameter("jobId") + " AND o.site_host_contact_id = c.id ";

String ai=((request.getParameter("ai")==null)?"42":request.getParameter("ai"));

Connection conn = DBConnect.getConnection();
Statement st = conn.createStatement();
ResultSet rs = st.executeQuery(query);

Hashtable rehash = new Hashtable();

while (rs.next()) {
	rehash.put("price", rs.getString("price"));
	rehash.put("laststatusid", rs.getString("laststatusid"));
	rehash.put("buyerContactId", rs.getString("buyer_contact_id"));
	rehash.put("vendorContactId", rs.getString("vendor_contact_id"));
	rehash.put("vendorCompanyId", rs.getString("vendor_company_id"));
	rehash.put("siteHostContactId", rs.getString("site_host_contact_id"));
	rehash.put("siteHostCompanyId", rs.getString("site_host_company_id"));
	rehash.put("siteHostGlobalMarkup", rs.getString("site_host_global_markup"));
	rehash.put("marcometGlobalFee", rs.getString("marcomet_global_fee"));
}
int creditLimit = 0;
String creditStatus="";
String creditQuery = "select l.value,l.notes,credit_limit from companies c left join lu_credit_status l on l.id=c.credit_status where c.id="+ up.getCompanyId();

ResultSet creditRS = st.executeQuery(creditQuery);
while (creditRS.next()) {
	creditStatus = creditRS.getString("value")+": "+creditRS.getString("notes");
	creditLimit = creditRS.getInt("credit_limit");
} 

int orderBalance=0;
String balanceSQL="select (sum(t.price) +  sum(t.shipprice)) - sum(t.payments) balance from (select  sum(j.price) price, 0 as shipprice, 0 as  payments from contacts c, jobs  j  where if(c.default_site_number=0,c.companyid=j.jbuyer_company_id,j.site_number=c.default_site_number)  and  c.id="+ up.getContactId() +" and j.status_id<>9 and j.status_id < 120  group by c.id union select 0 as  price, 0 as shipprice,  sum(arcd.payment_amount) payments from contacts c, jobs  j left join ar_invoice_details ari on ari.jobid=j.id left join ar_collection_details arcd on ari.ar_invoiceid=arcd.ar_invoiceid   where if(c.default_site_number =0,c.companyid=j.jbuyer_company_id,j.site_number=c.default_site_number)  and  c.id="+ up.getContactId() +" and j.status_id<>9 and j.status_id < 120  group by c.id union select 0 as  price, sum(s.price) as shipprice, 0 as payments from contacts c, jobs  j left join shipping_data s on s.job_id=j.id  where if(c.default_site_number=0,c.companyid=j.jbuyer_company_id,j.site_number=c.default_site_number)  and  c.id="+ up.getContactId() +" and j.status_id<>9 and j.status_id < 120  group by c.id) as t";

ResultSet balRS = st.executeQuery(balanceSQL);
while (balRS.next()) {
	orderBalance = balRS.getInt("balance");
}


st.close();
conn.close();
%><html>
<head>
  <title>RFQ Response</title>
  <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
  <link rel="stylesheet" href="<%=((SiteHostSettings)session.getAttribute("siteHostSettings")).getSiteHostRoot()%>/styles/vendor_styles.css" type="text/css">
<jsp:getProperty name="validator" property="javaScripts" />
<script language="JavaScript" src="/javascripts/mainlib.js"></script>
  <script language="javascript" type="text/javascript" src="/javascripts/tiny_mce/tiny_mce.js"></script>
  <script language="javascript" type="text/javascript">
	tinyMCE.init({
		theme : "advanced",
		mode : "exact",
		elements : "proposedChangeReason",
		submit_patch : false,
		content_css : "<%=(String)session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css",
		extended_valid_elements : "link[rel|href|type]",
		plugins : "table,visualchars",
		theme_advanced_buttons3_add_before : "tablecontrols,separator,visualchars",
		//invalid_elements : "a",
		theme_advanced_styles : "Title=title;Subtitle=subtitle;", // Theme specific setting CSS classes
		//execcommand_callback : "myCustomExecCommandHandler",
		debug : false
	});
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
</script>
</head>
<body class="body" background="<%=((SiteHostSettings)session.getAttribute("siteHostSettings")).getSiteHostRoot()%>/images/back3.jpg">
<form method="post" action="/servlet/com.marcomet.sbpprocesses.ProcessJobSubmit">
  <p class="Title">Job Quote</p>
  <br>
<jsp:include page="/includes/JobDetailHeader.jsp" flush="true"><jsp:param  name="jobId" value="<%=request.getParameter("jobId")%>" /></jsp:include>
<p>
<span class="label">Comments:</span>
<br>
<%String domainName = ((SiteHostSettings)session.getAttribute("siteHostSettings")).getDomainName();%>
<textarea name="proposedChangeReason" cols="80" rows="20"></textarea><br>
<br>
<input type="hidden" name="changeTypeId" value="4">
  <table border="0" cellspacing="0" cellpadding="0" valign="left">
    <tr> 
      <td>&nbsp;</td>
      <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
      <td class="tableheader" width="100">
        <div align="right">Est Cost$</div>
      </td>
      <td class="tableheader" width="100">
        <div align="right">Markup %</div>
      </td>
      <td class="tableheader" width="100">
        <div align="right">Seller MU</div>
      </td>
      <td class="tableheader" width="100">
        <div align="right">MC Fee</div>
      </td>
      <td class="tableheader" width="100">
        <div align="right">Price</div>
      </td>
    </tr>
    <tr>
      <td class="label">Quoted Amount:</td>
      <td>&nbsp;&nbsp;</td><%
      if (Integer.parseInt((String)rehash.get("buyerContactId")) == Integer.parseInt((String)rehash.get("siteHostContactId"))) { %>
      <td align="right">
        <input type="text" size="7" name="cost" onChange="updatePrices(<%=(String)rehash.get("marcometGlobalFee")%>, 1, 0, 0)" value="">
      </td>
      <td align="right">
        <div id="percentage">0</div>
		<input type="hidden" name="percentage" value="0">
      </td>
      <td align="right">
        <div id="mu">0</div>
		<input type="hidden" name="mu" value="0">
      </td><%
      } else if (Integer.parseInt((String)rehash.get("siteHostCompanyId")) == Integer.parseInt((String)session.getAttribute("companyId"))) { %>
      <td align="right">
        <input type="text" size="7" name="cost" onChange="updatePrices(<%=(String)rehash.get("marcometGlobalFee")%>, 1, 0, 1)" value="">
      </td>
      <td align="right">
        <input type="text" size="7" name="percentage" onChange="updatePrices(<%=(String)rehash.get("marcometGlobalFee")%>, 1, 0, 1)" value="<%= Double.parseDouble((String)rehash.get("siteHostGlobalMarkup")) * 100 %>">
      </td>
      <td align="right">
        <input type="text" size="7" name="mu" onChange="updatePrices(<%=(String)rehash.get("marcometGlobalFee")%>, 1, 1, 1)" value="">
      </td><%
      } else { %>
      <td align="right">
        <input type="text" size="7" name="cost" onChange="updatePrices(<%=(String)rehash.get("marcometGlobalFee")%>, 1, 0, 0)" value="">
      </td>
      <td align="right">
        <div id="percentage"><%= Double.parseDouble((String)rehash.get("siteHostGlobalMarkup")) * 100 %></div>
		<input type="hidden" name="percentage" value="<%= Double.parseDouble((String)rehash.get("siteHostGlobalMarkup")) * 100 %>">
      </td>
      <td align="right">
        <div id="mu">0</div>
        <input type="hidden" name="mu" value="0">
      </td><%
      } %>
      <td align="right">
        <div id="fee" class="body">0</div>
        <input type="hidden" name="fee" value="0">
      </td>
      <td align="right">
        <div id="price" class="body">0</div>
        <input type="hidden" name="price" value="0">
      </td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td class="label">Quoted Job Price</td>
      <td colspan="5">&nbsp;</td>
      <td align="right" class="body"> 
        <div id="adjustedPrice"><%= (String)rehash.get("price") %></div>
        <input type="hidden" name="jobPrice" value="<%= (String)rehash.get("price") %>">
      </td>
    </tr>
    <tr><td colspan=7  class="body"><b>Credit Limit for this Customer:</b>&nbsp;<%=((creditLimit==0)?"No Limit":"$"+creditLimit)%>&nbsp;&nbsp;|&nbsp;&nbsp;<b>Unpaid orders prior to this job change:</b>&nbsp;$<%=orderBalance%></td></tr>
<tr><td colspan=7  class="body"><b>Credit Status - </b>&nbsp;<%=creditStatus%></td></tr>

  </table>
<br>
<table border="0" width="35%" align="center">
  <tr>
    <td valign='middle' width="44%">
      <div align="center"><a href="javascript:tinyMCE.triggerSave();moveWorkFlow('<%=ai%>')"class="greybutton">Submit Quote</a></div>
    </td>
    <td width="8%">&nbsp;</td>
    <td valign="middle" width="48%"><a href="/minders/JobMinderSwitcher.jsp"class="greybutton">Cancel</a></td>
  </tr>
</table>
<input type="hidden" name="jobId" value="<%=request.getParameter("jobId")%>" >
<input type="hidden" name="nextStepActionId" value="">  
<input type="hidden" name="$$Return" value="[/minders/JobMinderSwitcher.jsp]">
<input type="hidden" name="contactId" value="<%=((UserProfile)session.getAttribute("userProfile")).getContactId()%>">
</form>
</body>
</html>
