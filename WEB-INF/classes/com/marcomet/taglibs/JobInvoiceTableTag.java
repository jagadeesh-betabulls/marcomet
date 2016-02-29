package com.marcomet.taglibs;

/**********************************************************************
Description:	This class will print a list of invoices for pages like 
				Job Details.

History:
	Date		Author			Description
	----		------			-----------
	7/5/2001	Thomas Dietrich	Created
	2/14/02		ekc modified 

**********************************************************************/

import com.marcomet.jdbc.*;
import com.marcomet.tools.*;

import java.io.*;
import java.sql.*;
import javax.servlet.jsp.*;
import javax.servlet.jsp.tagext.*;

public class JobInvoiceTableTag extends TagSupport {

	private String jobId;
	private String tableWidth = "100%"; 
	private boolean isVendor;
	
	public final  int doEndTag() throws JspException {

		
		Connection conn = null;
		FormaterTool formater = new FormaterTool();
		
		double totInvoice =0;
		double totPaid = 0;
		double totEscrow = 0;
		double totJobSales = 0;
		double totShipping = 0;
		double totSalesTax = 0;
		
		try {
			conn = DBConnect.getConnection();
			Statement st1 = conn.createStatement();
			ResultSet rs1 = st1.executeQuery("SELECT i.id,i.invoice_number 'invoicenumber', DATE_FORMAT(i.record_creation_timestamp,'%m/%d/%y') 'invoicedate', id.ar_invoice_amount 'invoiceamount', 'amountpaid',id.deposited 'inescrow', id.ar_purchase_amount 'purchaseamount', id.ar_shipping_amount 'shippingamount', id.ar_sales_tax 'salestaxamount' FROM ar_invoices i, ar_invoice_details id, jobs j WHERE j.id = id.jobid AND i.id = id.ar_invoiceid AND id.jobid = " + jobId);
		
			PreparedStatement pst1 = conn.prepareStatement("SELECT payment_amount 'paid' FROM ar_collection_details WHERE ar_invoiceid = ?" );
//			ResultSet rs2; //for collections against the invoice
				
			StringBuffer output = new StringBuffer();
			
			output.append("<table><tr><td class=\"tableheader\">Invoice#</td><td class=\"tableheader\">Inv Date</td><td class=\"tableheader\">Job Amount</td><td class=\"tableheader\">Shipping</td><td class=\"tableheader\">Sales Tax</td><td class=\"tableheader\">Inv Amount</td></tr>");
			
			
			while (rs1.next()){
				//get collection info for invoice
//				pst1.clearParameters();
//				pst1.setInt(1,rs1.getInt("invoicenumber"));								
//				rs2 = pst1.executeQuery();
							
				output.append("<tr><td class=\"label\" align=\"right\">");
				output.append("<a href=\"javascript:popw('/minders/workflowforms/PrintInvoice.jsp?invoiceId="+rs1.getString("i.id")+"','640','480')\">"+rs1.getString("invoicenumber")+"</a></td>");
				output.append("<td class=\"body\">"+rs1.getString("invoicedate")+"</td>");
				output.append("<td class=\"body\" align=\"right\">");
				output.append(formater.getCurrency(rs1.getDouble("purchaseamount")));
				output.append("</td><td class=\"body\" align=\"right\">");
				output.append(formater.getCurrency(rs1.getDouble("shippingamount")));
				output.append("</td><td class=\"body\" align=\"right\">");
				output.append(formater.getCurrency(rs1.getDouble("salestaxamount")));											
				output.append("</td>");
				output.append("<td class=\"body\"align=\"right\">"+formater.getCurrency(rs1.getDouble("invoiceamount"))+"</td></tr>");
				
				
				//add to totals
				totInvoice += rs1.getDouble("invoiceamount");
				totEscrow += rs1.getDouble("inescrow");
				totJobSales += rs1.getDouble("purchaseamount");
				totShipping += rs1.getDouble("shippingamount");
				totSalesTax += rs1.getDouble("salestaxamount");
				
			}
		
			//print out totals
			output.append("<tr><td class=\"label\" colspan=\"2\" align=\"right\">Total Billed</td><td class=\"Topborderlable\"  align=\"right\">");
			output.append(formater.getCurrency(totJobSales));
			output.append("</td><td class=\"Topborderlable\" align=\"right\">");
			output.append(formater.getCurrency(totShipping));
			output.append("</td><td class=\"Topborderlable\" align=\"right\">");
			output.append(formater.getCurrency(totSalesTax));
			output.append("</td><td class=\"Topborderlable\" align=\"right\">");
			output.append(formater.getCurrency(totInvoice));											
			output.append("</td></tr>");
					
		
			output.append("</table>");
			
			pageContext.getOut().print(output);
					
		} catch (IOException ex) {
			throw new JspException(ex.getMessage());	
		} catch (SQLException ex) {
			throw new JspException(ex.getMessage());
		} catch (Exception x) {
			throw new JspException(x.getMessage());
		} finally {
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}

		return EVAL_PAGE;
	}
	public final  void release() {
		super.release();
	}
	public final  void setIsVendor(Boolean temp){           //delete me when mma is up to date 
		this.isVendor = temp.booleanValue();
	}
	public final  void setIsVendor(boolean temp){
		this.isVendor = temp;
	}
	public final  void setJobId(String temp){
		this.jobId = temp;
	}
	public final  void setTableWidth(String temp){
		this.tableWidth = temp;
	}
}
