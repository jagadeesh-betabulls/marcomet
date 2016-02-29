package com.marcomet.admin.accounting;

/**********************************************************************
Description:	Hold AP Invoice Detail information till the user submits.

History:
	Date		Author			Description
	----		------			-----------
	8/28/01		Thomas Dietrich		Created

**********************************************************************/

import java.sql.*;
import java.util.Vector;
import com.marcomet.jdbc.DBConnect;


public class APPaymentDetailObject{

	private int apInvoiceId;
	//private int apPaymentId;
	private double amount;
	private String acctgSysRef;
	
	public String getAcctgSysRef(){
		return acctgSysRef;
	}
	public double getAmount(){
		return amount;
	}
	public int getApInvoiceId(){
		return apInvoiceId;
	}
	public Vector getJobIds() throws Exception {

		Vector jobIds = new Vector();
		
		Connection conn = null; 

		try {			
			conn = DBConnect.getConnection();
			Statement st0 = conn.createStatement();
			String query0 = "SELECT jobid FROM ap_invoice_details WHERE ap_invoiceid = " + apInvoiceId;
			ResultSet rs0 = st0.executeQuery(query0);
			while (rs0.next()) {
				jobIds.addElement(rs0.getString("jobid"));
			}

		} catch (Exception ex) {
			throw new Exception("getJobIds error: " + ex.getMessage());
		} finally {
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}

		return jobIds;
	}
	public void setAcctgSysRef(String temp)	{
		acctgSysRef = temp;	
	}
	public void setAmount(double temp){
		amount = temp;
	}
	public void setApInvoiceId(int temp){
		apInvoiceId = temp;	
	}
}
