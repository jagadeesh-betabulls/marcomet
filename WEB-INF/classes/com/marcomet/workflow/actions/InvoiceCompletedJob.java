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

public class InvoiceCompletedJob implements ActionInterface {

	//basic connections
	//private SimpleConnection sc;
	//private Connection conn;
	
	public InvoiceCompletedJob() {
		//sc = new SimpleConnection();
		//conn = sc.getConnection();
	}

	
	public Hashtable execute(MultipartRequest mr, HttpServletResponse response) throws Exception {
		
		Connection conn = null;
		try {
			conn = DBConnect.getConnection();
			Statement st = conn.createStatement();
			String jobId=((mr.getParameter("jobId")==null)?"0":mr.getParameter("jobId"));
			//If the job is complete and hasn't yet been billed check to see if ship_price_policy is shipping included or if shipping_amount > 0
			//If so, create a bill for this job and rerun the calculations.
			ResultSet rsStatus=st.executeQuery("Select distinct if(pp.id is not null and j.status_id='119' and (j.billable-j.billed>.1) and (j.ship_price_policy=1 or j.ship_price_policy=2),'true','false') as invoiceJob from jobs j left join products p on j.product_id=p.id left join product_prices pp on pp.prod_price_code=p.prod_price_code and j.quantity=pp.quantity where j.id="+jobId);
			boolean invoiceNow=false;
			if(rsStatus.next()){
				invoiceNow=((rsStatus.getString("invoiceJob")!=null && rsStatus.getString("invoiceJob").equals("true"))?true:false);
			}
			if(invoiceNow){
				com.marcomet.workflow.actions.InvoiceServlet InvS = new com.marcomet.workflow.actions.InvoiceServlet();
				Hashtable hs = new Hashtable();
				hs=InvS.execute(Integer.parseInt(jobId),0);
				JobFlowActionEmailer jfae=new JobFlowActionEmailer();
				hs=jfae.execute("78", jobId, "com.marcomet.workflow.actions.JobFlowActionEmailer");
			}
				
		} catch (Exception ex) {
			throw new Exception("InvoiceCompletedJob error " + ex.getMessage());
		} finally {
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}

		return new Hashtable();
	}
	
	public Hashtable execute(HttpServletRequest request, HttpServletResponse response) throws Exception {
		
		Connection conn = null;
		try {
			conn = DBConnect.getConnection();
			Statement st = conn.createStatement();
			String jobId=((request.getParameter("jobId")==null)?"0":request.getParameter("jobId"));
			//If the job is complete and hasn't yet been billed check to see if ship_price_policy is shipping included or if shipping_amount > 0
			//If so, create a bill for this job and rerun the calculations.
			ResultSet rsStatus=st.executeQuery("Select distinct if(pp.id is not null and j.status_id='119' and (j.billable-j.billed>.1) and (j.ship_price_policy=1 or j.ship_price_policy=2),'true','false') as invoiceJob from jobs j left join products p on j.product_id=p.id left join product_prices pp on pp.prod_price_code=p.prod_price_code and j.quantity=pp.quantity where j.id="+jobId);
			boolean invoiceNow=false;
			if(rsStatus.next()){
				invoiceNow=((rsStatus.getString("invoiceJob")!=null && rsStatus.getString("invoiceJob").equals("true"))?true:false);
			}
			if(invoiceNow){
				com.marcomet.workflow.actions.InvoiceServlet InvS = new com.marcomet.workflow.actions.InvoiceServlet();
				Hashtable hs = new Hashtable();
				hs=InvS.execute(Integer.parseInt(jobId),0);
				JobFlowActionEmailer jfae=new JobFlowActionEmailer();
				hs=jfae.execute("78", jobId, "com.marcomet.workflow.actions.JobFlowActionEmailer");
			}
				
		} catch (Exception ex) {
			throw new Exception("InvoiceCompletedJob error " + ex.getMessage());
		} finally {
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}

		return new Hashtable();
	}
}
