package com.marcomet.sbpprocesses;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.Statement;

import com.marcomet.jdbc.DBConnect;
import com.marcomet.tools.FormaterTool;

public class GenerateInvoiceDetails {
	
	public GenerateInvoiceBean invoiceDetails(String jobId) throws ClassNotFoundException, Exception
	{
		GenerateInvoiceBean invoice = new GenerateInvoiceBean();
		FormaterTool formater = new FormaterTool();
		
				
		double basePrice=0;
		double optionsPrice=0;	
		double changesPrice=0;	
		double invoicesPrice=0;
		double shippingPrice=0;
		double salestaxPrice=0;
		double discountPrice=0;
		double invoiceShipping=0;
		double invoiceSalesTax=0;
		double invoiceAmount=0;
		double invoicePurchaseAmount=0;

		
		
		double payments=0;
		
		double balance_due=0;
		
		Connection conn = DBConnect.getConnection();
		Statement st=conn.createStatement();		
		String query = "select * from ar_invoice_details where jobid = "+jobId;
		Statement stmt = conn.createStatement();
		
		ResultSet rsJob = stmt.executeQuery(query);
		rsJob.next();
		String invoiceId = rsJob.getString("id");
		
		String sql1 = "select * from ar_invoices where id = " + invoiceId;
		String sql2 = "select * from ar_invoice_details where ar_invoiceid = " + invoiceId;
		
		
		Statement st1 = conn.createStatement();
		Statement st2 = conn.createStatement();
		Statement st3=conn.createStatement();
		Statement st4=conn.createStatement();	
		Statement st5=conn.createStatement();
		Statement st6=conn.createStatement();
		Statement st7=conn.createStatement();	
		

		ResultSet rsInvoice = st1.executeQuery(sql1);
		ResultSet rsInvoiceDetail = st2.executeQuery(sql2);
		rsInvoice.next();
		rsInvoiceDetail.next();

		invoiceShipping=rsInvoiceDetail.getDouble("ar_shipping_amount");
		
		invoiceSalesTax=rsInvoiceDetail.getDouble("ar_sales_tax");
		
		invoiceAmount=rsInvoiceDetail.getDouble("ar_invoice_amount");
		
		String vendorId=rsInvoice.getString("vendor_id");
		
		invoicePurchaseAmount=rsInvoiceDetail.getDouble("ar_purchase_amount");
		
		String sql3 = "Select v.id,c.id companyId,c.company_name name,l.address1 address1,l.address2 address2,l.city city,s.value state,l.zip zip, l.fax fax from vendors v, companies c,company_locations l,lu_abreviated_states s where l.company_id=c.id and c.id=v.company_id and l.lu_location_type_id=3 and s.id=l.state and v.id="+vendorId;

		ResultSet rsVendorInfo = st3.executeQuery(sql3);
		rsVendorInfo.next();

		String sql4 = "Select concat(ct.firstname,\" \",ct.lastname) fullname, ct.id ctid, c.company_name companyname,l.address1 billtoaddress1,l.address2 billtoaddress2,l.city billtocity,s.value billtostate,l.zip billtozip ,shp.address1 shiptoaddress1,shp.address2 shiptoaddress2,shp.city shiptocity,sshp.value shiptostate,shp.zip shiptozip, ph.areacode phnareacode, ph.phone1 phnnum1, ph.phone2 phnnum2, fx.areacode faxareacode, fx.phone1 faxnum1, fx.phone2 faxnum2 ";
		sql4+=" from companies c,locations l,locations shp,lu_abreviated_states s,lu_abreviated_states sshp,contacts ct ";
		sql4+=" left join phones ph on ph.contactid=ct.id and ph.phonetype=1 ";
		
		sql4+=" left join phones fx on fx.contactid=ct.id and fx.phonetype=2 ";
		sql4+=" where c.id=ct.companyid and ct.id="+rsInvoice.getString("bill_to_contactid")+" and l.contactid=ct.id  and l.locationtypeid=2 and s.id=l.state and shp.contactid=ct.id  and shp.locationtypeid=1 and sshp.id=shp.state";
		
		
		ResultSet rsCustomerInfo = st4.executeQuery(sql4);
		rsCustomerInfo.next();
		System.out.println(rsInvoiceDetail.getString("jobid"));
		String sql5 = "Select * from jobs j Inner Join site_hosts sh ON j.jsite_host_id = sh.id Inner Join orders o ON j.jorder_id = o.id where j.id="+rsInvoiceDetail.getString("jobid");

		ResultSet rsJobInfo = st5.executeQuery(sql5);
		rsJobInfo.next();
		
		
		shippingPrice=rsJobInfo.getDouble("shipping_price");
		
		salestaxPrice=rsJobInfo.getDouble("sales_tax");
		
		String sql6 = "Select value from job_specs js, catalog_specs cs where js.job_id="+rsInvoiceDetail.getString("jobid")+" and js.cat_spec_id=cs.id and cs.spec_id=705";
		String jobQty="";
		ResultSet rsJobQty = st6.executeQuery(sql6);
		if (rsJobQty.next()){
			jobQty=((rsJobQty.getString("value")!=null && !rsJobQty.getString("value").equals(""))?rsJobQty.getString("value"):"");
			invoice.setJobQty(jobQty);
		}
		String sql = "select price from job_specs where (cat_spec_id=88888 or cat_spec_id=99999) and job_id="+rsInvoiceDetail.getString("jobid");
		
		ResultSet rsBasePrice = st.executeQuery(sql);
		while (rsBasePrice.next()){
			basePrice=rsBasePrice.getDouble("price")+basePrice;
			
		}

		 sql = "select sum(price) price from job_specs where (cat_spec_id<>88888 and cat_spec_id<>99999) and job_id="+rsInvoiceDetail.getString("jobid");

		ResultSet rsOptionPrice = st.executeQuery(sql);
		if (rsOptionPrice.next()){
			optionsPrice=rsOptionPrice.getDouble("price");
			
		}	

	// CSA added 02-01-2012 to present promo discount

		 sql = "select discount from jobs where id="+rsInvoiceDetail.getString("jobid");

		ResultSet rsDiscountPrice = st.executeQuery(sql);
		if (rsDiscountPrice.next()){
			discountPrice=rsDiscountPrice.getDouble("discount");
			
		}	

	// END - CSA added 02-01-2012 to present promo discount

		 sql = "select sum(d.ar_invoice_amount) price,sum(d.ar_sales_tax) salestaxPrice, sum(d.ar_shipping_amount) shippingPrice from ar_invoice_details d, ar_invoices i where i.id<'"+rsInvoice.getString("id")+"' and i.id=d.ar_invoiceid and d.jobid="+rsInvoiceDetail.getString("jobid");
		 st=conn.createStatement();
		ResultSet rsInvoicePrice = st.executeQuery(sql);
		if (rsInvoicePrice.next()){
			invoicesPrice=rsInvoicePrice.getDouble("price");
			
		}	

		 sql = "select sum(price) price from jobchanges where statusid=2 and jobid="+rsInvoiceDetail.getString("jobid");
		 st=conn.createStatement();
		ResultSet rsChangePrice = st.executeQuery(sql);
		if (rsChangePrice.next()){
			changesPrice=rsChangePrice.getDouble("price");
			
		}	
		 sql = "select * from ar_invoices i,ar_invoice_details d where i.id<"+rsInvoice.getString("id")+" and i.id=d.ar_invoiceid and d.jobid="+rsInvoiceDetail.getString("jobid");
		st=conn.createStatement();
		ResultSet rsInvoices = st.executeQuery(sql);
		rsInvoices.next();
		sql = "select st.value AS entity_string, rate from sales_tax, lu_abreviated_states st where st.id = sales_tax.entity and job_id = " + rsInvoiceDetail.getString("jobid");
		st=conn.createStatement();
		ResultSet rsTaxInfo = st.executeQuery(sql);
		rsTaxInfo.next();
		sql = "select sum(payment_amount) as payments from ar_collection_details where ar_invoiceid = " + invoiceId + " Group by ar_invoiceid";
		st=conn.createStatement();
		ResultSet rsPayments = st.executeQuery(sql);
		if (rsPayments.next()){
			payments=rsPayments.getDouble("payments") * -1;
			
		}
		double invAmt = invoiceAmount;
		balance_due = (invAmt) + payments;
		invoice.setBalance_due(balance_due);
		invoice.setFullname(rsCustomerInfo.getString("fullname"));
		invoice.setCompanyname(rsCustomerInfo.getString("companyname"));
		invoice.setBilltoaddress1(rsCustomerInfo.getString("billtoaddress1"));
		invoice.setBilltoaddress2(rsCustomerInfo.getString("billtoaddress2"));
		invoice.setBilltocity(rsCustomerInfo.getString("billtocity"));
		invoice.setBilltostate(rsCustomerInfo.getString("billtostate"));
		invoice.setBilltozip(rsCustomerInfo.getString("billtozip"));
		invoice.setShiptoaddress1(rsCustomerInfo.getString("shiptoaddress1"));
		invoice.setShiptoaddress2(rsCustomerInfo.getString("shiptoaddress2"));
		invoice.setShiptocity(rsCustomerInfo.getString("shiptocity"));
		invoice.setShiptostate(rsCustomerInfo.getString("shiptostate"));
		invoice.setShiptozip(rsCustomerInfo.getString("shiptozip"));
		invoice.setPhnareacode(rsCustomerInfo.getString("phnareacode"));
		invoice.setCustomerId(rsCustomerInfo.getString("ctid"));
		invoice.setInvoiceId(invoiceId);
		invoice.setCreateDate(rsInvoice.getString("creation_date"));
		invoice.setJobId(rsInvoiceDetail.getString("jobid"));
		invoice.setJobName(rsJobInfo.getString("job_name"));
		invoice.setInvoiceAmount(formater.getCurrency(invoiceAmount));
		invoice.setCurrentDue(formater.getCurrency(invoicePurchaseAmount+invoiceShipping));
		invoice.setJobBalanceUnbilled(formater.getCurrency(shippingPrice+salestaxPrice+optionsPrice+changesPrice+basePrice-discountPrice-invoicesPrice));
		invoice.setBilledToDate(formater.getCurrency(invoicesPrice));
		invoice.setJobTotal(formater.getCurrency(shippingPrice+salestaxPrice+optionsPrice+changesPrice+basePrice-discountPrice));
		invoice.setSalestax(formater.getCurrency(salestaxPrice));
		
		
		
		return invoice;
		
	}

}
