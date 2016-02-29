/**********************************************************************
Description:	This class will be used to perform actions on Press Releases

**********************************************************************/

package com.marcomet.commonprocesses;

import com.marcomet.jdbc.DBConnect;
import com.marcomet.tools.*;

import java.sql.*;

public class ProcessPR{
	
	FormaterTool fmt= new FormaterTool();
	StringTool str=new StringTool();
	//variables
	private int id;
	private	int prProdLineId = 0;
	private	int prProdId = 0;	
	private	int	prCompanyId = 0;
	private int	prStatusId = 0;
	private String prReleaseDate = "";
	private	String prPublication = "";
	private	String prSmallPicURL = "";
	private	String prFullPicURL = "";	
	private	String prDemoURL = "";
	private	String prPrintURL = "";		
	private	String body = "";
	private	String summary = "";	
	private	String prTitle = "";	
	private int prType = 0;	
	
	public ProcessPR(){
	}

	public final void setId(int temp){
		id = temp;	
	}
	public final void setId(String temp){
		setId(Integer.parseInt(temp));
	}
	public final int getId(){
		return id;
	}
	
	public final void setPrType(int temp){
		prType = temp;	
	}
	public final void setPrType(String temp){
		setPrType(Integer.parseInt(temp));
	}
	public final int getPrType(){
		return prType;
	}
	

	public final void setPrProdLineId(int temp){
		prProdLineId = temp;	
	}
	public final void setPrProdLineId(String temp){
		setPrProdLineId(Integer.parseInt(temp));
	}
	public final int getPrProdLineId(){
		return prProdLineId;
	}

	public final void setPrProdId(int temp){
		prProdId = temp;	
	}
	public final void setPrProdId(String temp){
		setPrProdId(Integer.parseInt(temp));
	}
	public final int getPrProdId(){
		return prProdId;
	}	
	
	public final void setPrCompanyId(int temp){
		prCompanyId = temp;	
	}
	public final void setPrCompanyId(String temp){
		setPrCompanyId(Integer.parseInt(temp));
	}
	public final int getPrCompanyId(){
		return prCompanyId;
	}
	
	
	public final void setPrStatusId(int temp){
		prStatusId = temp;	
	}
	public final void setPrStatusId(String temp){
		setPrStatusId(Integer.parseInt(temp));
	}
	public final int getPrStatusId(){
		if (prStatusId==0){
			return 1;
		}else{
			return prStatusId;
		}		
	}	

	public final void setPrReleaseDate(String temp){
		prReleaseDate = temp;	
	}
	public final String getPrReleaseDate(){
		return prReleaseDate;
	}

	public final void setPrPublication(String temp){
		prPublication = temp;	
	}
	public final String getPrPublication(){
		if (prPublication==null){
			return "";
		}else{
			return prPublication;
		}
	}	

	public final void setPrSmallPicURL(String temp){
		prSmallPicURL = temp;	
	}
	public final String getPrSmallPicURL(){
		if (prSmallPicURL==null){
			return "";
		}else{
			return prSmallPicURL;
		}		
	}
	public final void setPrFullPicURL(String temp){
		prFullPicURL = temp;	
	}
	public final String getPrFullPicURL(){
		if (prFullPicURL==null){
			return "";
		}else{
			return prFullPicURL;
		}		
	}	

	public final void setPrDemoURL(String temp){
		prDemoURL = temp;	
	}
	public final String getPrDemoURL(){
		if (prDemoURL==null){
			return "";
		}else{
			return prDemoURL;
		}		
	}
	public final void setPrPrintURL(String temp){
		prPrintURL = temp;			
	}
	public final String getPrPrintURL(){
		if (prPrintURL==null){
			return "";
		}else{
			return prPrintURL;
		}		
	}
		
		
	public final void setBody(String temp){
		body = temp;	
	}
	public final String getBody(){
		if (body==null){
			return "";
		}else{
			return body;
		}			
	}
	public final void setSummary(String temp){
		summary = temp;	
	}
	public final String getSummary(){
		if (summary==null){
			return "";
		}else{
			return summary;
		}		
	}	
	
	public final void setPrTitle(String temp){
		prTitle = temp;	
	}
	public final String getPrTitle(){
		if (prTitle==null){
			return "";
		}else{
			return prTitle;
		}			
	}
	

	
	public final void insert() throws SQLException, Exception{
		Connection conn = null; 

		try {			
			conn = DBConnect.getConnection();
			String insertSQL = "insert into press_releases ";
			insertSQL+="(prod_line_id,product_id,company_id,publication,title,summary,body,";
			insertSQL+="release_date,status_id,small_picurl,full_picurl,print_file_url,demo_url,pr_type)"; 
			insertSQL+=" VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
			PreparedStatement insert = conn.prepareStatement(insertSQL);
			int x=1;
			insert.setInt(x++,getPrProdLineId());
			insert.setInt(x++,getPrProdId());	
			insert.setInt(x++,getPrCompanyId());						
			insert.setString(x++,getPrPublication());
			insert.setString(x++,getPrTitle());
			insert.setString(x++,getSummary());
			insert.setString(x++,getBody());
			insert.setString(x++,str.mysqlFormatDate(getPrReleaseDate()));
			insert.setInt(x++,getPrStatusId());
			insert.setString(x++,getPrSmallPicURL());
			insert.setString(x++,getPrFullPicURL());				
			insert.setString(x++,getPrPrintURL());	
			insert.setString(x++,getPrDemoURL());	
			insert.setInt(x++,getPrType());										
			insert.execute();
		}finally {
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}		
		return;
	}	
	
	
	public final void update(String column, String value)throws SQLException, Exception{
		Statement qs = null;
		Connection conn = null; 

		try {			
			conn = DBConnect.getConnection();
			qs = conn.createStatement();
			String sql = "update pructs set " + column + " = \'" + value + "\' where id = " + getId();
			qs.execute(sql);
		} catch(SQLException e){
			throw new SQLException("update, " + e.getMessage());
		} catch (Exception x) {
			throw new SQLException(x.getMessage());
		} finally {
			try { qs.execute("UNLOCK TABLES"); } catch ( Exception x) { qs = null; }
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}
	}
	
	public final void update(int id, String column, String value) throws SQLException, Exception{
		setId(id);
		try{
			update(column,value);
		} catch(SQLException e){
			throw new SQLException("update, " + e.getMessage());
		}
	
	}
			
	
	public final void update(String column, int value)throws SQLException{
		Statement qs = null;
		Connection conn = null; 

		try {			
			conn = DBConnect.getConnection();
			qs = conn.createStatement();
			String sql = "update press_releases set " + column + " = \'" + value + "\' where id = " + getId();	
			qs.execute(sql);	
		} catch (Exception x) {
			throw new SQLException(x.getMessage());
		} finally {
			try { qs.close(); } catch ( Exception x) { qs = null; }
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}
	}
	
	public final void update(int id, String column, int value) throws SQLException{
		setId(id);
		update(column,value);	
	}
	
	public final void select(int key)throws SQLException{

		Statement qs = null;
		Connection conn = null; 

		try {			
			conn = DBConnect.getConnection();
			qs = conn.createStatement();
			setId(key);
			
			String sql = "select * from press_releases where id= " + id;
			ResultSet rs = qs.executeQuery(sql);
			if (rs.next()){		
				body = rs.getString("body");
				summary = rs.getString("summary");			
				prTitle = rs.getString("title");
				prStatusId = rs.getInt("status_id");
				prPublication = rs.getString("publication");	
				prReleaseDate=	rs.getString("release_date");				
	//			try{
	//				prReleaseDate = fmt.formatMysqlDate(rs.getString("release_date"));			
	//			}catch(Exception e){
	//			}
				prProdLineId = rs.getInt("prod_line_id");
				prCompanyId = rs.getInt("company_id");
				prStatusId = rs.getInt("status_id");	
				prDemoURL = rs.getString("demo_url");
				prPrintURL = rs.getString("print_file_url");					
				prFullPicURL = rs.getString("full_picurl");	
				prSmallPicURL = rs.getString("small_picurl");
				prType = rs.getInt("pr_type");			
			
			}
		} catch (Exception x) {
			throw new SQLException(x.getMessage());
		} finally {
			try { qs.close(); } catch ( Exception x) { qs = null; }
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}
	}
	
	public final void select(String key) throws SQLException{
		setId(key);
		select(id);	
	}		
		
			
	
	protected void finalize() {
		
	}
}
