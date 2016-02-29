/**********************************************************************
Description:	This class will be used to hold the neccesary tools to 
				create/update/delete invoices
**********************************************************************/

package com.marcomet.commonprocesses;

import com.marcomet.jdbc.*;

import java.sql.*;
import java.text.*;


public class ProcessARInvoice {

	//varables
	private int id;
	private String idString="";
	private double purchaseAmount;
	private double shippingAmount;
	private double salesTax;
	private double deposited;
	private double invoiceAmount;
	private int billToId;
	private int billToContactId;
	private int billToCompanyId;
	private int billToTypeId;
	private int vendorId=0;
	private int paymentOption=3;	
	private int invoiceType;
	private int salesTaxEntityId=0;
	private String invoiceNumber="";
	private String invoiceMessage="";
	
	public final void setId(int temp){
		id = temp;	
	}
	public final void setId(String temp){
		setId(Integer.parseInt(temp));
	}
	public final int getId(){
		return id;
	}
	
	public final void setPaymentOption(int temp){
		paymentOption = temp;	
	}
	public final void setPaymentOption(String temp){
		setPaymentOption(Integer.parseInt(temp));
	}
	public final int getPaymentOption(){
		return paymentOption;
	}	
	
	public final void setInvoiceMessage(String temp){
		invoiceMessage=temp;
	}
	
	public final String getInvoiceMessage(){
		return ((invoiceMessage==null)?"":invoiceMessage);
	}
	
	
	public final void setIdString(String temp){
		idString=temp;
	}
	public final String getIdString(){
		return idString;
	}
	
	
	public final void setVendorId(int temp){
		vendorId = temp;	
	}
	public final void setVendorId(String temp){
		setVendorId(Integer.parseInt(temp));
	}
	public final int getVendorId(){
		return vendorId;
	}	
		
	public final void setSalesTaxEntityId(int temp){
		salesTaxEntityId = temp;	
	}
	public final void setSalesTaxEntityId(String temp){
		setSalesTaxEntityId(Integer.parseInt(temp));
	}
	public final int getSalesTaxEntityId(){
		return salesTaxEntityId;
	}
	
	public final void setPurchaseAmount(double temp){
		purchaseAmount = temp;	
	}
	public final void setPurchaseAmount(String temp){
		setPurchaseAmount(Double.parseDouble(temp));
	}
	public final double getPurchaseAmount(){
		return purchaseAmount;
	}

	public final void setShippingAmount(double temp){
		shippingAmount = temp;	
	}
	public final void setShippingAmount(String temp){
		setShippingAmount(Double.parseDouble(temp));
	}
	public final double getShippingAmount(){
		return shippingAmount;
	}
				   
	public final void setSalesTax(double temp){
		salesTax = temp;	
	}
	public final void setSalesTax(String temp){
		setSalesTax(Double.parseDouble(temp));
	}
	public final double getSalesTax(){
		return salesTax;
	}

	public final void setDeposited(double temp){
		deposited = temp;	
	}
	public final void setDeposited(String temp){
		setDeposited(Double.parseDouble(temp));
	}
	public final double getDeposited(){
		return deposited;
	}
	
	public final void setInvoiceAmount(double temp){
		invoiceAmount = temp;	
	}
	public final void setInvoiceAmount(String temp){
		setInvoiceAmount(Double.parseDouble(temp));
	}
	public final double getInvoiceAmount(){
		return invoiceAmount;
	}
	
	public final void setBillToId(int temp){
		billToId = temp;	
	}
	public final void setBillToId(String temp){
		setBillToId(Integer.parseInt(temp));
	}
	public final int getBillToId(){
		return billToId;
	}	

	public final void setBillToContactId(int temp){
		billToContactId = temp;	
	}
	public final void setBillToContactId(String temp){
		setBillToContactId(Integer.parseInt(temp));
	}
	public final int getBillToContactId(){
		return billToContactId;
	}
	
	public final void setBillToCompanyId(int temp){
		billToCompanyId = temp;	
	}
	public final void setBillToCompanyId(String temp){
		setBillToCompanyId(Integer.parseInt(temp));
	}
	public final int getBillToCompanyId(){
		return billToCompanyId;
	}
	
	public final void setBillToTypeId(int temp){
		billToTypeId = temp;	
	}
	public final void setBillToTypeId(String temp){
		setBillToTypeId(Integer.parseInt(temp));
	}
	public final int getBillToTypeId(){
		return billToTypeId;
	}
	
	public final void setInvoiceType(int temp){
		invoiceType = temp;	
	}
	public final void setInvoiceType(String temp){
		setInvoiceType(Integer.parseInt(temp));
	}
	public final int getInvoiceType(){
		return invoiceType;
	}
	
	public final void setInvoiceNumber(String temp){
		invoiceNumber=temp;
	}
	public final String getInvoiceNumber(){
		return ((invoiceNumber==null)?"":invoiceNumber);
	}		

	public final String getCreationDate(){
		DateFormat mysqlFormat = new SimpleDateFormat("yyyy-MM-dd");	
		
		return mysqlFormat.format(new java.util.Date());		
	}	
	
	//if no connection is sent	
	public final int insert()
	throws SQLException{
					
		return processInsert();	
	
	}	
	
	//share connection from calling object	
	public final int insert(Connection tempConn) throws SQLException, Exception{
		//conn = tempConn;
		int i = processInsert();
		//conn = null;
		return i;		
	}
		
	public final int processInsert() throws SQLException{
		
		String insertSQL = "insert into ar_invoices(id,ar_purchase_amount,ar_shipping_amount,ar_sales_tax,deposited,ar_invoice_amount,bill_to_id,bill_to_type_id,ar_invoice_type, bill_to_companyid, bill_to_contactid,creation_date,sales_tax_state,vendor_id,invoice_number,message,payment_option)values(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
		
		Statement qs = null;
		Connection conn = null; 

		try {			
			conn = DBConnect.getConnection();
			qs = conn.createStatement();
			//lock table
			qs.execute("LOCK TABLES ar_invoices WRITE");	
					
			//set id if it is 0/null
			if(getId() <= 0){
				String getNextIdSQL = "select IF( max(id) IS NULL, 0, max(id))+1  from ar_invoices;";
				ResultSet rs1 = qs.executeQuery(getNextIdSQL);
				rs1.next(); 
				setId(rs1.getInt(1));
				setIdString(rs1.getString(1));
			}

			PreparedStatement insert = conn.prepareStatement(insertSQL);
			insert.setInt(1,getId());
			insert.setDouble(2,getPurchaseAmount());
			insert.setDouble(3,getShippingAmount());
			insert.setDouble(4,getSalesTax());
			insert.setDouble(5,getDeposited());
			insert.setDouble(6,getInvoiceAmount());		
			insert.setInt(7,getBillToId());
			insert.setInt(8,getBillToTypeId());
			insert.setInt(9,getInvoiceType());
			insert.setInt(10,getBillToCompanyId());
			insert.setInt(11,getBillToContactId());
			insert.setString(12,getCreationDate());
			insert.setInt(13,getSalesTaxEntityId());			
			insert.setInt(14,getVendorId());
			insert.setString(15,((getInvoiceNumber().equals(""))?getIdString():invoiceNumber));			
			insert.setString(16,getInvoiceMessage());
			insert.setInt(17,getPaymentOption());			
			insert.execute();
			
		} catch (Exception x) {
			throw new SQLException(x.getMessage());
		} finally {
			try { qs.execute("UNLOCK TABLES"); } catch ( Exception x) { qs = null; }
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}

		return getId();
	}			

	protected void finallize() {
		
	}	
			
}