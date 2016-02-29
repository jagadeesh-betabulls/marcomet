/*
 * created on Aug 12, 2003
 *
 * Steve Davis
 */
package com.marcomet.workflow;

import java.sql.*;
import com.marcomet.jdbc.*;

/**
 * @author sdavis
 * 
 */
public class DomainReference {

	public static final int CONTACT_ID = 1;
	public static final int VENDOR_ID = 2;
	public static final int PROJECT_ID = 3;
	public static final int JOB_ID = 4;
	public static final int ORDER_ID = 5;
	public static final int SITE_HOST_ID = 6;
	
	
	private DomainReference() {
		super();		
	}
	
	static public String getDomainReference(String id, int idType ){
		try {
			return getDomainReference(Integer.parseInt(id), idType);
		} catch (Exception e){
			return "";
		}	
	}

	static public String getDomainReference(int id, int idType ){
		
		
		Connection conn = null;
		Statement stmt = null;
		ResultSet rs1 = null;
		String domain = null;
		
		try {
			
			conn = DBConnect.getConnection();
			stmt = conn.createStatement();
			rs1 = stmt.executeQuery(createStatementByType(id, idType));
			
			if (rs1.next())  {
				domain = rs1.getString(1);
			}
		} catch ( Exception e ) {
			System.err.println("DomainReference : getDomainReference(" + id + "," + idType + ") : ERROR : " + e.getMessage());
			e.printStackTrace();
		} finally {
			try { if ( stmt != null ) stmt.close(); } catch ( Exception e ) {}
			stmt = null;
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}	
		
		return domain;		
	}
	
	static private String createStatementByType(int id, int idType){
		
		StringBuffer sqlBuff = new StringBuffer();
						
		switch (idType ){
			
			case CONTACT_ID:
					sqlBuff.append("SELECT V.email_link from contacts C, vendors V ");
					sqlBuff.append("where C.id = " + id );
					sqlBuff.append(" and V.company_id = C.companyid");
					break;
			case VENDOR_ID:
					sqlBuff.append("SELECT V.email_link from vendors V ");
					sqlBuff.append("where V.id = " + id );					
					break;
			case PROJECT_ID:
					sqlBuff.append("SELECT S.domain_name from projects P, orders O, ");
					sqlBuff.append("site_hosts S where P.id = " + id );
					sqlBuff.append(" and O.id = P.order_id and S.id = O.site_host_id");
					break;
			case JOB_ID:
					sqlBuff.append("SELECT S.domain_name from jobs J, projects P, orders O, ");
					sqlBuff.append("site_hosts S where J.id = " + id );
					sqlBuff.append(" and P.id = J.project_id and O.id = P.order_id and S.id = O.site_host_id");
					break;
			case ORDER_ID:
					sqlBuff.append("SELECT S.domain_name from orders O, ");
					sqlBuff.append("site_hosts S where O.id = " + id );
					sqlBuff.append(" and S.id = O.site_host_id");
					break;
			case SITE_HOST_ID:
					sqlBuff.append("SELECT S.domain_name from site_hosts S where S.id = " + id );
					break;			
		}
		
		
		return sqlBuff.toString(); 
	}
	

}

