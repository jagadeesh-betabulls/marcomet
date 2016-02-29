package com.marcomet.products;

/**********************************************************************
Description:	This class will dynamicly look up Product Information



History:
	Date		Author			Description
	----		------			-----------
	8/1/01		Ed Cimafonte	Get information regarding a specific product and its specs


**********************************************************************/

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import com.marcomet.jdbc.DBConnect;


public class ProductBean {
	
	private int productId = 0;
	private int prodLineId = 0;	
	private int topProdLineId = 0;		
	private String productName = "";
	private String productFullPicurl = "";
	private String productLineName = "";
	private String summary = "";
	private String description = "";
	private String productFeatures = "";
	private String productDemoFile = "";
	private String productPrintFile = "";		
	private String productSpecsTable = "";	
	private String productSpecDiagramPicUrl = "";		
		

	
	public ProductBean(){}
	
	protected void finalize() {
		
	}

	public String getProductName(){
		if(productName != null){
			return productName;
		}else{
			return "";
		}
	}
	public String getProductFullPicurl(){
		if(productFullPicurl != null){
			return productFullPicurl;
		}else{
			return "";
		}
	}
	public String getProductLineName(){
		if(productLineName != null){
			return productLineName;
		}else{
			return "";
		}
	}
	public String getProductSummary(){
		if(summary != null){
			return summary;
		}else{
			return "";
		}
	}
	public String getProductDescription(){
		if(description != null){
			return description;
		}else{
			return "";
		}
	}
	public String getProductFeatures(){
		if(productFeatures != null){
			return productFeatures;
		}else{
			return "";
		}
	}
	public String getProductDemoFile(){
		if(productDemoFile != null){
			return productDemoFile;
		}else{
			return "";
		}
	}
	
	public String getProductPrintFile(){
		if(productPrintFile != null){
			return productPrintFile;
		}else{
			return "";
		}
	}
		
	public String getSpecsTable(){
		if(productSpecsTable != null){
			return productSpecsTable;
		}else{
			return "";
		}
	}
	
	public String getProductSpecDiagramPicUrl(){
		if(productSpecDiagramPicUrl != null){
			return productSpecDiagramPicUrl;
		}else{
			return "";
		}
	}	

				

	public int getProdLineId() {
		return prodLineId;
	}
	

	public void setProductId(int temp) throws Exception{
		productId = temp;
		setProductInfo();		
	}
	
	public void setProductId(String temp) throws Exception {
		try {
			setProductId(Integer.parseInt(temp));
		}catch(NumberFormatException npe) {
		}
	
	}



	private void setProductInfo()throws Exception{
		Connection conn = null; 

		try {			
			conn = DBConnect.getConnection();
			ResultSet rs;


			PreparedStatement selectProduct;
			PreparedStatement selectProdLine;		
			PreparedStatement selectProdSpecs;
	

			String selectProductSQL = "select * from products where id = ?";
			String selectProductLineSQL = "select * from product_lines where id = ?";
			String selectProductSpecsSQL = "select ps.prod_spec_name, lu.prod_spec_value from product_specs ps  left join product_spec_values psv  on  ps.id=psv.prod_spec_id and psv.product_id=?  left join lu_product_spec_values lu on psv.prod_spec_value_id=lu.id   where ps.prod_line_id= ?";
			
			//get Product info
			selectProduct = conn.prepareStatement(selectProductSQL);
			selectProduct.clearParameters();
			selectProduct.setInt(1,productId);		
			rs = selectProduct.executeQuery();

			if(rs.next()){	
				 prodLineId = rs.getInt("prod_line_id");	
				 productName = rs.getString("prod_name");
				 productFullPicurl = rs.getString("full_picurl");
				 summary = rs.getString("summary");
				 description = rs.getString("detailed_description");
				 productFeatures = rs.getString("product_features");
				 productDemoFile = rs.getString("demo_url");
				 productPrintFile = rs.getString("print_file_url");
				 productSpecDiagramPicUrl = rs.getString("spec_diagram_picurl");			 

			}

			//get Product Line Info
			selectProdLine = conn.prepareStatement(selectProductLineSQL);
			selectProdLine.setInt(1,prodLineId);
			rs = selectProdLine.executeQuery();

			if(rs.next()){
				 productLineName = rs.getString("prod_line_name");	
				 topProdLineId = ((rs.getInt("top_level_prod_line_id")==0)?rs.getInt("id"):rs.getInt("top_level_prod_line_id"));	
					 		 
			}

			//get Product Specs -- Need to use the parent product line's id -put in an array
			selectProdSpecs = conn.prepareStatement(selectProductSpecsSQL);
			selectProdSpecs.setInt(1,productId);
			selectProdSpecs.setInt(2,topProdLineId);				
			rs = selectProdSpecs.executeQuery();

			while (rs.next()){
				if(rs.getString("prod_spec_value")!=null){
					productSpecsTable +="<tr><td class='specTableCellsLabel'>"+rs.getString("prod_spec_name")+"</td>";		 							
					productSpecsTable +="<td class='specTableCells'>"+rs.getString("prod_spec_value")+"</td></tr>";		 		 
				}
			}
		}finally{
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}
		
	}
}

