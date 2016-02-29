package com.marcomet.mail;

/**********************************************************************
Description:	this class handles deliveriing emails via the command line.
				the intentions is run this class via cron job so that the
				submission of forms take place a little quicker.
**********************************************************************/

import com.marcomet.jdbc.*;

import java.sql.*;

public class CronMailer{

public CronMailer(){
}
public static void main(String[] args) {
	//CronMailer clm = new CronMailer();
	
	Connection conn = null;
	JavaMailer1 jm = new JavaMailer1();
	String debugStr = null;
	String sql1 = "SELECT id, email_to, email_from, subject, body FROM email_sent_histories WHERE sent = '0'";
	String sql2 = "UPDATE email_sent_histories SET sent = ?, email_error = ? WHERE id = ?";	
	PreparedStatement selectEmails = null;
	PreparedStatement updateEmail = null;
	ResultSet rsEmails = null;
	try{	
		conn = DBConnectDirect.getConnection();
		selectEmails = conn.prepareStatement(sql1);
		updateEmail = conn.prepareStatement(sql2);
		String emailError = null;	
		rsEmails = selectEmails.executeQuery();
		while(rsEmails.next()){
			emailError = "";
			debugStr = rsEmails.getString("email_to") + " " + rsEmails.getString("email_from");
			jm.setTo(rsEmails.getString("email_to"));
			jm.setFrom(rsEmails.getString("email_from"));
			jm.setSubject(rsEmails.getString("subject"));
			jm.setBody(rsEmails.getString("body"));
			try{
				jm.sendEmail();
			}catch(Exception e){
				System.err.println(debugStr);
				System.err.println("Command Line Mailer failed on the send e: " + e.getMessage());
				emailError = e.getMessage();
			}	
			updateEmail.clearParameters();
			updateEmail.setString(1,new java.util.Date().toString());
			updateEmail.setString(2,emailError);
			updateEmail.setInt(3,rsEmails.getInt("id"));
			updateEmail.execute();		
		}

	}catch(SQLException sqle){
		System.err.println(debugStr);
		System.err.println("Command line mailer failed sqle: " + sqle.getMessage());
	}catch(Exception e){
		System.err.println(debugStr);
		e.printStackTrace();
	}finally{
		try{
			selectEmails.close();
			updateEmail.close();
			rsEmails.close();
			conn.close();
		}catch(Exception e){
		}finally{
			selectEmails = null;
			updateEmail=null;
			rsEmails=null;
			conn = null;		
		}
	}
//	System.out.println("CronMailer complete" + new java.util.Date().toString());
	System.exit(0);	
	}
}
