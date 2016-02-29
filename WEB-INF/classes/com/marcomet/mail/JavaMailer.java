package com.marcomet.mail;

import java.io.File;
import java.io.FileOutputStream;

/**********************************************************************
Description:	Java Emailer, result of simple emailer failing to send 
				messages that can be interpetted by Microsoft products,
				outlook, outlook express, and netscape.
**********************************************************************/

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.Properties;
import java.util.ResourceBundle;

import javax.activation.DataHandler;
import javax.activation.DataSource;
import javax.activation.FileDataSource;
import javax.mail.*;
import javax.mail.internet.*;

import com.itextpdf.text.BaseColor;
import com.itextpdf.text.Chunk;
import com.itextpdf.text.Document;
import com.itextpdf.text.Element;
import com.itextpdf.text.Font;
import com.itextpdf.text.Paragraph;
import com.itextpdf.text.Font.FontFamily;
import com.itextpdf.text.html.WebColors;
import com.itextpdf.text.pdf.PdfPCell;
import com.itextpdf.text.pdf.PdfPTable;
import com.itextpdf.text.pdf.PdfWriter;
import com.marcomet.jdbc.DBConnect;

public class JavaMailer{
	
	private String host ="localhost";
	private String from ;
	private String to ;
	private String subject ;
	private String body ;
	private String attachments="  ";
	private int siteHostId = 0;	
	private int emailType = 0;	
	private int emailId=0;
	private int emailFromId=0;
	private int emailToId=0;
	private int jobId;	
	private int responseToEmailId=0;	
	
	private String invoiceId = null ;
	private String purchaseAmount= null;
	private String shippingAmount= null;
	private double salesTax=0;
	private String creationDate= null;
	private String vendorId= null;
	private String billName= null;
	private String billAddress= null;
	private String billCity= null;
	private String billState= null;
	private String billZip= null;
	private String billFax= null;
	private String billToContactId= null;
	private String id= null;
	private String jobName= null;
	private String jobAmount= null;
	private double shippingPrice=0;
	private String invoiceNumber= null;
	private double salestaxPrice=0;
	private double optionsPrice=0;
	private double changesPrice=0;
	private double basePrice =0;
	private double discountPrice=0;
	private double jobTotal=0;
	private double invoicesPrice=0;
	private double BilledToDate=0;
	private double JobBalanceUnbilled=0;
	private double invoicePurchaseAmount=0;
	private double invoiceShipping=0;
	private double CurrentDue=0;
	private double invoiceAmount=0;
	private double payments=0;
	private double balance_due=0;
	private String toEmail=null;
	private String fullName=null;
	private String CompanyName=null;
	private String billtoaddress1=null;
	private String billtoaddress2=null;
	private String billtocity=null;
	private	String billtostate=null;
	private	String billtozip=null;
	private	String shiptoaddress1=null;
	private	String shiptoaddress2=null;
	private	String shiptocity=null;
	private	String shiptostate=null;
	private	String shiptozip=null;
	private	String phnareacode=null;
	private	String phnareacode1=null;
	private	String phnareacode2=null;
	private	String ctid=null;
	private	String faxareacode1=null;
	private String faxareacode2=null;
	private String faxareacode3=null;
	
	
	public static void main(String[] args) throws Exception{
		JavaMailer t=new JavaMailer();
		t.send();
		System.out.println("calling javamailer");
		
	}
	
	public JavaMailer() throws Exception{		
	
		ResourceBundle bundle = ResourceBundle.getBundle("com.marcomet.marcomet");
		host = bundle.getString("mailrouter");
		
		System.out.println("java mailer called succesfully");
		
	}
	protected void finalize(){
	}
	
	private void recordEmail() throws Exception{
		System.out.println("jobId is "+jobId);
		Connection conn = DBConnect.getConnection();
		PreparedStatement insertEmailHistory;
		Statement qs = conn.createStatement();		
		String insertEmailHistoryText = 
			"INSERT INTO email_sent_histories(email_to,email_from,subject,body,attachments,sent,site_host_id,email_type,email_to_id,email_from_id,job_id,response_to_email_id) values (?,?,?,?,?,?,?,?,?,?,?,?)";	
		
		try{
			qs.execute("LOCK TABLES email_sent_histories WRITE");	
			ResultSet rs = qs.executeQuery("select (IF( max(id) IS NULL, 0, max(id))+1)   as id from email_sent_histories");
			if (rs.next()){
				emailId=rs.getInt("id");			
			}		
//com.marcomet.tools.MessageLogger.logMessage("before record");			
			insertEmailHistory = conn.prepareStatement(insertEmailHistoryText);
			insertEmailHistory.clearParameters();
			insertEmailHistory.setString(1,to);		
			insertEmailHistory.setString(2,from);
			insertEmailHistory.setString(3,subject);
			insertEmailHistory.setString(4,body);
			insertEmailHistory.setString(5,attachments);
			insertEmailHistory.setString(6,"0");
			
			insertEmailHistory.setInt(7,siteHostId);
			insertEmailHistory.setInt(8,emailType);
			insertEmailHistory.setInt(9,emailToId);
			insertEmailHistory.setInt(10,emailFromId);
			insertEmailHistory.setInt(11,jobId);
			insertEmailHistory.setInt(12,responseToEmailId);
			//insertEmailHistory.setInt(12,171819);
			//insertEmailHistory.setInt(12,responseToEmailId);
			//insertEmailHistory.setInt(13,jobId);					
				
//com.marcomet.tools.MessageLogger.logMessage("before execute");			
			insertEmailHistory.execute();	
		System.out.println("currently in recordEmail & calling sendEmail()");
			sendEmail();
		}catch(SQLException sqle){
			//throw new Exception("Simple Emailer failed. history failed" + sqle.getMessage());
			sqle.printStackTrace();
		}finally {
			qs.execute("UNLOCK TABLES");				
			try { qs.close(); } catch ( Exception e) {}
			try { conn.close(); } catch ( Exception e) {}
		}
	}
	public void send() throws Exception{	
		System.out.println("currently in send & calling recordEmail()");
		recordEmail();		
	}
	public void sendEmail() throws Exception{
		
		Connection conn = DBConnect.getConnection();
    	Statement st=conn.createStatement();		
    	String query = "select * from ar_invoice_details where jobid = "+jobId;
    	ResultSet rsJob = null;
    	rsJob=	st.executeQuery(query);
    	 while (rsJob.next ())
    	   {
    		 
    	       invoiceId = rsJob.getString ("ar_invoiceId");
    	       purchaseAmount	=rsJob.getString("ar_purchase_amount");
    	       shippingAmount	=rsJob.getString("ar_shipping_amount");
    	      // creationDate		=rsJob.getString("creation_date");
    	       creationDate		=rsJob.getString("modification_date");
    	       invoicePurchaseAmount=rsJob.getDouble("ar_purchase_amount");
    	       invoiceShipping=rsJob.getDouble("ar_shipping_amount");
    	       invoiceAmount=rsJob.getDouble("ar_invoice_amount");
    	       
    	   }
    	 
    	 CurrentDue=invoicePurchaseAmount+invoiceShipping;
    	 
    	 System.out.println ("invoice id is "+invoiceId);
    	 System.out.println (purchaseAmount);
    	 System.out.println (shippingAmount);
    	 System.out.println (salesTax);
    	 System.out.println ("creationDate is"+creationDate);
    	 //System.out.println("invoicePurchaseAmount is "+invoicePurchaseAmount);
    	 System.out.println("CurrentDue is "+CurrentDue);
    	 System.out.println("invoiceShipping is "+invoiceShipping);
    	 System.out.println("invoiceAmount is "+invoiceAmount);
    	 
    	 
    	 Statement st1=conn.createStatement();		
    		String query1 ="select * from ar_invoices where invoice_number ="+invoiceId;
    		ResultSet rsJob1 = null;
    		rsJob1=	st1.executeQuery(query1);
    		while (rsJob1.next ())
    		   {
    			id=rsJob1.getString("id");
    			invoiceNumber = rsJob1.getString("invoice_number");
    			vendorId =rsJob1.getString("vendor_id");
    			billToContactId=rsJob1.getString("bill_to_contactid");
    		   }
    		
    		System.out.println ("vendor id for invoiceid "+invoiceId+" is "+vendorId);
    		System.out.println ("billToContactId for invoiceid "+invoiceId+" is "+billToContactId);
    		
    		
    		Statement st2=conn.createStatement();		
    		String query2 ="Select v.id,c.id companyId,c.company_name name,l.address1 address1,l.address2 address2,l.city city,s.value state,l.zip zip, l.fax fax from vendors v, companies c,company_locations l,lu_abreviated_states s where l.company_id=c.id and c.id=v.company_id and l.lu_location_type_id=3 and s.id=l.state and v.id="+vendorId;
    		
    		ResultSet rsJob2 = null;
    		rsJob2=	st2.executeQuery(query2);
    		while (rsJob2.next ())
    		   {
    			billName =rsJob2.getString("name");
    			billAddress=rsJob2.getString("address1");
    			billCity=rsJob2.getString("city");
    			billState=rsJob2.getString("state");
    			billZip=rsJob2.getString("zip");
    			billFax=rsJob2.getString("fax");
    			
    		   }
    		System.out.println("billName "+billName);
    		System.out.println("billAddress "+billAddress);
    		System.out.println("billCity "+billCity);
    		System.out.println("billState "+billState);
    		System.out.println("billZip "+billZip);
    		System.out.println("billFax "+billFax);
    		
    		 Statement st3=conn.createStatement();		
    			String query3 ="Select * from jobs j Inner Join site_hosts sh ON j.jsite_host_id = sh.id Inner Join orders o ON j.jorder_id = o.id where j.id="+jobId;
    			ResultSet rsJob3 = null;
    			rsJob3=	st3.executeQuery(query3);
    			while (rsJob3.next ())
    			   {
    				jobName =rsJob3.getString("job_name");
    				jobAmount=rsJob3.getString("billed");
    				 salesTax=rsJob3.getDouble("sales_tax");
    				 shippingPrice=rsJob3.getDouble("shipping_price");
    				 salestaxPrice=rsJob3.getDouble("sales_tax");
    				
    				 
    			   }
    		
    			
    		String	price = "select sum(price) price from job_specs where (cat_spec_id<>88888 and cat_spec_id<>99999) and job_id="+jobId;
    			ResultSet rsOptionPrice = st.executeQuery(price);
    			if (rsOptionPrice.next()){
    				optionsPrice=rsOptionPrice.getDouble("price");
    			}
    			
    			String changePrice = "select sum(price) price from jobchanges where statusid=2 and jobid="+jobId;
    			 st=conn.createStatement();
    			ResultSet rsChangePrice = st.executeQuery(changePrice);
    			if (rsChangePrice.next()){
    				changesPrice = rsChangePrice.getDouble("price");
    				
    			}
    			
    			String sql = "select price from job_specs where (cat_spec_id=88888 or cat_spec_id=99999) and job_id="+jobId;
    			
    			ResultSet rsBasePrice = st.executeQuery(sql);
    			while (rsBasePrice.next()){
    				 basePrice = rsBasePrice.getDouble("price")+basePrice;
    				
    			}
    			
    			String sql1 = "select discount from jobs where id="+jobId;

    			ResultSet rsDiscountPrice = st.executeQuery(sql1);
    			if (rsDiscountPrice.next()){
    				 discountPrice = rsDiscountPrice.getDouble("discount");
    				
    			}
    		
    			//jobTotal=shippingPrice+salestaxPrice+optionsPrice+changesPrice+basePrice-discountPrice;
    			jobTotal=shippingPrice+salestaxPrice+optionsPrice+changesPrice+basePrice-discountPrice;
    			System.out.println("jobTotal is "+jobTotal);
    			
    			sql = "select sum(d.ar_invoice_amount) price,sum(d.ar_sales_tax) salestaxPrice, sum(d.ar_shipping_amount) shippingPrice from ar_invoice_details d, ar_invoices i where i.id<'"+id+"' and i.id=d.ar_invoiceid and d.jobid="+jobId;
    			 st=conn.createStatement();
    			ResultSet rsInvoicePrice = st.executeQuery(sql);
    			if (rsInvoicePrice.next()){
    				invoicesPrice = rsInvoicePrice.getDouble("price");
    				
    			}
    			BilledToDate=invoicesPrice;
    			
    			//JobBalanceUnbilled=shippingPrice+salestaxPrice+optionsPrice+changesPrice+basePrice-discountPrice-invoicesPrice
    			
    			JobBalanceUnbilled=shippingPrice+salesTax+optionsPrice+changesPrice+basePrice-discountPrice-invoicesPrice;
    			System.out.println("JobBalanceUnbilled is "+JobBalanceUnbilled);
    			
    			String sql2 = "select sum(payment_amount) as payments from ar_collection_details where ar_invoiceid = " + invoiceId + " Group by ar_invoiceid";
    			st=conn.createStatement();
    			ResultSet rsPayments = st.executeQuery(sql2);
    			if (rsPayments.next()){
    				payments=rsPayments.getDouble("payments") * -1;
    				
    			}
    			
    			System.out.println("payments is "+payments);
    			balance_due = invoiceAmount + payments;
    			
    			String sql5 = "SELECT c.email FROM orders o, projects p, jobs j, contacts c WHERE j.project_id = p.id AND p.order_id = o.id AND c.id = o.buyer_contact_id AND j.id ="+jobId;
   			 st=conn.createStatement();
   			ResultSet rsEmail = st.executeQuery(sql5);
   			if (rsEmail.next()){
   				toEmail = rsEmail.getString("email");
   				
   			}
    			
   			System.out.println("toEmail is "+toEmail);
    		
   			
   			String sql4 = "Select concat(ct.firstname,ct.lastname) fullname, ct.id ctid, c.company_name companyname,l.address1 billtoaddress1,l.address2 billtoaddress2,l.city billtocity,s.value billtostate,l.zip billtozip ,shp.address1 shiptoaddress1,shp.address2 shiptoaddress2,shp.city shiptocity,sshp.value shiptostate,shp.zip shiptozip, ph.areacode phnareacode, ph.phone1 phnnum1, ph.phone2 phnnum2, fx.areacode faxareacode, fx.phone1 faxnum1, fx.phone2 faxnum2 ";
   			sql4+=" from companies c,locations l,locations shp,lu_abreviated_states s,lu_abreviated_states sshp,contacts ct ";
   			sql4+=" left join phones ph on ph.contactid=ct.id and ph.phonetype=1 ";
   			
   			sql4+=" left join phones fx on fx.contactid=ct.id and fx.phonetype=2 ";
   			sql4+=" where c.id=ct.companyid and ct.id="+billToContactId+" and l.contactid=ct.id  and l.locationtypeid=2 and s.id=l.state and shp.contactid=ct.id  and shp.locationtypeid=1 and sshp.id=shp.state";
   			
   			
   			ResultSet rsCustomerInfo = st.executeQuery(sql4);
   			while(rsCustomerInfo.next()){
   			
   				
   				fullName=rsCustomerInfo.getString("fullname");
   				CompanyName=rsCustomerInfo.getString("companyname");
   				billtoaddress1=rsCustomerInfo.getString("billtoaddress1");
   				billtoaddress2=rsCustomerInfo.getString("billtoaddress2");
   				billtocity=rsCustomerInfo.getString("billtocity");
   				billtostate=rsCustomerInfo.getString("billtostate");
   				billtozip=rsCustomerInfo.getString("billtozip");
   				shiptoaddress1=rsCustomerInfo.getString("shiptoaddress1");
   				shiptoaddress2=rsCustomerInfo.getString("shiptoaddress2");
   				shiptocity=rsCustomerInfo.getString("shiptocity");
   				shiptostate=rsCustomerInfo.getString("shiptostate");
   				shiptozip=rsCustomerInfo.getString("shiptozip");
   				phnareacode=rsCustomerInfo.getString("phnareacode");
   				phnareacode1=rsCustomerInfo.getString("phnnum1");
   				phnareacode2=rsCustomerInfo.getString("phnnum2");
   				faxareacode1=rsCustomerInfo.getString("faxareacode");
   				faxareacode2=rsCustomerInfo.getString("faxnum1");
   				faxareacode3=rsCustomerInfo.getString("faxnum2");
   				
   				ctid=rsCustomerInfo.getString("ctid");
   			}
   			
   			conn.close(); 
   			
   			String billToAddress=fullName+"\n"+billtoaddress1+"\n"+billtocity+"\n"+billtostate+"\n"+billtozip;
   			
   			String shippingAddress=fullName+"\n"+billtoaddress1+"\n"+billtocity+"\n"+billtostate+"\n"+billtozip;
   			
   			String customerContact=fullName+"\n"+billtoaddress1+"\n"+billtocity+"\n"+billtostate+"\n"+billtozip+"\n"+"Phone:"+phnareacode+"-"+phnareacode1+"-"+phnareacode2+"\n"+"Fax:"+faxareacode1+"-"+faxareacode2+"-"+faxareacode3;
   			
   			System.out.println("billToAddress is "+billToAddress);
   			System.out.println("customerContact is "+customerContact);
   			System.out.println("shippingAddress is "+shippingAddress);
   			
   			String jobCost="Job amount"+"\n"+"Shipping"+"\n"+"Sales Tax"+"\n"+"Job Total"+"\n"+"Job billed to date"+"\n"+"Job Balance Unbilled";
    		String summery="$"+jobAmount+"\n"+"$"+shippingPrice+"\n"+"$"+salesTax+"\n"+"$"+jobTotal+"\n"+"$"+BilledToDate+"\n"+"$"+JobBalanceUnbilled;
    		
    		String currentDue="Current Due On Job"+"\n"+"Sales Tax: (-) 0.00%"+"\n"+"Invoice Amount";
    		String Summary1="$"+CurrentDue+"\n"+"$"+salesTax+"\n"+"$"+invoiceAmount;
    		String paymentReceived="Payments Received"+"\n"+"Invoice Balance Due";
    		String Summary2="\n"+"$"+balance_due;
    		
    		
    		System.out.println("billAddress is "+billAddress);
    		
    		
    		//pdf section
    		
    		Document document=new Document();
            
    	      String path=System.getProperty("user.dir");
    	      System.out.println(path);
    	     
    	     
    	      try {
    	         
    	         
    	         
    	         
    	        
    	    	  PdfWriter.getInstance(document, new FileOutputStream(path+invoiceNumber+".pdf"));
    	          document.open();
    	         
    	          Font f=new Font(FontFamily.HELVETICA,15f,Font.BOLD,BaseColor.WHITE);
    	          Font f1=new Font(FontFamily.HELVETICA,13f,Font.NORMAL,BaseColor.WHITE);
    	          Font f2=new Font(FontFamily.HELVETICA,9f,Font.NORMAL,BaseColor.BLACK);
    	          Font f3=new Font(FontFamily.HELVETICA,10f,Font.NORMAL,BaseColor.WHITE);
    	          Font f4=new Font(FontFamily.HELVETICA,10f,Font.NORMAL,BaseColor.BLACK);
    	          
    	         // BaseColor myColor = WebColors.getRGBColor("#144f82");
    	          //BaseColor myColor = WebColors.getRGBColor("#99ccff");
    	          BaseColor myColor = WebColors.getRGBColor("#004284");
    	          
    	          
    	         // BaseColor bordercolor = WebColors.getRGBColor("#ffd600");
    	          BaseColor bordercolor = WebColors.getRGBColor("#CCB857");
    	          
    	          
    	          
    	         
    	          PdfPTable table01 = new PdfPTable(1);
    	          PdfPCell cell01 = new PdfPCell(new Paragraph("INVOICE",f));
    	          table01.setSpacingBefore(25);
    	          cell01.setHorizontalAlignment(Element.ALIGN_CENTER);
    	          cell01.setBackgroundColor(myColor);
    	          cell01.setBorderColorBottom(bordercolor);
    	          cell01.setBorderColor(BaseColor.WHITE);
    	          table01.addCell(cell01);
    	          table01.setSpacingAfter(25);
    	          table01.setSpacingBefore(40);
    	          table01.size();
    	         
    	          PdfPTable table02 = new PdfPTable(1);
    	          PdfPCell cell02 = new PdfPCell(new Paragraph("For your order in marketsdaysinn website",f));
    	          cell02.setHorizontalAlignment(Element.ALIGN_CENTER);
    	          cell02.setBackgroundColor(myColor);
    	          cell02.setBorderColorBottom(bordercolor);
    	          //cell02.setBorderColor(BaseColor.BLACK);
    	          cell02.setBorderColor(BaseColor.WHITE);
    	          table02.addCell(cell02);
    	          table02.setSpacingAfter(18);
    	         
    	          Paragraph paragraph = new Paragraph();
    	          Chunk chunk = new Chunk(" Invoice ");
    	          //chunk.setBackground(myColor);
    	          paragraph.add(chunk);
    	          paragraph.setAlignment(Element.ALIGN_CENTER);
    	          
    	         // paragraph.setSpacingAfter(25);
    	          //paragraph.setSpacingBefore(25);
    	         
    	          Paragraph paragraph1 = new Paragraph();
    	          Chunk chunk1 = new Chunk(" For your order in marketsdaysinn website ");
    	          paragraph1.add(chunk1);
    	          paragraph1.setAlignment(Element.ALIGN_CENTER);
    	          paragraph1.setSpacingAfter(25);
    	          paragraph1.setSpacingBefore(15);
    	        
    	          PdfPTable table = new PdfPTable(2);
    	          PdfPCell cell1 = new PdfPCell(new Paragraph("Bill to",f1));
    	          //cell1.setBorderColor(BaseColor.BLUE);
    	          cell1.setBackgroundColor(myColor);
    	          cell1.setHorizontalAlignment(Element.ALIGN_LEFT);
    	          PdfPCell cell2 = new PdfPCell(new Paragraph("Customer Contact",f1));
    	          cell2.setHorizontalAlignment(Element.ALIGN_LEFT);
    	          cell2.setBackgroundColor(myColor);
    	          PdfPCell cell4 = new PdfPCell(new Paragraph(billToAddress,f4));
    	          cell4.setHorizontalAlignment(Element.ALIGN_LEFT);
    	          PdfPCell cell5 = new PdfPCell(new Paragraph(customerContact,f4));
    	          cell5.setHorizontalAlignment(Element.ALIGN_LEFT);
    	      
    	         
    	          PdfPTable table1 = new PdfPTable(1);
    	          PdfPCell cell3 = new PdfPCell(new Paragraph("Ship to",f1));
    	           cell3.setHorizontalAlignment(Element.ALIGN_LEFT);
    	           cell3.setBackgroundColor(myColor);
    	            PdfPCell cell6 = new PdfPCell(new Paragraph(shippingAddress,f4));
    	            cell6.setHorizontalAlignment(Element.ALIGN_LEFT);
    	          
    	          
    	          table.addCell(cell1);
    	          table.addCell(cell2);
    	        
    	          table.addCell(cell4);
    	          table.addCell(cell5);
    	          table1.addCell(cell3);
    	          table1.addCell(cell6);
    	         
    	          PdfPTable nestedTable = new PdfPTable(6);
    	          //nestedTable.addCell(new Paragraph("Customer #"));
    	          PdfPCell cellN1 = new PdfPCell(new Paragraph("Customer #",f1));
    	          cellN1.setHorizontalAlignment(Element.ALIGN_CENTER);
    	          cellN1.setBackgroundColor(myColor);
    	          nestedTable.addCell(cellN1);
    	          //nestedTable.addCell(new Paragraph("Invoive number"));
    	          PdfPCell cellN2 = new PdfPCell(new Paragraph("Invoive number",f1));
    	          cellN2.setHorizontalAlignment(Element.ALIGN_CENTER);
    	          cellN2.setBackgroundColor(myColor);
    	          nestedTable.addCell(cellN2);
    	          //nestedTable.addCell(new Paragraph("Invoice Date"));
    	          PdfPCell cellN3 = new PdfPCell(new Paragraph("Invoice Date",f1));
    	          cellN3.setHorizontalAlignment(Element.ALIGN_CENTER);
    	          cellN3.setBackgroundColor(myColor);
    	          nestedTable.addCell(cellN3);
    	          //nestedTable.addCell(new Paragraph("Job Number"));
    	          PdfPCell cellN4 = new PdfPCell(new Paragraph("Job Number",f1));
    	          cellN4.setHorizontalAlignment(Element.ALIGN_CENTER);
    	          cellN4.setBackgroundColor(myColor);
    	          nestedTable.addCell(cellN4);
    	          //nestedTable.addCell(new Paragraph("Terms"));
    	          PdfPCell cellN5 = new PdfPCell(new Paragraph("Terms",f1));
    	          cellN5.setHorizontalAlignment(Element.ALIGN_CENTER);
    	          cellN5.setBackgroundColor(myColor);
    	          nestedTable.addCell(cellN5);
    	          //nestedTable.addCell(new Paragraph("Custumer po/ref"));
    	          PdfPCell cellN6 = new PdfPCell(new Paragraph("Custumer po/ref",f1));
    	          cellN6.setHorizontalAlignment(Element.ALIGN_CENTER);
    	          cellN6.setBackgroundColor(myColor);
    	          nestedTable.addCell(cellN6);
    	        
    	          PdfPTable nestedTable1 = new PdfPTable(6);
    	          nestedTable1.addCell(new Paragraph(id,f2));
    	          nestedTable1.addCell(new Paragraph(invoiceNumber,f2));
    	          nestedTable1.addCell(new Paragraph(creationDate,f2));
    	          nestedTable1.addCell(new Paragraph(jobId));
    	          nestedTable1.addCell(new Paragraph("Due Upon Receipt ",f2));
    	          nestedTable1.addCell(new Paragraph(" ",f2));
    	          nestedTable1.setHorizontalAlignment(Element.ALIGN_CENTER);
    	         
    	          PdfPTable tableN = new PdfPTable(1);
    	          tableN.addCell(nestedTable);
    	          PdfPTable tableN1 = new PdfPTable(1);
    	          tableN1.addCell(nestedTable1);
    	          tableN.setSpacingBefore(10f);
    	         // tableN1.setSpacingBefore(10f);
    	          tableN1.setSpacingAfter(10f);
    	         
    	          PdfPTable table3 = new PdfPTable(3);
    	          PdfPCell cellt1 = new PdfPCell(new Paragraph("Job Name/ Description",f1));
    	          cellt1.setBackgroundColor(myColor);
    	          cellt1.setHorizontalAlignment(Element.ALIGN_LEFT);
    	          PdfPCell cellt2 = new PdfPCell(new Paragraph("Job Cost",f1));
    	          cellt2.setBackgroundColor(myColor);
    	          cellt2.setHorizontalAlignment(Element.ALIGN_RIGHT);
    	          PdfPCell cellt3 = new PdfPCell(new Paragraph("Summary(US $)",f1));
    	          cellt3.setBackgroundColor(myColor);
    	          cellt3.setHorizontalAlignment(Element.ALIGN_RIGHT);
    	          table3.addCell(cellt1);
    	          table3.addCell(cellt2);
    	          table3.addCell(cellt3);
    	         
    	          PdfPTable table4 = new PdfPTable(3);
    	          PdfPCell cellt41 = new PdfPCell(new Paragraph(jobName,f2));
    	          cellt1.setHorizontalAlignment(Element.ALIGN_LEFT);
    	          PdfPCell cellt42 = new PdfPCell(new Paragraph(jobCost,f2));
    	          cellt42.setHorizontalAlignment(Element.ALIGN_RIGHT);
    	          PdfPCell cellt43 = new PdfPCell(new Paragraph(summery,f2));
    	          cellt43.setHorizontalAlignment(Element.ALIGN_RIGHT);
    	          table3.addCell(cellt41);
    	          table3.addCell(cellt42);
    	          table3.addCell(cellt43);
    	         
    	          float[] columnWidths = new float[] {27f, 22f, 22f};
    	        
    	          
    	          PdfPTable tablec1 = new PdfPTable(3);
    	          PdfPCell cellc1 = new PdfPCell(new Paragraph("Previous billing on this job",f1));
    	          cellc1.setBackgroundColor(myColor);
    	          cellc1.setHorizontalAlignment(Element.ALIGN_LEFT);
    	          PdfPCell cellc2 = new PdfPCell(new Paragraph("Current invoice",f1));
    	          cellc2.setBackgroundColor(myColor);
    	          cellc2.setHorizontalAlignment(Element.ALIGN_RIGHT);
    	          PdfPCell cellc3 = new PdfPCell(new Paragraph("Summary(US $)",f1));
    	          cellc3.setBackgroundColor(myColor);
    	          cellc3.setHorizontalAlignment(Element.ALIGN_RIGHT);
    	          tablec1.setWidths(columnWidths);
    	          tablec1.addCell(cellc1);
    	          tablec1.addCell(cellc2);
    	          tablec1.addCell(cellc3);
    	          tablec1.setSpacingBefore(7);
    	          
    	          
    	          PdfPTable tablec2 = new PdfPTable(3);
    	          PdfPCell cellc11 = new PdfPCell(new Paragraph(" ",f2));
    	         
    	          cellc11.setHorizontalAlignment(Element.ALIGN_LEFT);
    	          PdfPCell cellc12 = new PdfPCell(new Paragraph(currentDue,f2));
    	         
    	          cellc12.setHorizontalAlignment(Element.ALIGN_RIGHT);
    	          PdfPCell cellc13 = new PdfPCell(new Paragraph(Summary1,f2));
    	          
    	          cellc13.setHorizontalAlignment(Element.ALIGN_RIGHT);
    	          tablec2.setWidths(columnWidths);
    	          tablec2.addCell(cellc11);
    	          tablec2.addCell(cellc12);
    	          tablec2.addCell(cellc13);
    	          
    	          
    	          
    	          PdfPTable tablec3 = new PdfPTable(3);
    	          PdfPCell cellc31 = new PdfPCell(new Paragraph("Remit to",f1));
    	          cellc31.setBackgroundColor(myColor);
    	          cellc31.setHorizontalAlignment(Element.ALIGN_LEFT);
    	          PdfPCell cellc32 = new PdfPCell(new Paragraph("invoice balance",f1));
    	          cellc32.setBackgroundColor(myColor);
    	          cellc32.setHorizontalAlignment(Element.ALIGN_RIGHT);
    	          PdfPCell cellc33 = new PdfPCell(new Paragraph("Due (US $)",f1));
    	          cellc33.setBackgroundColor(myColor);
    	          cellc33.setHorizontalAlignment(Element.ALIGN_RIGHT);
    	          tablec3.setWidths(columnWidths);
    	          tablec3.addCell(cellc31);
    	          tablec3.addCell(cellc32);
    	          tablec3.addCell(cellc33);
    	          tablec3.setSpacingBefore(7);
    	          
    	          
    	          PdfPTable tablec4 = new PdfPTable(3);
    	          PdfPCell cellc41 = new PdfPCell(new Paragraph("Marcomet"+"\n"+"P.O. Box 368"+"\n"+"Tranquility, NJ 07879"+"\n",f2));
    	         
    	          cellc41.setHorizontalAlignment(Element.ALIGN_LEFT);
    	          PdfPCell cellc42 = new PdfPCell(new Paragraph(paymentReceived,f2));
    	         
    	          cellc42.setHorizontalAlignment(Element.ALIGN_RIGHT);
    	          PdfPCell cellc43 = new PdfPCell(new Paragraph(Summary2,f2));
    	          
    	          cellc43.setHorizontalAlignment(Element.ALIGN_RIGHT);
    	          tablec4.setWidths(columnWidths);
    	          tablec4.addCell(cellc41);
    	          tablec4.addCell(cellc42);
    	          tablec4.addCell(cellc43);
    	          
    	          
    	          
    	          //document.add(paragraph); 
    	          //document.add(paragraph1);
    	         // document.setMargins(10, 10, 10, 10);
    	          document.add(table01);
    	          document.add(table02);
    	          document.add(table);
    	          document.add(table1);
    	          document.add(tableN);
    	          document.add(tableN1);
    	          document.add(table3);
    	          document.add(table4);
    	          document.add(tablec1);
    	          document.add(tablec2);
    	          document.add(tablec3);
    	          document.add(tablec4);
    	          document.close();
    	          System.out.println("done succesfully....");
    	   


			// Get system properties
			Properties props = System.getProperties();

			// Setup mail server
			props.put("mail.smtp.host", host);
			
			from="beecool.63@gmail.com";
			final String username = "beecool.63@gmail.com";//change accordingly
	        final String password = "harsha@123";//change accordingly  
	        
	      String host = "smtp.gmail.com";

	    //  Properties props = new Properties();
	      props.put("mail.smtp.auth", "true");
	      props.put("mail.smtp.starttls.enable", "true");
	      props.put("mail.smtp.host", host);
	      props.put("mail.smtp.port", "587");

	      // Get the Session object.
	      Session session = Session.getInstance(props,
	         new javax.mail.Authenticator() {
	            protected PasswordAuthentication getPasswordAuthentication() {
	               return new PasswordAuthentication(username, password);
	       }
	         });
			
			
			
		
			 //Get session for server
			//Session session = Session.getDefaultInstance(props, null);

			// Define message
			MimeMessage message = new MimeMessage(session);
			System.out.println("message is "+message);
			

			// Set the from address	
			message.setFrom(new InternetAddress(from));
			System.out.println("from is "+from);
			System.out.println("to is "+to);
			String to="jagadeesh@betabulls.com";
			// Set the to address
			message.addRecipient(Message.RecipientType.TO, new InternetAddress(to));
			System.out.println("to is "+to);
			
			// Set the subject
			message.setSubject(subject);	
			System.out.println("subject is "+subject);
			
			// Set the content
			//message.setDescription(body);	
			// message.setContent(body, "text/html");
			// Send message
			//System.out.println("body is "+body);
		//	Transport.send(message);
			BodyPart messageBodyPart = new MimeBodyPart();
			messageBodyPart.setText(body);
			messageBodyPart.setContent(body, "text/html");
		   
		       // Create the message part
		       BodyPart messageBodyPart1 = new MimeBodyPart();


		       // Create a multipar message
		       Multipart multipart = new MimeMultipart();

		     

		       // Part two is attachment
		       //messageBodyPart = new MimeBodyPart();
		       String filename = invoiceNumber+".pdf";
		       DataSource source = new FileDataSource(path+invoiceNumber+".pdf");
		       messageBodyPart1.setDataHandler(new DataHandler(source));
		      messageBodyPart1.setFileName(filename);
		      multipart.addBodyPart(messageBodyPart);
		       multipart.addBodyPart(messageBodyPart1);

		       // Send the complete message parts
		       message.setContent(multipart);
		      
		       // Send message
		       Transport.send(message);
		       System.out.println("mail sent...");
			
    	      } catch (MessagingException e) {
    	          throw new RuntimeException(e);
    	       }
    	      File file= new File(path+invoiceNumber+".pdf");//"D:/pdfmail/hello.pdf"
    	      file.delete();
    	      System.out.println("file deleted...");
    	      
    	      }
	public void setBody(String temp){
		body = temp;
	}
	public void setFrom(String temp){
		from = temp;
	}
	public void setSubject(String temp){
		subject = temp;
	}
	public void setTo(String temp){
		to = temp;
	}
	public void setEmailType(int temp){
		emailType = temp;
	}
	public void setEmailType(String temp){
		emailType = Integer.parseInt(temp);
	}	
	public void setSiteHostId(int temp){
		siteHostId = temp;
	}
	public void setEmailFromId(int temp){
		emailFromId = temp;
	}	
	public void setEmailFromId(String temp){
		emailFromId = Integer.parseInt(temp);
	}	
	public void setEmailToId(int temp){
		emailToId = temp;
	}
	public void setEmailToId(String temp){
		emailToId = Integer.parseInt(temp);
	}
	
	public void setResponseToEmailId(int temp){
		responseToEmailId = temp;
	}
	public void setResponseToEmailId(String temp){
		responseToEmailId = Integer.parseInt(temp);
	}		
	
	public void setJobId(int temp){
		jobId = temp;
	}
	public void setJobId(String temp){
		setJobId(Integer.parseInt(temp));
	}		
	
			
	public void setSiteHostId(String temp){
		siteHostId = Integer.parseInt(temp);
	}	
	
	public int getEmailId(){
		return emailId;
	}
}

