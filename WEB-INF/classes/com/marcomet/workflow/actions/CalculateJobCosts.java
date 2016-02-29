package com.marcomet.workflow.actions;

/**********************************************************************
Description:	This class gathers all of the current cost information
				and populates the job table with lookup values.
**********************************************************************/

import java.sql.*;
import java.util.Hashtable;
import javax.servlet.http.*;
import com.marcomet.files.MultipartRequest;
import com.marcomet.jdbc.*;

public class CalculateJobCosts implements ActionInterface {

	//basic connections
	//private SimpleConnection sc;
	//private Connection conn;
	
	public CalculateJobCosts() {
		//sc = new SimpleConnection();
		//conn = sc.getConnection();
	}
	public void calculate(int jobId) throws Exception {
		this.calculate((new Integer(jobId)).toString());
	}
	public void calculate(String jobId) throws Exception {

		Connection conn = null;
		try {			
		
			conn = DBConnect.getConnection();
		
			Statement st = conn.createStatement();	
			Statement st2 = conn.createStatement();	
			Statement st3 = conn.createStatement();		
			
//FIRST-RUN-ONLY FIELDS
//initial fields set -- only need to run once at job creation, or if job is flagged for full recalc by nulling the order date (will be restored from order record anyway)
			boolean firstRun=false;
			boolean jobPosted=false;
			String shipLocationId="0";
			ResultSet rsJ=st2.executeQuery("select if(order_date is null,'true','false') order_date,if(post_date is null,'false','true') post_date,ship_location_id from jobs where id="+jobId);
			if(rsJ.next()){
				firstRun=((rsJ.getString("order_date").equals("true"))?true:false);
				jobPosted=((rsJ.getString("post_date").equals("false"))?false:true);
				shipLocationId=((rsJ.getString("ship_location_id")==null)?"0":rsJ.getString("ship_location_id"));
			}
			
			if(firstRun){
				//update Order Fields: buyer_company_id, buyer_contact_id,site_host_id, site_host_contact_id 
				try{
					String updateOrderInfo ="update jobs j,orders o,projects p,contacts c set j.site_number=c.default_site_number, j.order_date=o.date_created, j.jbuyer_company_id=o.buyer_company_id, j.jbuyer_contact_id=o.buyer_contact_id,j.jsite_host_id=o.site_host_id, j.jsite_host_contact_id =o.site_host_contact_id where j.order_date is null and j.project_id=p.id and p.order_id=o.id and o.buyer_contact_id=c.id and j.id=" + jobId;
					st.executeUpdate(updateOrderInfo);
				} catch (Exception ex) {
					try { conn.close(); } catch ( Exception x) { conn = null; }
					throw new Exception("CalculateJobCosts:updateOrderInfo " + ex.getMessage());
				} 
				//If this is an ad job and the adnumber field is blank populate it with the job number+property number
				try{
					String updateOrderInfo ="update jobs j,contacts c,job_specs js set js.value=concat(j.site_number,'_',j.id) where  j.id=" + jobId+" and js.job_id=j.id and js.cat_spec_id='11036' and (js.value='' or js.value is null)";
					st.executeUpdate(updateOrderInfo);
				} catch (Exception ex) {
					try { conn.close(); } catch ( Exception x) { conn = null; }
					throw new Exception("CalculateJobCosts:updateAdNumber " + ex.getMessage());
				} 
				
				//If this is an ad job and the materials close date (due date) is populated, add it to the job name
				try{
					String updateOrderInfo ="update jobs j left join job_specs jsPub on jsPub.job_id=j.id and jsPub.cat_spec_id='11041' and (jsPub.value<>'' and  jsPub.value is not null)  left join job_specs jsIDate on  jsIDate.job_id=j.id and jsIDate.cat_spec_id='11042' and (jsIDate.value<>'' and  jsIDate.value is not null)  , job_specs js  set j.job_name= concat(j.job_name,'; Materials Due: ',if(date_format(js.value,'%m/%d/%Y') is null,js.value,date_format(js.value,'%m/%d/%Y')), if(jsPub.id is null,'', concat(', Pub: ',jsPub.value)), if(jsIDate.id is null,'', concat(', Issue Date: ', jsIDate.value)) )   where js.job_id=j.id and js.cat_spec_id='11038' and (js.value<>'' and  js.value is not null) and j.id="+jobId;
					st.executeUpdate(updateOrderInfo);
				} catch (Exception ex) {
					try { conn.close(); } catch ( Exception x) { conn = null; }
					throw new Exception("CalculateJobCosts:updateDueDate " + ex.getMessage());
				} 
				
				// update product codes in jobs
				String updateProductCodes="update jobs j, job_specs js, catalog_specs cs set j.product_code = js.value where js.job_id=j.id and js.cat_spec_id=cs.id and cs.spec_id='9001' and j.id = " + jobId;
				try {
					st.executeUpdate(updateProductCodes);
				} catch (Exception ex) {
					try { conn.close(); } catch ( Exception x) { conn = null; }
					throw new Exception("updateProductCodes error " + ex.getMessage());
				} 
	
				// update product id in jobs.
				String selectProductId="Select * from jobs j, job_specs js, catalog_specs cs where js.job_id=j.id and js.cat_spec_id=cs.id and cs.spec_id='9000' and j.id = " + jobId;
				ResultSet rsPr=st2.executeQuery(selectProductId);
				String updateProductId="";
				if(rsPr.next()){
					updateProductId="update jobs j, job_specs js, catalog_specs cs set j.product_id = js.value where js.job_id=j.id and js.cat_spec_id=cs.id and cs.spec_id='9000' and j.id = " + jobId;			
				}else{
					updateProductId="update jobs j, products pr set j.product_id = pr.id where j.product_code=pr.prod_code and j.id = " + jobId;
				}
				
				try {
					st.executeUpdate(updateProductId);
				} catch (Exception ex) {
					try { conn.close(); } catch ( Exception x) { conn = null; }
					throw new Exception("CalculateJobCosts:updateProductId error " + ex.getMessage());
				}
	
				//Update product brand codes in jobs
				String updateBrandCodes="update jobs j, products pr set j.brand_code = pr.brand_code, j.root_prod_code = pr.root_prod_code,j.root_inv_prod_id = if(pr.root_inv_prod_id=0,pr.id,pr.root_inv_prod_id) where j.product_id=pr.id and j.id = " + jobId;
				try {
					st.executeUpdate(updateBrandCodes);
				} catch (Exception ex) {
					try { conn.close(); } catch ( Exception x) { conn = null; }
					throw new Exception("CalculateJobCosts:updateBrandCodes error " + ex.getMessage());
				}
						
				//Update product quantities in jobs
				String updateProductQuantities="update jobs j, job_specs js, catalog_specs cs set j.quantity = replace(js.value, ',', '') where js.job_id=j.id and js.cat_spec_id=cs.id and cs.spec_id='705' and j.id = " + jobId;
				try {
					st.executeUpdate(updateProductQuantities);
				} catch (Exception ex) {
					try { conn.close(); } catch ( Exception x) { conn = null; }
					throw new Exception("CalculateJobCosts:updateProductQuantities error " + ex.getMessage());
				} 
				
				//Update product prices and vendor fields -- Use warehouse on the vendor record (if null use marcomet) unless there's a warehouse on the product record.
				try{
					st.executeUpdate("update product_price_codes ppc, jobs j inner join products p on  j.product_id=p.id  left join product_prices pp on p.prod_price_code=pp.prod_price_code and j.quantity=pp.quantity left join vendors v on v.id=j.dropship_vendor  set j.dropship_vendor=ppc.dropship_vendor,j.non_billable_flag=pp.non_billable_flag,j.accrued_inventory_cost=pp.inventory_cost,j.est_material_cost=pp.po_cost+pp.inventory_cost,j.est_labor_cost=pp.MC_est_labor_cost, j.ship_cost_policy=if(pp.id is null,p.default_ship_cost_policy,pp.ship_cost_policy),j.jwarehouse_id=if(p.default_warehouse_id is not null and p.default_warehouse_id<>0,p.default_warehouse_id,v.default_warehouse_id) where p.prod_price_code=ppc.prod_price_code  and j.id="+jobId);
				} catch (Exception ex) {
					try { conn.close(); } catch ( Exception x) { conn = null; }
					throw new Exception("CalculateJobCosts:updateProductpricesFields error " + ex.getMessage());
				} 
				// If state is greater than 53 or = 2 or 12 (i.e. not in the continental US) remove ship price policies of 1 and 2 so shipping isn't fixed or included.
			//	try{
			//		st.executeUpdate("update jobs j left join shipping_locations l on l.id=j.ship_location_id left join lu_countries luc on l.country_code= set j.ship_price_policy=0 where (l.state>52 or l.state=2 or l.state=12) and j.ship_price_policy<>0 and j.id="+jobId);
			//	} catch (Exception ex) {
			//		try { conn.close(); } catch ( Exception x) { conn = null; }
			//		throw new Exception("CalculateJobCosts:updateShipPolicyForNonUsLocations error " + ex.getMessage());
			//	} 
			}
			
//END FIRST-RUN-ONLY FIELDS
			
			//If no sales tax record has been created for this job, create one now
			ResultSet rsSTax=st.executeQuery("Select * from sales_tax where job_id="+jobId);
			boolean taxNotFound=true;
			if(rsSTax.next()){
				taxNotFound=((rsSTax.getString("id")!=null && !rsSTax.getString("id").equals(""))?false:true);
			}
			if(taxNotFound){
				String taxEntity="153";
				String taxRate="0";
				String taxShipping="0";
				String taxJob="0";
				String buyerExempt="0";
				//get the tax entity and rate, calculate tax due
				String stSQL = "";
				if (shipLocationId.equals("0")){
					stSQL="SELECT l.state 'stateid', co.tax_exempt 'exempt',ls.state_tax_rate 'rate',ls.tax_shipping_flag 'tax_shipping',ls.tax_job_flag 'tax_job'  FROM locations l,lu_states ls, jobs j, projects p, orders o,companies co,contacts c WHERE l.state=ls.state_number and o.id = p.order_id AND p.id = j.project_id AND l.contactid=o.buyer_contact_id  AND c.id=o.buyer_contact_id and c.companyid=co.id AND l.locationtypeid=1 AND j.id = " + jobId;
				}else{
					stSQL="SELECT l.state 'stateid', co.tax_exempt 'exempt',ls.state_tax_rate 'rate',ls.tax_shipping_flag 'tax_shipping',ls.tax_job_flag 'tax_job'  FROM shipping_locations l,lu_states ls, jobs j, projects p, orders o,companies co,contacts c WHERE l.state=ls.state_number and o.id = p.order_id AND p.id = j.project_id AND l.id="+shipLocationId+"  AND c.id=o.buyer_contact_id and c.companyid=co.id AND j.id = " + jobId;					
					
				}
				ResultSet rsTaxInfo = st.executeQuery(stSQL);
				if (rsTaxInfo.next()) {
						taxEntity=rsTaxInfo.getString("stateid");
						buyerExempt=rsTaxInfo.getString("exempt");
						taxRate=rsTaxInfo.getString("rate");
						taxShipping=rsTaxInfo.getString("tax_shipping");
						taxJob=rsTaxInfo.getString("tax_job");
				}
				
				if (taxJob.equals("1")){
						stSQL = "Select p.taxable 'taxable' from jobs j, products p where  p.id=j.product_id AND j.id = " + jobId;
						rsTaxInfo = st.executeQuery(stSQL);
						if (rsTaxInfo.next()) {
							taxJob=rsTaxInfo.getString("taxable");
						}
				}
				st.executeUpdate("insert into sales_tax ( job_id, entity, rate, tax_shipping, tax_job, buyer_exempt) values ('"+jobId+"', '"+taxEntity+"', '"+taxRate+"', '"+taxShipping+"','"+taxJob+"', '"+buyerExempt+"')"); 
				
			}
		
// update product on_order and inventory amounts
			try {
				String selectProductInvId="Select root_inv_prod_id, product_id from jobs j where j.id = " + jobId;
				ResultSet rsInvPr=st.executeQuery(selectProductInvId);
				int invProductId=0;
				String productId="0";
				String updatePrOr="0";
				if(rsInvPr.next()){
					invProductId=Integer.parseInt(rsInvPr.getString("root_inv_prod_id"));
					productId=rsInvPr.getString("product_id");
				}
				
				if (invProductId>0){
					String productsOnOrder="SELECT sum(j.quantity-(if(s.shipping_quantity is null,0,s.shipping_quantity)))  FROM jobs j left join shipping_data s on s.job_id=j.id where j.status_id<>9 and j.status_id<>119 and j.status_id<>120 and  j.product_id='"+productId+"' GROUP BY j.product_id";
					ResultSet rsPrOr=st.executeQuery(productsOnOrder);
					if(rsPrOr.next()){
						updatePrOr="UPDATE products SET on_order_amount = "+rsPrOr.getString(1)+" WHERE id = '"+productId+"'";	
						st.executeUpdate(updatePrOr);
					}
				
					String rootProductOnOrder="SELECT sum(j.quantity-(if(s.shipping_quantity is null,0,s.shipping_quantity)))  FROM products p,jobs j left join shipping_data s on s.job_id=j.id where p.id=j.product_id and j.status_id<>9 and j.status_id<>119 and j.status_id<>120 and (p.root_inv_prod_id='"+invProductId+"' or  p.id='"+invProductId+"') ";
					ResultSet rsRtPrOr=st.executeQuery(rootProductOnOrder);
					if(rsRtPrOr.next()){
						updatePrOr="UPDATE products SET inv_on_order_amount = "+rsRtPrOr.getString(1)+" WHERE root_inv_prod_id = '"+invProductId+"' OR id = '"+invProductId+"'";	
						st.executeUpdate(updatePrOr);
					}
				
					//split this off into a separate servlet
					String invAmount="SELECT sum(amount) amount, sum(adjustment_action) action FROM inventory where root_inv_prod_id='"+invProductId+"' GROUP BY root_inv_prod_id";
					ResultSet rsInvAmt=st.executeQuery(invAmount);
					if(rsInvAmt.next()){
						updatePrOr="UPDATE products SET inventory_initialized="+rsInvAmt.getString(2)+", inventory_amount = "+((rsInvAmt.getString(2).equals("0"))?"0":rsInvAmt.getString(1))+" WHERE root_inv_prod_id = '"+invProductId+"' OR id = '"+invProductId+"'";	
						st.executeUpdate(updatePrOr);
					}
				}
				
			} catch (Exception ex) {
				try { conn.close(); } catch ( Exception x) { conn = null; }
				throw new Exception("CalculateJobCosts:productsOnOrder error " + ex.getMessage());
			}
			
// update jobs with billings data 

			String updateJobBillingsSelect="SELECT if(sum(ar_purchase_amount) is null,0,sum(ar_purchase_amount)) totARPurchase, if(sum(ar_shipping_amount) is null,0,sum(ar_shipping_amount)) totARShipping, if(sum(ar_sales_tax) is null,0,sum(ar_sales_tax)) totARSalesTax, if(sum(ar_invoice_amount) is null,0,sum(ar_invoice_amount)) totARInvoice FROM ar_invoice_details arid where jobid="+jobId;
			try {
				ResultSet rs1=st.executeQuery(updateJobBillingsSelect);
				if(rs1.next()){
					String updateJobBillings="UPDATE jobs j SET j.billed_purchase_amount = "+rs1.getString("totARPurchase")+", j.billed_shipping_amount = "+rs1.getString("totARShipping")+", j.billed_sales_tax_amount = "+rs1.getString("totARSalesTax")+" WHERE j.id = " + jobId;
					st.executeUpdate(updateJobBillings);
				}
			} catch (Exception ex) {
				try { conn.close(); } catch ( Exception x) { conn = null; }
				throw new Exception("CalculateJobCosts:updateJobBillingsSelect error " + ex.getMessage());
			}

			
			



//Roll up accrued po cost, other fields from prod_prices at point of ordering, create initial po_transactions record if necessary
//NOTE: After converting all existing records, move the 'if po doesn't exist' logic to first-run fields - po will be created manually if it's not created at outset.

			try{
				ResultSet rsJobs=st3.executeQuery("select * from jobs where id="+jobId);
				if (rsJobs.next()){
					
				}
				double accruedPoCost=0;
				boolean poExists=false;
				String poAdj="Select if(sum(adjustment_amount) is null,0,1) po_exists, if(sum(adjustment_amount) is null,0,sum(adjustment_amount) ) accruedCost from po_transactions where job_id="+jobId;
				ResultSet rsPOAdj=st.executeQuery(poAdj);
				if(rsPOAdj.next()){
					accruedPoCost=rsPOAdj.getDouble("accruedCost");	
					poExists=((rsPOAdj.getString("po_exists").equals("1"))?true:false);
				}

				if (poExists){
					st.executeUpdate("update jobs j set j.accrued_po_cost="+accruedPoCost+" where j.id="+jobId); //Note this gets run whether or not there is a post date on the job 
				}else{
					ResultSet rsPOCost=st.executeQuery("select j.order_date, if(pp.po_cost is null,0,pp.po_cost) po_cost,ppc.dropship_vendor from jobs j left join products p on j.product_id=p.id left join product_prices pp on (j.quantity=pp.quantity and p.prod_price_code=pp.prod_price_code) left join product_price_codes ppc on p.prod_price_code=ppc.prod_price_code where j.id="+jobId);
					String dsVendor="0";
					String orderDate="";
					if(rsPOCost.next()){
						accruedPoCost=rsPOCost.getDouble("po_cost");	
						dsVendor=((rsPOCost.getString("dropship_vendor")==null)?"105":rsPOCost.getString("dropship_vendor"));
						orderDate=rsPOCost.getString("order_date");			
						st.executeUpdate("insert into po_transactions ( job_id, vendor_id, adjustment_code, purchase_cost_adj_amt, adjustment_amount, adjustment_date, adjustment_notes) values ('"+jobId+"', '"+dsVendor+"', '0', '"+accruedPoCost+"','"+accruedPoCost+"', '"+orderDate+"', 'Job Cost')"); 
						String updateAccruedPOCost ="update jobs j,products p,product_prices pp set j.non_billable_flag=pp.non_billable_flag,j.accrued_po_cost='"+accruedPoCost+"',j.accrued_inventory_cost=pp.inventory_cost,j.est_material_cost=pp.po_cost+pp.inventory_cost,j.est_labor_cost=pp.MC_est_labor_cost where j.product_id=p.id and p.prod_price_code=pp.prod_price_code and j.quantity=pp.quantity and j.dropship_vendor is not null and j.order_date is null and j.id="+jobId;
						st.executeUpdate(updateAccruedPOCost);
					}
				}

			} catch (Exception ex) {
				try { conn.close(); } catch ( Exception x) { conn = null; }
				throw new Exception("CalculateJobCosts:updateAccruedPOCost " + ex.getMessage());
			}

//Misc job rollup and financial calcs.						
							
			String jobSpecsQuery = "SELECT SUM(js.cost) AS cost, SUM(js.fee) AS fee, SUM(js.mu) AS mu, SUM(js.price) AS price FROM job_specs js WHERE js.job_id = " + jobId;
//			String shippingQuery = "SELECT if((j.std_ship_price>0 and j.ship_price_policy=2),j.std_ship_price,if(j.ship_price_policy=1,0,SUM(s.price))) AS shipping_price, SUM(s.cost) AS shipping_cost, SUM(s.mu) as shipping_mu, SUM(s.shipping_quantity) as shipping_quantity  FROM jobs j left join shipping_data s on j.id=s.job_id where j.id="+ jobId+"  group by job_id";
			String shippingQuery = "SELECT if((j.std_ship_price>0 and (j.ship_price_policy=2 or j.ship_price_policy=3)),j.std_ship_price,if(j.ship_price_policy=1,0,SUM(s.price))) AS shipping_price, SUM(s.cost) AS shipping_cost, SUM(s.mu) as shipping_mu, SUM(s.shipping_quantity) as shipping_quantity  FROM jobs j left join shipping_data s on j.id=s.job_id where j.id="+ jobId+"  group by job_id";
			String taxQuery = "SELECT rate, tax_shipping, tax_job, buyer_exempt FROM sales_tax WHERE job_id = " + jobId;
			String changesQuery = "SELECT SUM(jc.price) AS changes_price, SUM(jc.cost) AS changes_cost, SUM(mu) as changes_mu FROM jobchanges jc, lu_job_change_statuses ljcs WHERE UCASE(ljcs.value) = 'APPROVED' AND ljcs.id = jc.statusid AND jc.jobid = " + jobId;

			String collectedQuery = "SELECT SUM(acd.payment_amount) AS collected_amount FROM ar_collection_details acd, ar_invoice_details aid, ar_invoices ai WHERE ai.id = aid.ar_invoiceid AND acd.ar_invoiceid = ai.id AND jobid = " + jobId;
			String discountQuery = "SELECT discount FROM jobs WHERE id = " + jobId;
			
			String billedQuery = "SELECT SUM(aid.ar_invoice_amount) AS billed_amount FROM ar_invoice_details aid, ar_invoices ai WHERE ai.id = aid.ar_invoiceid AND jobid = " + jobId;
			// Hard coded recipient type
			String vendorPayableQuery = "SELECT SUM(aid.amount) AS vendor_payable FROM ap_invoices ai, ap_invoice_details aid, jobs j WHERE aid.ap_invoiceid = ai.id AND ai.pay_to_company_id = j.vendor_company_id AND j.id = aid.jobid AND lu_ap_recipient_type_id = 3 AND aid.jobid = " + jobId;
			String siteHostPayableQuery = "SELECT SUM(aid.amount) AS site_host_payable FROM ap_invoices ai, ap_invoice_details aid, jobs j WHERE aid.ap_invoiceid = ai.id AND ai.pay_to_company_id = j.vendor_company_id AND j.id = aid.jobid AND lu_ap_recipient_type_id = 2 AND aid.jobid = " + jobId;
			// Hard coded recipient type
			String aPVendorAllQuery = "SELECT SUM(api.ap_invoice_amount) FROM ap_invoices api, ap_invoice_details apid, jobs j, vendors v WHERE apid.ap_invoiceid = api.id AND v.id = j.vendor_id and v.company_id = pay_to_company_id AND apid.jobid = j.id AND lu_ap_recipient_type_id = 3 AND j.id = " + jobId;
			String aPVendorPaidQuery = "SELECT sum(appd.amount) FROM ap_payments app, ap_payment_details appd, jobs j, ap_invoice_details apid, vendors v WHERE app.id = appd.ap_payment_id AND apid.ap_invoiceid = appd.ap_invoice_id AND v.id = j.vendor_id AND v.company_id = app.paid_company_id AND apid.jobid = j.id AND lu_ap_recipient_type_id = 3 AND j.id = " + jobId;
			// Hard coded recipient type
			String aPSiteHostAllQuery = "SELECT SUM(api.ap_invoice_amount) FROM ap_invoices api, ap_invoice_details apid, jobs j, site_hosts sh, projects p, orders o WHERE apid.ap_invoiceid = api.id AND o.id = p.order_id AND p.id = j.project_id AND o.site_host_id = sh.id AND sh.company_id = pay_to_company_id AND apid.jobid = j.id AND lu_ap_recipient_type_id = 2 AND j.id = " + jobId;
			String aPSiteHostPaidQuery = "SELECT sum(appd.amount) FROM ap_payments app, ap_payment_details appd, jobs j, ap_invoice_details apid, projects p, orders o, site_hosts sh WHERE app.id = appd.ap_payment_id AND apid.ap_invoiceid = appd.ap_invoice_id AND o.id = p.order_id AND p.id = j.project_id AND o.site_host_id = sh.id AND sh.company_id = app.paid_company_id AND apid.jobid = j.id AND lu_ap_recipient_type_id = 2 AND j.id = " + jobId;
			
	        String insertCosts = "update jobs set recalc_flag=0, cost = ?, fee = ?, mu = ?, price = ?, shipping_price = ?, sales_tax = ?, billable = ?, collected = ?, billed = ?, payable_to_vendor = ?, paid_to_vendor = ?, vendor_job_share = ?, balance_to_vendor = ?, payable_to_site_host = ?, paid_to_site_host = ?, site_host_job_share = ?, balance_to_site_host = ?,quantity_shipped=? where id = ?";	
			
			//sums up job spec totals
			double cost = 0;
			double fee = 0;
			double mu = 0;
			double price = 0;
									
			ResultSet rs1 = st.executeQuery(jobSpecsQuery);
			if(rs1.next()){
				cost = rs1.getDouble("cost");
				fee = rs1.getDouble("fee");
				mu = rs1.getDouble("mu");
				price = rs1.getDouble("price");
			}

			double discount = 0;
			ResultSet rsD = st.executeQuery(discountQuery);
			while (rsD.next()) {
				discount = rsD.getDouble("discount");
			}
			
			double shippingPrice = 0;
			double shippingCost = 0;
			double shippingMu = 0;
			double shippingQuantity = 0;
			ResultSet rs2 = st.executeQuery(shippingQuery);
			while (rs2.next()) {
				shippingPrice = rs2.getDouble("shipping_price");
				shippingCost = rs2.getDouble("shipping_cost");
				shippingMu = rs2.getDouble("shipping_mu");
				shippingQuantity = rs2.getDouble("shipping_quantity");
			}

			double taxRate = 0;
			int taxJob = 1;
			int taxShipping = 1;
			int buyerExempt = 0;
			ResultSet rs3 = st.executeQuery(taxQuery);
			while (rs3.next()) {
				taxRate = rs3.getDouble("rate");
				taxJob = rs3.getInt("tax_job");
				taxShipping = rs3.getInt("tax_shipping");
				buyerExempt = rs3.getInt("buyer_exempt");
			}
			
			double changesPrice = 0;
			double changesCost = 0;
			double changesMu = 0;
			ResultSet rs4 = st.executeQuery(changesQuery);
			while (rs4.next()) {
				changesPrice = rs4.getDouble("changes_price");
				changesCost = rs4.getDouble("changes_cost");
				changesMu = rs4.getDouble("changes_mu");
			}

			double collected = 0;
			ResultSet rs5 = st.executeQuery(collectedQuery);
			while (rs5.next()) {
				collected = rs5.getDouble("collected_amount");
			}

			double billed = 0;
			ResultSet billedRS = st.executeQuery(billedQuery);
			while (billedRS.next()) {
				billed = billedRS.getDouble("billed_amount");
			}

			double payableToVendor = 0;
			ResultSet rs6 = st.executeQuery(vendorPayableQuery);
			while (rs6.next()) {
				payableToVendor = rs6.getDouble("vendor_payable");
			}

			double payableToSiteHost = 0;
			ResultSet rs7 = st.executeQuery(siteHostPayableQuery);
			while (rs7.next()) {
				payableToSiteHost = rs7.getDouble("site_host_payable");
			}

			double subTotal = price + changesPrice-discount;

			//calculate sales tax
			double salesTax = 0;
			if (buyerExempt == 1) {
				salesTax = 0;
			} else {
			    double tempShipping = shippingPrice;
			    double tempTotal = subTotal;
			    if (taxShipping == 1) {
			        tempShipping = tempShipping * (taxRate/100);
			    } else {
					tempShipping = 0;
				}
			    if (taxJob == 1) {
			        tempTotal = tempTotal * (taxRate/100);
			    } else {
					tempTotal = 0;
				}
				salesTax = tempShipping + tempTotal;
			}

			double billable = subTotal + salesTax + shippingPrice;
	  		
			
			//accounting section for vendor and site host
			double aPVendorAll = 0;
			ResultSet rsAccounting = st.executeQuery(aPVendorAllQuery);
			if(rsAccounting.next()) {
				aPVendorAll = rsAccounting.getDouble(1);
			}
			
			double aPVendorPaid = 0;
			rsAccounting = st.executeQuery(aPVendorPaidQuery);
			if(rsAccounting.next()) {
				aPVendorPaid = rsAccounting.getDouble(1);
			}
			
			double aPSiteHostAll = 0;
			rsAccounting = st.executeQuery(aPSiteHostAllQuery);
			if(rsAccounting.next()) {
				aPSiteHostAll = rsAccounting.getDouble(1);
			}
			
			double aPSiteHostPaid = 0;
			rsAccounting = st.executeQuery(aPSiteHostPaidQuery);
			if(rsAccounting.next()) {
				aPSiteHostPaid = rsAccounting.getDouble(1);
			}

			double vendorJobShare = cost + changesCost + shippingCost + salesTax;
			double siteHostJobShare = mu + changesMu + shippingMu;
			
			//update jobs table with new numbers
			int i = 1;
	
			PreparedStatement updateJobs = conn.prepareStatement(insertCosts);
			updateJobs.setDouble(i++, cost);
			updateJobs.setDouble(i++, fee);
			updateJobs.setDouble(i++, mu);
			updateJobs.setDouble(i++, subTotal);
			updateJobs.setDouble(i++, shippingPrice);
			updateJobs.setDouble(i++, salesTax);
			updateJobs.setDouble(i++, billable);
			updateJobs.setDouble(i++, collected);
			updateJobs.setDouble(i++, billed);
			updateJobs.setDouble(i++, payableToVendor);
			updateJobs.setDouble(i++, aPVendorPaid);
			updateJobs.setDouble(i++, vendorJobShare);
			updateJobs.setDouble(i++, (aPVendorAll-aPVendorPaid));
			updateJobs.setDouble(i++, payableToSiteHost);
			updateJobs.setDouble(i++, aPSiteHostPaid);
			updateJobs.setDouble(i++, siteHostJobShare);
			updateJobs.setDouble(i++, (aPSiteHostAll-aPSiteHostPaid));
			updateJobs.setDouble(i++, shippingQuantity);
			updateJobs.setInt(i++, Integer.parseInt(jobId));
			updateJobs.executeUpdate();
			updateJobs.close();
			//st.execute(insertCosts);


	
		try{
			ResultSet rsAS=st.executeQuery("select if(sum(sh.cost+sh.subvendor_handling)is null, 0 , sum(sh.cost+sh.subvendor_handling)) cost from shipping_data sh where sh.job_id="+jobId+" and sh.shipping_vendor_id<>105 union select if(sum(sh.cost+sh.subvendor_handling)is null, 0 , sum(sh.cost)) cost from shipping_data sh where sh.job_id="+jobId+" and sh.shipping_vendor_id=105");
			double accruedShipping=0;
			while(rsAS.next()){
				accruedShipping+=rsAS.getDouble("cost");
			}
			String updateShipSql="update jobs j set j.accrued_shipping=? where j.id=?";
			PreparedStatement updateShip = conn.prepareStatement(updateShipSql);
			i=1;
			updateShip.setDouble(i++, accruedShipping);
			updateShip.setInt(i++, Integer.parseInt(jobId));
			updateShip.executeUpdate();
			updateShip.close();
		} catch (Exception ex) {
			try { conn.close(); } catch ( Exception x) { conn = null; }
			throw new Exception("CalculateJobCosts:updateAccruedShipping " + ex.getMessage());
		}


		

//The order of the following updates is important in calculating whether to apply post date...		

//update cancelled_date on the job if the job was cancelled
		try{
			String updateCancelledDate ="update jobs j set cancelled_date=Now() where cancelled_date is null and status_id=9 and j.id="+jobId;
			st.executeUpdate(updateCancelledDate);
		} catch (Exception ex) {
			try { conn.close(); } catch ( Exception x) { conn = null; }
			throw new Exception("CalculateJobCosts:updateCancelledDate " + ex.getMessage());
		}


//update post_date on the job if the job was cancelled
	//Also update the accrued dates on any po transaction and shipping records.
	//Note field post_date is date only, post_date_time includes time of posting for accruals
		
		try{
			if(!jobPosted){
				st.executeUpdate("update jobs j set post_date=cancelled_date,post_date_time=cancelled_date,accrued_po_cost=0,accrued_shipping=0,accrued_inventory_cost=0,est_material_cost=0 where post_date is null and status_id=9 and j.id="+jobId);			
				st.executeUpdate("update po_transactions p, jobs j set p.purchase_cost_adj_amt=0,p.adjustment_amount=0,p.accrued_date=j.post_date_time where j.id=p.job_id and (p.accrued_date is null or p.accrued_date='0000-00-00 00:00:00') and j.status_id=9 and j.id="+jobId);
				st.executeUpdate("update shipping_data s, jobs j set s.accrued_date=j.post_date_time where j.id=s.job_id and post_date is not null and j.id="+jobId);
				rsJ=st2.executeQuery("select if(order_date is null,'true','false') order_date,if(post_date is null,'false','true') post_date from jobs where id="+jobId);
				if(rsJ.next()){
					firstRun=((rsJ.getString("order_date").equals("true"))?true:false);
					jobPosted=((rsJ.getString("post_date").equals("false"))?false:true);
				}
			}
		} catch (Exception ex) {
			try { conn.close(); } catch ( Exception x) { conn = null; }
			throw new Exception("CalculateJobCosts:updatePostCancelledJobs " + ex.getMessage());
		}
		
//If the job was on hold awaiting payment (123) and the payment was made, move the job status to awaiting confirmation (2)
		
		try{
			st.executeUpdate("update jobs j set status_id=2,last_status_id=123 where status_id=123 and billed>0 and billed-collected<=0 and j.id="+jobId);			
		} catch (Exception ex) {
			try { conn.close(); } catch ( Exception x) { conn = null; }
			throw new Exception("CalculateJobCosts:MoveAwaitingPayment " + ex.getMessage());
		}

//update confirmed_date on the job if the job was confirmed
		try{
			String updateConfirmedDate ="update jobs j set confirmed_date=Now() where confirmed_date is null and status_id=112 and j.id="+jobId;
			st.executeUpdate(updateConfirmedDate);
		} catch (Exception ex) {
			try { conn.close(); } catch ( Exception x) { conn = null; }
			throw new Exception("CalculateJobCosts:updateConfirmedDate " + ex.getMessage());
		}

 
//update completed_date on the job if the job was completed
		try{
			String updateCompletedDate ="update jobs j set completed_date=Now() where completed_date is null and status_id=119 and j.id="+jobId;
			st.executeUpdate(updateCompletedDate);
		} catch (Exception ex) {
		throw new Exception("CalculateJobCosts:updateCompletedDate " + ex.getMessage());
		}



//update post_date on the job if conditions are met
	//Also update the accrued dates on any po transaction and shipping records.
	//Note field post_date is date only, post_date_time includes time of posting for accruals
	
		try{
			if(!(jobPosted)){
				st.executeUpdate("update jobs j set post_date=Now(),post_date_time=Now() where post_date is null and j.id="+jobId+" AND ((j.status_id=120) or (j.status_id=119 and j.billed>=j.billable))");
				st.executeUpdate("update po_transactions p, jobs j set p.accrued_date=j.post_date_time where j.id=p.job_id and post_date is not null and j.id="+jobId);
				st.executeUpdate("update shipping_data s, jobs j set s.accrued_date=j.post_date_time where j.id=s.job_id and post_date is not null and j.id="+jobId);
			}
		} catch (Exception ex) {
			throw new Exception("CalculateJobCosts:updatePostDate " + ex.getMessage());
		}

	} catch(Exception ex) {
		throw new Exception("Error calculating cost " + ex.getMessage());
	} finally {
		try { conn.close(); } catch ( Exception x) { conn = null; }
	}	
}
	
	public Hashtable execute(MultipartRequest mr, HttpServletResponse response) throws Exception {
	
		try {
			String jobId = mr.getParameter("jobId");
			this.calculate(jobId);
				
		} catch (Exception ex) {
			throw new Exception("CalculateJobCosts error " + ex.getMessage());
		}

		return new Hashtable();
	}
	public Hashtable execute(HttpServletRequest request, HttpServletResponse response) throws Exception {
			
		Connection conn = null;
		try {
			conn = DBConnect.getConnection();
			//must test for order
			if(request.getAttribute("orderId")!=null){
				String sql1 = "SELECT j.id FROM projects p, jobs j WHERE p.id = j.project_id AND p.order_id = " + (String)request.getAttribute("orderId");
				PreparedStatement getJobs = conn.prepareStatement(sql1);
				ResultSet rs1 = getJobs.executeQuery();
				while(rs1.next()){
					this.calculate(rs1.getString("id"));
				}
				
			}else{	
				String jobId = request.getParameter("jobId");
				this.calculate(jobId);
			}	
				
		} catch (Exception ex) {
			throw new Exception("CalculateJobCosts error " + ex.getMessage());
		} finally {
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}

		return new Hashtable();
	}
}
