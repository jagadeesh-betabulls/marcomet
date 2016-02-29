package com.marcomet.products;

/**********************************************************************
Description:	Enter and Edit Product information
**********************************************************************/

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.marcomet.jdbc.DBConnect;
import com.marcomet.tools.ReturnPageContentServlet;
import com.marcomet.tools.StringTool;



public class UpdateProduct extends HttpServlet{
	
	//variables
	String errorMessage;
	int prodLineId;
		//jdbc connections
	
	public UpdateProduct(){
	
	}

	public void doPost(HttpServletRequest request, HttpServletResponse response)
	throws ServletException{
		
		try{
			UpdateProd(request); 
		}catch(Exception e){
			errorMessage ="There was an error: " + e.getMessage();
			exitWithError(request,response);			
		}
	ReturnPageContentServlet rpcs = new ReturnPageContentServlet();
	rpcs.printNextPage(this,request,response);						
	}
	private void exitWithError(HttpServletRequest request, HttpServletResponse response)
	throws ServletException{
		
		//set error attribute
		request.setAttribute("errorMessage",errorMessage);	
		
		//goto an error page
		RequestDispatcher rd;
		rd = getServletContext().getRequestDispatcher(request.getParameter("errorPage"));
		try {
			rd.forward(request, response);	
		}catch(IOException ioe) {
			throw new ServletException("UpdateProduct, forward failed on an error" + ioe.getMessage());
		}
	}


	private void UpdateProd(HttpServletRequest request)
	throws SQLException, Exception{
		StringTool str=new StringTool();
		Connection conn = null; 

		try {			
			conn = DBConnect.getConnection();
		
				String sql= "update products set prod_line_id="+request.getParameter("prodLineId");
				sql+=", prod_name=\""+request.getParameter("prodName")+"\"";
				sql+=", company_id="+request.getParameter("prodCompanyId");
				sql+=", product_features= ?";
				sql+=", detailed_description= ?"; 		
				sql+=", summary= ? ";				
				sql+=", demo_url= ? ";
				sql+=", print_file_url= ? ";	
				sql+=", spec_diagram_picurl= ? ";
				sql+=", full_picurl= ? ";								
				sql+=", small_picurl= ? ";
				sql+=", status_id= ?, send_sample=?,send_literature=?,application=?,show_manuals=?,show_drivers=?,show_support_request=?,show_sample_request=?,template=?";			
				sql+=" where id = " + request.getParameter("prodId");		
				PreparedStatement selectProducts = conn.prepareStatement(sql);
				selectProducts.setString(1,request.getParameter("prodFeatures"));	
				selectProducts.setString(2,request.getParameter("description"));
				selectProducts.setString(3,request.getParameter("summary"));
				selectProducts.setString(4,request.getParameter("productDemoURL"));
				selectProducts.setString(5,request.getParameter("productPrintURL"));
				selectProducts.setString(6,request.getParameter("productSpecDiagramPicURL"));
				selectProducts.setString(7,request.getParameter("productFullPicURL"));
				selectProducts.setString(8,request.getParameter("productSmallPicURL"));	
				selectProducts.setString(9,request.getParameter("statusId"));
				selectProducts.setString(10,((request.getParameter("sendSample")==null || request.getParameter("sendSample").equals(""))?"0":request.getParameter("sendSample")));
				selectProducts.setString(11,((request.getParameter("sendLiterature")==null || request.getParameter("sendLiterature").equals(""))?"0":request.getParameter("sendLiterature")));	
				selectProducts.setString(12,request.getParameter("application"));
				selectProducts.setString(13,((request.getParameter("showManuals")==null || request.getParameter("showManuals").equals(""))?"0":request.getParameter("showManuals")));
				selectProducts.setString(14,((request.getParameter("showDrivers")==null || request.getParameter("showDrivers").equals(""))?"0":request.getParameter("showDrivers")));
				selectProducts.setString(15,((request.getParameter("showSupportRequest")==null || request.getParameter("showSupportRequest").equals(""))?"0":request.getParameter("showSupportRequest")));
				selectProducts.setString(16,((request.getParameter("showSampleRequest")==null || request.getParameter("showSampleRequest").equals(""))?"0":request.getParameter("showSampleRequest")));
				selectProducts.setString(17,request.getParameter("template"));																									
				selectProducts.execute();
				Statement qs = conn.createStatement();
				ResultSet rs;
				int specValueId = 0;
	//Need to cycle through all the productSpecValueXX fields: 
				int x=0;
				while (request.getParameter("productSpecValue"+(x))!=null){
					//If productSpecValueEntry has a value check to see if the value exists in the lu table
					if(request.getParameter("productSpecValueEntry"+x)!=null && !request.getParameter("productSpecValueEntry"+x).trim().equals("")){
						sql="select * from lu_product_spec_values where prod_spec_value = ?";
						PreparedStatement checkSpecs = conn.prepareStatement(sql);								
						checkSpecs.setString(1,request.getParameter("productSpecValueEntry"+x).trim());
						rs=checkSpecs.executeQuery();	
						if (rs.next()){	 //If yes, use the id of the found value as the spec valueid
							specValueId = rs.getInt("id");
						}else{ //If no, enter it into the spec value table and use the new id as the spec value id
							rs = qs.executeQuery("select max(id)+1 as id from lu_product_spec_values");
							if (rs.next()){
								specValueId = rs.getInt("id");
								sql="insert into lu_product_spec_values (id,prod_spec_value) values (?,?)";
								PreparedStatement insertSpecs = conn.prepareStatement(sql);								
								insertSpecs.setInt(1,specValueId);
								insertSpecs.setString(2,str.replaceSubstring(request.getParameter("productSpecValueEntry"+x),"°","&deg;"));
								insertSpecs.execute();
							}
						}
					}else{
						specValueId = Integer.parseInt(request.getParameter("productSpecValue"+x));
					}
					rs= qs.executeQuery("select * from product_spec_values where product_id="+request.getParameter("prodId")+" and prod_spec_id = "+request.getParameter("specvalueid"+x));
					if (rs.next() ){
						sql="update product_spec_values set prod_spec_value_id = ? where id=?";
						PreparedStatement updateSpecs = conn.prepareStatement(sql);								
						updateSpecs.setInt(1,specValueId);
						updateSpecs.setInt(2,rs.getInt("id"));
						updateSpecs.execute();						
					}else{
						rs = qs.executeQuery("select max(id)+1 as id from product_spec_values");
						if (rs.next()){						
							sql="insert into product_spec_values (id,prod_spec_id,product_id,prod_spec_value_id) values (?,?,?,?)";
							PreparedStatement insertnewSpecs = conn.prepareStatement(sql);																	
							insertnewSpecs.setInt(1,rs.getInt("id"));
							insertnewSpecs.setInt(2,Integer.parseInt(request.getParameter("specvalueid"+x)));
							insertnewSpecs.setInt(3,Integer.parseInt(request.getParameter("prodId")));	
							insertnewSpecs.setInt(4,specValueId);														
							insertnewSpecs.execute();								
						}
					}
					x++;
				}
				
		} catch(SQLException e){
			throw new SQLException("UpdateProduct, " + e.getMessage());		
		} catch (Exception x) {
			throw new SQLException(x.getMessage());
		} finally {
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}
	}
	
	protected void finalize() {
		
	}
	
}

