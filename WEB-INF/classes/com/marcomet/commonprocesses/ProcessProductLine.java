 /**********************************************************************
Description:	This class will be used to perform actions on ProductLines
**********************************************************************/

package com.marcomet.commonprocesses;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

import com.marcomet.jdbc.DBConnect;

public class ProcessProductLine{

	//variables
	private int id;
	private	int prodLineParentId = 0;
	private	int prodLineTopParentId = 0;
	private	int	prodLineCompanyId = 0;
	private int	prodLineDivisionId = 0;
	private	int prodManagerId = 0;
	private	int sequence = 0;	
	private	int statusId = 1;	
	private	String prodLineMainFeatures = "";
	private	String prodLineMainBenefits = "";
	private String prodLineUSP="";
	private	String description = "";
	private	String prodLineName = "";	
	private	String header = "";	
	private	String footer = "";		
	private	String topLevelFlag = "";					
	private	String homepageHtml = "";		
	private	String smallPicURL = "";	
	private	String fullPicURL = "";					

	
	public ProcessProductLine(){
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
	
	public final void setSequence(int temp){
		sequence = temp;	
	}
	public final void setSequence(String temp){
		setSequence(Integer.parseInt(temp));
	}
	public final int getSequence(){
		return sequence;
	}
	
	
	public final int getProdLineId(){
		return id;
	}	
	
	public final void setProdManagerId(int temp){
		prodManagerId = temp;	
	}
	public final void setProdManagerId(String temp){
		setProdManagerId(Integer.parseInt(temp));
	}
	public final int getProdManagerId(){
		return prodManagerId;
	}
	
	public final void setStatusId(int temp){
		statusId = temp;	
	}
	public final void setStatusId(String temp){
		setStatusId(Integer.parseInt(temp));
	}
	public final int getStatusId(){
		return statusId;
	}

	public final void setProdLineDivisionId(int temp){
		prodLineDivisionId = temp;	
	}
	public final void setProdLineDivisionId(String temp){
		setProdLineDivisionId(Integer.parseInt(temp));
	}
	public final int getProdLineDivisionId(){
		return prodLineDivisionId;
	}
	
	public final void setProdLineCompanyId(int temp){
		prodLineCompanyId = temp;	
	}
	public final void setProdLineCompanyId(String temp){
		setProdLineCompanyId(Integer.parseInt(temp));
	}
	public final int getProdLineCompanyId(){
		return prodLineCompanyId;
	}
	
	public final void setProdLineTopParentId(int temp){
		prodLineTopParentId = temp;	
	}
	public final void setProdLineTopParentId(String temp){
		try {
			setProdLineTopParentId(Integer.parseInt(temp));
		}catch(Exception e){
		}		
	}
	public final int getProdLineTopParentId(){
		return prodLineTopParentId;
	}
	
	
	public final void setProdLineParentId(int temp){
		prodLineParentId = temp;	
	}
	public final void setProdLineParentId(String temp){
		setProdLineParentId(Integer.parseInt(temp));
	}
	public final int getProdLineParentId(){
		return prodLineParentId;
	}	
		

	public final void setProdLineMainFeatures(String temp){
		prodLineMainFeatures = temp;	
	}
	public final String getProdLineMainFeatures(){
		return ((prodLineMainFeatures==null)?"":prodLineMainFeatures);
	}
	
	public final void setHeader(String temp){
		header = temp;	
	}
	public final String getHeader(){
		return ((header==null)?"":header);
	}
	
	public final void setFooter(String temp){
		footer = temp;	
	}
	public final String getFooter(){
		return ((footer==null)?"":footer);
	}
	
	public final void setSmallPicURL(String temp){
		smallPicURL = temp;	
	}
	public final String getSmallPicURL(){
		return ((smallPicURL==null)?"":smallPicURL);
	}
	
	public final void setFullPicURL(String temp){
		fullPicURL = temp;	
	}
	public final String getFullPicURL(){
		return ((fullPicURL==null)?"":fullPicURL);
	}
	


	public final void setProdLineMainBenefits(String temp){
		prodLineMainBenefits = temp;	
	}
	public final String getProdLineMainBenefits(){
		return ((prodLineMainBenefits==null)?"":prodLineMainBenefits);
	}
	
	public final void setProdLineUSP(String temp){
		prodLineUSP = temp;	
	}
	public final String getProdLineUSP(){
		return ((prodLineUSP==null)?"":prodLineUSP);
	}
	
	public final void setDescription(String temp){
		description = temp;	
	}
	public final String getDescription(){
		return description;
	}
	
	public final void setProdLineName(String temp){
		prodLineName = temp;	
	}
	public final String getProdLineName(){
		return prodLineName;
	}
	
	public final void setTopLevelFlag(String temp){
		topLevelFlag = temp;	
	}
	public final String getTopLevelFlag(){
		return ((topLevelFlag==null)?"":topLevelFlag);
	}
	
	public final void setHomepageHtml(String temp){
		homepageHtml = temp;	
	}
	public final String getHomepageHtml(){
		return ((homepageHtml==null)?"":homepageHtml);
	}
	
	
	public final String getTopId(String temp) throws SQLException, Exception{
		Statement qs = null;
		Connection conn = null; 

		try {			
			conn = DBConnect.getConnection();
			qs = conn.createStatement();
			ResultSet rs = qs.executeQuery("Select * from product_lines where id="+temp);	
			if (rs.next()){
				if ((rs.getString("top_level_prod_line_id")==null) || (rs.getString("top_level_prod_line_id")).equals("")){
					return (temp);
				}
				return rs.getString("top_level_prod_line_id");
			}else{
				return "";
			}
		}finally {
			try { qs.close(); } catch ( Exception x) { qs = null; }
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}
	}
	
	public final String getCompanyId(String temp) throws SQLException, Exception{
		Statement qs = null;
		Connection conn = null; 

		try {			
			conn = DBConnect.getConnection();
			qs = conn.createStatement();
			ResultSet rs = qs.executeQuery("Select * from site_hosts where id="+temp);	
			if (rs.next())
			{
				return rs.getInt("company_id")+"";
			}else{
				return "";
			}
		}finally {
			try { qs.close(); } catch ( Exception x) { qs = null; }
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}
	}
	
	public final void insert() throws SQLException, Exception{

		Statement qs = null;
		Connection conn = null; 

		try {			
			conn = DBConnect.getConnection();
			qs = conn.createStatement();
			ResultSet rs = qs.executeQuery("select (IF( max(id) IS NULL, 0, max(id))+1) as id from product_lines");
			String newProductId="";
			if (rs.next()){
				newProductId=rs.getString("id");			
			}		
			String sql= "insert into product_lines (prod_line_id,top_level_prod_line_id,company_id,division_id,prod_manager_id,mainfeatures,mainbenefits,USP,description,prod_line_name,status_id,id,sequence,top_level_flag,homepage_html,full_picurl,small_picurl) ";
			sql+=" values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";		
			String insertHeaderSQL = "insert into product_line_headers_footers (company_id,prod_line_id,header,footer) values (?,?,?,?)";
			PreparedStatement selectProducts = conn.prepareStatement(sql);
			PreparedStatement insertHeader = conn.prepareStatement(insertHeaderSQL);			
			selectProducts.setInt(1,getProdLineParentId());				
			selectProducts.setInt(2,getProdLineTopParentId());
			selectProducts.setInt(3,getProdLineCompanyId());		
			selectProducts.setInt(4,getProdLineDivisionId());
			selectProducts.setInt(5,getProdManagerId());
			selectProducts.setString(6,getProdLineMainFeatures());
			selectProducts.setString(7,getProdLineMainBenefits());
			selectProducts.setString(8,getProdLineUSP());	
			selectProducts.setString(9,getDescription());	
			selectProducts.setString(10,getProdLineName());	
			selectProducts.setInt(11,getStatusId());	
			selectProducts.setString(12,newProductId);	
			selectProducts.setInt(13,getSequence());
			selectProducts.setString(14,getTopLevelFlag());
			selectProducts.setString(15,getHomepageHtml());
			selectProducts.setString(16,getFullPicURL());
			selectProducts.setString(17,getSmallPicURL());																								
			selectProducts.execute();	
			insertHeader.setInt(1,getProdLineCompanyId());
			insertHeader.setString(2,newProductId);	
			insertHeader.setString(3,getHeader());	
			insertHeader.setString(4,getFooter());									
			insertHeader.execute();
				
		} catch(SQLException e){
			throw new SQLException("insert product line, " + e.getMessage());
		}finally {
			try { qs.close(); } catch ( Exception x) { qs = null; }
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}
		
		return;// getId();
	}	


	public final void update() throws SQLException, Exception{

		Connection conn = null; 

		try {			
			conn = DBConnect.getConnection();
			String sql= "update product_lines set prod_line_id=?,top_level_prod_line_id=?,";
			sql+="company_id=?,division_id=?,prod_manager_id=?,mainfeatures=?,mainbenefits=?,";
			sql+="USP=?,description=?,prod_line_name=?,status_id=? where id=?";	
			PreparedStatement selectProducts = conn.prepareStatement(sql);
			selectProducts.setInt(1,getProdLineParentId());	
			selectProducts.setInt(2,getProdLineTopParentId());
			selectProducts.setInt(3,getProdLineCompanyId());
			selectProducts.setInt(4,getProdLineDivisionId());
			selectProducts.setInt(5,getProdManagerId());
			selectProducts.setString(6,getProdLineMainFeatures());
			selectProducts.setString(7,getProdLineMainBenefits());
			selectProducts.setString(8,getProdLineUSP());	
			selectProducts.setString(9,getDescription());	
			selectProducts.setString(10,getProdLineName());	
			selectProducts.setInt(11,getStatusId());	
			selectProducts.setInt(12,getId());														
			selectProducts.execute();

		}finally {
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}	
		
		return;// getId();	
	}	
	
		
	

	
	public final void select(int key)throws SQLException{
		Statement qs = null;
		Connection conn = null; 

		try {			
			conn = DBConnect.getConnection();
			qs = conn.createStatement();
			setId(key);			
			String sql = "select * from product_lines pl left join product_line_headers_footers hf on pl.id=hf.prod_line_id  where pl.id= " + id;
			ResultSet rs = qs.executeQuery(sql);
			if (rs.next()){
				description = rs.getString("description");
				prodLineName = rs.getString("prod_line_name");
				prodLineParentId = rs.getInt("pl.prod_line_id");
				prodLineTopParentId = rs.getInt("top_level_prod_line_id");
				prodLineCompanyId = rs.getInt("company_id");
				prodLineDivisionId = rs.getInt("division_id");
				prodManagerId = rs.getInt("pl.prod_manager_id");
				prodLineMainFeatures = rs.getString("mainfeatures");
				prodLineMainBenefits = rs.getString("mainbenefits");
				prodLineUSP = rs.getString("usp");
				statusId = rs.getInt("status_id");	
				header = rs.getString("header");						
				footer = rs.getString("footer");
				homepageHtml = rs.getString("homepage_html");
				topLevelFlag = rs.getString("top_level_flag");	
				smallPicURL = rs.getString("small_picurl");	
				fullPicURL = rs.getString("full_picurl");																
				sequence = rs.getInt("pl.sequence");														

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
