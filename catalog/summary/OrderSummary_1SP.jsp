<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<%@ page import="java.text.*,java.sql.*,com.marcomet.users.security.*,com.marcomet.tools.*,com.marcomet.environment.*,java.util.*,com.marcomet.catalog.*;" %>
<%@ taglib uri="/WEB-INF/tld/iterationTagLib.tld" prefix="iterate" %>
<%@ include file="/includes/SessionChecker.jsp" %>
<%@ taglib uri="/WEB-INF/tld/taglib.tld" prefix="taglib" %>
<jsp:useBean id="sl" class="com.marcomet.tools.SimpleLookups" scope="page" />
<jsp:useBean id="connection" class="com.marcomet.jdbc.ConnectionBean" scope="session" />
<jsp:useBean id="formater" class="com.marcomet.tools.FormaterTool" scope="page" />
<% 
UserProfile up = (UserProfile)session.getAttribute("userProfile");

Connection conn = com.marcomet.jdbc.DBConnect.getConnection();
Statement st = conn.createStatement();
DecimalFormat numberFormatter = new DecimalFormat("#,###,###");
String previewTemplate="/preview/brochure_from_sc.jsp";
SiteHostSettings shs = (SiteHostSettings)session.getAttribute("siteHostSettings"); 
boolean editor= (((RoleResolver)session.getAttribute("roles")).roleCheck("editor"));
boolean overLimit=false;
int creditStatus = 0;
int countryId = 0;
String nonUSTxt="";
String pageId="";
String orderSummaryTxt="";
String spPageId="";
int co_days=0;
int jobId=0;
String fileName="";
int poId=0;
ResultSet coRS = st.executeQuery("select distinct if(b.id is not null,b.default_number,a.default_number) as 'default_number' from sys_defaults a left join sys_defaults b on a.title=b.title and b.sitehost_id='"+shs.getSiteHostId()+"' where a.title='checkout_hold'");
if (coRS.next()){	co_days=coRS.getInt("default_number");}

int creditLimit = 0;
double invoiceBalance=0.00;
double propInvoiceBalance=0.00;
String creditQuery = "select credit_status,country_id,p.body as body,sp.body as spBody,p.id pageId,sp.id spPageId, credit_limit from companies c,locations l left join pages p on p.title='Non US Shipments' left join pages sp on sp.page_name='orderSummaryText' where l.companyid=c.id  and c.id="+ up.getCompanyId() +" group by c.id";
ResultSet creditRS = st.executeQuery(creditQuery);
while (creditRS.next()) {
	creditStatus = creditRS.getInt("credit_status");
	countryId = creditRS.getInt("country_id");
	creditLimit = creditRS.getInt("credit_limit");
	nonUSTxt = creditRS.getString("body");
	pageId = creditRS.getString("pageId");
	orderSummaryTxt = creditRS.getString("spBody");
	spPageId = creditRS.getString("spPageId");
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
	if ( (proparRS.getString("invoice_balance") != null && proparRS.getDouble("invoice_balance")>.001) && proparRS.getInt("age") > co_days ) {
		propInvoiceBalance+=proparRS.getDouble("invoice_balance");
		proppastdue = 1;
	} else if ( (proparRS.getString("invoice_balance") != null && proparRS.getDouble("invoice_balance")<.001)) {
		propInvoiceBalance+=proparRS.getDouble("invoice_balance");
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
	if ((arRS.getString("invoice_balance") != null && arRS.getDouble("invoice_balance")>.001) &&  arRS.getInt("age") > co_days ) {
		invoiceBalance+=arRS.getDouble("invoice_balance");
		pastdue = 1;
	} else if ((arRS.getString("invoice_balance") != null && arRS.getDouble("invoice_balance")<.001) ) {
		invoiceBalance+=arRS.getDouble("invoice_balance");
	} 
}

pastdue=((invoiceBalance < .01) ? 0:pastdue);
String promoStatus="";
if (session.getAttribute("promoCode")!=null && !(session.getAttribute("promoCode").toString().equals(""))){
	ResultSet arPromo = st.executeQuery("Select if(end_date<NOW(),'has expired and will not be applied.',if(start_date>NOW(),'has not started yet and will not be applied.','Valid')) as status from promotions where promo_code='"+session.getAttribute("promoCode").toString()+"'");
	while (arPromo.next()) {
		promoStatus=arPromo.getString("status");
	}
}
 %><html>
<head>
<%
if (session.getAttribute("selfDesigned")==null || session.getAttribute("selfDesigned").toString().equals("false")){%>
  <title>Pending Job Summary</title>
  <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
  <link rel="stylesheet" href="/styles/marcomet.css" type="text/css">
  <link rel="stylesheet" href="<%=(String)session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css">

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
            <td class="planheader1" width="60%" height="9">Job Name / Description (Click to view Job Details)</td>
            <td class="planheader1" width="10%" height="9">Quantity</td>
                        <td class="planheader1" width="10%" height="9">Remove from Cart?</td>
            <td class="planheader1" width="10%" height="9"> 
              <div align="right"><%=( ((String)session.getAttribute("siteHostRoot")).equals("/sitehosts/network")?"Price&nbsp;":"Estimate&nbsp;" )%></div>
            </td>
            <td class="planheader1" width="10%" height="8"> 
              <div align="right">Shipping&nbsp;</div>
            </td>
            <td class="planheader1" width="10%" height="8"> 
              <div align="right">Deposit/Payment&nbsp;</div>
            </td>
          </tr>
          <%
        double priceSubtotal = 0.00;
        double shipSubtotal = 0.00;
		double depositSubtotal = 0.00;
        boolean ordersPresent = false;
		ShoppingCart shoppingCart = (ShoppingCart)session.getAttribute("shoppingCart");
        if (shoppingCart != null) {
        	overLimit=(((orderBalance+shoppingCart.getOrderPrice())>creditLimit && creditLimit>0)?true:false);
           Vector projects = shoppingCart.getProjects();
           if (projects.size() > 0) {
              for (int i=0; i<projects.size(); i++) { 
                 ProjectObject po = (ProjectObject)projects.elementAt(i);
                 poId=po.getId();
                 Vector jobs = po.getJobs();
                 for (int j=0; j<jobs.size(); j++) {
                    JobObject jo = (JobObject)jobs.elementAt(j);
                    //if this page was entered as a result of a self-help designed file run that was turned into an order push the price and quantity values into the job and remove the 'usePreview' from session.
                   
                   if(request.getParameter("priorJobId")!=null && !request.getParameter("priorJobId").equals("")){
                   		jo.setPriorJobId(((request.getParameter("priorJobId")==null || request.getParameter("priorJobId").equals(""))?"":request.getParameter("priorJobId")));
                   }
                    
					if(	request.getParameter("orderFromSelfDesigned")!=null && request.getParameter("orderFromSelfDesigned").equals("true")){
						//push quantity and price into job	
						jo.setQuantity(Integer.parseInt(((request.getParameter("quantity")==null || request.getParameter("quantity").equals(""))?"0":request.getParameter("quantity"))));
						double jPrice=Double.parseDouble(((request.getParameter("price")==null || request.getParameter("price").equals(""))?"0":request.getParameter("price")));
						JobSpecObject jso = new JobSpecObject(99999, 99999, "Base Price", jPrice, 0.00, Integer.parseInt(up.getContactId()), Integer.parseInt(shs.getSiteHostId()), false);

						jo.addJobSpec(jso);
						session.setAttribute("usePreview","false");
						session.setAttribute("selfDesigned","false");
					}
                    double price = jo.getPrice();
                    double shipping = jo.getShippingPrice();
                    int shipPricePolicy=jo.getShippingPricePolicy();;
                    shipSubtotal=shipSubtotal+shipping;
					double deposit = jo.getEscrowDollarAmount();
                    ordersPresent = true; 
                    %>
          <tr> 
            <td class="lineitems"><%
            %><a href="javascript:pop('/catalog/summary/OrderSummaryJobDetails.jsp?jobId=<%= jo.getId()%>','500','500')" class="minderACTION"><%=jo.getJobName()%></a></td>
            <td class="lineitems">
              <div align="right"><%=((jo.getQuantity()==0)?"NA":numberFormatter.format(jo.getQuantity()))%></div>
            </td>
            <td class="lineitems"> 
              <div align="center"><a href="/catalog/summary/RemoveProjectConfirmation.jsp?projectId=<%= po.getId()+"" %>" class="minderACTION">delete</a></div>
            </td>
            <td class="lineitems"> 
              <div align="right"><%= (jo.isRFQ())?"RFQ":formater.getCurrency(price)%></div>
            </td>
            <td class="lineitems"> 
              <div align="right"><%= ((shipPricePolicy==1)?"Included":((shipping==0.00)?"TBD":formater.getCurrency(shipping)))%></div>
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
              <div align="right"><%= formater.getCurrency(shipSubtotal) %></div>
            </td>
            <td class="lineitems"> 
              <div align="right"><%= formater.getCurrency(shoppingCart.getOrderEscrowTotal()) %></div>
            </td>
          </tr>
          <tr> 
            <td class="lineitems" colspan=5 align="right"><%if(session.getAttribute("promoCode")==null || session.getAttribute("promoCode").toString().equals("")){%> 
         <a href="javascript:pop('/popups/PromoCode.jsp','250','150')" class='menuLink'>&nbsp;&raquo;&nbsp;Apply Promo Code&nbsp;</a><span align="right" id="promoCode" class='lineitems'></span><%}else{%><a href="javascript:pop('/popups/PromoCode.jsp','250','150')" class='menuLink'>&nbsp;&raquo;&nbsp;Change Promo Code&nbsp;</a><span align="right" id="promoCode" class='lineitems'>Promo Code:&nbsp;<%=session.getAttribute("promoCode").toString()%>&nbsp;<%if (promoStatus==null || promoStatus.equals("") ){session.removeAttribute("promoCode");%><font color='red'>NOTE:Invalid&nbsp;Promo&nbsp;Code</font><%}else if(!promoStatus.equals("Valid")){session.removeAttribute("promoCode");%><font color='red'>NOTE:Promotion&nbsp;<%=promoStatus%></font><%}%></span><%}%>
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
	%>
	<%
	String editTxt2=((editor)?"<a href= 'javascript:pop(\"/popups/QuickChangeInnerForm.jsp?inner=orderSummaryTxt&cols=70&rows=6&question=Change%20Order%20Text%20Text&primaryKeyValue="+spPageId+"&columnName=body&tableName=pages&valueType=string\",600,200)'>&raquo;</a>&nbsp;":"");
	%><div class=bodytext><%=editTxt2%><span id=orderSummaryTxt><%=orderSummaryTxt%></span></div>
	<br><%String editTxt=((editor)?"<a href= 'javascript:pop(\"/popups/QuickChangeInnerForm.jsp?inner=nonUSTxt&cols=70&rows=6&question=Change%20Non-US%20Text&primaryKeyValue="+pageId+"&columnName=body&tableName=pages&valueType=string\",600,200)'>&raquo;</a>&nbsp;":"");%><%=((countryId!=1 || editor)?"<div class=nonUSTxt>"+ editTxt + "<span id=nonUSTxt>" + nonUSTxt + "</span></div>":"")%><%

 } 
%></td>
      <td width="4%"></td>
    </tr><%
  if(ordersPresent) { 
	%><tr> 
      <td valign="bottom" colspan="100%" align="center"> 
        <table><%=(((proppastdue+pastdue)>0) ? "<tr><td colspan=3>Balance Over "+co_days+" days for all accounts on this property: "+formater.getCurrency(propInvoiceBalance)+"</td></tr>":"")%><%=(((proppastdue+pastdue)>0) ? "<tr><td colspan=3>Balance Over "+co_days+" days for this account: "+formater.getCurrency(invoiceBalance)+"</td></tr>":"")%>
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
	if (session.getAttribute("demo")==null && ((validprop == 1 && proppastdue != 1 &&  creditStatus != 1 && pastdue == 0 && overLimit==false) || creditStatus == 2)) { %>
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
        <table><%=(((proppastdue+pastdue)>0) ? "<tr><td colspan=3>Balance Over "+co_days+" days for all accounts on this property: "+formater.getCurrency(propInvoiceBalance)+"</td></tr>":"")%><%=(((proppastdue+pastdue)>0)  ? "<tr><td colspan=3>Balance Over "+co_days+" days for this account: "+formater.getCurrency(invoiceBalance)+"</td></tr>":"")%>
          <tr>
            <td align="right"><a href="javascript:parent.window.location.replace('/index.jsp?contents=<%=(String)session.getAttribute("siteHostRoot")%>/contents/SiteHostIndex.jsp')" class="greybutton">Add&nbsp;New</a></td>
            <td>&nbsp;</td>
            <td align="left"><a href="/" class="greybutton">Home</a></td>
          </tr>
        </table>
      </td>
    </tr><%
  } 
  //if this is called from the 'Process Jobs' button don't use the footer
  if(HttpUtils.getRequestURL(request).toString().indexOf("OrderSummary")==-1){
%><tr> 
      <td valign="bottom" align="center" colspan="10"> 
        <jsp:include page="/footers/inner_footer.jsp" flush="true"></jsp:include>
      </td>
    </tr><%}%>
  </table>
    <input type="hidden" name="priorJobId" value="<%=request.getParameter("priorJobId")%>">  
</form><%
	if(session.getAttribute("reprintJob")!=null){
		session.removeAttribute("reprintJob");
		session.removeAttribute("priorJobId");
	}
}else{ 

/*********************************************************************************************************
//if this is the result of a self-designed 'run'
**********************************************************************************************************/


String rePrint=((request.getParameter("rePrint")==null || request.getParameter("rePrint").equals("") || request.getParameter("rePrint").equals("false"))?"false":"true");
session.setAttribute("reprintJob",rePrint);

%>  <title>Self-Designed Item Summary</title>
  <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
  <link rel="stylesheet" href="<%=(String)session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css">
  <link rel="stylesheet" href="/styles/marcomet.css" type="text/css">
  <META HTTP-EQUIV="Cache-Control" CONTENT="no-cache">
	<META HTTP-EQUIV="Pragma" CONTENT="no-cache">
	<META HTTP-EQUIV="Expires" CONTENT="-1">
	<style>.nonUSTxt{background-color:#ffffcc;}</style>
	<script language="javascript" src="/javascripts/mainlib.js"></script>
</head>
<body leftmargin="10" topmargin="0" marginwidth="0" marginheight="0" onLoad="populateTitle('Self-Designed Item Summary')" >
<form method="post" action="/servlet/com.marcomet.sbpprocesses.ProcessJobSubmit" >
  <table border="0" cellpadding="0" cellspacing="0" width="100%" height="100%" align="center">
    <tr valign="top"> 
      <td colspan="10" valign="top"> 
        <table width="100%" align="center" class="body">
          <tr> 
            <p> 
            <td class="Title"colspan="10" height="1" style="margin-left:10px;"> 
		  <div class="offeringTITLE">
		   New Self-Help Design Center:<br>What would you like to do with the file you've just designed:
		</div> 
		<div class="bodyblack">
		   Please choose how you would like to process this pdf file. 
		</div>
            </td>
          </tr>
          <%
        double priceSubtotal = 0.00;
        double shipSubtotal = 0.00;
		double depositSubtotal = 0.00;
        boolean ordersPresent = false;
        String pdfPreviewTemplate="";
		ShoppingCart shoppingCart = (ShoppingCart)session.getAttribute("shoppingCart");
		JobSpecObject jso1 = (JobSpecObject)shoppingCart.getJobSpec(9100);
		if (jso1 != null ){
			pdfPreviewTemplate = (String)jso1.getValue();
		}else{
		 	pdfPreviewTemplate = "";
		}
        if (shoppingCart != null) {
        	overLimit=(((orderBalance+shoppingCart.getOrderPrice())>creditLimit && creditLimit>0)?true:false);
           Vector projects = shoppingCart.getProjects();
           if (projects.size() > 0) {
              for (int i=0; i<projects.size(); i++) { 
                 ProjectObject po = (ProjectObject)projects.elementAt(i);
                 poId=po.getId();
                 Vector jobs = po.getJobs();
                 for (int j=0; j<jobs.size(); j++) {
                    JobObject jo = (JobObject)jobs.elementAt(j);
                    if(request.getParameter("jobId").equals(jo.getId()+"")){
                    	jobId=jo.getId();
	                    double price = jo.getPrice();
	                    double shipping = jo.getShippingPrice();
	                    int shipPricePolicy=jo.getShippingPricePolicy();;
	                    shipSubtotal=shipSubtotal+shipping;
						double deposit = jo.getEscrowDollarAmount();
	                    ordersPresent = true;
	                    fileName=jo.getPreBuiltPDFFileURL();
	                }
                 }
              } 

           } else { 
			%><tr> 
            <td class="lineitems" colspan="10">Empty No Items Present</td>
          </tr>
          <%
           }
        } else { %>
          <tr> 
            <td class="lineitems" colspan="10" height="2">Empty No Items Present</td>
          </tr>
          <%
        } %>
        </table>
      </td>
    </tr>

<tr>
<td>
<table>
<tr>
		<td align="left" ><blockquote style="margin-left:40px;"><a href="javascript:saveFile('<%=previewTemplate%>','<%=pdfPreviewTemplate.replace(".","_laser.")%>','Laser','false')" class="plainLink" style="color:#0044a0;">&raquo;&nbsp;Save and Download a Laser-Printable PDF</a><span class="bodyBlack">-- Allows you to save to your PC a PDF file which can be printed on your color laser printer.</span> 
		<br><br><br>
		<a href="javascript:saveFile('<%=previewTemplate%>','<%=pdfPreviewTemplate.replace(".","_prepress.")%>','PrePress','false')" class="plainLink" style="color:#0044a0;">&raquo;&nbsp;Save and Download a Press-Ready PDF</a><span class="bodyBlack"> -- Allows you to save to your PC a professional press-ready PDF file which you can deliver to the printer of your choice.</span>
		<br><br>
		<span class="bodyBlack"><b>Place an Order to Print this File</b> -- If you'd like us to print the file you've just designed simply choose the quantity from the grid below.</span></div><div>&nbsp;&nbsp;&nbsp; <br><%
        //Create the pricing grid
        Vector vPrices = new Vector();
        int y=0;
        String pSQL="Select count(pp.id) as numZero from product_prices pp,products p where pp.prod_price_code=p.prod_price_code and (quantity=0 || price <=.009) and p.id="+((request.getParameter("productId")==null)?"''":request.getParameter("productId"))+" group BY pp.prod_price_code";
        
        ResultSet rsPriceCount = st.executeQuery(pSQL);
        int numZero=0;
		if(rsPriceCount.next()){
			numZero=((rsPriceCount.getString("numZero")==null || rsPriceCount.getString("numZero").equals(""))?0:rsPriceCount.getInt("numZero"));
		}
		
        pSQL="Select format(quantity,0) as quantity,format(price,2) as price,format(price/quantity,3) as perItem  from product_prices pp,products p where pp.prod_price_code=p.prod_price_code and quantity>0 and price >.009 and p.id="+((request.getParameter("productId")==null)?"''":request.getParameter("productId"))+" ORDER BY pp.quantity";
		int colNum=numZero;
		ResultSet rsPrices = st.executeQuery(pSQL);
		while (rsPrices.next()){
			vPrices.addElement(((rsPrices.getString("quantity")==null)?"":rsPrices.getString("quantity")));
			vPrices.addElement(((rsPrices.getString("price")==null)?"":rsPrices.getString("price")));
			vPrices.addElement(((rsPrices.getString("perItem")==null)?"":rsPrices.getString("perItem")));
			y++;			
		}
		if(y>0){
			%><table border="0" cellpadding="0" cellspacing="0" width="100%">
  <tr><td class="catalogLABEL" colspan="<%=y+1%>">Click on price to continue...</td></tr>
  <tr><td class="tableheader" colspan="<%=y%>">Quantity (sheet)</td></tr>
  <tr><%
			for (int z=0; z<vPrices.size(); z=z+3) {
				%><td class="planheader2" align="center"><%=vPrices.get(z).toString()%></td><%
			}%>
	  </tr>  <tr><%
			for (int z=0; z<vPrices.size(); z=z+3) {
				%><td class="lineitems" align="center" onMouseOver="this.style.backgroundColor='#FFEBCD';" onMouseOut='this.style.backgroundColor="white"' ><a class="lineitemslink" href="javascript:orderJobFromSelfDesigned('0','<%=colNum++%>','<%=vPrices.get(z).toString().replaceAll(",","")%>','<%=vPrices.get(z+1).toString().replaceAll(",","")%>','<%=previewTemplate%>','<%=pdfPreviewTemplate.replace(".","_prepress.")%>','PrePress','true')">$<%=vPrices.get(z+1).toString()%>&nbsp;<span class="pricePerItem"> [$<%=vPrices.get(z+2).toString()%> each]</span></a></td><%
			}%>
	</table><%
		}else{%><table style="border: #7f8180 1px solid;" cellpadding="2" cellspacing="0">
          		<tr><td class='tableHeader'>Price Quoted at Time of Order</td></tr></table><%
        }
        //<br>&nbsp;&nbsp;&nbsp;<a href="javascript:orderJobFromSelfDesign()" class="greybutton">ORDER&nbsp;&raquo;</a></div></td>%>
	<br>
	<img src="/images/spacer.gif" height="40">
	<br>
	<div align="center" id="processButtons"><a href="/catalog/summary/RemoveSelfDesignedConfirmation.jsp?projectId=<%=poId%>" class="greybutton">&nbsp;&nbsp;CANCEL AND DELETE THE FILE&nbsp;&nbsp;</a><br><br></div>     
	</blockquote>
	
	 </td>
    </tr>
</table>

</td>
</tr>
<tr><td>&nbsp;</td></tr>
  </table>
<div id='pdfPrep' style="display:none;"><iframe height="0"  width="0" marginwidth="0" marginheight="0" frameborder="0" id="preview" name="preview" ></iframe></div>
  <table width=100% ><tr><td>
        <jsp:include page="/footers/inner_footer.jsp" flush="true"></jsp:include>
      </td>
    </tr>
  </table>-->
<script>
  function orderJobFromSelfDesigned(rowNum,colNum,quantity,price,prodTemplate,pdfTemplate,savedFileType,rePrint){
  		if (document.getElementById('processButtons').innerHTML=='<span class="menuLink">&nbsp;&nbsp;PROCESSING REQUEST . . .&nbsp;&nbsp;</span>'){
  			alert('Your request is already being processed, please wait for it to complete.');
			Return;
  		}
  		document.forms[0].lastRow.value=rowNum;
  		document.forms[0].lastCol.value=colNum;
  		document.forms[0].quantity.value=quantity;
  		document.forms[0].price.value=price;
  		document.forms[0].orderFromSelfDesigned.value='true';
  		document.forms[0].target='preview';
		saveFile(prodTemplate,pdfTemplate,savedFileType,rePrint);
  }
  
  function saveFile(prodTemplate,pdfTemplate,savedFileType,rePrint){
	if (document.getElementById('processButtons').innerHTML=='<span class="menuLink">&nbsp;&nbsp;PROCESSING REQUEST . . .&nbsp;&nbsp;</span>'){
		alert('Your request is already being processed, please wait for it to complete.');
		Return;
	}
  	document.getElementById('processButtons').innerHTML='<span class="menuLink">&nbsp;&nbsp;PROCESSING REQUEST . . .&nbsp;&nbsp;</span>';
	document.forms[0].savedFileType.value=savedFileType;
	document.forms[0].pdfPreviewTemplate.value=pdfTemplate;
	document.forms[0].rePrint.value=rePrint;
  	document.forms[0].printFileType.value=savedFileType;
    document.forms[0].action="/catalog/checkout/SaveTemplatedFile.jsp";
    document.getElementById('preview').src='http://<%=((session.getAttribute("baseURL")==null)?"":session.getAttribute("baseURL").toString())%>'+prodTemplate+'?saveFile=true&pdfPreviewTemplate='+pdfTemplate+'&savedFileType='+savedFileType+'&catJobId=<%=request.getParameter("catJobId")%>';
}


</script>
  <input type="hidden" name="orderFromSelfDesigned" value="">
  <input type="hidden" name="quantity" value="">
  <input type="hidden" name="coordinates" value="">
  <input type="hidden" name="selfDesigned" value="<%=((request.getParameter("selfDesigned")==null)?"":request.getParameter("selfDesigned"))%>">
  <input type="hidden" name="vendorId" value="<%=request.getParameter("vendorId")%>">
  <input type="hidden" name="prePopId" value="<%=request.getParameter("prePopId")%>">
  <input type="hidden" name="prePopTable" value="<%=request.getParameter("prePopTable")%>">
  <input type="hidden" name="siteHostId" value="<%=shs.getSiteHostId()%>">
  <input type="hidden" name="currentCatalogPage" value="2">
  <input type="hidden" name="catJobId" value="<%=request.getParameter("catJobId")%>">
  <input type="hidden" name="priorJobId" value="<%=request.getParameter("priorJobId")%>">  
  <input type="hidden" name="offeringId" value="<%=request.getParameter("offeringId")%>">
  <input type="hidden" name="tierId" value="<%=request.getParameter("tierId")%>">
  <input type="hidden" name="prodCode" value="<%=request.getParameter("prodCode")%>">
  <input type="hidden" name="usePreview" value="<%=request.getParameter("usePreview")%>">
  <input type="hidden" name="savedFileType" value="">
  <input type="hidden" name="printFileType" value="<%=((request.getParameter("printFileType")==null)?"":request.getParameter("printFileType"))%>">
  <input type="hidden" name="productCode" value="<%=((request.getParameter("productCode")==null)?"":request.getParameter("productCode"))%>">
  <input type="hidden" name="productId" value="<%=((request.getParameter("productId")==null)?"":request.getParameter("productId"))%>">
  <input type="hidden" name="price" value="">
  <input type="hidden" name="pdfPreviewTemplate" value="">
  <input type="hidden" name="rePrint" value="">
  <input type="hidden" name="jobId" value="<%=jobId%>">
  <input type="hidden" name="projectId" value="<%=poId%>">
  <input type="hidden" name="lastRow" value="">
  <input type="hidden" name="lastCol" value="">

</form>

<%}
st.close();conn.close();
if(session.getAttribute("saveFileType")!=null){
	String saveFileType=session.getAttribute("saveFileType").toString();
	session.removeAttribute("saveFileType");
	//<script>saveFile('saveFileType');</script>
}
%></body>
</html>