package com.marcomet.products;

/**********************************************************************
Description:	Enter and Edit Product Line information
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

import com.marcomet.commonprocesses.ProcessProductLine;
import com.marcomet.jdbc.DBConnect;
import com.marcomet.tools.ReturnPageContentServlet;



public class UpdateProductLine extends HttpServlet{
	//variables
	
	String errorMessage;
	int prodLineId;
	public UpdateProductLine(){
	
	}

	public void doPost(HttpServletRequest request, HttpServletResponse response)
	throws ServletException{
		
		try{
			UpdateProdLine(request); 
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
			throw new ServletException("UpdateProductLine, forward failed on an error" + ioe.getMessage());
		}
	}

	private void UpdateProdLine(HttpServletRequest request)
	throws SQLException, Exception{

		Connection conn = null; 

		try {			
			conn = DBConnect.getConnection();
			ProcessProductLine pPl = new ProcessProductLine();
			

			Statement qs = conn.createStatement();
			
		
				String sql= "update product_lines set prod_line_id=?,top_level_prod_line_id=?,";
				sql+="company_id=?,division_id=?,prod_manager_id=?,mainfeatures=?,mainbenefits=?,";
				sql+="USP=?,description=?,prod_line_name=?,status_id=?,sequence=?,top_level_flag=?,homepage_html=?,small_picurl=?,full_picurl=? where id=?";	
				String tempstr=pPl.getTopId(request.getParameter("prodLineParentId"));
				int tempTop=( (tempstr==null || tempstr.equals(""))?0:((tempstr.equals("0")&&!request.getParameter("prodLineParentId").equals("0"))?Integer.parseInt(request.getParameter("prodLineParentId")):Integer.parseInt(tempstr)) );
				PreparedStatement selectProducts = conn.prepareStatement(sql);
				selectProducts.setInt(1,Integer.parseInt(request.getParameter("prodLineParentId")));	
				selectProducts.setInt(2,tempTop);
				selectProducts.setInt(3,Integer.parseInt(request.getParameter("prodLineCompanyId")));
				selectProducts.setInt(4,0);
				selectProducts.setInt(5,Integer.parseInt(request.getParameter("prodManagerId")));
				selectProducts.setString(6,"");
				selectProducts.setString(7,"");
				selectProducts.setString(8,"");	
				selectProducts.setString(9,request.getParameter("description"));	
				selectProducts.setString(10,request.getParameter("prodLineName"));	
				selectProducts.setInt(11,Integer.parseInt(request.getParameter("statusId")));	
				selectProducts.setInt(12,Integer.parseInt(request.getParameter("sequence")));
				selectProducts.setString(13,request.getParameter("topLevelFlag"));
				selectProducts.setString(14,request.getParameter("homepageHtml"));	
				selectProducts.setString(15,request.getParameter("smallPicURL"));	
				selectProducts.setString(16,request.getParameter("fullPicURL"));												
				selectProducts.setInt(17,Integer.parseInt(request.getParameter("prodLineId")));															
				selectProducts.execute();
//check to see if there is a header/footer record associated with this product line


				ResultSet rs = qs.executeQuery("select * from product_line_headers_footers where prod_line_id="+request.getParameter("prodLineId"));
				if (rs.next()){	  //if there is then update it with new info
					String updateHeaderSQL = "update product_line_headers_footers set header=? ,footer=? where id=?";
					PreparedStatement updateHeader = conn.prepareStatement(updateHeaderSQL);							
					updateHeader.setString(1,request.getParameter("header"));	
					updateHeader.setString(2,request.getParameter("footer"));	
					updateHeader.setInt(3,rs.getInt("id"));												
					updateHeader.execute();					
				}else{	//if not, insert it
					if (request.getParameter("header")!=null && !request.getParameter("header").equals("") && request.getParameter("footer")!=null && !request.getParameter("footer").equals(""))	{
						String insertHeaderSQL = "insert into product_line_headers_footers (company_id,prod_line_id,header,footer) values (?,?,?,?)";
						PreparedStatement insertHeader = conn.prepareStatement(insertHeaderSQL);							
						insertHeader.setInt(2,Integer.parseInt(request.getParameter("prodLineId")));
						insertHeader.setInt(1,Integer.parseInt(request.getParameter("prodLineCompanyId")));
						insertHeader.setString(3,request.getParameter("header"));	
						insertHeader.setString(4,request.getParameter("footer"));									
						insertHeader.execute();
					}			
				}
			}catch(SQLException e){
				throw new ServletException("UpdateProductLine, " + e.getMessage());
			
		}finally{
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}	
	}
	
	protected void finalize() {
		
	}
	
}


