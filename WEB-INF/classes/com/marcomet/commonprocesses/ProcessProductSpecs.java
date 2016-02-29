/**********************************************************************
Description:	This class will be used to perform actions on Product Spec Templates
**********************************************************************/

package com.marcomet.commonprocesses;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

import com.marcomet.jdbc.DBConnect;

public class ProcessProductSpecs{

	//variables
	private	int prodLineId = 0;
	private String topProdLineId="";
	private int companyId=0;
	ProcessProductLine pPl = new ProcessProductLine();			

	
	public ProcessProductSpecs(){
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
	
	public final void setCompanyId(int temp){
		companyId = temp;	
	}
	public final void setCompanyId(String temp){
		setCompanyId(Integer.parseInt(temp));
	}	
	public final int getCompanyId(){
		return companyId;
	}	
	

	public final void insert(String value)throws SQLException, Exception{
		Statement qs = null;
		Connection conn = null; 

		try {			
			conn = DBConnect.getConnection();
			qs = conn.createStatement();
			String sql = "insert into product_specs (prod_line_id,prod_spec_name) values("+getProdLineId()+",\"" + value + "\")";
			qs.execute(sql);
		} catch(SQLException e){
			throw new SQLException("insert, " + e.getMessage());
		} finally {
			try { qs.close(); } catch ( Exception x) { qs = null; }
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}
	}

	public final void update(int id,String value)throws SQLException, Exception{
		Statement qs = null;
		Connection conn = null; 

		try {			
			conn = DBConnect.getConnection();
			qs = conn.createStatement();
			String sql = "update product_specs set prod_spec_name = \'" + value + "\' where id = " + id;
			qs.execute(sql);
		} catch(SQLException e){
			throw new SQLException("update, " + e.getMessage());
		} finally {
			try { qs.close(); } catch ( Exception x) { qs = null; }
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}	
	}
			
	
	public final void update(int id,int value)throws SQLException{
		Statement qs = null;
		Connection conn = null; 

		try {			
			conn = DBConnect.getConnection();
			qs = conn.createStatement();
			String sql = "update product_specs set prod_spec_name = \'" + value + "\' where id = " + id;
			qs.execute(sql);
		} catch(Exception e){
			throw new SQLException("update, " + e.getMessage());
		} finally {
			try { qs.close(); } catch ( Exception x) { qs = null; }
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}	
	}
	
	public final String getProductSpecsTable() throws SQLException{
		StringBuffer productSpecsTable = new StringBuffer();
		String selectProductSpecsSQL = "select ps.id,ps.prod_spec_name value from product_specs ps  where ps.prod_line_id= ?";		
		String selectProductSpecValuesSQL = "select distinct ps.id,ps.prod_spec_name value from product_specs ps,product_lines pl where pl.company_id=? and ps.prod_line_id=pl.id order by prod_spec_name";		
		Connection conn = null; 

		try {			
			conn = DBConnect.getConnection();
			//get Product Specs -- Need to use the parent product line's id 
			PreparedStatement selectProdSpecs = conn.prepareStatement(selectProductSpecsSQL);
			PreparedStatement selectProdSpecValues = conn.prepareStatement(selectProductSpecValuesSQL);		
			selectProdSpecs.setInt(1,getProdLineId());
			selectProdSpecValues.setInt(1,getCompanyId());						
			ResultSet rs = selectProdSpecs.executeQuery();
			ResultSet rsPSVals=selectProdSpecValues.executeQuery();
			String selectValues="";
			while (rsPSVals.next()){
				selectValues+="<OPTION value=\"";
				selectValues+=((rsPSVals.getString("value")==null)?"":rsPSVals.getString("value"));
				selectValues+="\"";
				selectValues+= ">";
				selectValues+=((rsPSVals.getString("value")==null)?"":rsPSVals.getString("value"))+"</OPTION>\">";				
			}
			int x=0;
			while (rs.next()){
				productSpecsTable.append("<tr>");		 			
			//create the drop-down table for this spec
				productSpecsTable.append("<td class='specTableCells' width=1><select name=\"productSpecValue"+x+"\" >");
				productSpecsTable.append("<OPTION value=\"0\" selected >-Select-</OPTION>\">");			
				productSpecsTable.append(selectValues);
				productSpecsTable.append("</select>");	
				productSpecsTable.append("</td><td class='yellowButtonBox'><a href=\"javascript:setval("+x+",3);\" class=yellowButton>Copy&gt;</a></td><td class='specTableCells'><input name=\"productSpecValueEntry"+x+"\" type=\"text\" size=\"50\" max=\"30\" value=\""+rs.getString("value")+"\">");
				productSpecsTable.append("<input name=\"specvalueid"+(x)+"\" type=\"hidden\"  value=\""+rs.getString("id")+"\"></td></tr>");		 
				x++;
			}
			for (int y=(x);y<=50;y++){
				productSpecsTable.append("<td class='specTableCells' width=1><select name=\"productSpecValue"+y+"\" >");
				productSpecsTable.append("<OPTION value=\"0\" selected >-Select-</OPTION>\">");	
				productSpecsTable.append(selectValues);					
				productSpecsTable.append("</select>");	
				productSpecsTable.append("</td><td class='yellowButtonBox'><a href=\"javascript:setval("+y+",3);\" class=yellowButton>Copy&gt;</a></td><td class='specTableCells'><input name=\"productSpecValueEntry"+y+"\" type=\"text\" size=\"50\" max=\"30\" value=\"\">");
				productSpecsTable.append("<input name=\"specvalueid"+(y)+"\" type=\"hidden\"  value=\"0\"></td></tr>");
			}
		} catch(Exception e){
			throw new SQLException(e.getMessage());
		} finally {			
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}	
		
		return productSpecsTable.toString();		
	}
	
	protected void finalize() {
	
	}
	
}
