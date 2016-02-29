package com.marcomet.mail;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.nio.file.Files;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.Date;
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

public class TestPdf  {
 //public void pdfMail( ) throws ClassNotFoundException, SQLException, Exception {
    public static void main(String[] args) throws ClassNotFoundException, SQLException, Throwable {
      // Recipient's email ID needs to be mentioned.
    	int jobId=469310;
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
    	      // salesTax			=rsJob.getString("ar_sales_tax");
    	       //creationDate		=rsJob.getString("creation_date");
    	       //modification_date
    	       creationDate		=rsJob.getString("modification_date");
    	   }
    	 
    	 //String timeStamp = new SimpleDateFormat("yyyy.MM.dd.HH.mm.ss").format(creationDate);
    	 
    	 System.out.println ("invoice id is "+invoiceId);
    	 System.out.println (purchaseAmount);
    	 System.out.println (shippingAmount);
    	 System.out.println (salesTax);
    	 System.out.println (creationDate);
    	 
    	 
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
    			
    		conn.close(); 
    		
    		String billToAddress=billName+"\n"+billAddress+"\n"+billCity+"\n"+billState+"\n"+billZip+"\n"+billFax;
    		String customerContact=billName+"\n"+billAddress+"\n"+billCity+"\n"+billState+"\n"+billZip+"\n"+billFax;
    		String shippingAddress=billName+"\n"+billAddress+"\n"+billCity+"\n"+billState+"\n"+billZip+"\n"+billFax;
    		String jobCost="Job amount"+"\n"+"Shipping"+"\n"+"Sales Tax"+"\n"+"Job Total"+"\n"+"Job billed to date"+"\n"+"Job Balance Unbilled";
    		String summery="$"+jobAmount+"\n"+"$"+shippingPrice+"\n"+"$"+salesTax+"\n"+"$"+jobTotal+"\n"+"$"+BilledToDate+"\n"+"$"+JobBalanceUnbilled;
    		
        System.out.println(billAddress);
      // Assuming you are sending email through relay.jangosmtp.net
        
        String to = "pagadalajagadeesh@gmail.com";

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
         
         
         
         
        
         PdfWriter.getInstance(document, new FileOutputStream(path+"/"+to+".pdf"));
          document.open();
         
          Font f=new Font(FontFamily.HELVETICA,15f,Font.ITALIC,BaseColor.WHITE);
          Font f1=new Font(FontFamily.HELVETICA,13f,Font.NORMAL,BaseColor.WHITE);
          Font f2=new Font(FontFamily.HELVETICA,9f,Font.NORMAL,BaseColor.BLACK);
          Font f3=new Font(FontFamily.HELVETICA,9f,Font.NORMAL,BaseColor.WHITE);
          
          
         // BaseColor myColor = WebColors.getRGBColor("#144f82");
          //BaseColor myColor = WebColors.getRGBColor("#99ccff");
          BaseColor myColor = WebColors.getRGBColor("#004284");
          BaseColor bordercolor = WebColors.getRGBColor("#ffd600");
          
          
         
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
          cell02.setBorderColor(BaseColor.BLACK);
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
          PdfPCell cell4 = new PdfPCell(new Paragraph(billToAddress,f2));
          cell4.setHorizontalAlignment(Element.ALIGN_LEFT);
          PdfPCell cell5 = new PdfPCell(new Paragraph(customerContact,f2));
          cell5.setHorizontalAlignment(Element.ALIGN_LEFT);
      
         
          PdfPTable table1 = new PdfPTable(1);
          PdfPCell cell3 = new PdfPCell(new Paragraph("Ship to",f1));
           cell3.setHorizontalAlignment(Element.ALIGN_LEFT);
           cell3.setBackgroundColor(myColor);
            PdfPCell cell6 = new PdfPCell(new Paragraph(shippingAddress,f2));
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
       String filename = path+"/"+to+".pdf";
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
     
      File file= new File(path+"/"+to+".pdf");//"D:/pdfmail/hello.pdf"
      System.out.println(path+"/"+to+".pdf");
      file.delete();
      System.out.println("file deleted...");
   }
}