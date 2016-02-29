package com.marcomet.commonprocesses;

/**********************************************************************
Description:	This class manages processes related to insertion orders for media
**********************************************************************/

import java.sql.*;
import java.util.Hashtable;
import javax.servlet.http.*;
import com.marcomet.files.MultipartRequest;
import com.marcomet.jdbc.*;
import com.marcomet.workflow.actions.*;

public class ProcessInsertions {
	private String related="";
	private String subject="";
	private String body="";
	private String creationDate="";
	private String recipient_email1="";
	private int recipient_id1=0;
	private String recipient_email2="";
	private int recipient_id2=0;

	public void createAlerts() throws Exception {

		Connection conn = null;
		
			conn = DBConnect.getConnection();
			Statement st = conn.createStatement();	
			Statement st2 = conn.createStatement();	
			Statement st3 = conn.createStatement();		
			
// PROCESS TICKLER ALERTS
			//Find all insertions that have a Materials Close Date of 30 days or less from current date
			//and that have not had an alert issued previously

			ResultSet rsJ=st.executeQuery("select i.* from insertions i left join tickler_alerts ta on related=i.io_number and related_table='insertions' and (alert_type='Ad Production 30 days' or alert_type='Ad Production 15 days') where ta.id is null and DATEDIFF(if (i.material_close_date='1899-12-31', on_sale_date-40,i.material_close_date),curdate())<31 AND i.on_sale_date>curdate() and plan_status<>'cancelled' ");
			while(rsJ.next()){
				//create the insertion tickler message and populate the tickler_alerts
				try{
					int i=0;
					String insertTA="insert into tickler_alerts ( related, related_table, subject, body, recipient_email1,recipient_id1,recipient_email2,recipient_id2,alert_type,creation_date) values (?, 'insertions', ?, ?, ?,?,?,?,'Ad Production 30 days',Now())";
					PreparedStatement updateTA = conn.prepareStatement(insertTA);
					
					updateTA.setString(i++, rsJ.getString("io_number"));
					updateTA.setString(i++, "Ad Production Needed: 30 days or less until Due Date");
					updateTA.setString(i++, body);
					updateTA.setString(i++, recipient_email1);
					updateTA.setInt(i++, recipient_id1);
					updateTA.setString(i++, recipient_email2);
					updateTA.setInt(i++, recipient_id2);
					updateTA.executeUpdate();
					updateTA.close();
					
					//Insert an email to be sent from the system into the email_sent_histories table

				} catch (Exception ex) {
					try { conn.close(); } catch ( Exception x) { conn = null; }
					throw new Exception("ProcessInsertionTicklers:processTicklerAlerts " + ex.getMessage());
				} 
			}
			
			//Find all insertions that have a Materials Close Date of 15 days or less from current date
			//and that have not had a 15 day alert issued previously

			rsJ=st.executeQuery("select i.* from insertions i left join tickler_alerts ta on related=i.io_number and related_table='insertions' and alert_type='Ad Production 15 days' where ta.id is null and DATEDIFF(if (i.material_close_date='1899-12-31', on_sale_date-40,i.material_close_date),curdate())<31 AND i.on_sale_date>curdate() and plan_status<>'cancelled' ");
			while(rsJ.next()){
				//create the insertion tickler message and populate the tickler_alerts
				try{
					int i=0;
					String insertTA="insert into tickler_alerts ( related, related_table, subject, body, recipient_email1,recipient_id1,recipient_email2,recipient_id2,alert_type,creation_date) values (?, 'insertions', ?, ?, ?,?,?,?,'Ad Production 15 days',Now())";
					PreparedStatement updateTA = conn.prepareStatement(insertTA);
					
					updateTA.setString(i++, rsJ.getString("io_number"));
					updateTA.setString(i++, "Ad Production Needed: 30 days or less until Due Date");
					updateTA.setString(i++, body);
					updateTA.setString(i++, recipient_email1);
					updateTA.setInt(i++, recipient_id1);
					updateTA.setString(i++, recipient_email2);
					updateTA.setInt(i++, recipient_id2);
					updateTA.executeUpdate();
					updateTA.close();

				} catch (Exception ex) {
					try { conn.close(); } catch ( Exception x) { conn = null; }
					throw new Exception("ProcessInsertionTicklers:processTicklerAlerts " + ex.getMessage());
				} 
			}

		}
	
	
	
}