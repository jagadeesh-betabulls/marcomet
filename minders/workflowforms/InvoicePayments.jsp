<%@ page import="java.sql.*,com.marcomet.jdbc.*"%>
<%@ include file="/includes/SessionChecker.jsp"%>
<jsp:useBean id="formater" class="com.marcomet.tools.FormaterTool"
	scope="page" />
<jsp:useBean id="str" class="com.marcomet.tools.StringTool" scope="page" />
<html>
	<head>
		<title>Payments Invoice <%=request.getParameter("invoiceId")%>
		</title>
		<meta http-equiv="Content-Type"
			content="text/html; charset=iso-8859-1">
		<link rel="stylesheet"
			href='<%=(String) session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css'
			type="text/css">
	</head>
	<body>
		<table border="0" cellspacing="0" cellpadding="0" width="92%"
			align="center">
			<%
				double basePrice = 0;
				double optionsPrice = 0;
				double changesPrice = 0;
				double invoicesPrice = 0;
				double shippingPrice = 0;
				double salestaxPrice = 0;
				double payments = 0;
				double balance_due = 0;
				String sql1 = "select * from ar_invoices where id = "
						+ request.getParameter("invoiceId");
				String sql2 = "select * from ar_invoice_details where ar_invoiceid = "
						+ request.getParameter("invoiceId");
				Connection conn = DBConnect.getConnection();
				Statement st1 = conn.createStatement();
				Statement st2 = conn.createStatement();
				ResultSet rsInvoice = st1.executeQuery(sql1);
				ResultSet rsInvoiceDetail = st2.executeQuery(sql2);
				rsInvoice.next();
				rsInvoiceDetail.next();
				String invoiceShipping = rsInvoiceDetail
						.getString("ar_shipping_amount");
				String invoiceSalesTax = rsInvoiceDetail.getString("ar_sales_tax");
				String invoiceAmount = rsInvoiceDetail
						.getString("ar_invoice_amount");
				String vendorId = rsInvoice.getString("vendor_id");
				String invoicePurchaseAmount = rsInvoiceDetail
						.getString("ar_purchase_amount");
				String sql3 = "Select v.id,c.id companyId,c.company_name name,l.address1 address1,l.address2 address2,l.city city,s.value state,l.zip zip, l.fax fax from vendors v, companies c,company_locations l,lu_abreviated_states s where l.company_id=c.id and c.id=v.company_id and l.lu_location_type_id=3 and s.id=l.state and v.id="
						+ vendorId;
				Statement st3 = conn.createStatement();
				ResultSet rsVendorInfo = st3.executeQuery(sql3);
				rsVendorInfo.next();
				String sql4 = "Select concat(ct.firstname,\" \",ct.lastname) fullname, ct.id ctid, c.company_name companyname,l.address1 billtoaddress1,l.address2 billtoaddress2,l.city billtocity,s.value billtostate,l.zip billtozip ,shp.address1 shiptoaddress1,shp.address2 shiptoaddress2,shp.city shiptocity,sshp.value shiptostate,shp.zip shiptozip, ph.areacode phnareacode, ph.phone1 phnnum1, ph.phone2 phnnum2, fx.areacode faxareacode, fx.phone1 faxnum1, fx.phone2 faxnum2 ";
				sql4 += " from companies c,locations l,locations shp,lu_abreviated_states s,lu_abreviated_states sshp,contacts ct ";
				sql4 += " left join phones ph on ph.contactid=ct.id and ph.phonetype=1 ";
				sql4 += " left join phones fx on fx.contactid=ct.id and fx.phonetype=2 ";
				sql4 += " where c.id=ct.companyid and ct.id="
						+ rsInvoice.getString("bill_to_contactid")
						+ " and l.contactid=ct.id  and l.locationtypeid=2 and s.id=l.state and shp.contactid=ct.id  and shp.locationtypeid=1 and sshp.id=shp.state";
				Statement st4 = conn.createStatement();
				ResultSet rsCustomerInfo = st4.executeQuery(sql4);
				rsCustomerInfo.next();
				String sql5 = "Select * from jobs j, projects p, orders o, site_hosts sh where j.id="
						+ rsInvoiceDetail.getString("jobid")
						+ " and j.project_id = p.id and p.order_id = o.id and o.site_host_id = sh.id";
				Statement st5 = conn.createStatement();
				ResultSet rsJobInfo = st5.executeQuery(sql5);
				rsJobInfo.next();
				shippingPrice = rsJobInfo.getDouble("shipping_price");
				salestaxPrice = rsJobInfo.getDouble("sales_tax");
				String sql6 = "Select value from job_specs js, catalog_specs cs where js.job_id="
						+ rsInvoiceDetail.getString("jobid")
						+ " and js.cat_spec_id=cs.id and cs.spec_id=705";
				Statement st6 = conn.createStatement();
				ResultSet rsJobQty = st6.executeQuery(sql6);
				rsJobQty.next();
				String sql = "select price from job_specs where (cat_spec_id=88888 or cat_spec_id=99999) and job_id="
						+ rsInvoiceDetail.getString("jobid");
				Statement st = conn.createStatement();
				ResultSet rsBasePrice = st.executeQuery(sql);
				while (rsBasePrice.next()) {
					basePrice = rsBasePrice.getDouble("price") + basePrice;
				}
				sql = "select sum(price) price from job_specs where (cat_spec_id<>88888 and cat_spec_id<>99999) and job_id="
						+ rsInvoiceDetail.getString("jobid");

				st = conn.createStatement();
				ResultSet rsOptionPrice = st.executeQuery(sql);

				if (rsOptionPrice.next()) {
					optionsPrice = rsOptionPrice.getDouble("price");
				}
				sql = "select sum(d.ar_invoice_amount) price,sum(d.ar_sales_tax) salestaxPrice, sum(d.ar_shipping_amount) shippingPrice from ar_invoice_details d, ar_invoices i where i.id<'"
						+ rsInvoice.getString("id")
						+ "' and i.id=d.ar_invoiceid and d.jobid="
						+ rsInvoiceDetail.getString("jobid");
				st = conn.createStatement();
				ResultSet rsInvoicePrice = st.executeQuery(sql);
				if (rsInvoicePrice.next()) {
					invoicesPrice = rsInvoicePrice.getDouble("price");
				}

				sql = "select sum(price) price from jobchanges where statusid=2 and jobid="
						+ rsInvoiceDetail.getString("jobid");
				st = conn.createStatement();
				ResultSet rsChangePrice = st.executeQuery(sql);
				if (rsChangePrice.next()) {
					changesPrice = rsChangePrice.getDouble("price");
				}
				sql = "select * from ar_invoices i,ar_invoice_details d where i.id<"
						+ rsInvoice.getString("id")
						+ " and i.id=d.ar_invoiceid and d.jobid="
						+ rsInvoiceDetail.getString("jobid");
				st = conn.createStatement();
				ResultSet rsInvoices = st.executeQuery(sql);
				rsInvoices.next();
				sql = "select st.value AS entity_string, rate from sales_tax, lu_abreviated_states st where st.id = sales_tax.entity and job_id = "
						+ rsInvoiceDetail.getString("jobid");
				st = conn.createStatement();
				ResultSet rsTaxInfo = st.executeQuery(sql);
				rsTaxInfo.next();
				sql = "select arc.check_number as chk_no, cc.value as cc_type, arc.check_auth_code as cc_auth, arc.deposit_date as dep_date, arcd.payment_amount as pmt_detail from ar_collection_details arcd, ar_collections arc left join lu_credit_cards cc on cc.id = arc.check_number where arcd.ar_collectionid=arc.id and arcd.ar_invoiceid = "
						+ request.getParameter("invoiceId");
				st = conn.createStatement();

				ResultSet rsPaymentDetails = st.executeQuery(sql);
				rsPaymentDetails.next();

				sql = "select sum(payment_amount) as payments from ar_collection_details where ar_invoiceid = "
						+ request.getParameter("invoiceId")
						+ " Group by ar_invoiceid";

				st = conn.createStatement();

				ResultSet rsPayments = st.executeQuery(sql);

				if (rsPayments.next()) {

					payments = rsPayments.getDouble("payments") * -1;

				}

				double invAmt = Double.valueOf(invoiceAmount.trim()).doubleValue();

				balance_due = (invAmt) + payments;
			%>

			<tr>

				<td class="billheader">
					<b><font size="5">Payments on <%=rsVendorInfo.getString("name")%>&nbsp;Invoice</font>
					</b>
				</td>

			</tr>

			<tr>

				<td class="billheader">
					<b><font size="4">for your order on the <%=rsJobInfo.getString("site_host_name")%>&nbsp;website&nbsp;(<%=rsJobInfo.getString("site_name")%>)</font>
					</b>
				</td>

			</tr>
		</table>

		<br>

		<br>

		<table width="90%" border="0" cellspacing="0" cellpadding="0"
			align="center">

			<tr>

				<td>

					<div align="left">

						<table width="50%" cellpadding="0" border="0" cellspacing="0">

							<tr>

								<td class="billheader" align="left" height="20">

									<div align="left">
										<b>Bill To</b>
									</div>

								</td>

								<td class="billheader" align="left" height="20">

									<div align="left">
										<b>Ship To</b>
									</div>

								</td>

							</tr>

							<tr>

								<td class="bill">

									<%=((rsCustomerInfo.getString("fullname") == null) ? ""
							: "<b>" + rsCustomerInfo.getString("fullname")
									+ "<br></b>")%>

									<%=((rsCustomerInfo.getString("companyname") == null) ? ""
									: rsCustomerInfo.getString("companyname")
											+ "<br>")%>

									<%=((rsCustomerInfo.getString("billtoaddress1") == null || rsCustomerInfo
									.getString("billtoaddress1").equals("")) ? ""
									: rsCustomerInfo
											.getString("billtoaddress1")
											+ "<br>")%>

									<%=((rsCustomerInfo.getString("billtoaddress2") == null || rsCustomerInfo
									.getString("billtoaddress2").equals("")) ? ""
									: rsCustomerInfo
											.getString("billtoaddress2")
											+ "<br>")%>

									<%=((rsCustomerInfo.getString("billtocity") == null) ? ""
							: rsCustomerInfo.getString("billtocity") + ",  ")%>

									<%=((rsCustomerInfo.getString("billtostate") == null) ? ""
							: rsCustomerInfo.getString("billtostate") + "  ")%>

									<%=((rsCustomerInfo.getString("billtozip") == null) ? ""
							: rsCustomerInfo.getString("billtozip") + "<br>")%>

									<%=((rsCustomerInfo.getString("phnareacode") == null) ? ""
							: "Phn: " + rsCustomerInfo.getString("phnareacode")
									+ "-")%>

									<%=((rsCustomerInfo.getString("phnnum1") == null) ? ""
							: rsCustomerInfo.getString("phnnum1") + "-")%>

									<%=((rsCustomerInfo.getString("phnnum2") == null) ? ""
							: rsCustomerInfo.getString("phnnum2") + "<br>")%>

									<%=((rsCustomerInfo.getString("faxareacode") == null) ? ""
							: "Fax: " + rsCustomerInfo.getString("faxareacode")
									+ "-")%>

									<%=((rsCustomerInfo.getString("faxnum1") == null) ? ""
							: rsCustomerInfo.getString("faxnum1") + "-")%>

									<%=((rsCustomerInfo.getString("faxnum2") == null) ? ""
							: rsCustomerInfo.getString("faxnum2"))%>
								</td><td class="bill">
									<%=((rsCustomerInfo.getString("shiptoaddress1") == null || rsCustomerInfo
									.getString("shiptoaddress1").equals("")) ? ""
									: rsCustomerInfo
											.getString("shiptoaddress1")
											+ "<br>")%>
									<%=((rsCustomerInfo.getString("shiptoaddress2") == null || rsCustomerInfo
									.getString("shiptoaddress2").equals("")) ? ""
									: rsCustomerInfo
											.getString("shiptoaddress2")
											+ "<br>")%>
									<%=((rsCustomerInfo.getString("shiptocity") == null) ? ""
							: rsCustomerInfo.getString("shiptocity") + ",  ")%>
									<%=((rsCustomerInfo.getString("shiptostate") == null) ? ""
							: rsCustomerInfo.getString("shiptostate") + "  ")%>
									<%=((rsCustomerInfo.getString("shiptozip") == null) ? ""
							: rsCustomerInfo.getString("shiptozip"))%>
								</td>
							</tr>
						</table>
					</div>
					<p align="left"></p>
					<div align="left">
						<table width="72%" cellpadding="0" border="0" cellspacing="0">
							<tr>
								<td class="billheader" align="left" height="20" width="21%">
									<b>Customer #:</b>
							</td>
								<td class="billheader" align="left" height="20" width="21%">
									<div align="left">
									<b>Invoice Number</b>
								</div>
								</td>
								<td class="billheader" align="left" height="20" width="22%">
									<div align="left">
									<b>Invoice Date</b>
								</div>
								</td>
								<td class="billheader" align="left" height="20" width="21%">
									<div align="left">
									<b>Job Number</b>
								</div>
								</td>
								<td class="billheader" align="left" height="20" width="36%">
									<div align="left">
									<b>Terms</b>
								</div>
								</td>
							</tr>
							<tr>
								<td class="bill" height="20" width="21%">
								<%=((rsCustomerInfo.getString("ctid") == null) ? ""
						: rsCustomerInfo.getString("ctid"))%>
							</td>
								<td class="bill" height="20" width="21%">
								<%=rsInvoice.getString("invoice_number")%>
							</td>
								<td class="bill" height="20" width="22%">
								<%=formater.formatMysqlDate(rsInvoice
						.getString("creation_date"))%>
							</td>
								<td class="bill" height="20" width="21%">
								<%=rsInvoiceDetail.getString("jobid")%>
							</td>
								<td class="bill" height="20" width="36%">
								Due Upon Receipt
							</td>
							</tr>
						</table>
						<p></p>
				</div>
				</td>
			</tr>
		</table>
		<table width="90%" cellpadding="0" cellspacing="0" border="0"
		align="center">
			<tr>
				<td class="bill" colspan="2" height="20">
					<table width="100%" align="left" cellspacing="0" Border="0"
					cellpadding="0">
						<tr bgcolor="#CCFFFF">
							<td class="bill" width="30%" height="20">
								<div align="right">
								Payments Received
							</div>
							</td>
							<td class="bill" width="70%" height="20">
							<!-- end payment detail -->
								<%
							do {
							%>
							&nbsp
							<%
									if ((rsPaymentDetails.getString("chk_no") != null)
									&& (rsPaymentDetails.getString("cc_auth") == null)) {
							%>
								<div align="right">
								Chk &nbsp;
								<%=rsPaymentDetails.getString("chk_no")%>
								&nbsp; pd &nbsp;
								<%=rsPaymentDetails.getString("dep_date")%>
								&nbsp; &nbsp;
								<%=formater.getCurrency(rsPaymentDetails
								.getString("pmt_detail"))%>
							</div>
							<%
									}
										if ((rsPaymentDetails.getString("chk_no") != null)
									&& (rsPaymentDetails.getString("cc_auth") != null)) {
							%>
								<div align="right">
								<%=rsPaymentDetails.getString("cc_type")%>
								&nbsp;pd&nbsp;
								<%=rsPaymentDetails.getString("dep_date")%>
								&nbsp; &nbsp;
								<%=formater.getCurrency(rsPaymentDetails
								.getString("pmt_detail"))%>
								</div>
							<%
								}
									} while (rsPaymentDetails.next());
								%>
								<!-- end payment detail -->

								<!--            <div align="right"><%=formater.getCurrency(payments)%></div> -->

							</td>

						</tr>

					</table>

				</td>

			</tr>

		</table>

		<hr color="red" size="1" width="92%" align="center">

	</body>

</html>

<%
		try {
		st.close();
	} catch (Exception x) {
	}
	;
	try {
		st1.close();
	} catch (Exception x) {
	}
	;
	try {st2.close();} catch (Exception x) {
	}
	;
	try {
		st3.close();
	} catch (Exception x) {
	}
	;
	try {
		st4.close();
	} catch (Exception x) {
	}
	;
	try {
		st5.close();
	} catch (Exception x) {
	}
	;
	try {
		st6.close();
	} catch (Exception x) {
	}
	;
	try {
		conn.close();
	} catch (Exception x) {
	}
	;
%>

