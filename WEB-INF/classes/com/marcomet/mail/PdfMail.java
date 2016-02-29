package com.marcomet.mail;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.nio.file.Files;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.Properties;

import javax.activation.DataHandler;
import javax.activation.DataSource;
import javax.activation.FileDataSource;
import javax.mail.BodyPart;
import javax.mail.Message;
import javax.mail.MessagingException;
import javax.mail.Multipart;
import javax.mail.PasswordAuthentication;
import javax.mail.Session;
import javax.mail.Transport;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeBodyPart;
import javax.mail.internet.MimeMessage;
import javax.mail.internet.MimeMultipart;
import javax.servlet.http.HttpUtils;

import com.itextpdf.text.BaseColor;
import com.itextpdf.text.Chunk;
import com.itextpdf.text.Document;
import com.itextpdf.text.DocumentException;
import com.itextpdf.text.Element;
import com.itextpdf.text.Font;
import com.itextpdf.text.Font.FontFamily;
import com.itextpdf.text.FontFactory;
import com.itextpdf.text.PageSize;
import com.itextpdf.text.Paragraph;
import com.itextpdf.text.html.WebColors;
import com.itextpdf.text.pdf.BaseFont;
import com.itextpdf.text.pdf.CMYKColor;
import com.itextpdf.text.pdf.FontSelector;
import com.itextpdf.text.pdf.PdfPCell;
import com.itextpdf.text.pdf.PdfPTable;
import com.itextpdf.text.pdf.PdfWriter;
import com.marcomet.jdbc.DBConnect;
import com.marcomet.environment.SiteHostSettings;
import com.marcomet.jdbc.*;
import com.marcomet.tools.StringTool;

public class PdfMail  {
	//public void pdfMail(String jobId) throws ClassNotFoundException, SQLException, Exception {
    public static void main(String[] args) throws ClassNotFoundException, SQLException, Throwable {
      // Recipient's email ID needs to be mentioned.
    	int jobId=1943;
    	String invoiceId ="";
    	String purchaseAmount="";
    	String shippingAmount="";
    	double salesTax=0;
    	String creationDate="";
    	String vendorId="";
    	String billName="";
    	String billAddress="";
    	String billCity="";
    	String billState="";
    	String billZip="";
    	String billFax="";
    	String billToContactId="";
    	String id="";
    	String jobName="";
    	String jobAmount="";
    	double shippingPrice=0;
    	String invoiceNumber="";
    	double salestaxPrice=0;
    	double optionsPrice=0;
    	double changesPrice=0;
    	double basePrice =0;
    	double discountPrice=0;
    	double jobTotal=0;
    	double invoicesPrice=0;
    	double BilledToDate=0;
    	double JobBalanceUnbilled=0;
    	double invoicePurchaseAmount=0;
    	double invoiceShipping=0;
    	double CurrentDue=0;
    	double invoiceAmount=0;
    	double payments=0;
    	double balance_due=0;
    	String toEmail="";
    	String fullName="";
    	String CompanyName="";
    	String billtoaddress1="";
    	String billtoaddress2="";
    	String billtocity="";
    	String billtostate="";
    	String billtozip="";
    	String shiptoaddress1="";
    	String shiptoaddress2="";
    	String shiptocity="";
    	String shiptostate="";
    	String shiptozip="";
    	String phnareacode="";
    	String phnareacode1="";
    	String phnareacode2="";
    	String ctid="";
    	String faxareacode1=null;
    	String faxareacode2=null;
    	String faxareacode3=null;
    	
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
    		String query1 ="select * from brandhq_dev.ar_invoices where invoice_number ="+invoiceId;
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
    		
   			
   			String sql4 = "Select concat(ct.firstname,\" \",ct.lastname) fullname, ct.id ctid, c.company_name companyname,l.address1 billtoaddress1,l.address2 billtoaddress2,l.city billtocity,s.value billtostate,l.zip billtozip ,shp.address1 shiptoaddress1,shp.address2 shiptoaddress2,shp.city shiptocity,sshp.value shiptostate,shp.zip shiptozip, ph.areacode phnareacode, ph.phone1 phnnum1, ph.phone2 phnnum2, fx.areacode faxareacode, fx.phone1 faxnum1, fx.phone2 faxnum2 ";
   			sql4+=" from companies c,locations l,locations shp,lu_abreviated_states s,lu_abreviated_states sshp,contacts ct ";
   			sql4+=" left join phones ph on ph.contactid=ct.id and ph.phonetype=1 ";
   			
   			sql4+=" left join phones fx on fx.contactid=ct.id and fx.phonetype=2 ";
   			sql4+=" where c.id=ct.companyid and ct.id="+jobId+" and l.contactid=ct.id  and l.locationtypeid=2 and s.id=l.state and shp.contactid=ct.id  and shp.locationtypeid=1 and sshp.id=shp.state";
   			
   			
   			ResultSet rsCustomerInfo = st.executeQuery(sql4);
   			if(rsCustomerInfo.next()){
   			
   				
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
      // Assuming you are sending email through relay.jangosmtp.net
        
        String to = "sekhar@betabulls.com";

        // Sender's email ID needs to be mentioned
        String from = "beecool.63@gmail.com";
        final String username = "beecool.63@gmail.com";//change accordingly
        final String password = "harsha@123";//change accordingly  
        
      String host = "smtp.gmail.com";

      Properties props = new Properties();
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

      Document document=new Document();
        
      String path=System.getProperty("user.dir");
      System.out.println(path);
     
     
      try {
         
         
         
         
        
    	  PdfWriter.getInstance(document, new FileOutputStream(path+"/invoice.pdf"));
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
          PdfPCell cellN1 = new PdfPCell(new Paragraph("Customer #",f3));
          cellN1.setHorizontalAlignment(Element.ALIGN_CENTER);
          cellN1.setBackgroundColor(myColor);
          nestedTable.addCell(cellN1);
          //nestedTable.addCell(new Paragraph("Invoive number"));
          PdfPCell cellN2 = new PdfPCell(new Paragraph("Invoive number",f3));
          cellN2.setHorizontalAlignment(Element.ALIGN_CENTER);
          cellN2.setBackgroundColor(myColor);
          nestedTable.addCell(cellN2);
          //nestedTable.addCell(new Paragraph("Invoice Date"));
          PdfPCell cellN3 = new PdfPCell(new Paragraph("Invoice Date",f3));
          cellN3.setHorizontalAlignment(Element.ALIGN_CENTER);
          cellN3.setBackgroundColor(myColor);
          nestedTable.addCell(cellN3);
          //nestedTable.addCell(new Paragraph("Job Number"));
          PdfPCell cellN4 = new PdfPCell(new Paragraph("Job Number",f3));
          cellN4.setHorizontalAlignment(Element.ALIGN_CENTER);
          cellN4.setBackgroundColor(myColor);
          nestedTable.addCell(cellN4);
          //nestedTable.addCell(new Paragraph("Terms"));
          PdfPCell cellN5 = new PdfPCell(new Paragraph("Terms",f3));
          cellN5.setHorizontalAlignment(Element.ALIGN_CENTER);
          cellN5.setBackgroundColor(myColor);
          nestedTable.addCell(cellN5);
          //nestedTable.addCell(new Paragraph("Custumer po/ref"));
          PdfPCell cellN6 = new PdfPCell(new Paragraph("Custumer po/ref",f3));
          cellN6.setHorizontalAlignment(Element.ALIGN_CENTER);
          cellN6.setBackgroundColor(myColor);
          nestedTable.addCell(cellN6);
        
          PdfPTable nestedTable1 = new PdfPTable(6);
          nestedTable1.addCell(new Paragraph(id,f2));
          nestedTable1.addCell(new Paragraph(invoiceNumber,f2));
          nestedTable1.addCell(new Paragraph(creationDate,f2));
          nestedTable1.addCell(new Paragraph("781",f2));
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
          
         
         
       // Create a default MimeMessage object.
       Message message = new MimeMessage(session);
   
       // Set From: header field of the header.
       message.setFrom(new InternetAddress(from));
   
       // Set To: header field of the header.
       message.setRecipients(Message.RecipientType.TO,
               InternetAddress.parse(to));
   
       // Set Subject: header field
       message.setSubject("Invoice");
   
       // Create the message part
       BodyPart messageBodyPart = new MimeBodyPart();

       // Now set the actual message
       messageBodyPart.setText("This is invoice from marketsinn");

       // Create a multipar message
       Multipart multipart = new MimeMultipart();

       // Set text message part
       multipart.addBodyPart(messageBodyPart);

       // Part two is attachment
       messageBodyPart = new MimeBodyPart();
       String filename = path+"/invoice.pdf";
       DataSource source = new FileDataSource(filename);
       messageBodyPart.setDataHandler(new DataHandler(source));
       messageBodyPart.setFileName(filename);
       multipart.addBodyPart(messageBodyPart);

       // Send the complete message parts
       message.setContent(multipart);

       // Send message
       Transport.send(message);

       System.out.println("message Sent successfully....");

      } catch (MessagingException e) {
         throw new RuntimeException(e);
      }
     
      File file= new File(path+"/invoice.pdf");//"D:/pdfmail/hello.pdf"
      file.delete();
      System.out.println("file deleted...");
   }
}