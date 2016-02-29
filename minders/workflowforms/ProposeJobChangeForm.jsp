<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<%@ page import="java.sql.*,java.text.*,java.util.*,com.marcomet.jdbc.*,com.marcomet.tools.*,com.marcomet.workflow.*,com.marcomet.users.security.*,com.marcomet.environment.*;" %>
<%@ include file="/includes/SessionChecker.jsp" %>
<jsp:useBean id="validator" class="com.marcomet.tools.FieldValidationBean" scope="page" />
<%
UserProfile up = (UserProfile)session.getAttribute("userProfile");
response.setHeader("Cache-Control","no-cache"); //HTTP 1.1
response.setHeader("Pragma","no-cache"); //HTTP 1.0
response.setDateHeader ("Expires", 0); //prevents caching at the proxy server

String query = "SELECT j.price 'price', j.last_status_id 'laststatusid', jbuyer_contact_id, vendor_contact_id, jsite_host_contact_id, site_host_global_markup, marcomet_global_fee FROM jobs j  WHERE  j.id =" + request.getParameter("jobId");

Connection conn = DBConnect.getConnection();
Statement st = conn.createStatement();
ResultSet rs = st.executeQuery(query);

Hashtable rehash = new Hashtable();

while (rs.next()) {
	rehash.put("price", rs.getString("price"));
	rehash.put("laststatusid", rs.getString("laststatusid"));
	rehash.put("buyerContactId", rs.getString("jbuyer_contact_id"));
	rehash.put("vendorContactId", rs.getString("vendor_contact_id"));
	rehash.put("siteHostContactId", rs.getString("jsite_host_contact_id"));
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
String balanceSQL="select sum(balance) balance from (SELECT (if(j.billed=0,j.billable,j.billed) - if(sum(ar_collection_details.payment_amount) is null,0,sum(ar_collection_details.payment_amount))) as balance FROM contacts c, jobs j left join ar_invoice_details  on ar_invoice_details.jobid = j.id left JOIN ar_invoices ON ar_invoice_details.ar_invoiceid = ar_invoices.id left JOIN ar_collection_details ON ar_collection_details.ar_invoiceid = ar_invoices.id WHERE c.id="+ (String)rehash.get("buyerContactId") +" and if(c.default_site_number=0,c.companyid=j.jbuyer_company_id,j.site_number = c.default_site_number) and j.status_id<>9 and j.status_id<120 group by j.id) a";

ResultSet balRS = st.executeQuery(balanceSQL);
while (balRS.next()) {
	orderBalance = balRS.getInt("balance");
}


%><html>
<head>
  <title>Propose Change Order</title>
  <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
  <link rel="stylesheet" href="<%=(String)session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css">
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
	
window.name="costmain";
var newwindow;
var orderData_Generate;
function newWindow(url)
{
	newwindow=window.open(url,'name','height=500,width=500,left=100, top=100,resizable=yes,scrollbars=yes,toolbar=no,status=no');
}
function init()
{
  document.forms[0].proposedChangeReason.value="";
  document.forms[0].cost.value="";
}

function table_generate() {
	document.forms[0].proposedChangeReason.value= orderData_Generate;
	
}

window.onload=init;

</script>
</head>
<jsp:getProperty name="validator" property="javaScripts" />
<script language="JavaScript" src="/javascripts/mainlib.js"></script>
<body background="<%=(String)session.getAttribute("siteHostRoot")%>/images/back3.jpg">
<form method="post" action="/servlet/com.marcomet.workflow.jobchanges.JobChangeParker">
  <p class="Title">Propose Job Change </p>
  <jsp:include page="/includes/JobDetailHeader.jsp" flush="true"><jsp:param  name="jobId" value="<%=request.getParameter("jobId")%>" /></jsp:include> 
  <p>
  <table border="0" cellspacing="2" cellpadding="0" align="center" >
<tr>
<td colspan='2'>
<p><span class="label">Message / Changes:</span>
<br>
<textarea name="proposedChangeReason" cols="80" rows="20"></textarea>
<a href='javascript:newWindow("/popups/PricingForm.jsp?prodPriceCode=ws-Ad-DOL")' class='greybutton'>CALCULATE AD PRICING</a>&nbsp;&nbsp;<a href='javascript:pop("/popups/PurchaseOrder.jsp?jobId=<%=request.getParameter("jobId")%>&actingRole=vendor","800","800")' class='greybutton'>Show / Adjust PO</a>      
</p></td>
</tr>
<tr><td colspan='2'>&nbsp;</td></tr>
    <tr> 
    <td width='60%' valign='top'>
    <span class="label">Reason for Change:</span>
    <span class='body'><%	String sqlChangeTypes = "select * from jobchangetypes where onoff = 1"; 
	ResultSet rsChangeTypes = st.executeQuery(sqlChangeTypes); 
	while(rsChangeTypes.next()){
		if ( (Integer.parseInt((String)rehash.get("laststatusid")) >= 2) && (Integer.parseInt(rsChangeTypes.getString("value")) == 1) ) {
		} else { %>
			<br>&nbsp;&nbsp;&nbsp;<input type="radio" name="changeTypeId" value="<%= rsChangeTypes.getString("value")%>" <%= ((rsChangeTypes.getString("value").equals("6"))?"checked":"")%> > <%= rsChangeTypes.getString("text")%><%=((rsChangeTypes.getString("needs_approval").equals("1"))?" (needs approval)":"")%>
<%	    }
	} %></span></td>
	<td width='40%' valign='top'><span class="label">Cost change to job:</span><br>
	<table><tr><td class="minderheaderright" > 
          Est Cost$
      </td>
      <td class="minderheaderright" > 
          Price
      </td>
</tr>
    <tr><%
      if (Integer.parseInt((String)rehash.get("buyerContactId")) == Integer.parseInt((String)rehash.get("siteHostContactId"))) { %>
      <td align="right" class="body"> 
        <input type="text" size="12" name="cost" onChange="updatePrices(<%=(String)rehash.get("marcometGlobalFee")%>, 1, 0, 0)" value="" class='lineitemsright'><input type="hidden" name="percentage" value="0"><input type="hidden" name="mu" value="0"><input type="hidden" name="fee" value="0">
      </td>
<%
      } else if (Integer.parseInt((String)rehash.get("siteHostContactId")) == Integer.parseInt(((UserProfile)session.getAttribute("userProfile")).getContactId())) { %>
      <td align="right" class="body"> 
        <input type="text" size="12" name="cost" onChange="updatePrices(<%=(String)rehash.get("marcometGlobalFee")%>, 1, 0, 1)" value="" class='lineitemsright'><input type="hidden" name="percentage" value="0"><input type="hidden" name="mu" value="0"><input type="hidden" name="fee" value="0">
      </td>
<%
      } else { %>
      <td align="right" class="body"> 
        <input type="text" size="12" name="cost" onChange="updatePrices(<%=(String)rehash.get("marcometGlobalFee")%>, 1, 0, 0)" value="" class='lineitemsright'><input type="hidden" name="percentage" value="0"><input type="hidden" name="mu" value="0"><input type="hidden" name="fee" value="0">
      </td>
<%
      } %>

      <td align="right" class="body"> 
        <div id="price" class='lineitems'>0</div>
        <input type="hidden" name="price" value="0">
      </td>
    </tr>
    <tr> 
      <td class="minderheaderright">Adjusted Job Price&nbsp;
      </td>
      <td align="right" class="body"> 
        <span id="adjustedPrice" class="TopborderLable"><%= (String)rehash.get("price") %></span>
        <input type="hidden" name="jobPrice" value="<%= (String)rehash.get("price") %>">
</td></tr></table>
    </td>
    </tr>
<tr><td colspan=2  class="body"><b>Credit Limit for this Customer:</b>&nbsp;<%=((creditLimit==0)?"No Limit":"$"+creditLimit)%>&nbsp;&nbsp;|&nbsp;&nbsp;<b>Unpaid orders prior to this job change:</b>&nbsp;$<%=orderBalance%></td></tr>
<tr><td colspan=2  class="body"><b>Credit Status - </b>&nbsp;<%=creditStatus%></td></tr>
  </table>
  <br>
  <table border="0" width="250" align="center" cellpadding="2">
    <tr valign="middle" align="center"> 
      <td width="50%"> 
        <div align="center"><a href="/minders/JobMinderSwitcher.jsp" class="greybutton">CANCEL</a></div>
      </td>
      <td width="1%">&nbsp;</td>
      <td width="49%"> 
        <div align="center"><a href="javascript:tinyMCE.triggerSave();submitForm()" class="greybutton">SUBMIT</a></div>
      </td>
    </tr>
  </table>
<input type="hidden" name="jobId" value="<%=request.getParameter("jobId")%>" >
<input type="hidden" name="$$Return" value="[/minders/JobMinderSwitcher.jsp]">
<input type="hidden" name="errorPage" value="/minders/workflowforms/ProposeJobChangeForm.jsp">
<input type="hidden" name="contactId" value="<%=((UserProfile)session.getAttribute("userProfile")).getContactId()%>">
</form>
</body>
</html><%st.close(); conn.close();%>
