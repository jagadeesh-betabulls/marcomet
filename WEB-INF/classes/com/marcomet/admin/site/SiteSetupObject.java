/**********************************************************************
Description:	This class will hold/retrieve site information

History:
	Date		Author			Description
	----		------			-----------
	10/26/01	Thomas Dietrich		Created

**********************************************************************/

package com.marcomet.admin.site;

import com.marcomet.jdbc.*;
import java.sql.*;

public class SiteSetupObject{

	private int siteHostId;
	private String innerFrameSetHeight;
	private String outerFrameSetHeight;

	public SiteSetupObject(String siteHostId)
	throws SQLException{
		setSiteHostId(siteHostId);
		loadValues();
	}

	public final void setSiteHostId(String temp){
		this.siteHostId = Integer.parseInt(temp);
	}	
	
	public final void setSiteHostId(int temp){
		this.siteHostId = temp;
	}

	public final String getOuterFrameSetHeight(){
		return outerFrameSetHeight;
	}
	
	public final String getInnerFrameSetHeight(){
		return innerFrameSetHeight;
	}			
	
	private final void loadValues()
	throws SQLException{
		String sqlCompanyInfo = 
			"SELECT inner_frame_set_height,outer_frame_set_height FROM site_hosts WHERE id = ?";
			
		

		Connection conn = null;
		
		try{
			
			conn = DBConnect.getConnection();
		
			//get company info from companies table
			PreparedStatement siteSetupInfo = conn.prepareStatement(sqlCompanyInfo);
			siteSetupInfo.setInt(1, siteHostId);
			ResultSet rsInfo = siteSetupInfo.executeQuery();
			
			if(rsInfo.next()){
				innerFrameSetHeight = rsInfo.getString("inner_frame_set_height");
				outerFrameSetHeight = rsInfo.getString("outer_frame_set_height");
			}	
		
		} catch (Exception x) {
			throw new SQLException(x.getMessage());
		}finally{
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}
	
	}	
	 	



}