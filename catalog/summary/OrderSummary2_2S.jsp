<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<%@ page import="java.text.*,java.sql.*,com.marcomet.users.security.*,com.marcomet.tools.*,com.marcomet.environment.*,java.util.*,com.marcomet.catalog.*;" %>
<%@ taglib uri="/WEB-INF/tld/iterationTagLib.tld" prefix="iterate" %>
<%@ include file="/includes/SessionChecker.jsp" %>
<%@ taglib uri="/WEB-INF/tld/taglib.tld" prefix="taglib" %>
<jsp:useBean id="sl" class="com.marcomet.tools.SimpleLookups" scope="page" />
<jsp:useBean id="connection" class="com.marcomet.jdbc.ConnectionBean" scope="session" />
<jsp:useBean id="formater" class="com.marcomet.tools.FormaterTool" scope="page" />
<jsp:useBean id="shipper" class="com.marcomet.commonprocesses.ProcessShippingCost" scope="page" />
<jsp:useBean id="validator" class="com.marcomet.tools.FieldValidationBean" scope="page" />
<jsp:useBean id="cB" class="com.marcomet.beans.SBPContactBean" scope="page" />

<jsp:setProperty name="cB" property="*"/>
<%
//load up required fields always present
    String[] flds = {"firstName", "lastName", "addressMail1", "cityMail", "zipcodeMail", "email"};
    if (((ShoppingCart) session.getAttribute("shoppingCart")).getOrderEscrowTotal() > 0) {
//	flds.add("ccNumber");
    }

    validator.setReqTextFields(flds);
    String[] ipflds = {"newUserName", "newPassword"};
    validator.setReqTextFieldsIP(ipflds);
    String[] reqCheckBoxesIP = {"userAgreement"};
    validator.setReqCheckBoxesIP(reqCheckBoxesIP);
//String[] numFlds = {""};
//validator.setNumberFields(numFlds);
//String[] zipcodeFlds = {"zipcodeMail"};
//validator.setZipcodeFields(zipcodeFlds);
    String[] passwords = {"newPassword", "newPasswordCheck"};
    validator.setPasswordMatchesIP(passwords);

//if is null, first time here, or is "" due to return from login.
    if (request.getParameter("firstName") == null || request.getParameter("firstName").trim().equals("")) {
      cB.setContactId((String) session.getAttribute("contactId"));
    }
%>
<%
    UserProfile up = (UserProfile) session.getAttribute("userProfile");

    Connection conn = com.marcomet.jdbc.DBConnect.getConnection();
    Statement st = conn.createStatement();
    DecimalFormat numberFormatter = new DecimalFormat("#,###,###");
    String previewTemplate = "/preview/brochure_from_sc.jsp";
    SiteHostSettings shs = (SiteHostSettings) session.getAttribute("siteHostSettings");
    boolean editor = (((RoleResolver) session.getAttribute("roles")).roleCheck("editor"));
    boolean overLimit = false;
//boolean shippingCalculated = (request.getParameter("shippingCalculated") != null && request.getParameter("shippingCalculated").equals("true")) ? true : false;
    int creditStatus = 0;
    int countryId = 0;
    String nonUSTxt = "";
    String pageId = "";
    String orderSummaryTxt = "";
    String spPageId = "";
    int co_days = 0;
    int jobId = 0;
    String fileName = "";
    int poId = 0;
    ResultSet coRS = st.executeQuery("select distinct if(b.id is not null,b.default_number,a.default_number) as 'default_number' from sys_defaults a left join sys_defaults b on a.title=b.title and b.sitehost_id='" + shs.getSiteHostId() + "' where a.title='checkout_hold'");
    if (coRS.next()) {
      co_days = coRS.getInt("default_number");
    }

    int orderBalance = 0;
    String balanceSQL = "select (sum(t.price) +  sum(t.shipprice)) - sum(t.payments) balance from (select  sum(j.price) price, 0 as shipprice, 0 as  payments from contacts c, jobs  j  where if(c.default_site_number=0,c.companyid=j.jbuyer_company_id,j.site_number=c.default_site_number)  and  c.id=" + up.getContactId() + " and j.status_id<>9 and j.status_id < 120  group by c.id union select 0 as  price, 0 as shipprice,  sum(arcd.payment_amount) payments from contacts c, jobs  j left join ar_invoice_details ari on ari.jobid=j.id left join ar_collection_details arcd on ari.ar_invoiceid=arcd.ar_invoiceid   where if(c.default_site_number =0,c.companyid=j.jbuyer_company_id,j.site_number=c.default_site_number)  and  c.id=" + up.getContactId() + " and j.status_id<>9 and j.status_id < 120  group by c.id union select 0 as  price, sum(s.price) as shipprice, 0 as payments from contacts c, jobs  j left join shipping_data s on s.job_id=j.id  where if(c.default_site_number=0,c.companyid=j.jbuyer_company_id,j.site_number=c.default_site_number)  and  c.id=" + up.getContactId() + " and j.status_id<>9 and j.status_id < 120  group by c.id) as t";

    ResultSet balRS = st.executeQuery(balanceSQL);
    while (balRS.next()) {
      orderBalance = balRS.getInt("balance");
    }

    int creditLimit = 0;
    double invoiceBalance = 0.00;
    double propInvoiceBalance = 0.00;
    String creditQuery = "select credit_status,country_id,p.body as body,sp.body as spBody,p.id pageId,sp.id spPageId, credit_limit from companies c,locations l left join pages p on p.title='Non US Shipments' left join pages sp on sp.page_name='orderSummaryText' where l.companyid=c.id  and c.id=" + up.getCompanyId() + " group by c.id";
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
%>
<html>
<head>
  <%
    if (session.getAttribute("selfDesigned") == null || session.getAttribute("selfDesigned").toString().equals("false")) {%>
  <title>Pending Job Summary</title>
  <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
  <link rel="stylesheet" href="/styles/marcomet.css" type="text/css">
  <link rel="stylesheet" href="<%=(String) session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css">
  <link rel="stylesheet" href="/styles/modalbox.css" type="text/css">
  <META HTTP-EQUIV="Cache-Control" CONTENT="no-cache">
  <META HTTP-EQUIV="Pragma" CONTENT="no-cache">
  <META HTTP-EQUIV="Expires" CONTENT="-1">
  <style>.nonUSTxt{background-color:#ffffcc;}</style>
  <script type="text/javascript" src="/javascripts/prototype.js"></script>
  <script type="text/javascript" src="/javascripts/scriptaculous.js"></script>
  <script type="text/javascript" src="/javascripts/modalbox.js"></script>
  <script language="javascript" src="/javascripts/mainlib.js"></script>
</head>
<body leftmargin="0" topmargin="0" marginwidth="0" marginheight="0" onLoad="populateTitle('Order Checkout')" background="<%=(String) session.getAttribute("siteHostRoot")%>/images/back3.jpg">
<div id="divWait" align="center" style="display:none;">
  <h5>Please Wait<img src="/images/generic/dotdot.gif" width="72" height="10"></h5>
</div>
<div id="waitSection" style="display:none;">
  <br><br><br><br><br><br>
  <div align="center">
    <h2>Processing Order<img src="/images/generic/dotdot.gif" width="72" height="10"></h2>
  </div>
</div>
<script type="text/javascript">
  AjaxModalBox.open($('divWait'), {title: 'Please Wait', width: 200, height: 100});
</script>
<%
    int validprop = 0;
    String propertyvalidationQuery = "SELECT  distinct contacts.id,contacts.default_site_number AS csite,v_properties.site_number AS wsite FROM contacts Inner Join locations on locations.contactid=contacts.id and locations.locationtypeid=1 Left Join v_properties ON contacts.default_site_number = v_properties.site_number and ( left(v_properties.zip,5) =left(locations.zip,5) or  left(v_properties.alt_zip,5) =left(locations.zip,5)) WHERE contacts.id= " + up.getContactId() + "  and ((v_properties.site_number IS NOT NULL  AND contacts.default_site_number is not null and contacts.default_site_number <> '0' and contacts.default_site_number <> '') or bypass_site_number_validation_flag=1 or contacts.default_site_number='000') order by contacts.default_site_number";

    ResultSet propRS = st.executeQuery(propertyvalidationQuery);
    while (propRS.next()) {
      validprop = 1;
    }

    int proppastdue = 0;
    String proparQuery = "select ari.invoice_number, ari.creation_date, ari.ar_invoice_amount, sum(arcd.payment_amount) as invoice_payments, ari.ar_invoice_amount - (if(sum(arcd.payment_amount) is null,0,sum(arcd.payment_amount))) as invoice_balance, (TO_DAYS(NOW()) - TO_DAYS(ari.creation_date)) as age from contacts c left join jobs j on  if(c.default_site_number is null or c.default_site_number=0 or TRIM(LEADING '0' from default_site_number)='' ,j.jbuyer_company_id=c.companyid, j.site_number=c.default_site_number)  inner join ar_invoice_details arid on arid.jobid=j.id left join ar_invoices ari on ari.id=arid.ar_invoiceid left join ar_collection_details arcd on arcd.ar_invoiceid=ari.id  where  c.id =" + up.getContactId() + "  and arid.ar_invoiceid=ari.id and  (ari.exclude_from_credit_check<>1 and ari.exclude_from_statements<>1)  and  (ari.vendor_id = 105 or ari.vendor_id = 2)  group by ari.invoice_number having (invoice_balance) >0.001 or (invoice_balance) < -0.001  order by ari.creation_date";

    ResultSet proparRS = st.executeQuery(proparQuery);
    while (proparRS.next()) {
      propInvoiceBalance += (proparRS.getString("invoice_balance") == null || proparRS.getDouble("invoice_balance") > 0 ? 0 : proparRS.getDouble("invoice_balance"));
      if ((proparRS.getString("invoice_balance") != null && proparRS.getDouble("invoice_balance") > .001) && proparRS.getInt("age") > co_days) {
        propInvoiceBalance += proparRS.getDouble("invoice_balance");
        proppastdue = 1;
      } else if ((proparRS.getString("invoice_balance") != null && proparRS.getDouble("invoice_balance") < .001)) {
        propInvoiceBalance += proparRS.getDouble("invoice_balance");
      }
    }

    proppastdue = ((propInvoiceBalance < .01) ? 0 : proppastdue);
    int pastdue = 0;
    invoiceBalance = 0;
    String arQuery = "select ari.invoice_number, ari.creation_date, ari.ar_invoice_amount, sum(arcd.payment_amount) as invoice_payments, ari.ar_invoice_amount - (if(sum(arcd.payment_amount) is null,0,sum(arcd.payment_amount))) as invoice_balance, (TO_DAYS(NOW()) - TO_DAYS(ari.creation_date)) as age from ar_invoices ari left join ar_collection_details arcd on arcd.ar_invoiceid=ari.id where (ari.exclude_from_credit_check<>1 and ari.exclude_from_statements<>1) and  (ari.vendor_id = 105 or ari.vendor_id = 2) and ari.bill_to_companyid =" + up.getCompanyId() + " group by ari.invoice_number having (invoice_balance) >0.001 or (invoice_balance) < -0.001 order by ari.creation_date";

    ResultSet arRS = st.executeQuery(arQuery);
    while (arRS.next()) {
      invoiceBalance += ((arRS.getString("invoice_balance") == null || arRS.getDouble("invoice_balance") > 0) ? 0 : arRS.getDouble("invoice_balance"));
      if ((arRS.getString("invoice_balance") != null && arRS.getDouble("invoice_balance") > .001) && arRS.getInt("age") > co_days) {
        invoiceBalance += arRS.getDouble("invoice_balance");
        pastdue = 1;
      } else if ((arRS.getString("invoice_balance") != null && arRS.getDouble("invoice_balance") < .001)) {
        invoiceBalance += arRS.getDouble("invoice_balance");
      }
    }

    pastdue = ((invoiceBalance < .01) ? 0 : pastdue);
    String promoStatus = "";
    if (session.getAttribute("promoCode") != null && !(session.getAttribute("promoCode").toString().equals(""))) {
      ResultSet arPromo = st.executeQuery("Select if(end_date<NOW(),'has expired and will not be applied.',if(start_date>NOW(),'has not started yet and will not be applied.','Valid')) as status from promotions where promo_code='" + session.getAttribute("promoCode").toString() + "'");
      while (arPromo.next()) {
        promoStatus = arPromo.getString("status");
      }
    }
%>
<form method="post" action="/servlet/com.marcomet.sbpprocesses.ProcessJobSubmit" >
  <table border="0" cellpadding="0" cellspacing="0" width="100%" height="100%">
    <tr valign="top">
      <td colspan="10" height="155">
        <table width="98%" align="center" class="body">
          <tr>
            <p>
            <td class="Title"colspan="10" height="1">
              <span class="offeringTITLE">
                <% if (((String) session.getAttribute("siteHostRoot")).equals("/sitehosts/network")) {%>Pending Profile Submittal
                <% } else {%>
                Pending Job Summary (Unprocessed Jobs)
                <% }%>
              </span>
              <hr align="left" color=red size="1">
            </td>
          </tr>
          <tr>
            <td class="planheader1" width="39%" height="9">Job Name / Description (Click to view Job Details)</td>
            <td class="planheader1" width="8%" height="9">Quantity</td>
            <td class="planheader1" width="8%" height="9">Remove from Cart?</td>
            <td class="planheader1" width="9%" height="9">
              <div align="right"><%=(((String) session.getAttribute("siteHostRoot")).equals("/sitehosts/network") ? "Price&nbsp;" : "Estimate&nbsp;")%></div>
            </td>
            <td class="planheader1" width="9%" height="8">
              <div align="right">Deposit/Payment&nbsp;</div>
            </td>
            <td class="planheader1" width="9%" height="9">
              <div align="right">Discount</div>
            </td>
            <td class="planheader1" width="9%" height="9">
              <div align="right">Shipping</div>
            </td>
            <td class="planheader1" width="9%" height="9">Total</td>
          </tr>
          <%
    double priceSubtotal = 0.00;
    double shipSubtotal = 0.00;
    double depositSubtotal = 0.00;
    double joStdShippingPrice = 0.00;
    boolean ordersPresent = false;

    int jobCount = -1;
    String shippingType = "";
    //String shipPolicy = "1";

    int jobNo = (request.getParameter("jobNo") != null) ? Integer.parseInt(request.getParameter("jobNo")) : -1;
    String shipType = request.getParameter("shipType");

    CatalogShipmentCreationServlet shipment = new CatalogShipmentCreationServlet();
    shipment.createShipment(session);

    ShoppingCart shoppingCart = (ShoppingCart) session.getAttribute("shoppingCart");
    if (shoppingCart != null) {
      overLimit = (((orderBalance + shoppingCart.getOrderPrice()) > creditLimit && creditLimit > 0) ? true : false);

      Vector shipments = shoppingCart.getShipments();
      if (shipments.size() > 0) {
        for (int j = 0; j < shipments.size(); j++) {
          jobCount = j;
          ShipmentObject so = (ShipmentObject) shipments.elementAt(j);
          Vector jobs = so.getJobs();
          double soWeight = so.getWeight();
          double soShippingCost = 0.00;
          //if (shippingCalculated) {
          soShippingCost = so.getShippingCost() + so.getHandlingCost();
          //}

          for (int k = 0; k < jobs.size(); k++) {
            JobObject jo = (JobObject) jobs.elementAt(k);
            double price = jo.getPrice();
            double deposit = jo.getEscrowDollarAmount();
            double discount = 0.00;
            double handlingCost = 0.00;
            int shipmentId = 0;
            int shipPricePolicy = 2;
            jo.setDiscount(discount);
            ordersPresent = true;

            String productId = "", contactId = "";
            int amount = 0;
            double joTotalWeight = 0.00;
            double joPercentShipment = 0.00;

            JobSpecObject jsoProductCode = (JobSpecObject) jo.getJobSpecs().get("9001");
            String query = "SELECT id FROM products WHERE prod_code='" + jsoProductCode.getValue() + "'";
            ResultSet rs = st.executeQuery(query);
            if (rs.next()) {
              productId = rs.getString("id");
            }
            rs.close();
            contactId = (String) session.getAttribute("contactId");
            JobSpecObject jsoQuantity = (JobSpecObject) jo.getJobSpecs().get("705");
            amount = Integer.parseInt(jsoQuantity.getValue());

            //query = "SELECT weight, number_of_boxes FROM product_prices WHERE quantity=" + amount + " AND prod_price_code=(SELECT prod_price_code FROM products WHERE id=" + productId + ")";
            query = "SELECT pp.weight_per_box 'weight', pp.number_of_boxes FROM product_prices pp, products p WHERE pp.quantity=" + amount + " AND pp.prod_price_code=p.prod_price_code AND p.id=" + productId;
            ResultSet rs1 = st.executeQuery(query);
            if (rs1.next()) {
              joTotalWeight = (Double.parseDouble(rs1.getString("number_of_boxes")) * Double.parseDouble(rs1.getString("weight")));
            }

            if (soShippingCost != 0.00) {
              joPercentShipment = ((joTotalWeight / soWeight) * 100);
              joStdShippingPrice = (soShippingCost * (joPercentShipment / 100));
              shippingType = so.getShipType();
              shipmentId = so.getId();

            } else {
              joPercentShipment = 0;
              joStdShippingPrice = 0.00;
              shipmentId = 0;
            }

            String shipPolicy = "";
            query = "SELECT pp.ship_price_policy, pp.std_ship_price FROM product_prices pp, products p WHERE pp.quantity=" + amount + " AND pp.prod_price_code=p.prod_price_code AND p.id=" + productId;
            ResultSet rs2 = st.executeQuery(query);
            if (rs2.next()) {
              shipPolicy = rs2.getString("ship_price_policy");
              if (shipPolicy.equals("0")) {
                //joStdShippingPrice = joStdShippingPrice;
                shipPricePolicy = 2;
              } else if (shipPolicy.equals("1")) {
                joStdShippingPrice = 0.00;
                shipPricePolicy = 0;
              } else if (shipPolicy.equals("2")) {
                joStdShippingPrice = Double.parseDouble(rs1.getString("std_ship_price"));
                shipPricePolicy = Integer.parseInt(shipPolicy);
              }
            }

            jo.setShipPricePolicy(shipPricePolicy);
            jo.setShippingPrice(joStdShippingPrice);
            jo.setShippingType(shippingType);
            jo.setShipmentId(shipmentId);
            System.out.println("stdShipPrice from jo :" + jo.getShippingPrice());
            System.out.println("shipPricePolicy from jo: " + jo.getShipPricePolicy());
            jo.setPercentageOfShipment(joPercentShipment);
          %>
          <tr>
            <td class="lineitems"><a href="javascript:pop('/catalog/summary/OrderSummaryJobDetails.jsp?jobId=<%= jo.getId()%>','500','500')" class="minderACTION"><%=jo.getJobName()%></a></td>
            <td class="lineitems">
              <div align="right"><%=((jo.getQuantity() == 0) ? "NA" : numberFormatter.format(jo.getQuantity()))%></div>
            </td>
            <td class="lineitems">
              <div align="center"><a href="/catalog/summary/RemoveJobConfirmation.jsp?jobId=<%= jo.getId()%>" class="minderACTION">delete</a></div>
            </td>
            <td class="lineitems">
              <div align="right"><%= (jo.isRFQ()) ? "RFQ" : formater.getCurrency(price)%></div>
            </td>
            <td class="lineitems">
              <div align="right"><%= formater.getCurrency(deposit)%></div>
            </td>
            <td class="lineitems">
              <div align="right"><%= formater.getCurrency(discount)%></div>
            </td>
            <td class="lineitems">
              <div align="right"><%= (shipPolicy.equals("0")) ? ((joStdShippingPrice == 0.00) ? "TBD *" : formater.getCurrency(joStdShippingPrice)) : "$0.00"%></div>
            </td>
            <%double total = ((jo.isRFQ() ? 0.00 : price)) - discount - deposit + joStdShippingPrice;%>
            <td class="lineitems">
              <div align="right"><%= formater.getCurrency(total)%></div>
            </td>
          </tr><%
                }
              }
              double totalPrice = shoppingCart.getOrderPrice() - shoppingCart.getDiscount() - shoppingCart.getOrderEscrowTotal() + shoppingCart.getShippingPrice();
          %><tr>
            <td>&nbsp;</td>
            <td>&nbsp;</td>
            <td class="lineitems">
              <div align="right">Totals:</div>
            </td>
            <td class="lineitems">
              <div align="right"><%= formater.getCurrency(shoppingCart.getOrderPrice())%></div>
            </td>
            <td class="lineitems">
              <div align="right"><%= formater.getCurrency(shoppingCart.getOrderEscrowTotal())%></div>
            </td>
            <td class="lineitems">
              <div align="right"><%= formater.getCurrency(shoppingCart.getDiscount())%></div>
            </td>
            <td class="lineitems">
              <div align="right"><%= formater.getCurrency(shoppingCart.getShippingPrice())%></div>
            </td>
            <td class="lineitems">
              <div align="right"><%= formater.getCurrency(totalPrice)%></div>
            </td>
          </tr>
          <tr>
            <td class="lineitems" colspan=5 align="right"><%if (session.getAttribute("promoCode") == null || session.getAttribute("promoCode").toString().equals("")) {%>
              <a href="javascript:pop('/popups/PromoCode.jsp','250','150')" class='menuLink'>&nbsp;&raquo;&nbsp;Apply Promo Code&nbsp;</a><span align="right" id="promoCode" class='lineitems'></span><%} else {%><a href="javascript:pop('/popups/PromoCode.jsp','250','150')" class='menuLink'>&nbsp;&raquo;&nbsp;Change Promo Code&nbsp;</a><span align="right" id="promoCode" class='lineitems'>Promo Code:&nbsp;<%=session.getAttribute("promoCode").toString()%>&nbsp;<%if (promoStatus == null || promoStatus.equals("")) {
    session.removeAttribute("promoCode");%><font color='red'>NOTE:Invalid&nbsp;Promo&nbsp;Code</font><%} else if (!promoStatus.equals("Valid")) {
  session.removeAttribute("promoCode");%><font color='red'>NOTE:Promotion&nbsp;<%=promoStatus%></font><%}%></span><%}%>
            </td>
          </tr>
          <tr>
            <td colspan="10"><%if (joStdShippingPrice == 0.00) {%>
              * To Be Determined: Shipping price could not be determined at this time and will be calculated either upon quoting the job or on final invoicing.
              <%}%>
            </td>
          </tr><%
            } else {
          %><tr>
            <td class="lineitems" colspan="10">Empty No Orders Present</td>
          </tr>
          <%            }
          } else {%>
          <tr>
            <td class="lineitems" colspan="10" height="2">Empty No Orders Present</td>
          </tr>
          <%    }%>
        </table>
      </td>
    </tr>
    <%if (ordersPresent) {
    %>
    <tr>
      <td valign="bottom" colspan="100%" align="center">
        <table><%=(((proppastdue + pastdue) > 0) ? "<tr><td colspan=3>Balance Over " + co_days + " days for all accounts on this property: " + formater.getCurrency(propInvoiceBalance) + "</td></tr>" : "")%><%=(((proppastdue + pastdue) > 0) ? "<tr><td colspan=3>Balance Over " + co_days + " days for this account: " + formater.getCurrency(invoiceBalance) + "</td></tr>" : "")%>
          <tr><%
  if (creditStatus != 2 && overLimit) {
            %><td colspan = 3 class="errorbox" >Processing this order requires an increase to your existing credit
              limit with us.<br>Please click "Contact Info" below to reach Marketing Services for assistance.  Thank you.<br><br>
              <a class="menuLINK" href="javascript:pop('<%=(String) session.getAttribute("siteHostRoot")%>/contents/contacts.jsp','650','450')">[CONTACT INFO]</a>
            </td><%

            } else if (creditStatus != 2 && pastdue == 1) {
            %><td colspan = 3 class="errorbox" >Online ordering has been temporarily suspended until your overdue invoices are paid.<br>Please click "home" to go back to the home page, then click on your overdue invoices listed on the lower left to pay immediately by credit card and complete your order, or to print them and pay by check.  If you need immediate assistance, please click "contact info" below to reach Marketing Services.<br><br>
              <a class="menuLINK" href="javascript:pop('<%=(String) session.getAttribute("siteHostRoot")%>/contents/contacts.jsp','650','450')">[CONTACT INFO]</a>
            </td><%

            } else if (creditStatus != 2 && proppastdue == 1) {
            %> <td colspan = 3 class="errorbox" >Online ordering for your account has been temporarily suspended for overdue invoices from other accounts related to your property.<br>Please click "contact info" below to reach Marketing Services so that we may resolve your account.<br><br>
              <a  class="menuLINK"  href="javascript:pop('<%=(String) session.getAttribute("siteHostRoot")%>/contents/contacts.jsp','650','450')">[CONTACT INFO]</a>
            </td> <%
            } else if (creditStatus == 1 || validprop == 0) {
            %> <td colspan = 3 class="errorbox" ><b>Online ordering for your account has been temporarily suspended for account validation.<br>Please click "contact info" below to reach Marketing Services and validate your account.</b><br><br><a class="menuLINK" href="javascript:pop('<%=(String) session.getAttribute("siteHostRoot")%>/contents/contacts.jsp','650','450')">[CONTACT INFO]</a>
            </td> <%
            }
          %></tr>
          <tr>
            <td align="right" width="48%">
              <div align="right"><a href="/catalog/summary/OrderSummary.jsp" class="greybutton">Cancel</a></div>
            </td>
            <td width="4%">&nbsp;</td>
            <td align="left" width="48%">
              <div align="left"><a href="javascript:processOrder()" class="greybutton">Submit&nbsp;Jobs</a></div>
            </td>
          </tr>
        </table>
      </td>
    </tr>
    <%} else {
    %>
    <tr>
      <td valign="bottom" colspan="100%" align="center">
        <table><%=(((proppastdue + pastdue) > 0) ? "<tr><td colspan=3>Balance Over " + co_days + " days for all accounts on this property: " + formater.getCurrency(propInvoiceBalance) + "</td></tr>" : "")%><%=(((proppastdue + pastdue) > 0) ? "<tr><td colspan=3>Balance Over " + co_days + " days for this account: " + formater.getCurrency(invoiceBalance) + "</td></tr>" : "")%>
          <tr>
            <td align="right"><a href="javascript:parent.window.location.replace('/index.jsp?contents=<%=(String) session.getAttribute("siteHostRoot")%>/contents/SiteHostIndex.jsp')" class="greybutton">Add&nbsp;New</a></td>
            <td>&nbsp;</td>
            <td align="left"><a href="/" class="greybutton">Home</a></td>
          </tr>
        </table>
      </td>
    </tr>
    <%
    }
//if this is called from the 'Process Jobs' button don't use the footer

    if (HttpUtils.getRequestURL(request).toString().indexOf("OrderSummary2") == -1) {
    %>
    <tr>
      <td valign="bottom" align="center" colspan="10">
        <jsp:include page="/footers/inner_footer.jsp" flush="true"></jsp:include>
      </td>
    </tr>
    <%}%>
  </table>
  <div id="divChangeShipType" style="background-color: #fffccc; border: 2px solid black; display: none;">
    <br>
    &nbsp;&nbsp;Shipper :&nbsp;<%= shipper.getShipper().toUpperCase()%>
    <br>
    &nbsp;&nbsp;Shipping Type :&nbsp;
    <select id="ddShipType" onchange="javascript:toggleShipType($('ddShipType').options[$('ddShipType').selectedIndex].value); AjaxModalBox.open($('divWait'), {width : 200, height : 100});">
      <option value="">Select Shipping Type
      <option id="shipGround" value="ground">
      <option id="shipThreeDay" value="threeday">
      <option id="shipSecondDay" value="secondday">
      <option id="shipNextDay" value="nextday">
    </select>
    <br><br>
    &nbsp;&nbsp;<input type="button" value="Cancel" onClick="AjaxModalBox.close()">
    <br><br>
  </div>
  <script type="text/javascript">
    function processOrder(){
      document.getElementById("waitSection").style.display='';
      document.forms[0].nextStepActionId.value= '1';
      submitForm();
    }

    function toggleShipType(shipType){
      if(shipType == "ground"){
        if(AjaxModalBox.options.shippingType != 'ground'){
          window.location.href = '/catalog/summary/OrderSummary2.jsp?jobNo='+AjaxModalBox.options.jobNo+'&shipType=ground';
        }
        AjaxModalBox.close();
      }
      else if(shipType == "nextday"){
        if(AjaxModalBox.options.shippingType != 'nextday'){
          window.location.href = '/catalog/summary/OrderSummary2.jsp?jobNo='+AjaxModalBox.options.jobNo+'&shipType=nextday';
        }
        AjaxModalBox.close();
      }
      else if(shipType == "secondday"){
        if(AjaxModalBox.options.shippingType != 'secondday'){
          window.location.href = '/catalog/summary/OrderSummary2.jsp?jobNo='+AjaxModalBox.options.jobNo+'&shipType=secondday';
        }
        AjaxModalBox.close();
      }
      else if(shipType == "threeday"){
        if(AjaxModalBox.options.shippingType != 'threeday'){
          window.location.href = '/catalog/summary/OrderSummary2.jsp?jobNo='+AjaxModalBox.options.jobNo+'&shipType=threeday';
        }
        AjaxModalBox.close();
      }
    }

    function openChangeShipTypePopup(shippingType, jobCount, groundCost, threeDayCost, secondDayCost, nextDayCost){
      AjaxModalBox.open($('divChangeShipType'), {title: 'Change Ship Type', width: 300, shippingType: shippingType, jobNo: jobCount});
      $('shipGround').text = "Ground : $" + groundCost;
      $('shipThreeDay').text = "Three Day : $" + threeDayCost;
      $('shipSecondDay').text = "Second Day : $" + secondDayCost;
      $('shipNextDay').text = "Next Day : $" + nextDayCost;
      if(shippingType == 'ground'){
        $('shipGround').selected = true;
      }
      else if(shippingType == 'threeday'){
        $('shipThreeDay').selected = true;
      }
      else if(shippingType == 'secondday'){
        $('shipSecondDay').selected = true;
      }
      else if(shippingType == 'nextday'){
        $('shipNextDay').selected = true;
      }
    }
  </script>
  <table align="center" width="80%" class=label>
    <tr>
      <td colspan="4" height="31"> <span class="catalogTITLE">Order will be shipped/billed to the following site. If product is for a different location please logout and back in as the contact for that site.</span><font color="red"><span class="catalogTITLE">
      </span><%= (request.getAttribute("errorMessage") == null) ? "" : (String) request.getAttribute("errorMessage")%></font></td>
    </tr>
    <tr>
      <td colspan="4" class="subtitle1">User Information</td>
      <tr>
      </tr>
      <td height="22">Title:</td>

      <td height="22" colspan="3">
        <input type='hidden' value="<%= cB.getTitleIdString()%>" name="titleId"><%= sl.getValue("lu_titles", "id", cB.getTitleIdString(), "value")%><!--<taglib:LUDropDownTag dropDownName="titleId" table="lu_titles" extra="onChange=\"formChangedArea('Contact')\"" selected="<%= cB.getTitleIdString()%>"/>-->
      </td>
    </tr>
    <tr>
      <td>First &amp; Last Name: *</td>

      <td colspan="3">
        <input name="firstName" type="hidden" size="20" max="20" value="<%= cB.getFirstName()%>" onChange="formChangedArea('Contact')"><%= cB.getFirstName()%>
        <input name="lastName" type="hidden" size="30" max="30" value="<%= cB.getLastName()%>" onChange="formChangedArea('Contact')"><%= cB.getLastName()%>
      </td>
    </tr>
    <tr>
      <td>Company Name: *</td>
      <td colspan="3"><input name="companyName" type="hidden" size="32" max="64" value="<%= cB.getCompanyName()%>" onChange="formChangedArea('Company')"><%= cB.getCompanyName()%></td>
    </tr>
    <tr>
      <td>Wyndham Site #: </td>
      <td colspan="3"><input name="siteNumber" type="hidden" size="10" max="64" value="<%= cB.getSiteNumber()%>" onChange="formChangedArea('Contact')"><%= cB.getSiteNumber()%></td>
    </tr>
    <tr>
      <td>Property Management Site #: </td>
      <td colspan="3"><input name="pmSiteNumber" type="hidden" size="10" max="64" value="<%= cB.getPMSiteNumber()%>" onChange="formChangedArea('Contact')"><%= cB.getPMSiteNumber()%></td>
    </tr>
    <tr>
      <td>Job Title:</td>
      <td colspan="3"><input type="hidden" name="jobTitle" size="20" max="20" value="<%= cB.getJobTitle()%>" onChange="formChangedArea('Contact')"><%= cB.getJobTitle()%></td>
    </tr>
    <tr>

      <td>E-mail: *</td>

      <td colspan="3">
      <input type="hidden" name="email" value="<%= cB.getEmail()%>" onChange="formChangedArea('Contact')"><%= cB.getEmail()%></td>
    </tr>
    <tr>
      <td>Website Address:</td>
      <td colspan="3"><input type="hidden" name="companyURL" value="<%= cB.getCompanyURL()%>" onChange="formChangedArea('Company')"><%= cB.getCompanyURL()%></td>
    </tr>
    <tr>
      <td colspan="4" class="subtitle1">Mailing Address:</td>
    </tr>
    <tr>

      <td width="27%">Address: *</td>
      <td colspan="3">
        <input type="hidden" name="addressMail1" size=56 max=200 value="<%= cB.getAddressMail1()%>" onChange="formChangedArea('Locations')"><%= cB.getAddressMail1()%><br>
        <input type="hidden" name="addressMail2" size=56 max=200 value="<%= cB.getAddressMail2()%>" onChange="formChangedArea('Locations')"><%= cB.getAddressMail2()%>
      </td>
    </tr>
    <tr>

      <td width="27%">City, State &amp; Zip: *</td>
      <td colspan="3">

        <input type="hidden" name="cityMail" value="<%= cB.getCityMail()%>" onChange="formChangedArea('Locations')"><%= cB.getCityMail()%>
        ,
        <!--<taglib:LUDropDownTag extra="onChange=\"formChangedArea('Locations')\"" dropDownName="stateMailId" table="lu_abreviated_states" selected="<%= cB.getStateMailId()%>" /> --><input type="hidden" value="<%=cB.getStateMailId()%>" name="stateMailId"><%= sl.getValue("lu_abreviated_states", "id", cB.getStateMailIdString(), "value")%>
        <input type="hidden" name="zipcodeMail" value="<%= cB.getZipcodeMail()%>" onChange="formChangedArea('Locations')"><%= cB.getZipcodeMail()%>
      </td>
    </tr>
    <tr>
      <td>Country: *</td>
      <td colspan="3">
        <!--<taglib:LUDropDownTag dropDownName="countryMailId" table="lu_countries"  extra="onChange=\"formChangedArea('Locations')\""  selected="<%= cB.getCountryMailId()%>"/>--><input type="hidden" value="<%=cB.getCountryMailId()%>" name="countryMailId"><%= sl.getValue("lu_countries", "id", cB.getCountryMailIdString(), "value")%>
      </td>
    </tr>
    <tr>
      <td colspan="4">&nbsp;</td>
    </tr>
    <tr>
      <td colspan="3"><span class="subtitle1">Billing Information:</span>*</td>
      <td width="63%">
      <input type="hidden" value="true" name="sameAsAbove" <%= (cB.getSameAsAbove()) ? "checked" : ""%> onClick="formChangedArea('Locations')">Same as above</td>
    </tr>
    <tr>
      <td width="27%">Address:</td>
      <td colspan="3">
        <input type="hidden" name="addressBill1" size=56 max=200 value="<%= cB.getAddressBill1()%>" onChange="formChangedArea('Locations')" ><%= cB.getAddressBill1()%><br>
        <input type="hidden" name="addressBill2" size=56 max=200 value="<%= cB.getAddressBill2()%>" onChange="formChangedArea('Locations')" ><%= cB.getAddressBill2()%>
      </td>
    </tr>
    <tr>
      <td width="27%">City, State &amp; Zip:</td>
      <td colspan="3">
        <input type="hidden" name="cityBill" value="<%= cB.getCityBill()%>" onChange="formChangedArea('Locations')"><%= cB.getCityBill()%>
        ,
        <!--		<taglib:LUDropDownTag dropDownName="stateBillId" table="lu_abreviated_states" extra="onChange=\"formChangedArea('Locations')\"" selected="<%= cB.getStateBillId()%>" /> --><input type="hidden" value="<%=cB.getStateBillId()%>" name="stateBillId"><%= sl.getValue("lu_abreviated_states", "id", cB.getStateBillIdString(), "value")%>
        <input type="hidden" name="zipcodeBill" value="<%= cB.getZipcodeBill()%>" onChange="formChangedArea('Locations')"><%= cB.getZipcodeBill()%>
      </td>
    </tr>
    <tr>
      <td>Country:</td>
      <td colspan="3"><!--<taglib:LUDropDownTag dropDownName="countryBillId" table="lu_countries"  extra="onChange=\"formChangedArea('Locations')\"" selected="<%= cB.getCountryBillId()%>" />--><input type="hidden" value="<%=cB.getCountryBillId()%>" name="countryBillId"><%= sl.getValue("lu_countries", "id", cB.getCountryBillIdString(), "value")%></td>
    </tr>
    <tr>
      <td colspan="4"><%= (request.getParameter("ccerrormessage") == null) ? "" : request.getParameter("ccerrormessage")%></td>
    </tr>
    <tr><td colspan=4><hr size=1></td></tr>
    <%if (((ShoppingCart) session.getAttribute("shoppingCart")).getOrderEscrowTotal() > 0) {%>
    <tr>
      <td valign="top" class="subtitle1">Order Total:</td>
      <td colspan=3><%= formater.getCurrency(((ShoppingCart) session.getAttribute("shoppingCart")).getOrderEscrowTotal())%><font color="#FF0000"></font></td>
    </tr>
    <tr><td colspan=4><hr size=1></td></tr>

    <tr>
      <td colspan="4" height="30" class="subtitle1">Credit Card Information:</td>
    </tr>
    <tr>

      <td width="27%">Credit Card Type: *</td>
      <td colspan="3">
        <taglib:LUDropDownTag dropDownName="ccType" table="lu_credit_cards" selected="<%= (request.getParameter(\"ccType\")==null)?\"\":request.getParameter(\"ccType\")%>"/>
      </td>
    </tr>
    <tr>
      <td width="27%">Credit Card Number: *</td>
      <td colspan="3">
        <input type="hidden" name="ccNumber" value="<%= (request.getParameter("ccNumber") == null) ? "0" : request.getParameter("ccNumber")%>" size="19">
      </td>
    </tr>
    <tr>
      <td width="27%">Credit Card Exp. Date: *</td>
      <td colspan="3"> Month:
        <select name="ccMonth">
          <option value="01">January</option>

          <option value="02">February</option>
          <option value="03">March</option>
          <option value="04">April</option>
          <option value="05">May</option>
          <option value="06">June</option>
          <option value="07">July</option>
          <option value="08">August</option>
          <option value="09">September</option>
          <option value="10">October</option>
          <option value="11">November</option>
          <option value="12">December</option>
        </select>
        Year:
        <select name="ccYear">
          <option value="01">2001</option>
          <option value="02">2002</option>
          <option value="03">2003</option>
          <option value="04">2004</option>
          <option value="05">2005</option>
          <option value="06">2006</option>
          <option value="07">2007</option>
          <option value="08">2008</option>
          <option value="09">2009</option>
          <option value="10">2010</option>
        </select>
      </td>
    </tr>
    <%}%>
    <%-- </table>
    <table align="center" width="80%" class=label>	 --%>
    <tr>

      <td width="27%">Phone: *
        <input type="hidden" name="phoneCount" value="3">
      </td>
      <td colspan="3">
        <!--<taglib:LUDropDownTag dropDownName="phoneTypeId0" table="lu_phone_types" extra="onChange=\"formChangedArea('Phones')\"" selected="<%= cB.getPhoneTypeIdString(0)%>"/>--><input type="hidden" value="<%=cB.getPhoneTypeIdString(0)%>" name="phoneTypeId0"><%= sl.getValue("lu_phone_types", "id", cB.getPhoneTypeIdString(0), "value")%>
        <input type="hidden" name="areaCode0" size="3" value="<%= cB.getAreaCode(0)%>" onChange="formChangedArea('Phones')"><%= cB.getAreaCode(0)%>-<%= cB.getPrefix(0)%>-<%= cB.getLineNumber(0)%><%= ((cB.getExtension(0).equals("")) ? "" : " ext: " + cB.getExtension(0))%>
        <input type="hidden" name="prefix0" size="4" value="<%= cB.getPrefix(0)%>" onChange="formChangedArea('Phones')">
        <input type="hidden" name="lineNumber0" size="5" value="<%= cB.getLineNumber(0)%>" onChange="formChangedArea('Phones')">
        ex:
        <input type="hidden" name="extension0" size="4" value="<%= cB.getExtension(0)%>" onChange="formChangedArea('Phones')">
        <br>
        <!--	<taglib:LUDropDownTag dropDownName="phoneTypeId1" table="lu_phone_types" extra="onChange=\"formChangedArea('Phones')\"" selected="<%= cB.getPhoneTypeIdString(1)%>"/>--><input type="hidden" value="<%=cB.getPhoneTypeIdString(1)%>" name="phoneTypeId1"><%= sl.getValue("lu_phone_types", "id", cB.getPhoneTypeIdString(1), "value")%>
        <input type="hidden" name="areaCode1" size="3" value="<%= cB.getAreaCode(1)%>" onChange="formChangedArea('Phones')"><%= cB.getAreaCode(1)%>-<%= cB.getPrefix(1)%>-<%= cB.getLineNumber(1)%><%= ((cB.getExtension(1).equals("")) ? "" : " ext: " + cB.getExtension(1))%>
        <input type="hidden" name="prefix1" size="4" value="<%= cB.getPrefix(1)%>" onChange="formChangedArea('Phones')">
        <input type="hidden" name="lineNumber1" size="5" value="<%= cB.getLineNumber(1)%>" onChange="formChangedArea('Phones')">
        ex:
        <input type="hidden" name="extension1" size="4" value="<%= cB.getExtension(1)%>" onChange="formChangedArea('Phones')">
        <br>
        <!--	<taglib:LUDropDownTag dropDownName="phoneTypeId2" table="lu_phone_types" extra="onChange=\"formChangedArea('Phones')\"" selected="<%= cB.getPhoneTypeIdString(2)%>"/>--><input type="hidden" value="<%=cB.getPhoneTypeIdString(2)%>" name="phoneTypeId2"><%= sl.getValue("lu_phone_types", "id", cB.getPhoneTypeIdString(2), "value")%>
        <input type="hidden" size="3" name="areaCode2" value="<%= cB.getAreaCode(2)%>" onChange="formChangedArea('Phones')"><%= cB.getAreaCode(2)%>-<%= cB.getPrefix(2)%>-<%= cB.getLineNumber(2)%><%= ((cB.getExtension(2).equals("")) ? "" : " ext: " + cB.getExtension(2))%>
        <input type="hidden" name="prefix2" size="4" value="<%= cB.getPrefix(2)%>" onChange="formChangedArea('Phones')">
        <input type="hidden" name="lineNumber2" size="5" value="<%= cB.getLineNumber(2)%>" onChange="formChangedArea('Phones')">
        ex:
        <input type="hidden" name="extension2" size="4" value="<%= cB.getExtension(2)%>" onChange="formChangedArea('Phones')">
        <br>
      </td>
    </tr>
  </table>
  <input type="hidden" name="priorJobId" value="<%=request.getParameter("priorJobId")%>">
  <input type="hidden" name="nextStepActionId" value="">
  <input type="hidden" name="jobId" value="0">
  <input type="hidden" name="defaultRoleId" value="1">
  <input type="hidden" name="errorPage" value="/catalog/checkout/OrderCheckOutForm.jsp">
  <input type="hidden" name="dollarAmount" value="<%= ((ShoppingCart) session.getAttribute("shoppingCart")).getOrderEscrowTotal()%>">
  <input type="hidden" name="$$Return" value="[/catalog/checkout/ThankYouForOrder.jsp]">
  <input type="hidden" name="formChangedPhones" value="<%= (request.getParameter("formChangedPhones") == null) ? "0" : request.getParameter("formChangedPhones")%>">
  <input type="hidden" name="formChangedLocations" value="<%= (request.getParameter("formChangedLocations") == null) ? "0" : request.getParameter("formChangedLocations")%>">
  <input type="hidden" name="formChangedContact" value="<%= (request.getParameter("formChangedCompany") == null) ? "0" : request.getParameter("formChangedContact")%>">
  <input type="hidden" name="formChangedCompany" value="<%= (request.getParameter("formChangedCompany") == null) ? "0" : request.getParameter("formChangedCompany")%>">
</form>
<%
    if (session.getAttribute("reprintJob") != null) {
      session.removeAttribute("reprintJob");
      session.removeAttribute("priorJobId");
    }

  } else {

    /*********************************************************************************************************
    //if this is the result of a self-designed 'run'
     **********************************************************************************************************/
    String rePrint = ((request.getParameter("rePrint") == null || request.getParameter("rePrint").equals("") || request.getParameter("rePrint").equals("false")) ? "false" : "true");
    session.setAttribute("reprintJob", rePrint);

%>  <title>Self-Designed Item Summary</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link rel="stylesheet" href="<%=(String) session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css">
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
    String pdfPreviewTemplate = "";
    ShoppingCart shoppingCart = (ShoppingCart) session.getAttribute("shoppingCart");
    JobSpecObject jso1 = (JobSpecObject) shoppingCart.getJobSpec(9100);
    if (jso1 != null) {
      pdfPreviewTemplate = (String) jso1.getValue();
    } else {
      pdfPreviewTemplate = "";
    }

    if (shoppingCart != null) {
      overLimit = (((orderBalance + shoppingCart.getOrderPrice()) > creditLimit && creditLimit > 0) ? true : false);
      Vector projects = shoppingCart.getProjects();
      if (projects.size() > 0) {
        for (int i = 0; i < projects.size(); i++) {
          ProjectObject po = (ProjectObject) projects.elementAt(i);
          poId = po.getId();
          Vector jobs = po.getJobs();
          for (int j = 0; j < jobs.size(); j++) {
            JobObject jo = (JobObject) jobs.elementAt(j);
            if (request.getParameter("jobId").equals(jo.getId() + "")) {
              jobId = jo.getId();
              double price = jo.getPrice();
              double shipping = jo.getShippingPrice();
              int shipPricePolicy = jo.getShipPricePolicy();
              shipSubtotal = shipSubtotal + shipping;
              double deposit = jo.getEscrowDollarAmount();
              ordersPresent = true;
              fileName = jo.getPreBuiltPDFFileURL();
            }
          }
        }
      } else {
      %><tr>
        <td class="lineitems" colspan="10">Empty No Items Present</td>
      </tr>
      <%        }
      } else {%>
      <tr>
        <td class="lineitems" colspan="10" height="2">Empty No Items Present</td>
      </tr>
      <%    }%>
    </table>
  </td>
</tr>
<tr>
<td>
<table>
<tr>
<td align="left" ><blockquote style="margin-left:40px;"><a href="javascript:saveFile('<%=previewTemplate%>','<%=pdfPreviewTemplate.replace(".", "_laser.")%>','Laser','false')" class="plainLink" style="color:#0044a0;">&raquo;&nbsp;Save and Download a Laser-Printable PDF</a><span class="bodyBlack">-- Allows you to save to your PC a PDF file which can be printed on your color laser printer.</span>
  <br><br><br>
  <a href="javascript:saveFile('<%=previewTemplate%>','<%=pdfPreviewTemplate.replace(".", "_prepress.")%>','PrePress','false')" class="plainLink" style="color:#0044a0;">&raquo;&nbsp;Save and Download a Press-Ready PDF</a><span class="bodyBlack"> -- Allows you to save to your PC a professional press-ready PDF file which you can deliver to the printer of your choice.</span>
  <br><br>
  <span class="bodyBlack"><b>Place an Order to Print this File</b> -- If you'd like us to print the file you've just designed simply choose the quantity from the grid below.</span></div><div>&nbsp;&nbsp;&nbsp; <br><%
    //Create the pricing grid
    Vector vPrices = new Vector();
    int y = 0;
    String pSQL = "Select count(pp.id) as numZero from product_prices pp,products p where pp.prod_price_code=p.prod_price_code and (quantity=0 || price <=.009) and p.id=" + ((request.getParameter("productId") == null) ? "''" : request.getParameter("productId")) + " group BY pp.prod_price_code";

    ResultSet rsPriceCount = st.executeQuery(pSQL);
    int numZero = 0;
    if (rsPriceCount.next()) {
      numZero = ((rsPriceCount.getString("numZero") == null || rsPriceCount.getString("numZero").equals("")) ? 0 : rsPriceCount.getInt("numZero"));
    }

    pSQL = "Select format(quantity,0) as quantity,format(price,2) as price,format(price/quantity,3) as perItem  from product_prices pp,products p where pp.prod_price_code=p.prod_price_code and quantity>0 and price >.009 and p.id=" + ((request.getParameter("productId") == null) ? "''" : request.getParameter("productId")) + " ORDER BY pp.quantity";
    int colNum = numZero;
    ResultSet rsPrices = st.executeQuery(pSQL);
    while (rsPrices.next()) {
      vPrices.addElement(((rsPrices.getString("quantity") == null) ? "" : rsPrices.getString("quantity")));
      vPrices.addElement(((rsPrices.getString("price") == null) ? "" : rsPrices.getString("price")));
      vPrices.addElement(((rsPrices.getString("perItem") == null) ? "" : rsPrices.getString("perItem")));
      y++;

    }


    if (y > 0) {
  %><table border="0" cellpadding="0" cellspacing="0" width="100%">
    <tr><td class="catalogLABEL" colspan="<%=y + 1%>">Click on price to continue...</td></tr>
    <tr><td class="tableheader" colspan="<%=y%>">Quantity (sheet)</td></tr>
    <tr><%
    for (int z = 0; z <
            vPrices.size(); z =
                    z + 3) {
      %><td class="planheader2" align="center"><%=vPrices.get(z).toString()%></td><%
    }%>
    </tr>  <tr><%
    for (int z = 0; z <
            vPrices.size(); z =
                    z + 3) {
    %><td class="lineitems" align="center" onMouseOver="this.style.backgroundColor='#FFEBCD';" onMouseOut='this.style.backgroundColor="white"' ><a class="lineitemslink" href="javascript:orderJobFromSelfDesigned('0','<%=colNum++%>','<%=vPrices.get(z).toString().replaceAll(",", "")%>','<%=vPrices.get(z + 1).toString().replaceAll(",", "")%>','<%=previewTemplate%>','<%=pdfPreviewTemplate.replace(".", "_prepress.")%>','PrePress','true')">$<%=vPrices.get(z + 1).toString()%>&nbsp;<span class="pricePerItem"> [$<%=vPrices.get(z + 2).toString()%> each]</span></a></td><%
    }%>
  </table><%
  } else {%><table style="border: #7f8180 1px solid;" cellpadding="2" cellspacing="0">
  <tr><td class='tableHeader'>Price Quoted at Time of Order</td></tr></table><%    }
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
<table width=100% >
  <tr>
    <td>
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
    document.getElementById('preview').src='http://<%=((session.getAttribute("baseURL") == null) ? "" : session.getAttribute("baseURL").toString())%>'+prodTemplate+'?saveFile=true&pdfPreviewTemplate='+pdfTemplate+'&savedFileType='+savedFileType+'&catJobId=<%=request.getParameter("catJobId")%>';
  }


</script>
<input type="hidden" name="orderFromSelfDesigned" value="">
<input type="hidden" name="quantity" value="">
<input type="hidden" name="coordinates" value="">
<input type="hidden" name="selfDesigned" value="<%=((request.getParameter("selfDesigned") == null) ? "" : request.getParameter("selfDesigned"))%>">
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
<input type="hidden" name="printFileType" value="<%=((request.getParameter("printFileType") == null) ? "" : request.getParameter("printFileType"))%>">
<input type="hidden" name="productCode" value="<%=((request.getParameter("productCode") == null) ? "" : request.getParameter("productCode"))%>">
<input type="hidden" name="productId" value="<%=((request.getParameter("productId") == null) ? "" : request.getParameter("productId"))%>">
<input type="hidden" name="price" value="">
<input type="hidden" name="pdfPreviewTemplate" value="">
<input type="hidden" name="rePrint" value="">
<input type="hidden" name="jobId" value="<%=jobId%>">
<input type="hidden" name="projectId" value="<%=poId%>">
<input type="hidden" name="lastRow" value="">
<input type="hidden" name="lastCol" value="">
</form>
<%}
    st.close();
    conn.close();
    if (session.getAttribute("saveFileType") != null) {
      String saveFileType = session.getAttribute("saveFileType").toString();
      session.removeAttribute("saveFileType");
//<script>saveFile('saveFileType');</script>
    }
%>
<script>
  AjaxModalBox.close();
</script>
</body>
</html>