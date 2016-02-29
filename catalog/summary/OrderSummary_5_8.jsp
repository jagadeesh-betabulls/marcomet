<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<%@ page import="java.sql.*,com.marcomet.users.security.*,com.marcomet.tools.*,com.marcomet.environment.*,java.util.*,com.marcomet.catalog.*;" %>
<%@ taglib uri="/WEB-INF/tld/iterationTagLib.tld" prefix="iterate" %>
<%@ include file="/includes/SessionChecker.jsp" %>
<jsp:useBean id="connection" class="com.marcomet.jdbc.ConnectionBean" scope="session" />
<jsp:useBean id="formater" class="com.marcomet.tools.FormaterTool" scope="page" />
<% UserProfile up = (UserProfile)session.getAttribute("userProfile");
SiteHostSettings shs = (SiteHostSettings)session.getAttribute("siteHostSettings"); 
boolean editor= (((RoleResolver)session.getAttribute("roles")).roleCheck("editor"));
boolean overLimit=false;
int creditStatus = 0;
int countryId = 0;
String nonUSTxt="";
String pageId="";
int creditLimit = 0;
double invoiceBalance=0.00;
double propInvoiceBalance=0.00;
String creditQuery = "select credit_status,country_id,body,p.id pageId, credit_limit from companies c,locations l left join pages p on p.title='Non US Shipments' where l.companyid=c.id  and c.id="+ up.getCompanyId() +" group by c.id";
Connection conn = com.marcomet.jdbc.DBConnect.getConnection();
Statement st = conn.createStatement();
ResultSet creditRS = st.executeQuery(creditQuery);
while (creditRS.next()) {
	creditStatus = creditRS.getInt("credit_status");
	countryId = creditRS.getInt("country_id");
	creditLimit = creditRS.getInt("credit_limit");
	nonUSTxt = creditRS.getString("body");
	pageId = creditRS.getString("pageId");
} 

int validprop = 0;

String propertyvalidationQuery = "SELECT  distinct contacts.id,contacts.default_site_number AS csite,v_properties.site_number AS wsite FROM contacts Inner Join locations on locations.contactid=contacts.id and locations.locationtypeid=1 Left Join v_properties ON contacts.default_site_number = v_properties.site_number and ( left(v_properties.zip,5) =left(locations.zip,5) or  left(v_properties.alt_zip,5) =left(locations.zip,5)) WHERE contacts.id= "  + up.getContactId() + "  and ((v_properties.site_number IS NOT NULL  AND contacts.default_site_number is not null and contacts.default_site_number <> '0' and contacts.default_site_number <> '') or bypass_site_number_validation_flag=1 or contacts.default_site_number='000') order by contacts.default_site_number";

ResultSet propRS = st.executeQuery(propertyvalidationQuery);
while (propRS.next()) {
		validprop = 1;
}

int proppastdue = 0; 

String proparQuery = "select ari.invoice_number, ari.creation_date, ari.ar_invoice_amount, sum(arcd.payment_amount) as invoice_payments, ari.ar_invoice_amount - (if(sum(arcd.payment_amount) is null,0,sum(arcd.payment_amount))) as invoice_balance, (TO_DAYS(NOW()) - TO_DAYS(ari.creation_date)) as age from contacts c left join jobs j on  if(c.default_site_number is null or c.default_site_number=0 or TRIM(LEADING '0' from default_site_number)='' ,j.jbuyer_company_id=c.companyid, j.site_number=c.default_site_number)  inner join ar_invoice_details arid on arid.jobid=j.id left join ar_invoices ari on ari.id=arid.ar_invoiceid left join ar_collection_details arcd on arcd.ar_invoiceid=ari.id  where  c.id =" + up.getContactId() + "  and arid.ar_invoiceid=ari.id and  (ari.exclude_from_credit_check<>1 and ari.exclude_from_statements<>1)  and  (ari.vendor_id = 105 or ari.vendor_id = 2)  group by ari.invoice_number having (invoice_balance) >0.001 or (invoice_balance) < -0.001  order by ari.creation_date";

ResultSet proparRS = st.executeQuery(proparQuery);
while (proparRS.next()) {
	propInvoiceBalance+=(proparRS.getString("invoice_balance") == null || proparRS.getDouble("invoice_balance")>0?0:proparRS.getDouble("invoice_balance"));
	if ( (proparRS.getString("invoice_balance") != null && proparRS.getDouble("invoice_balance")>.001) && proparRS.getInt("age") > 90 ) {
		propInvoiceBalance+=proparRS.getDouble("invoice_balance");
		proppastdue = 1;
	} 
}
proppastdue=((propInvoiceBalance < .01) ? 0:proppastdue);

int pastdue = 0; 
int orderBalance=0;
String balanceSQL="select (sum(t.price) +  sum(t.shipprice)) - sum(t.payments) balance from (select  sum(j.price) price, 0 as shipprice, 0 as  payments from contacts c, jobs  j  where if(c.default_site_number=0,c.companyid=j.jbuyer_company_id,j.site_number=c.default_site_number)  and  c.id="+ up.getContactId() +" and j.status_id<>9 and j.status_id < 120  group by c.id union select 0 as  price, 0 as shipprice,  sum(arcd.payment_amount) payments from contacts c, jobs  j left join ar_invoice_details ari on ari.jobid=j.id left join ar_collection_details arcd on ari.ar_invoiceid=arcd.ar_invoiceid   where if(c.default_site_number =0,c.companyid=j.jbuyer_company_id,j.site_number=c.default_site_number)  and  c.id="+ up.getContactId() +" and j.status_id<>9 and j.status_id < 120  group by c.id union select 0 as  price, sum(s.price) as shipprice, 0 as payments from contacts c, jobs  j left join shipping_data s on s.job_id=j.id  where if(c.default_site_number=0,c.companyid=j.jbuyer_company_id,j.site_number=c.default_site_number)  and  c.id="+ up.getContactId() +" and j.status_id<>9 and j.status_id < 120  group by c.id) as t";

ResultSet balRS = st.executeQuery(balanceSQL);
while (balRS.next()) {
	orderBalance = balRS.getInt("balance");
}


invoiceBalance=0;
String arQuery = "select ari.invoice_number, ari.creation_date, ari.ar_invoice_amount, sum(arcd.payment_amount) as invoice_payments, ari.ar_invoice_amount - (if(sum(arcd.payment_amount) is null,0,sum(arcd.payment_amount))) as invoice_balance, (TO_DAYS(NOW()) - TO_DAYS(ari.creation_date)) as age from ar_invoices ari left join ar_collection_details arcd on arcd.ar_invoiceid=ari.id where (ari.exclude_from_credit_check<>1 and ari.exclude_from_statements<>1) and  (ari.vendor_id = 105 or ari.vendor_id = 2) and ari.bill_to_companyid ="  + up.getCompanyId() + " group by ari.invoice_number having (invoice_balance) >0.001 or (invoice_balance) < -0.001 order by ari.creation_date";

ResultSet arRS = st.executeQuery(arQuery);
while (arRS.next()) {
	invoiceBalance+=((arRS.getString("invoice_balance") == null || arRS.getDouble("invoice_balance")>0 )?0:arRS.getDouble("invoice_balance"));
	if ((arRS.getString("invoice_balance") != null && arRS.getDouble("invoice_balance")>.001) &&  arRS.getInt("age") > 90 ) {
		invoiceBalance+=arRS.getDouble("invoice_balance");
		pastdue = 1;
	} 
}

pastdue=((invoiceBalance < .01) ? 0:pastdue);

 %><html>
<head>
  <title>Pending Job Summary</title>
  <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
  <link rel="stylesheet" href="<%=(String)session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css">
  <link rel="stylesheet" href="/styles/marcomet.css" type="text/css">
  <META HTTP-EQUIV="Cache-Control" CONTENT="no-cache">
	<META HTTP-EQUIV="Pragma" CONTENT="no-cache">
	<META HTTP-EQUIV="Expires" CONTENT="-1">
	<style>.nonUSTxt{background-color:#ffffcc;}</style>
	<script language="javascript" src="/javascripts/mainlib.js"></script>
</head>
<body leftmargin="0" topmargin="0" marginwidth="0" marginheight="0" onLoad="populateTitle('Pending Job Summary')" background="<%=(String)session.getAttribute("siteHostRoot")%>/images/back3.jpg">
<form method="post" action="/servlet/com.marcomet.sbpprocesses.ProcessJobSubmit" >
  <table border="0" cellpadding="0" cellspacing="0" width="100%" height="100%">
    <tr valign="top"> 
      <td colspan="10" height="155"> 
        <table width="98%" align="center" class="body">
          <tr> 
            <p> 
            <td class="Title"colspan="10" height="1"> 
		  <span class="offeringTITLE">
		  <% if (((String)session.getAttribute("siteHostRoot")).equals("/sitehosts/network")) { %>Pending Profile Submittal
		   <% } else { %>
		   Pending Job Summary (Unprocessed Jobs)
		   <% } %>
		</span> 
              <hr align="left" color=red size="1">
            </td>
          </tr>
          <tr> 
            <td class="planheader1" width="60%" height="9">Job Name / Description</td>
            <td class="planheader1" width="10%" height="9">Job Specs</td>
            <td class="planheader1" width="10%" height="9">Remove?</td>
            <td class="planheader1" width="10%" height="9"> 
              <div align="right"><%=( ((String)session.getAttribute("siteHostRoot")).equals("/sitehosts/network")?"Price":"Estimate" )%></div>
            </td>
            <td class="planheader1" width="10%" height="8"> 
              <div align="right">Deposit/Payment</div>
            </td>
          </tr>
          <%
        double priceSubtotal = 0.00;
		double depositSubtotal = 0.00;
        boolean ordersPresent = false;
		ShoppingCart shoppingCart = (ShoppingCart)session.getAttribute("shoppingCart");
        if (shoppingCart != null) {
        	overLimit=(((orderBalance+shoppingCart.getOrderPrice())>creditLimit && creditLimit>0)?true:false);
           Vector projects = shoppingCart.getProjects();
           if (projects.size() > 0) {
              for (int i=0; i<projects.size(); i++) { 
                 ProjectObject po = (ProjectObject)projects.elementAt(i);
                 Vector jobs = po.getJobs();
                 for (int j=0; j<jobs.size(); j++) {
                    JobObject jo = (JobObject)jobs.elementAt(j);
                    double price = jo.getPrice();
					double deposit = jo.getEscrowDollarAmount();
                    ordersPresent = true; %>
          <tr> 
            <td class="lineitems"><%=jo.getJobName()%></td>
            <td class="lineitems"> 
              <div align="center"><a href="javascript:pop('/catalog/summary/OrderSummaryJobDetails.jsp?jobId=<%= jo.getId()%>','500','500')" class="minderACTION">view</a></div>
            </td>
            <td class="lineitems"> 
              <div align="center"><a href="/catalog/summary/RemoveProjectConfirmation.jsp?projectId=<%= po.getId()+"" %>" class="minderACTION">delete</a></div>
            </td>
            <td class="lineitems"> 
              <div align="right"><%= (jo.isRFQ())?"RFQ":formater.getCurrency(price)%></div>
            </td>
            <td class="lineitems"> 
              <div align="right"><%= formater.getCurrency(deposit)%></div>
            </td>
          </tr><%
                 }
              } 
			%><tr> 
            <td>&nbsp;</td>
            <td>&nbsp;</td>
            <td class="lineitems"> 
              <div align="right">Totals:</div>
            </td>
            <td class="lineitems"> 
              <div align="right"><%= formater.getCurrency(shoppingCart.getOrderPrice()) %></div>
            </td>
            <td class="lineitems"> 
              <div align="right"><%= formater.getCurrency(shoppingCart.getOrderEscrowTotal()) %></div>
            </td>
          </tr><%
           } else { 
			%><tr> 
            <td class="lineitems" colspan="10">Empty No Orders Present</td>
          </tr>
          <%
           }
        } else { %>
          <tr> 
            <td class="lineitems" colspan="10" height="2">Empty No Orders Present</td>
          </tr>
          <%
        } %>
        </table>
      </td>
    </tr>
    <tr> 
      <td width="2%">&nbsp;&nbsp;&nbsp;</td>
      <td class="body" width="95%" valign="top"><%
 if (((String)session.getAttribute("siteHostRoot")).equals("/sitehosts/network")) { %>
	  Processing your profiling job(s) will submit them for our review and processing and will save them to your Profiling Console. Your Profiling Console enables you to view your job's status. Upon receiving your profiling job, we will review and process your profiling data. We will contact you if necessary to to discuss any potential changes or advice that may be beneficial or required. 
  Thank You.<%
 } else { 
	%>Processing your job(s) will submit them for our review and will save them to your Jobs Console. Your Jobs Console enables you to view your jobs status and manage it through completion. Upon receiving your jobs, we will review the job specifications and contact you to discuss any potential changes or advice that may be beneficial or required. </p>
        <p> Any estimates displayed are for your budgetary information and actual pricing will be determined upon our review of your specific job request. All quotes or required changes to your estimate will be sent to you for approval prior to the commencement of work </p>
        <p>You you may continue to add as many jobs as you wish before processing by clicking on &quot;Add New&quot; below. Thank You.</p><%String editTxt=((editor)?"<a href= 'javascript:pop(\"/popups/QuickChangeInnerForm.jsp?inner=nonUSTxt&cols=70&rows=6&question=Change%20Non-US%20Text&primaryKeyValue="+pageId+"&columnName=body&tableName=pages&valueType=string\",600,200)'>&raquo;</a>&nbsp;":"");%><%=((countryId!=1 || editor)?"<div class=nonUSTxt>"+ editTxt + "<span id=nonUSTxt>" + nonUSTxt + "</span></div>":"")%><%

 } 
%></td>
      <td width="4%"></td>
    </tr><%
  if(ordersPresent) { 
	%><tr> 
      <td valign="bottom" colspan="100%" align="center"> 
        <table><%=(((proppastdue+pastdue)>0) ? "<tr><td colspan=3>Balance Over 90 days for all accounts on this property: "+formater.getCurrency(propInvoiceBalance)+"</td></tr>":"")%><%=(((proppastdue+pastdue)>0) ? "<tr><td colspan=3>Balance Over 90 days for this account: "+formater.getCurrency(invoiceBalance)+"</td></tr>":"")%>
		<tr><%
		 if ( creditStatus != 2 && overLimit ) { 
			%><td colspan = 3 class="errorbox" >Processing this order requires an increase to your existing credit
limit with us.<br>Please click "Contact Info" below to reach Marketing Services for assistance.  Thank you.<br><br>
              <a class="menuLINK" href="javascript:pop('<%=(String)session.getAttribute("siteHostRoot")%>/contents/contacts.jsp','650','450')">[CONTACT INFO]</a>
          </td><%
 
 } else if ( creditStatus != 2 && pastdue == 1 ) { 
			%><td colspan = 3 class="errorbox" >Online ordering has been temporarily suspended until your overdue invoices are paid.<br>Please click "home" to go back to the home page, then click on your overdue invoices listed on the lower left to pay immediately by credit card and complete your order, or to print them and pay by check.  If you need immediate assistance, please click "contact info" below to reach Marketing Services.<br><br>
              <a class="menuLINK" href="javascript:pop('<%=(String)session.getAttribute("siteHostRoot")%>/contents/contacts.jsp','650','450')">[CONTACT INFO]</a>
          </td><%
 
 } else if ( creditStatus != 2 && proppastdue == 1) { 
	%> <td colspan = 3 class="errorbox" >Online ordering for your account has been temporarily suspended for overdue invoices from other accounts related to your property.<br>Please click "contact info" below to reach Marketing Services so that we may resolve your account.<br><br>
              <a  class="menuLINK"  href="javascript:pop('<%=(String)session.getAttribute("siteHostRoot")%>/contents/contacts.jsp','650','450')">[CONTACT INFO]</a>
          </td> <%

 
 } else if ( creditStatus == 1 || validprop == 0) { 
	%> <td colspan = 3 class="errorbox" ><b>Online ordering for your account has been temporarily suspended for account validation.<br>Please click "contact info" below to reach Marketing Services and validate your account.</b><br><br><a class="menuLINK" href="javascript:pop('<%=(String)session.getAttribute("siteHostRoot")%>/contents/contacts.jsp','650','450')">[CONTACT INFO]</a>
          </td> <%
 } 
 %></tr>
          <tr><% 
          
     if (((String)session.getAttribute("siteHostRoot")).equals("/sitehosts/network")) { 
	%><td align="center"></td><%

	 } else { 
		if (( creditStatus != 1 && validprop == 1 && pastdue == 0 ) || creditStatus == 2) { 
			%><td align="center"><a href="javascript:parent.window.location.replace('/index.jsp?contents=<%=(String)session.getAttribute("siteHostRoot")%>/contents/SiteHostCommerceIndex.jsp')" class="greybutton">Add&nbsp;New</a></td><%
		 } else { 
			%><td align="center">&nbsp&nbsp&nbsp</td><%
		 } 
	} 
	if (session.getAttribute("demo")==null && ((validprop == 1 && proppastdue != 1 &&  creditStatus != 1 && pastdue == 0 ) || creditStatus == 2)) { %>
            <td align="left"><a href="/catalog/checkout/OrderCheckOutForm.jsp" class="greybutton">Process</a></td>
		   <% 
	} else { %>
            <td align="center"><a href="/" class="greybutton">Home</a></td><%=((session.getAttribute("demo")==null)?"":"</tr><tr><td align=center colspan=3 class=title>[ DEMO SITE ]</td>")%><%
 	} 
			%></tr>
        </table>
      </td>
    </tr><%	
  } else { 
	%><tr> 
      <td valign="bottom" colspan="100%" align="center"> 
        <table><%=(((proppastdue+pastdue)>0) ? "<tr><td colspan=3>Balance Over 90 days for all accounts on this property: "+formater.getCurrency(propInvoiceBalance)+"</td></tr>":"")%><%=(((proppastdue+pastdue)>0)  ? "<tr><td colspan=3>Balance Over 90 days for this account: "+formater.getCurrency(invoiceBalance)+"</td></tr>":"")%>
          <tr>
            <td align="right"><a href="javascript:parent.window.location.replace('/index.jsp?contents=<%=(String)session.getAttribute("siteHostRoot")%>/contents/SiteHostCommerceIndex.jsp')" class="greybutton">Add&nbsp;New</a></td>
            <td>&nbsp;</td>
            <td align="left"><a href="/" class="greybutton">Home</a></td>
          </tr>
        </table>
      </td>
    </tr><%
  } 
%><tr> 
      <td valign="bottom" align="center" colspan="10"> 
        <jsp:include page="/footers/inner_footer.jsp" flush="true"></jsp:include>
      </td>
    </tr>
  </table>
</form>
</body>
</html><%conn.close(); %>