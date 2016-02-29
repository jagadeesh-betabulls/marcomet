/**********************************************************************
Description:	Base Email Class, now will only include information for substitutions

**********************************************************************/

package com.marcomet.mail;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

import com.marcomet.jdbc.DBConnect;
import com.marcomet.tools.FormaterTool;
import com.marcomet.tools.MessageLogger;
import com.marcomet.tools.StringTool;


abstract public class EmailBodyBaseClass {
	
	//basic connections	
	private Connection conn;
	
	//globals abstract functions
	abstract protected String getOrderId();
	abstract protected String getJobId();
	abstract protected String getDomainName();
	abstract protected String getCustomerContactId();
	abstract protected String getVendorContactId();
	abstract protected String getSiteHostCompanyId();
	abstract protected String getSubject();               //for the subject line		
	
			
	protected EmailBodyBaseClass() {
	}
	
	protected String getBaseBody(String key) throws SQLException{
		
		if (conn == null) {	
			try {
			conn = DBConnect.getConnection();
			} catch ( Exception x ) {
				throw new SQLException("Could not connect to DB: " + x.getMessage());
			}
		}
			
		StringTool st = new StringTool();
		String body = "";
		String sql = "select email_body from email_form_letters where email_key = '" + key +"'";
		Statement qs = conn.createStatement();
		ResultSet rs1 = qs.executeQuery(sql);
			
		if (rs1.next())	 {
			body = rs1.getString(1);
		}else {	
			throw new SQLException("No email body in database found, key: " + key);
		}	
		
		try{		
			
			//duh			
			body = (body.indexOf("#today date#")==-1)?body:st.replaceSubstring(body,"#today date#",getTodayDate());
			
			//functions that use jobId
			body = (body.indexOf("#job number#")==-1)?body:st.replaceSubstring(body,"#job number#", getJobId());
			body = (body.indexOf("#service type#")==-1)?body:st.replaceSubstring(body,"#service type#",getServiceType());
			body = (body.indexOf("#job type#")==-1)?body:st.replaceSubstring(body,"#job type#",getJobType());
			body = (body.indexOf("#job link#")==-1)?body:st.replaceSubstring(body,"#job link#",getJobLink());
			body = (body.indexOf("#jobname#")==-1)?body:st.replaceSubstring(body,"#jobname#",getJobName());
			body = (body.indexOf("#style sheet link#")==-1)?body:st.replaceSubstring(body,"#style sheet link#",getStyleSheetLink());
			body = (body.indexOf("#buyer loginname#")==-1)?body:st.replaceSubstring(body,"#buyer loginname#",getBuyerLoginName());
			body = (body.indexOf("#buyer email#")==-1)?body:st.replaceSubstring(body,"#buyer email#",getBuyerEmail());
			body = (body.indexOf("#message newest interim comp/proof#")==-1)?body:st.replaceSubstring(body,"#message newest interim comp/proof#",getMessageNewestCompProof("1"));		
			body = (body.indexOf("#message newest final comp/proof#")==-1)?body:st.replaceSubstring(body,"#message newest final comp/proof#",getMessageNewestCompProof("2"));		
			body = (body.indexOf("#message newest review comp/proof#")==-1)?body:st.replaceSubstring(body,"#message newest review comp/proof#",getMessageNewestCompProof("8"));
		
			//functions that use contactId for customer
			body = (body.indexOf("#customer fullname#")==-1)?body:st.replaceSubstring(body,"#customer fullname#",getFullname(getCustomerContactId()));					
			body = (body.indexOf("#customer firstname#")==-1)?body:st.replaceSubstring(body,"#customer firstname#",getFirstName(getCustomerContactId()));
			body = (body.indexOf("#customer loginname#")==-1)?body:st.replaceSubstring(body,"#customer loginname#",getLoginName(getCustomerContactId()));
			body = (body.indexOf("#customer company name#")==-1)?body:st.replaceSubstring(body,"#customer company name#",getCompanyName(getCustomerContactId()));
			body = (body.indexOf("#customer password#")==-1)?body:st.replaceSubstring(body,"#customer password#",getPassword(getCustomerContactId()));		
			body = (body.indexOf("#customer registration date#")==-1)?body:st.replaceSubstring(body,"#customer registration date#",getRegistrationDate(getCustomerContactId()));
			body = (body.indexOf("#customer email#")==-1)?body:st.replaceSubstring(body,"#customer email#",getEmail(getCustomerContactId()));		
			body = (body.indexOf("#customer address1mail#")==-1)?body:st.replaceSubstring(body,"#customer address1mail#",getAddress1Mail(getCustomerContactId()));
			body = (body.indexOf("#customer address2mail#")==-1)?body:st.replaceSubstring(body,"#customer address2mail#",getAddress2Mail(getCustomerContactId()));						
			body = (body.indexOf("#customer address1bill#")==-1)?body:st.replaceSubstring(body,"#customer address1bill#",getAddress1Bill(getCustomerContactId()));
			body = (body.indexOf("#customer address2bill#")==-1)?body:st.replaceSubstring(body,"#customer address2bill#",getAddress2Bill(getCustomerContactId()));						
			body = (body.indexOf("#customer citystatezipcodemail#")==-1)?body:st.replaceSubstring(body,"#customer citystatezipcodemail#",getCityStateZipcodeMail(getCustomerContactId()));	
			body = (body.indexOf("#customer citystatezipcodebill#")==-1)?body:st.replaceSubstring(body,"#customer citystatezipcodebill#",getCityStateZipcodeBill(getCustomerContactId()));	
			body = (body.indexOf("#customer contactid#")==-1)?body:st.replaceSubstring(body,"#customer contactid#",getCustomerContactId());													
		

			//functions that use contactId for vendor
			body = (body.indexOf("#vendor fullname#")==-1)?body:st.replaceSubstring(body,"#vendor fullname#",getFullname(getVendorContactId()));					
			body = (body.indexOf("#vendor firstname#")==-1)?body:st.replaceSubstring(body,"#vendor firstname#",getFirstName(getVendorContactId()));
			body = (body.indexOf("#vendor loginname#")==-1)?body:st.replaceSubstring(body,"#vendor loginname#",getLoginName(getVendorContactId()));
			body = (body.indexOf("#vendor password#")==-1)?body:st.replaceSubstring(body,"#vendor password#",getPassword(getVendorContactId()));		
			body = (body.indexOf("#vendor company name#")==-1)?body:st.replaceSubstring(body,"#vendor company name#",getCompanyName(getVendorContactId()));		
			body = (body.indexOf("#vendor registration date#")==-1)?body:st.replaceSubstring(body,"#vendor registration date#",getRegistrationDate(getVendorContactId()));
			body = (body.indexOf("#vendor email#")==-1)?body:st.replaceSubstring(body,"#vendor email#",getEmail(getVendorContactId()));		
			body = (body.indexOf("#vendor address1mail#")==-1)?body:st.replaceSubstring(body,"#vendor address1mail#",getAddress1Mail(getVendorContactId()));
			body = (body.indexOf("#vendor address2mail#")==-1)?body:st.replaceSubstring(body,"#vendor address2mail#",getAddress2Mail(getVendorContactId()));						
			body = (body.indexOf("#vendor address1bill#")==-1)?body:st.replaceSubstring(body,"#vendor address1bill#",getAddress1Bill(getVendorContactId()));
			body = (body.indexOf("#vendor address2bill#")==-1)?body:st.replaceSubstring(body,"#vendor address2bill#",getAddress2Bill(getVendorContactId()));						
			body = (body.indexOf("#vendor citystatezipcodemail#")==-1)?body:st.replaceSubstring(body,"#vendor citystatezipcodemail#",getCityStateZipcodeMail(getVendorContactId()));	
			body = (body.indexOf("#vendor citystatezipcodebill#")==-1)?body:st.replaceSubstring(body,"#vendor citystatezipcodebill#",getCityStateZipcodeBill(getVendorContactId()));
		
	
			//uses orderId
			body = (body.indexOf("#order payment#")==-1)?body:st.replaceSubstring(body,"#order payment#",getOrderPaymentType());
			body = (body.indexOf("#order amount#")==-1)?body:st.replaceSubstring(body,"#order amount#",getOrderAmount());				
			body = (body.indexOf("#order number#")==-1)?body:st.replaceSubstring(body,"#order number#",getOrderId());
			body = (body.indexOf("#order date#")==-1)?body:st.replaceSubstring(body,"#order date#",getOrderDate());
			body = (body.indexOf("#jobtable customer#")==-1)?body:st.replaceSubstring(body,"#jobtable customer#",getOrderJobTableCustomer());
			body = (body.indexOf("#jobstable vendor#")==-1)?body:st.replaceSubstring(body,"#jobstable vendor#",getOrderJobTableVendor(getVendorContactId(), getOrderId()));
		
			//site host section
			body = (body.indexOf("#sitehost email#")==-1)?body:st.replaceSubstring(body,"#sitehost email#",getContactEmailViaCompanyId(getSiteHostCompanyId()));
			body = (body.indexOf("#sitehost company name#")==-1)?body:st.replaceSubstring(body,"#sitehost company name#",getCompanyNameViaCompanyId(getSiteHostCompanyId())); 
			body = (body.indexOf("#sitehost domain name#")==-1)?body:st.replaceSubstring(body,"#sitehost domain name#",getDomainName() ); 			
		
		}catch(Exception e){
			try{
				MessageLogger.logMessage(e.getMessage());
			}catch(Exception e2){
				throw new SQLException("emailbaseclass logger failed");
			}	
		
		}	
	
		try {
			conn.close();
		}catch(Exception e) {
		}finally  {
			conn = null;
			
		}
		
		//now return finshed product
		return body;	
	}
			
	//****** substitution functions	*******
	protected String getJobLink() {
		
		return "http://" + getDomainName() + "/index.jsp?contents=/minders/JobMinderSwitcher.jsp";
	}	
	
	protected String getStyleSheetLink() {
		
		String siteHostRoot = "";
		
		java.util.StringTokenizer st = new java.util.StringTokenizer(getDomainName(), ".");
		if (st.hasMoreElements()) {
			siteHostRoot = st.nextToken();
		}		
		
		return "<link rel=\"stylesheet\" href=\"http://" + getDomainName() + "/sitehosts/" + siteHostRoot + "/styles/vendor_styles.css\" type=\"text/css\">";
	}	
	
	
	protected String getOrderDate() throws SQLException {
		if (conn == null) {			
			try {
				conn = DBConnect.getConnection();
				} catch ( Exception x ) {
					throw new SQLException("Could not connect to DB: " + x.getMessage());
				}
		}
		
		String sql = "SELECT DATE_FORMAT(o.date_created,'%m/%d/%y') FROM orders o WHERE o.id = " + getOrderId() + "";
		Statement qs = conn.createStatement();
		
		ResultSet rs1;
		try{
				rs1 = qs.executeQuery(sql);
		}catch(SQLException sqle){
			throw new SQLException("sql: " + sql + ",selqe: " + sqle);
		}
		
		if (rs1.next())	 {
			return rs1.getString(1);
		}else {	
			throw new SQLException("No order date in database found, jobId: " + getJobId());
		}
	}
	
	protected String getOrderPaymentType() throws SQLException {
		if (conn == null) {			
			try {
				conn = DBConnect.getConnection();
				} catch ( Exception x ) {
					throw new SQLException("Could not connect to DB: " + x.getMessage());
				}
		}
		
		String sql = "SELECT lucc.value FROM projects p, jobs j, ar_invoices ari, ar_invoice_details arid, ar_collections arc, ar_collection_details arcd, lu_credit_cards lucc WHERE arc.id = arcd.ar_collectionid AND arcd.ar_invoiceid = ari.id AND ari.id = arid.ar_invoiceid AND p.id = j.project_id AND arc.check_number = lucc.id AND ari.ar_invoice_type = 1  AND p.order_id = " + getOrderId() + "";
		Statement qs = conn.createStatement();
		
		ResultSet rs1;
		try{
				rs1 = qs.executeQuery(sql);
		}catch(SQLException sqle){
			throw new SQLException("sql: " + sql + ",selqe: " + sqle);
		}
		
		if (rs1.next())	 {
			return rs1.getString(1);
		}else {	
			throw new SQLException("No order payment type in database found orderId: " + getOrderId());
		}
	}	
	
	protected String getOrderAmount() throws SQLException{
		if (conn == null) {			
			try {
				conn = DBConnect.getConnection();
				} catch ( Exception x ) {
					throw new SQLException("Could not connect to DB: " + x.getMessage());
				}	
		}
		
		String sql = "select sum(id.deposited)from orders o, ar_invoices i, ar_invoice_details id, projects p, jobs j where i.id = id.ar_invoiceid and p.order_id = o.id and j.project_id = p.id and i.ar_invoice_type = 1 and j.id = id.jobid and o.id = " + getOrderId() + "";
		Statement qs = conn.createStatement();
		
		ResultSet rs1;
		try{
				rs1 = qs.executeQuery(sql);
		}catch(SQLException sqle){
			throw new SQLException("sql: " + sql + ",selqe: " + sqle);
		}
		
		if (rs1.next())	 {
			return "$" + rs1.getString(1);
		}else {	
			throw new SQLException("No order amount in database found, jobId: " + getJobId());
		}
	}

	protected String getOrderJobTableCustomer() throws SQLException {
		if (conn == null) {			
			try {
				conn = DBConnect.getConnection();
			} catch ( Exception x ) {
				throw new SQLException("Could not connect to DB: " + x.getMessage());
			}	
		}
		
		String sql = "SELECT prd.prod_name, ppc.unit, prd.prod_code, p.id 'pnumber', j.id 'jobnumber', j.quantity, j.product_id, lujt.value 'jjobtype', lust.value 'jservicetype', j.price 'jjobprice', j.escrow_amount 'jdeposited' FROM orders o, projects p, lu_job_types lujt, lu_service_types lust, jobs j LEFT JOIN products prd on prd.id=j.product_id LEFT JOIN product_price_codes ppc on ppc.prod_price_code=prd.prod_price_code WHERE lust.id = j.service_type_id and lujt.id = j.job_type_id and j.project_id = p.id and p.order_id = o.id and o.id = " + getOrderId() + "";
		Statement qs = conn.createStatement();
		
		ResultSet rs1;
		try{
				rs1 = qs.executeQuery(sql);
		}catch(SQLException sqle){
			throw new SQLException("sql: " + sql + ",selqe: " + sqle);
		}
		
		double totalPrice = 0;
		double totalDeposited = 0;
		FormaterTool ft = new FormaterTool();
		StringBuffer sb = new StringBuffer("<table border=2 bordercolor=\"black\"><tr bgcolor=\"#bebebe\"><td>Project ID</td><td>Job #</td><td>Job Description</td><td>Job Price</td><td>Deposit</td></tr>");
		
		while(rs1.next()){
			sb.append("<tr><td>");
			sb.append(rs1.getString("pnumber"));
			sb.append("</td><td>");
			sb.append(rs1.getString("jobnumber"));
			sb.append("</td><td>");
			if (rs1.getString("j.product_id")!=null && !rs1.getString("j.product_id").equals("")){
				sb.append(rs1.getString("prd.prod_code")+": ");
				sb.append(rs1.getString("prd.prod_name"));
				if (!(rs1.getString("j.quantity")==null) && !rs1.getString("j.quantity").equals("")){
					sb.append(" (");
					sb.append(rs1.getString("j.quantity")+" ");
					sb.append(((rs1.getString("ppc.unit")!=null && !rs1.getString("ppc.unit").equals(""))?rs1.getString("ppc.unit"):""));
					sb.append(" ) ");
				}
			}else{
				sb.append(rs1.getString("jjobtype"));
				sb.append(" / ");
				sb.append(rs1.getString("jservicetype"));
			}
			sb.append("</td><td align='right'>");
			sb.append(ft.getCurrency(rs1.getDouble("jjobprice")));
			sb.append("</td><td align='right'>");
			sb.append(ft.getCurrency(rs1.getDouble("jdeposited")));
			sb.append("</td></tr>");
			
			totalPrice += rs1.getDouble("jjobprice");
			totalDeposited += rs1.getDouble("jdeposited");
				
		}
		sb.append("<tr><td colspan=3 align=right>Job Totals</td><td>");
		sb.append(ft.getCurrency(totalPrice));
		sb.append("</td><td>");
		sb.append(ft.getCurrency(totalDeposited));
		sb.append("</td><tr></table>");		
		
		return sb.toString();
	}
	
	private String getOrderJobTableVendor(String vendorContactId, String orderId) throws SQLException{
		if (conn == null) {			
			try {
				conn = DBConnect.getConnection();
			} catch ( Exception x ) {
				throw new SQLException("Could not connect to DB: " + x.getMessage());
			}		
		}
		
		String sql = "SELECT p.id 'pnumber', prd.prod_code, prd.prod_name, ppc.unit,j.product_id,j.quantity, j.id 'jobnumber', lujt.value 'jjobtype', lust.value 'jservicetype', j.price 'jjobprice', j.escrow_amount 'jdeposited' FROM orders o, projects p, lu_job_types lujt, lu_service_types lust, jobs j   LEFT JOIN products prd on j.product_id=prd.id LEFT JOIN product_price_codes ppc on ppc.prod_price_code=prd.prod_price_code  WHERE lust.id = j.service_type_id AND lujt.id = j.job_type_id AND j.project_id = p.id AND p.order_id = o.id AND o.id =" + getOrderId() + " AND j.vendor_contact_id = " + vendorContactId;
		Statement qs = conn.createStatement();
		
		ResultSet rs1;
		try{
				rs1 = qs.executeQuery(sql);
		}catch(SQLException sqle){
			throw new SQLException("sql: " + sql + ",selqe: " + sqle);
		}
		
		double totalPrice = 0;
		double totalDeposited = 0;
		FormaterTool ft = new FormaterTool();
		StringBuffer sb = new StringBuffer("<table border=2 bordercolor=\"black\"><tr bgcolor=\"#bebebe\"><td>Project ID</td><td>Job #</td><td>Job Description</td><td>Job Price</td><td>Deposit</td></tr>");
		
		while(rs1.next()){
			sb.append("<tr><td>");
			sb.append(rs1.getString("pnumber"));
			sb.append("</td><td>");
			sb.append(rs1.getString("jobnumber"));
			sb.append("</td><td>");
			if (rs1.getString("j.product_id")!=null && !rs1.getString("j.product_id").equals("")){
				sb.append(rs1.getString("prd.prod_code")+": ");
				sb.append(rs1.getString("prd.prod_name"));
				if (!rs1.getString("j.quantity").equals("")){
				sb.append(" (");
				sb.append(rs1.getString("j.quantity")+" ");
				sb.append(((rs1.getString("ppc.unit")!=null && !rs1.getString("ppc.unit").equals(""))?rs1.getString("ppc.unit"):""));
				sb.append(" ) ");
				}
			}else{
				sb.append(rs1.getString("jjobtype"));
				sb.append(" / ");
				sb.append(rs1.getString("jservicetype"));
			}
			sb.append("</td><td align='right'>");
			sb.append(ft.getCurrency(rs1.getDouble("jjobprice")));
			sb.append("</td><td align='right'>");
			sb.append(ft.getCurrency(rs1.getDouble("jdeposited")));
			sb.append("</td></tr>");
			
			totalPrice += rs1.getDouble("jjobprice");
			totalDeposited += rs1.getDouble("jdeposited");
				
		}
		sb.append("<tr><td colspan=3 align=right>Job Totals</td><td>");
		sb.append(ft.getCurrency(totalPrice));
		sb.append("</td><td>");
		sb.append(ft.getCurrency(totalDeposited));
		sb.append("</td><tr></table>");		
		
		return sb.toString();
	}
			  

	protected String getBuyerEmail() throws SQLException {
		if (conn == null) {			
			try {
				conn = DBConnect.getConnection();
			} catch ( Exception x ) {
				throw new SQLException("Could not connect to DB: " + x.getMessage());
			}
		}
		
		String sql = "SELECT c.email FROM orders o, projects p, jobs j, contacts c WHERE j.project_id = p.id AND p.order_id = o.id AND c.id = o.buyer_contact_id AND j.id = " + getJobId() + "";
		Statement qs = conn.createStatement();
		
		ResultSet rs1;
		try{
				rs1 = qs.executeQuery(sql);
		}catch(SQLException sqle){
			throw new SQLException("sql: " + sql + ",selqe: " + sqle);
		}
		
		if (rs1.next())	 {
			return rs1.getString(1);
		}else {	
			throw new SQLException("No buyer first email in database found, jobId: " + getJobId());
		}	
	}
	
	protected String getBuyerLoginName() throws SQLException {
		if (conn == null) {			
			try {
				conn = DBConnect.getConnection();
			} catch ( Exception x ) {
				throw new SQLException("Could not connect to DB: " + x.getMessage());
			}	
		}
			
		String sql = "SELECT l.user_name FROM orders o, projects p, jobs j, logins l WHERE j.project_id = p.id AND p.order_id = o.id AND o.buyer_contact_id = l.contact_id AND j.id = " + getJobId() + "";
		Statement qs = conn.createStatement();
		
		ResultSet rs1;
		try{
				rs1 = qs.executeQuery(sql);
		}catch(SQLException sqle){
			throw new SQLException("sql: " + sql + ",selqe: " + sqle);
		}
		
		if (rs1.next())	 {
			return rs1.getString(1);
		}else {	
			throw new SQLException("No user login name in database found, jobId: " + getJobId());
		}	
	}		

	protected String getLUTableValue(String id, String LUTable) throws SQLException {
		if (conn == null) {			
			try {
				conn = DBConnect.getConnection();
			} catch ( Exception x ) {
				throw new SQLException("Could not connect to DB: " + x.getMessage());
			}	
		}
		
		String sql = "select value from " + LUTable + " where id = " + id + "";
		Statement qs = conn.createStatement();
		
		ResultSet rs1;
		try{
				rs1 = qs.executeQuery(sql);
		}catch(SQLException sqle){
			throw new SQLException("sql: " + sql + ",selqe: " + sqle);
		}
		
		if (rs1.next()){
			return rs1.getString(1);
		}else {	
			return "";
		}	
	}

	
//*********************** Changed over to look at the LU-tables *********************	
	protected String getServiceType() throws SQLException {
		if (conn == null) {			
			try {
				conn = DBConnect.getConnection();
			} catch ( Exception x ) {
				throw new SQLException("Could not connect to DB: " + x.getMessage());
			}	
		}
		
		String sql = "select service_type_id from jobs where id = " + getJobId() + "";
		Statement qs = conn.createStatement();
		
		ResultSet rs1;
		try{
				rs1 = qs.executeQuery(sql);
		}catch(SQLException sqle){
			throw new SQLException("sql: " + sql + ",selqe: " + sqle);
		}
		
		if (rs1.next()){
			return getLUTableValue(rs1.getString(1), "lu_service_types");
		}else {	
			throw new SQLException("No service type name in database found, jobId: " + getJobId());
		}	
	}

	protected String getJobName() throws SQLException, Exception {
		String jobname="";
		if (conn == null) {			
			try {
				conn = DBConnect.getConnection();
			} catch ( Exception x ) {
				throw new SQLException("Could not connect to DB: " + x.getMessage());
			}	
		}
		String sql = "select prod_name, j.quantity, pp.unit as jobname, prod_code from jobs j,products p, product_price_codes pp  where j.product_id=p.id and p.prod_price_code=pp.prod_price_code and j.id=" + getJobId();
		Statement qs = conn.createStatement();
		ResultSet rs1;
		try{
			rs1 = qs.executeQuery(sql);
		}catch(SQLException sqle){
			throw new SQLException("sql: " + sql + ",selqe: " + sqle);
		}
		
		if (rs1.next()){
			jobname=rs1.getString(4)+": "+rs1.getString(1)+((!rs1.getString(2).equals(""))?"(" + rs1.getString(2)+" "+rs1.getString(3)+")":"");
		}else {	
			jobname = getJobType()+ ", " +getServiceType();
		}
		return jobname;
	}	
	
	protected String getJobType() throws SQLException {
		try {
			conn = DBConnect.getConnection();
		} catch ( Exception x ) {
			throw new SQLException("Could not connect to DB: " + x.getMessage());
		}
		
		String sql = "select job_type_id from jobs where id = " + getJobId() + "";
		Statement qs = conn.createStatement();
		
		ResultSet rs1;
		try{
				rs1 = qs.executeQuery(sql);
		}catch(SQLException sqle){
			throw new SQLException("sql: " + sql + ",selqe: " + sqle);
		}
		
		if (rs1.next())	 {
			return getLUTableValue(rs1.getString(1), "lu_job_types");
		}else {	
			throw new SQLException("No job type name in database found, jobId: " + getJobId());
		}	
	}	
//**************************************************************************	
		  
	protected String getTodayDate(){
		return new java.util.Date().toString();
	} 	

	protected String getMessageNewestCompProof(String type) throws SQLException {
		try {
			conn = DBConnect.getConnection();
		} catch ( Exception x ) {
			throw new SQLException("Could not connect to DB: " + x.getMessage());
		}
		
		String sql = "select message from form_messages where form_id = "+ type +" and job_id = "+ getJobId() + " order by time_stamp desc";
		Statement qs = conn.createStatement();
		
		ResultSet rs1;
		try{
				rs1 = qs.executeQuery(sql);
		}catch(SQLException sqle){
			throw new SQLException("sql: " + sql + ",selqe: " + sqle);
		}
		
		if (rs1.next())	 {
			return rs1.getString(1);
		}else {	
			return "";  	//not all jobs have messages so just sub the tags with "" if there isn't one.
		}	
	}	
	
	//########### new user section ###########	
	protected String getFullname(String contactId) throws SQLException {
		try {
			conn = DBConnect.getConnection();
		} catch ( Exception x ) {
			throw new SQLException("Could not connect to DB: " + x.getMessage());
		}
		
		String sql = "select concat(firstname,' ',lastname) from contacts where id = " + contactId +"";
		Statement qs = conn.createStatement();

		ResultSet rs1;
		try{
				rs1 = qs.executeQuery(sql);
		}catch(SQLException sqle){
			throw new SQLException("sql: " + sql + ",selqe: " + sqle);
		}	
			
		if (rs1.next())	 {
			return rs1.getString(1);
		}else {	
			return ""; 
		}	
	}
	
	protected String getFirstName(String contactId) throws SQLException {
		if (conn == null) {			
			try {
				conn = DBConnect.getConnection();
			} catch ( Exception x ) {
				throw new SQLException("Could not connect to DB: " + x.getMessage());
			}	
		}
		
		String sql = "select firstname from contacts where id = " + contactId +"";
		Statement qs = conn.createStatement();

		ResultSet rs1;
		try{
				rs1 = qs.executeQuery(sql);
		}catch(SQLException sqle){
			throw new SQLException("sql: " + sql + ",selqe: " + sqle);
		}
		
		if (rs1.next())	 {
			return rs1.getString(1);
		}else {	
			return ""; 
		}	
	}

	protected String getEmail(String contactId) throws SQLException {
		if (conn == null) {			
			try {
				conn = DBConnect.getConnection();
			} catch ( Exception x ) {
				throw new SQLException("Could not connect to DB: " + x.getMessage());
			}		
		}
		
		String sql = "select email from contacts where id = " + contactId +"";
		Statement qs = conn.createStatement();
		
		ResultSet rs1;
		try{
				rs1 = qs.executeQuery(sql);
		}catch(SQLException sqle){
			throw new SQLException("sql: " + sql + ",selqe: " + sqle);
		}
		
		
		if (rs1.next())	 {
			return rs1.getString(1);
		}else {	
			return ""; 
		}	
	}
	
	protected String getRegistrationDate(String contactId) throws SQLException {
		if (conn == null) {			
			try {
				conn = DBConnect.getConnection();
			} catch ( Exception x ) {
				throw new SQLException("Could not connect to DB: " + x.getMessage());
			}	
		}
		
		String sql = "select DATE_FORMAT(date_created,'%m/%d/%y') from contacts where id = " + contactId +"";
		Statement qs = conn.createStatement();

		ResultSet rs1;
		try{
				rs1 = qs.executeQuery(sql);
		}catch(SQLException sqle){
			throw new SQLException("sql: " + sql + ",selqe: " + sqle);
		}
		
		if (rs1.next())	 {
			return rs1.getString(1);
		}else {	
			return contactId + "<==not found"; 
		}	
	}
		
	protected String getLoginName(String contactId) throws SQLException {
		if (conn == null) {			
			try {
				conn = DBConnect.getConnection();
			} catch ( Exception x ) {
				throw new SQLException("Could not connect to DB: " + x.getMessage());
			}	
		}
			
		String sql = "SELECT user_name FROM logins WHERE contact_id = " + contactId +"";
		Statement qs = conn.createStatement();

		ResultSet rs1;
		try{
				rs1 = qs.executeQuery(sql);
		}catch(SQLException sqle){
			throw new SQLException("sql: " + sql + ",selqe: " + sqle);
		}
		
		if (rs1.next())	 {
			return rs1.getString(1);
		}else {	
			return ""; 
		}	
	}
	
	protected String getPassword(String contactId) throws SQLException {
		if (conn == null) {			
			try {
				conn = DBConnect.getConnection();
			} catch ( Exception x ) {
				throw new SQLException("Could not connect to DB: " + x.getMessage());
			}	
		}
		
		String sql = "SELECT user_password FROM logins WHERE contact_id = " + contactId +"";
		Statement qs = conn.createStatement();
		
		ResultSet rs1;
		try{
				rs1 = qs.executeQuery(sql);
		}catch(SQLException sqle){
			throw new SQLException("sql: " + sql + ",selqe: " + sqle);
		}
		
		if (rs1.next())	 {
			return rs1.getString(1);
		}else {	
			return ""; 
		}	
	}

	protected String getCompanyName(String contactId) throws SQLException {
		if (conn == null) {			
			try {
				conn = DBConnect.getConnection();
			} catch ( Exception x ) {
				throw new SQLException("Could not connect to DB: " + x.getMessage());
			}	
		}
		
		String sql = "SELECT com.company_name FROM contacts c, companies com WHERE c.companyid = com.id AND c.id = " + contactId +"";
		Statement qs = conn.createStatement();
		
		ResultSet rs1;
		try{
			rs1 = qs.executeQuery(sql);
		}catch(SQLException sqle){
			throw new SQLException("sql: " + sql + ",selqe: " + sqle);
		}
		
		if (rs1.next())	 {
			return rs1.getString(1);
		}else {	
			return ""; 
		}	
	}

	
	protected String getAddress1Mail(String contactId) throws SQLException {
		if (conn == null) {			
			try {
				conn = DBConnect.getConnection();
			} catch ( Exception x ) {
				throw new SQLException("Could not connect to DB: " + x.getMessage());
			}
		}
		
		String sql = "SELECT l.address1 FROM locations l, lu_location_types llt WHERE llt.value='Mailing' AND llt.id = l.locationtypeid AND contactid = " + contactId +"";
		Statement qs = conn.createStatement();

		ResultSet rs1;
		try{
				rs1 = qs.executeQuery(sql);
		}catch(SQLException sqle){
			throw new SQLException("sql: " + sql + ",selqe: " + sqle);
		}
		
		if (rs1.next())	 {
			return rs1.getString(1);
		}else {	
			return ""; 
		}	
	}		

	protected String getAddress2Mail(String contactId) throws SQLException {
		if (conn == null) {			
			try {
				conn = DBConnect.getConnection();
			} catch ( Exception x ) {
				throw new SQLException("Could not connect to DB: " + x.getMessage());
			}
		}
		
		String sql = "SELECT l.address2 FROM locations l, lu_location_types llt WHERE llt.value='Mailing' and llt.id = l.locationtypeid and contactid = " + contactId +"";
		Statement qs = conn.createStatement();

		ResultSet rs1;
		try{
				rs1 = qs.executeQuery(sql);
		}catch(SQLException sqle){
			throw new SQLException("sql: " + sql + ",selqe: " + sqle);
		}
		
		if (rs1.next())	 {
			return rs1.getString(1);
		}else {	
			return ""; 
		}	
	}	

	protected String getAddress1Bill(String contactId) throws SQLException {
		if (conn == null) {			
			try {
				conn = DBConnect.getConnection();
			} catch ( Exception x ) {
				throw new SQLException("Could not connect to DB: " + x.getMessage());
			}	
		}
		
		String sql = "SELECT l.address1 FROM locations l, lu_location_types llt WHERE llt.value='Billing' and llt.id = l.locationtypeid and contactid = " + contactId +"";
		Statement qs = conn.createStatement();

		ResultSet rs1;
		try{
				rs1 = qs.executeQuery(sql);
		}catch(SQLException sqle){
			throw new SQLException("sql: " + sql + ",selqe: " + sqle);
		}
		
		if (rs1.next())	 {
			return rs1.getString(1);
		}else {	
			return ""; 
		}	
	}		

	protected String getAddress2Bill(String contactId) throws SQLException {
		if (conn == null) {			
			try {
				conn = DBConnect.getConnection();
			} catch ( Exception x ) {
				throw new SQLException("Could not connect to DB: " + x.getMessage());
			}
		}
		
		String sql = "SELECT l.address2 FROM locations l, lu_location_types llt WHERE llt.value='Billing' and llt.id = l.locationtypeid and contactid = " + contactId +"";
		Statement qs = conn.createStatement();

		ResultSet rs1;
		try{
				rs1 = qs.executeQuery(sql);
		}catch(SQLException sqle){
			throw new SQLException("sql: " + sql + ",selqe: " + sqle);
		}
		
		if (rs1.next())	 {
			return rs1.getString(1);
		}else {	
			return ""; 
		}	
	}

	
	protected String getCityStateZipcodeMail(String contactId) throws SQLException {
		if (conn == null) {			
			try {
				conn = DBConnect.getConnection();
			} catch ( Exception x ) {
				throw new SQLException("Could not connect to DB: " + x.getMessage());
			}
		}
		
		String sql = "SELECT concat(l.city, ', ', s.value,' ', l.zip) FROM locations l, lu_abreviated_states s, lu_location_types llt where s.id = l.state and llt.id = l.locationtypeid and llt.value = 'Mailing' and contactid = " + contactId +"";
		Statement qs = conn.createStatement();

		ResultSet rs1;
		try{
				rs1 = qs.executeQuery(sql);
		}catch(SQLException sqle){
			throw new SQLException("sql: " + sql + ",selqe: " + sqle);
		}
		
		if (rs1.next())	 {
			return rs1.getString(1);
		}else {	
			return ""; 
		}	
	}	
		
	protected String getCityStateZipcodeBill(String contactId) throws SQLException {
		if (conn == null) {			
			try {
				conn = DBConnect.getConnection();
			} catch ( Exception x ) {
				throw new SQLException("Could not connect to DB: " + x.getMessage());
			}
		}
		
		String sql = "SELECT concat(l.city, ', ', s.value,' ', l.zip) FROM locations l, lu_abreviated_states s, lu_location_types llt where s.id = l.state and llt.id = l.locationtypeid and llt.value = 'Billing' and contactid = " + contactId +"";
		Statement qs = conn.createStatement();

		ResultSet rs1;
		try{
				rs1 = qs.executeQuery(sql);
		}catch(SQLException sqle){
			throw new SQLException("sql: " + sql + ",selqe: " + sqle);
		}
		
		if (rs1.next())	 {
			return rs1.getString(1);
		}else {	
			return ""; 
		}	
	}	
	
	protected String getContactEmailViaCompanyId(String companyId) throws SQLException {
		if (conn == null) {			
			try {
				conn = DBConnect.getConnection();
			} catch ( Exception x ) {
				throw new SQLException("Could not connect to DB: " + x.getMessage());
			}	
		}
		
		String sql = "SELECT email FROM contacts WHERE companyid = " + companyId +"";
		Statement qs = conn.createStatement();

		ResultSet rs1;
		try{
				rs1 = qs.executeQuery(sql);
		}catch(SQLException sqle){
			throw new SQLException("sql: " + sql + ",selqe: " + sqle);
		}
		
		if (rs1.next())	 {
			return rs1.getString(1);
		}else {	
			return ""; 
		}		
	}

	protected String getCompanyNameViaCompanyId(String companyId) throws SQLException {
		if (conn == null) {			
			try {
				conn = DBConnect.getConnection();
			} catch ( Exception x ) {
				throw new SQLException("Could not connect to DB: " + x.getMessage());
			}	
		}
		
		String sql = "SELECT company_name FROM companies WHERE id = " + companyId +"";
		Statement qs = conn.createStatement();

		ResultSet rs1;
		try{
				rs1 = qs.executeQuery(sql);
		}catch(SQLException sqle){
			throw new SQLException("sql: " + sql + ",selqe: " + sqle);
		}
		
		if (rs1.next())	 {
			return rs1.getString(1);
		}else {	
			return ""; 
		}		
	}

	
		
	//**** substitutions section end ************	
	
	
	//**** support section for information that the sub classes need to gain ********
	
	protected String loadOrderIdViaJobId(String jobId) throws SQLException {
		if (conn == null) {			
			try {
				conn = DBConnect.getConnection();
			} catch ( Exception x ) {
				throw new SQLException("Could not connect to DB: " + x.getMessage());
			}
		}
		
		String sql = "select o.id from jobs j, projects p, orders o where o.id = p.order_id and j.project_id = p.id and j.id = " + jobId + "";
		Statement qs = conn.createStatement();
		
		ResultSet rs1;
		try{
				rs1 = qs.executeQuery(sql);
		}catch(SQLException sqle){
			throw new SQLException("sql: " + sql + ",selqe: " + sqle);
		}
	
		if (rs1.next())	 {
			return rs1.getString(1);
		}else {	
			throw new SQLException("No order number in database found jobId: " + jobId);
		}	
	}
	
	protected String loadCustomerIdViaJobId(String jobId) throws SQLException {
		if (conn == null) {			
			try {
				conn = DBConnect.getConnection();
			} catch ( Exception x ) {
				throw new SQLException("Could not connect to DB: " + x.getMessage());
			}
		}
						
		String sql = "SELECT o.buyer_contact_id FROM orders o, projects p, jobs j WHERE o.id = p.order_id AND p.id = j.project_id AND j.id = " + jobId + "";
		Statement qs = conn.createStatement();
		
		ResultSet rs1;
		try{
				rs1 = qs.executeQuery(sql);
		}catch(SQLException sqle){
			throw new SQLException("sql: " + sql + ",selqe: " + sqle);
		}
		
		if (rs1.next())	 {
			return rs1.getString(1);
		}else {	
			throw new SQLException("No customer in database found jobId: " + jobId + ",sql: " + sql);
		}	
	}	

	protected String loadVendorContactIdViaJobId(String jobId) throws SQLException {
		if (conn == null) {			
			try {
				conn = DBConnect.getConnection();
			} catch ( Exception x ) {
				throw new SQLException("Could not connect to DB: " + x.getMessage());
			}
		}
		
		String sql = "SELECT c.id FROM jobs j, vendors v, contacts c WHERE c.companyid = v.company_id AND v.id = j.vendor_id AND v.company_id AND j.id = " + jobId + "";
		Statement qs = conn.createStatement();
		
		ResultSet rs1;
		try{
			rs1 = qs.executeQuery(sql);
		}catch(SQLException sqle){
			throw new SQLException("sql: " + sql + ",selqe: " + sqle);
		}
		
		if (rs1.next())	 {
			return rs1.getString(1);
		}else {	
			throw new SQLException("No vendor in database found jobId: " + jobId + ",sql: " + sql);
		}	
	}	
//********* support end *****************	
	
	protected void finalize() {
		try {
			conn.close();
		}catch(Exception e) {
		}finally  {
			conn = null;			
		}
	}	
}
