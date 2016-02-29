/**********************************************************************
Description:	Java Emailer, result of simple emailer failing to send 
				messages that can be interpetted by Microsoft products,
				outlook, outlook express, and netscape.
**********************************************************************/

package com.marcomet.mail;
import java.io.ByteArrayOutputStream;
/*betabulls*/
import java.io.ByteArrayOutputStream;
import java.io.OutputStream;
import java.util.Properties;

import javax.activation.DataHandler;
import javax.activation.DataSource;
import javax.mail.Message;
import javax.mail.PasswordAuthentication;
import javax.mail.Session;
import javax.mail.Transport;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeBodyPart;
import javax.mail.internet.MimeMessage;
import javax.mail.internet.MimeMultipart;
import javax.mail.util.ByteArrayDataSource;

import com.itextpdf.text.Chunk;
import com.itextpdf.text.Document;
import com.itextpdf.text.Paragraph;
import com.itextpdf.text.pdf.PdfWriter;
 

/*end betabulls*/









import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.Properties;
import java.util.ResourceBundle;

import javax.mail.Message;
import javax.mail.MessagingException;
import javax.mail.PasswordAuthentication;
import javax.mail.Session;
import javax.mail.Transport;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeBodyPart;
import javax.mail.internet.MimeMessage;
import javax.mail.util.ByteArrayDataSource;

import com.marcomet.jdbc.DBConnect;
//import com.marcomet.products.InvoiceDO;
import com.marcomet.sbpprocesses.GenerateInvoiceBean;
import com.marcomet.workflow.actions.SubmitNewOrder;

public class JavaMailer1{
	
	private String host = "localhost";
	private String from = "";
	private String to = "";
	private String subject ="";
	private String body = "";
	private int siteHostId = 0;	
	private int emailType = 0;	
	private int emailId=0;
	private int emailFromId=0;
	private int emailToId=0;
	private int jobId=0;	
	private int responseToEmailId=0;	
	
	public JavaMailer1(){		
	
		ResourceBundle bundle = ResourceBundle.getBundle("com.marcomet.marcomet");
		host = bundle.getString("mailrouter");
		
	}
	protected void finalize(){
	}
	
	private void recordEmail() throws Exception{
		
		Connection conn = DBConnect.getConnection();
		PreparedStatement insertEmailHistory;
		Statement qs = conn.createStatement();		
		String insertEmailHistoryText = 
			"INSERT INTO email_sent_histories(site_host_id,email_to,email_from,subject,body,sent,email_type,id,email_from_id,attachments,email_to_id,job_id,response_to_email_id) values (?,?,?,?,?,?,?,?,?,?,?,?,?)";	
		
		try{
			qs.execute("LOCK TABLES email_sent_histories WRITE");	
			ResultSet rs = qs.executeQuery("select (IF( max(id) IS NULL, 0, max(id))+1)   as id from email_sent_histories");
			if (rs.next()){
				emailId=rs.getInt("id");			
			}		
//com.marcomet.tools.MessageLogger.logMessage("before record");			
			insertEmailHistory = conn.prepareStatement(insertEmailHistoryText);
			insertEmailHistory.clearParameters();
			insertEmailHistory.setInt(1,siteHostId);		
			insertEmailHistory.setString(2,to);
			insertEmailHistory.setString(3,from);
			insertEmailHistory.setString(4,subject);
			insertEmailHistory.setString(5,body);
			//betabulls change
			insertEmailHistory.setString(6,"0");
			//end betabulls change
			insertEmailHistory.setInt(7,emailType);
			insertEmailHistory.setInt(8,emailId);
			insertEmailHistory.setInt(9,emailFromId);
			System.out.println(emailToId);
			insertEmailHistory.setString(10,"");
			insertEmailHistory.setInt(11,emailToId);
			insertEmailHistory.setInt(12,jobId);					
			insertEmailHistory.setInt(13,responseToEmailId);	
//com.marcomet.tools.MessageLogger.logMessage("before execute");			
			insertEmailHistory.execute();	
		
		}catch(SQLException sqle){
			throw new Exception("Simple Emailer failed. history failed" + sqle.getMessage());
		}finally {
			qs.execute("UNLOCK TABLES");				
			try { qs.close(); } catch ( Exception e) {}
			try { conn.close(); } catch ( Exception e) {}
		}
	}
	public void send() throws Exception{	
		recordEmail();		
	}
	public void sendEmail() throws Exception{

			// Get system properties
			Properties props = System.getProperties();

			// Setup mail server
			props.put("mail.smtp.host", "smtp.gmail.com");
			
			// Get session
			Session session = Session.getDefaultInstance(props, null);

			// Define message
			MimeMessage message = new MimeMessage(session);

			// Set the from address	
			message.setFrom(new InternetAddress(from));
				
			// Set the to address
			System.out.println("email"+to);
			to = "swethakrgs@gmail.com";
			
			message.addRecipient(Message.RecipientType.TO, new InternetAddress(to));
			
			// Set the subject
			message.setSubject(subject);	
			
			// Set the content
			message.setContent(body, "text/html");	

			// Send message
			Transport.send(message);
						
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
	/* Coded for temporarily to test the mail from local */
	/* this will be called to send the attachments */
	public void sendEmailUsingTemp(GenerateInvoiceBean invoiceBean) throws Exception{
		// Get system properties
		Properties props = System.getProperties();
		  
		  props.put("mail.smtp.host", "smtp.gmail.com");  
		  props.put("mail.smtp.socketFactory.port", "465");  
		  props.put("mail.smtp.socketFactory.class",  
		            "javax.net.ssl.SSLSocketFactory");  
		  props.put("mail.smtp.auth", "true");  
		  props.put("mail.smtp.port", "465");  
		  String content = "Invoice PDF mail";
		  String sender = "swetha@betabulls.com"; //replace this with a valid sender email address
          String recipient = "swethakrgs@gmail.com"; //replace this with a valid recipient email address

		
		// Get session
		  Session session = Session.getInstance(props,  
				   new javax.mail.Authenticator() {  
				   protected PasswordAuthentication getPasswordAuthentication() {  
				   return new PasswordAuthentication("beecool.63@gmail.com","harsha@123");//change accordingly  
				   }  
				  });  
		  ByteArrayOutputStream outputStream = null;

			
		// Set the to address
		System.out.println("email"+to);
		String to = "swethakrgs@gmail.com";
		  //compose message  
		try {           
			
			
            //construct the text body part
            MimeBodyPart textBodyPart = new MimeBodyPart();
            textBodyPart.setText(content);
            /*StringBuilder builder = new StringBuilder();
            

           
            String html = builder.toString();*/
            String invoice = "Bill To :"+invoiceBean.getFullname()+"\n"+invoiceBean.getCompanyname()+"\n"+invoiceBean.getBilltoaddress1()+
            			"\n"+invoiceBean.getBilltocity()+"\n"+invoiceBean.getBilltostate()+"\n"+invoiceBean.getBilltozip()+"\n \n Ship To :\n"+invoiceBean.getShiptoaddress1()+
            			"\n"+invoiceBean.getShiptoaddress2()+""+invoiceBean.getShiptocity()+"\n"+invoiceBean.getShiptostate()+"\n"+invoiceBean.getShiptozip()+
            			"\n"+invoiceBean.getPhnareacode()+"\n \n Customer Id :"+invoiceBean.getCustomerId()+"\n Invoice Number :"+invoiceBean.getInvoiceId()+"\n Invoice Date :"+invoiceBean.getCreateDate()+
            			"\n Job Number :"+invoiceBean.getJobId()+"\n Job Name / Description :"+invoiceBean.getJobName()+"\n Job Quantity :"+invoiceBean.getJobQty()+"\n Job Amount :"+invoiceBean.getJobBalanceUnbilled()+
            			"\n Sales Tax :"+invoiceBean.getSalestax()+"\n Job Balance Unbilled :"+invoiceBean.getJobBalanceUnbilled();
             
             
             System.out.println("in :"+invoice);
             
            outputStream = getPDFContent(invoice);
            byte[] bytes = outputStream.toByteArray();
                         
             
            //construct the pdf body part
            DataSource dataSource = new ByteArrayDataSource(bytes, "application/pdf");
            MimeBodyPart pdfBodyPart = new MimeBodyPart();
            pdfBodyPart.setDataHandler(new DataHandler(dataSource));
            pdfBodyPart.setFileName("test.pdf");
            
            //construct the mime multi part
            MimeMultipart mimeMultipart = new MimeMultipart();
            
            
            
            mimeMultipart.addBodyPart(textBodyPart);
            mimeMultipart.addBodyPart(pdfBodyPart);
             
            //create the sender/recipient addresses
            InternetAddress iaSender = new InternetAddress(sender);
            InternetAddress iaRecipient = new InternetAddress(recipient);
             
            //construct the mime message
            MimeMessage mimeMessage = new MimeMessage(session);
            mimeMessage.setSender(iaSender);
            mimeMessage.setSubject(subject);
            mimeMessage.setRecipient(Message.RecipientType.TO, iaRecipient);
            mimeMessage.setContent(mimeMultipart);
             
            //send off the email
            Transport.send(mimeMessage);
             
            System.out.println("sent from " + sender + 
                    ", to " + recipient + 
                    "; server = " + to + ", port = " + to);       
        } catch(Exception ex) {
            ex.printStackTrace();
        } finally {
            //clean off
            if(null != outputStream) {
                try { outputStream.close(); outputStream = null; }
                catch(Exception ex) { }
            }
        }
	}
     
    /**
     * Return the content of a PDF file (using iText API)
     * to the {@link OutputStream}.
     * @param outputStream {@link OutputStream}.
     * @throws Exception
     */
    public ByteArrayOutputStream getPDFContent(String invoiceNumber) throws Exception {
        //now write the PDF content to the output stream
        ByteArrayOutputStream outputStream = new ByteArrayOutputStream();

        Document document = new Document();
        PdfWriter.getInstance(document, outputStream);
         
        document.open();
         
        document.addTitle("Test PDF");
        document.addSubject("Testing email PDF");
        document.addKeywords("iText, email");
        document.addAuthor("Jee Vang");
        document.addCreator("Jee Vang");
         
        Paragraph paragraph = new Paragraph();
        paragraph.add(new Chunk(invoiceNumber));
        document.add(paragraph);
         
        document.close();
        
        return outputStream;
    }
     
    /**
     * Main method.
     * @param args No args required.
     * @throws Exception 
     */
    /*public static void main(String[] args) throws Exception {
        JavaMailer demo = new JavaMailer();
        demo.sendEmailUsingTemp();
    }*/
}
