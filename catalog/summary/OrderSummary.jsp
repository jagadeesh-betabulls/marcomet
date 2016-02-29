<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<%@ page import="java.text.*,java.sql.*,com.marcomet.users.security.*,com.marcomet.tools.*,com.marcomet.environment.*,java.util.*,com.marcomet.catalog.*;" %>
<%@ taglib uri="/WEB-INF/tld/iterationTagLib.tld" prefix="iterate" %>
<%@ include file="/includes/SessionChecker.jsp" %>
<%@ taglib uri="/WEB-INF/tld/taglib.tld" prefix="taglib" %>
<jsp:useBean id="sl" class="com.marcomet.tools.SimpleLookups" scope="page" />
<jsp:useBean id="connection" class="com.marcomet.jdbc.ConnectionBean" scope="session" />
<jsp:useBean id="formater" class="com.marcomet.tools.FormaterTool" scope="page" />
<html>
<head>
  <%    if ((session.getAttribute("selfDesigned") == null || session.getAttribute("selfDesigned").toString().equals("false")) || (request.getParameter("selfDesigned") != null && request.getParameter("selfDesigned").toString().equals("false"))) {

	%><script>top.window.location.replace("/");</script></head></html><%

  } else {
    UserProfile up = (UserProfile) session.getAttribute("userProfile");

    Connection conn = com.marcomet.jdbc.DBConnect.getConnection();
    Statement st = conn.createStatement();
    DecimalFormat numberFormatter = new DecimalFormat("#,###,###");
    String previewTemplate = "/preview/brochure_from_sc.jsp";
    SiteHostSettings shs = (SiteHostSettings) session.getAttribute("siteHostSettings");
    boolean editor = (((RoleResolver) session.getAttribute("roles")).roleCheck("editor"));
    boolean overLimit = false;
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
      } //else if ((proparRS.getString("invoice_balance") != null && proparRS.getDouble("invoice_balance") < .001)) {
        //propInvoiceBalance += proparRS.getDouble("invoice_balance");
      //}
    }

    proppastdue = ((propInvoiceBalance < .01) ? 0 : proppastdue);

    int pastdue = 0;
    int orderBalance = 0;
    String balanceSQL = "select (sum(t.price) +  sum(t.shipprice)) - sum(t.payments) balance from (select  sum(j.price) price, 0 as shipprice, 0 as  payments from contacts c, jobs  j  where if(c.default_site_number=0,c.companyid=j.jbuyer_company_id,j.site_number=c.default_site_number)  and  c.id=" + up.getContactId() + " and j.status_id<>9 and j.status_id < 120  group by c.id union select 0 as  price, 0 as shipprice,  sum(arcd.payment_amount) payments from contacts c, jobs  j left join ar_invoice_details ari on ari.jobid=j.id left join ar_collection_details arcd on ari.ar_invoiceid=arcd.ar_invoiceid   where if(c.default_site_number =0,c.companyid=j.jbuyer_company_id,j.site_number=c.default_site_number)  and  c.id=" + up.getContactId() + " and j.status_id<>9 and j.status_id < 120  group by c.id union select 0 as  price, sum(s.price) as shipprice, 0 as payments from contacts c, jobs  j left join shipping_data s on s.job_id=j.id  where if(c.default_site_number=0,c.companyid=j.jbuyer_company_id,j.site_number=c.default_site_number)  and  c.id=" + up.getContactId() + " and j.status_id<>9 and j.status_id < 120  group by c.id) as t";

    ResultSet balRS = st.executeQuery(balanceSQL);
    while (balRS.next()) {
      orderBalance = balRS.getInt("balance");
    }


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
    ShoppingCart shoppingCart = (ShoppingCart) session.getAttribute("DIYshoppingCart");
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
    String pSQL = "";
    int numZero = 0;

    pSQL = "Select format(quantity,0) as quantity,format(price,2) as price,format(price/quantity,3) as perItem from product_prices pp,products p where pp.site_id='"+shs.getSiteHostId()+"' and pp.prod_price_code=p.prod_price_code and (quantity=0 or price <.01) and p.id=" + ((request.getParameter("productId") == null) ? "''" : request.getParameter("productId")) + " ORDER BY pp.quantity";
    
    int colNum = numZero;
    ResultSet rsPrices1 = st.executeQuery(pSQL);
    while (rsPrices1.next()) {
      vPrices.addElement("");
      vPrices.addElement("");
      vPrices.addElement("");
      y++;

    }
    
    pSQL = "Select format(quantity,0) as quantity,format(price,2) as price,format(price/quantity,3) as perItem from product_prices pp,products p where pp.site_id='"+shs.getSiteHostId()+"' and pp.prod_price_code=p.prod_price_code and quantity>0 and price >.009 and p.id=" + ((request.getParameter("productId") == null) ? "''" : request.getParameter("productId")) + " ORDER BY pp.quantity";
    colNum = numZero;
    ResultSet rsPrices = st.executeQuery(pSQL);
    while (rsPrices.next()) {
      vPrices.addElement(((rsPrices.getString("quantity") == null) ? "" : rsPrices.getString("quantity")));
      vPrices.addElement(((rsPrices.getString("price") == null) ? "" : rsPrices.getString("price")));
      vPrices.addElement(((rsPrices.getString("perItem") == null) ? "" : rsPrices.getString("perItem")));
      y++;

    }
    
    if (y==0){
	    pSQL = "Select count(pp.id) from product_prices pp,products p where pp.site_id='0' and pp.prod_price_code=p.prod_price_code and (quantity=0 or price <.01) and p.id=" + ((request.getParameter("productId") == null) ? "''" : request.getParameter("productId")) + " ORDER BY pp.quantity";
	    colNum = numZero;
	    ResultSet rsPrices00 = st.executeQuery(pSQL);
	    while (rsPrices00.next()) {
	      vPrices.addElement("");
	      vPrices.addElement("");
	      vPrices.addElement("");
	      y++;
	    }
	    
	    pSQL = "Select format(quantity,0) as quantity,format(price,2) as price,format(price/quantity,3) as perItem from product_prices pp,products p where pp.site_id='0' and pp.prod_price_code=p.prod_price_code and quantity>0 and price >.009 and p.id=" + ((request.getParameter("productId") == null) ? "''" : request.getParameter("productId")) + " ORDER BY pp.quantity";
	    colNum = numZero;
	    ResultSet rsPrices0 = st.executeQuery(pSQL);
	    while (rsPrices0.next()) {
	      vPrices.addElement(((rsPrices0.getString("quantity") == null) ? "" : rsPrices0.getString("quantity")));
	      vPrices.addElement(((rsPrices0.getString("price") == null) ? "" : rsPrices0.getString("price")));
	      vPrices.addElement(((rsPrices0.getString("perItem") == null) ? "" : rsPrices0.getString("perItem")));
	      y++;
	
	    }
	    
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
                    
    if(vPrices.get(z + 2).toString().equals("")){
    	colNum++;
     %><td><%
    }else{                
    %><td class="lineitems" align="center" onMouseOver="this.style.backgroundColor='#FFEBCD';" onMouseOut='this.style.backgroundColor="white"' ><a class="lineitemslink" href="javascript:orderJobFromSelfDesigned('0','<%=colNum++%>','<%=vPrices.get(z).toString().replaceAll(",", "")%>','<%=vPrices.get(z + 1).toString().replaceAll(",", "")%>','<%=previewTemplate%>','<%=pdfPreviewTemplate.replace(".", "_prepress.")%>','PrePress','true')">$<%=vPrices.get(z + 1).toString()%>&nbsp;<span class="pricePerItem"> [$<%=vPrices.get(z + 2).toString()%> each]</span></a>
    <%}%>
    </td><%
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
    document.forms[0].selfDesigned.value='false';
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
<input type="hidden" name="jobId" value="<%=request.getParameter("jobId")%>">
<input type="hidden" name="projectId" value="<%=poId%>">
<input type="hidden" name="lastRow" value="">
<input type="hidden" name="lastCol" value="">
</form>
<%
    st.close();
    conn.close();
%></body>
</html><%
}
if (session.getAttribute("saveFileType") != null) {
  String saveFileType = session.getAttribute("saveFileType").toString();
  session.removeAttribute("saveFileType");
}
%>