/**********************************************************************
Description:	This class will be used to perform actions on Products
**********************************************************************/

package com.marcomet.commonprocesses;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

import com.marcomet.jdbc.DBConnect;

public class ProcessProduct{

	//variables
	private int id;
	private	int prodLineId = 0;
	private	int	prodCompanyId = 0;
	private	int	statusId = 1;	
	private	String prodFeatures = "";
	private	String prodSmallPicURL = "";
	private	String prodFullPicURL = "";	
	private	String prodSpecDiagramPicURL = "";
	private	String prodDemoURL = "";
	private	String prodPrintURL = "";		
	private	String description = "";
	private	String summary = "";	
	private	String prodName = "";
	private	String prodLineName = "";	
	private int sendSample=0;
	private int sendLiterature=1;
	private String productSpecsTable="";
	private String application="";
	private String template="";
	private int showManuals=0;
	private int showDrivers=0;	
	private int showSampleRequest=0;		
	private int showSupportRequest=0;	


	
	
	public ProcessProduct(){
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
	
	public final int getProdId(){
		return id;
	}
	
	public final int getSendSample(){
		return sendSample;
	}
	public final void setSendSample(int temp){
		sendSample = temp;	
	}
	public final void setSendSample(String temp){
		setSendSample(Integer.parseInt( ((temp==null)?"0":temp)));
	}
	
	public final int getSendLiterature(){
		return sendLiterature;
	}
	public final void setSendLiterature(int temp){
		sendLiterature = temp;	
	}
	public final void setSendLiterature(String temp){
		setSendLiterature(Integer.parseInt( ((temp==null)?"0":temp)));
	}
	
	public final int getShowDrivers(){
		return showDrivers;
	}
	public final void setShowDrivers(int temp){
		showDrivers = temp;	
	}
	public final void setShowDrivers(String temp){
		setShowDrivers(Integer.parseInt( ((temp==null)?"0":temp)));
	}
	
	public final int getShowManuals(){
		return showManuals;
	}
	public final void setShowManuals(int temp){
		showManuals = temp;	
	}
	public final void setShowManuals(String temp){
		setShowManuals(Integer.parseInt( ((temp==null)?"0":temp)));
	}	
	
	public final int getShowSupportRequest(){
		return showSupportRequest;
	}
	public final void setShowSupportRequest(int temp){
		showSupportRequest = temp;	
	}
	public final void setShowSupportRequest(String temp){
		setShowSupportRequest(Integer.parseInt( ((temp==null)?"0":temp)));
	}

	public final int getShowSampleRequest(){
		return showSampleRequest;
	}
	public final void setShowSampleRequest(int temp){
		showSampleRequest = temp;	
	}
	public final void setShowSampleRequest(String temp){
		setShowSampleRequest(Integer.parseInt( ((temp==null)?"0":temp)));
	}

	public final void setProdCompanyId(int temp){
		prodCompanyId = temp;	
	}
	public final void setProdCompanyId(String temp){
		setProdCompanyId(Integer.parseInt(temp));
	}
	public final int getProdCompanyId(){
		return prodCompanyId;
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
	
	
	public final void setProdLineId(int temp){
		prodLineId = temp;	
	}
	public final void setProdLineId(String temp){
		setProdLineId(Integer.parseInt(temp));
	}
	public final int getProdLineId(){
		return prodLineId;
	}	
		

	public final void setProdFeatures(String temp){
		prodFeatures = temp;	
	}
	public final String getProdFeatures(){
		return prodFeatures;
	}
	
	public final void setTemplate(String temp){
		template = temp;	
	}
	public final String getTemplate(){
		return template;
	}
	
	public final void setApplication(String temp){
		application = temp;	
	}
	public final String getApplication(){
		return ((application==null)?"":application);
	}
	
	public final void setProdSmallPicURL(String temp){
		prodSmallPicURL = temp;	
	}
	public final String getProdSmallPicURL(){
		return prodSmallPicURL;
	}
	public final void setProdFullPicURL(String temp){
		prodFullPicURL = temp;	
	}
	public final String getProdFullPicURL(){
		return prodFullPicURL;
	}	
	public final void setProdSpecDiagramPicURL(String temp){
		prodSpecDiagramPicURL = temp;	
	}
	public final String getProdSpecDiagramPicURL(){
		return prodSpecDiagramPicURL;
	}
	public final void setProdDemoURL(String temp){
		prodDemoURL = temp;	
	}
	public final String getProdDemoURL(){
		return prodDemoURL;
	}
	public final void setProdPrintURL(String temp){
		prodPrintURL = temp;	
	}
	public final String getProdPrintURL(){
		return prodPrintURL;
	}
	
	public final String getSpecsTable(){
		return productSpecsTable;
	}
		
		
	public final void setDescription(String temp){
		description = temp;	
	}
	public final String getDescription(){
		return description;
	}
	public final void setSummary(String temp){
		summary = temp;	
	}
	public final String getSummary(){
		return ((summary==null)?"":summary);
	}	
	
	public final void setProdName(String temp){
		prodName = temp;	
	}
	public final String getProdName(){
		return prodName;
	}
	
	public final void setProdLineName(String temp){
		prodLineName = temp;	
	}
	public final String getProdLineName(){
		return prodLineName;
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
		String newProductId="";
		Statement qs = null;
		Connection conn = null; 

		try {			
			conn = DBConnect.getConnection();
			qs = conn.createStatement();
			//lock table
			qs.execute("LOCK TABLES products WRITE");	
			ResultSet rs = qs.executeQuery("select (IF( max(id) IS NULL, 0, max(id))+1)   as id from products");
			if (rs.next()){
				newProductId=rs.getString("id");			
			}
			String insertSQL = "INSERT INTO products (id,prod_line_id,company_id,product_features,summary,detailed_description,small_picurl,full_picurl,demo_url,print_file_url,spec_diagram_picurl,prod_name,status_id,send_sample,send_literature,application,template,show_manuals,show_drivers,show_support_request,show_sample_request) ";
			insertSQL+=" VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
			PreparedStatement insertProducts = conn.prepareStatement(insertSQL);
			int x=1;
			insertProducts.setInt(x++,Integer.parseInt(newProductId));			
			insertProducts.setInt(x++,getProdLineId());
			insertProducts.setInt(x++,getProdCompanyId());
			insertProducts.setString(x++,getProdFeatures());
			insertProducts.setString(x++,getSummary());
			insertProducts.setString(x++,getDescription());
			insertProducts.setString(x++,getProdSmallPicURL());
			insertProducts.setString(x++,getProdFullPicURL());
			insertProducts.setString(x++,getProdDemoURL());
			insertProducts.setString(x++,getProdPrintURL());
			insertProducts.setString(x++,getProdSpecDiagramPicURL());
			insertProducts.setString(x++,getProdName());
			insertProducts.setInt(x++,getStatusId());
			insertProducts.setInt(x++,getSendSample());
			insertProducts.setInt(x++,getSendLiterature());		
			insertProducts.setString(x++,getApplication());	
			insertProducts.setString(x++,getTemplate());
			insertProducts.setInt(x++,getShowManuals());
			insertProducts.setInt(x++,getShowDrivers());
			insertProducts.setInt(x++,getShowSupportRequest());
			insertProducts.setInt(x++,getShowSampleRequest());																											
			insertProducts.execute();
			//update(3,"detailed_description",insertSQL);
		}finally {
			try { qs.execute("UNLOCK TABLES"); } catch ( Exception x) { qs = null; }
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}		
		setId(newProductId);
		return;
	}	

	//try to get connection sharing going	
//	public int insert(Connection tempConn) throws SQLException, Exception{
//		conn = tempConn;
//		int i = insert();
//		conn = null;
//		return i;		
	
	public final void update(String column, String value)throws SQLException, Exception{
		Statement qs = null;
		Connection conn = null; 

		try {			
			conn = DBConnect.getConnection();
			qs = conn.createStatement();
			String sql = "update products set " + column + " = \'" + value + "\' where id = " + getId();
			qs.execute(sql);
		} catch(SQLException e){
			throw new SQLException("update, " + e.getMessage());
		}finally {
			try { qs.close(); } catch ( Exception x) { qs = null; }
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
			String sql = "update products set " + column + " = \'" + value + "\' where id = " + getId();	
			qs.execute(sql);	
		} catch(Exception e){
			throw new SQLException("update, " + e.getMessage());
		}finally {
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
			String sql = "select * from products where id= " + id;
			ResultSet rs = qs.executeQuery(sql);
			if (rs.next()){		
				description = rs.getString("detailed_description");
				summary = rs.getString("summary");			
				prodName = rs.getString("prod_name");
				prodLineId = rs.getInt("prod_line_id");
				prodCompanyId = rs.getInt("company_id");
				statusId = rs.getInt("status_id");				
				prodFeatures = rs.getString("product_features");	
				prodDemoURL = rs.getString("demo_url");
				prodPrintURL = rs.getString("print_file_url");				
				prodSpecDiagramPicURL = rs.getString("spec_diagram_picurl");	
				prodFullPicURL = rs.getString("full_picurl");	
				prodSmallPicURL = rs.getString("small_picurl");	
				sendSample = rs.getInt("send_sample");
				sendLiterature = rs.getInt("send_literature");	
				application = rs.getString("application");	
				template = rs.getString("template");									
				showDrivers=rs.getInt("show_drivers");
				showManuals=rs.getInt("show_manuals");
				showSupportRequest=rs.getInt("show_support_request");
				showSampleRequest=rs.getInt("show_sample_request");												
				String selectProductLineSQL = "select * from product_lines where id = ?";
				String selectProductSpecsSQL = "select ps.prod_spec_name, lu.prod_spec_value from product_specs ps  left join product_spec_values psv  on  ps.id=psv.prod_spec_id and psv.product_id=?  left join lu_product_spec_values lu on psv.prod_spec_value_id=lu.id   where ps.prod_line_id= ?";
				
				PreparedStatement selectProdLine = conn.prepareStatement(selectProductLineSQL);
				selectProdLine.setInt(1,prodLineId);
				rs = selectProdLine.executeQuery();
				int topProdLineId=0;
				if(rs.next()){
					 prodLineName = rs.getString("prod_line_name");	
					 topProdLineId = ((rs.getInt("top_level_prod_line_id")==0)?rs.getInt("id"):rs.getInt("top_level_prod_line_id"));	
						 		 
				}
	
				//get Product Specs -- Need to use the parent product line's id -put in an array
				PreparedStatement selectProdSpecs = conn.prepareStatement(selectProductSpecsSQL);
				selectProdSpecs.setInt(1,id);
				selectProdSpecs.setInt(2,topProdLineId);				
				rs = selectProdSpecs.executeQuery();
	
				while (rs.next()){
					if(rs.getString("prod_spec_value")!=null){
						productSpecsTable +="<tr><td class='specTableCellsLabel'>"+rs.getString("prod_spec_name")+"</td>";		 							
						productSpecsTable +="<td class='specTableCells'>"+rs.getString("prod_spec_value")+"</td></tr>";		 		 
					}
				}
				
				
												
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
		
			
	
	public final String getProductSpecsTable() throws SQLException{
					
		String productSpecsTable = "";
		Connection conn = null; 

		try {			
			conn = DBConnect.getConnection();
			int topProdLineId = 0;
/*rs*/		String selectProductSpecsSQL = "select ps.id,ps.prod_spec_name, lu.id as luId,lu.prod_spec_value from product_specs ps  left join product_spec_values psv  on  ps.id=psv.prod_spec_id and psv.product_id=?  left join lu_product_spec_values lu on psv.prod_spec_value_id=lu.id   where ps.prod_line_id= ?";		
/*rs2*/		String selectProductSpecValuesSQL = "select distinct  lu.id, lu.prod_spec_value value from product_specs ps  left join product_spec_values psv  on  ps.id=psv.prod_spec_id  left join lu_product_spec_values lu on psv.prod_spec_value_id=lu.id where  ps.id=?";		
			String selectProductLineSQL = "select * from product_lines where id = ?";
			//get Product Line Info
			PreparedStatement selectProdLine = conn.prepareStatement(selectProductLineSQL);

			selectProdLine.setInt(1,getProdLineId());
			ResultSet rs2=selectProdLine.executeQuery();
			if (rs2.next()){
				prodLineName=rs2.getString("prod_line_name");
			}
			ResultSet rs = selectProdLine.executeQuery();
			if(rs.next()){
				 String tempstr=rs.getString("top_level_prod_line_id");
				 topProdLineId=( (tempstr==null || tempstr.equals(""))?0:((tempstr.equals("0")&&getProdLineId()!=0)?getProdLineId():Integer.parseInt(tempstr)) );			 
			}

			//get Product Specs -- Need to use the parent product line's id -put in an array
			PreparedStatement selectProdSpecs = conn.prepareStatement(selectProductSpecsSQL);
			selectProdSpecs.setInt(1,getId());
			selectProdSpecs.setInt(2,topProdLineId);
				
			rs = selectProdSpecs.executeQuery();
		
			int x=0;
			while (rs.next()){
				PreparedStatement selectProdSpecValues = conn.prepareStatement(selectProductSpecValuesSQL);
				selectProdSpecValues.setInt(1,rs.getInt("id"));
				rs2 = selectProdSpecValues.executeQuery();		
				productSpecsTable +="<tr><td class='specTableCellsLabel'>"+rs.getString("prod_spec_name")+"</td>";		 			
			//create the drop-down table for this spec
				productSpecsTable +="<td class='specTableCells'><select name=\"productSpecValue"+x+"\" >";
				productSpecsTable +="<OPTION value=\"0\" selected >-Select-</OPTION>\">";			
				while (rs2.next()) {			
					productSpecsTable +="<OPTION value=\"";
					productSpecsTable +=rs2.getString("id");
					productSpecsTable +="\"";
					String tempstring=((rs.getString("luId")==null)?"":rs.getString("luId"));
					if(rs2.getString("id")!=null && rs2.getString("id").equals(tempstring)){
						productSpecsTable +=" selected ";
					}	
					productSpecsTable +=">";
					String tempStr=((rs2.getString("value")==null)?"":((rs2.getString("value").length()<90)?rs2.getString("value"):rs2.getString("value").substring(0,90)+"...") );	
					productSpecsTable +=(tempStr)+"</OPTION>\">";			

				}
				productSpecsTable +="</select>";	
				productSpecsTable +="</td><td class='yellowButtonBox'><a href=\"javascript:setval("+x+",3);\" class=yellowButton>Copy&gt;</a></td><td class='specTableCells'><input name=\"productSpecValueEntry"+x+"\" type=\"text\" size=\"50\" max=\"30\" value=\"\">";
				productSpecsTable +="<input name=\"specvalueid"+(x)+"\" type=\"hidden\"  value=\""+rs.getString("id")+"\"></td></tr>";		 
				x++;
			}
		} catch (Exception x) {
			throw new SQLException(x.getMessage());		
		} finally {
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}
		
		return productSpecsTable;
	}
	
	protected void finalize() {
		
	}
}
