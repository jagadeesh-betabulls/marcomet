

/**********************************************************************
Description:	This class will present Product Lines and Products
				in a summary format



History:
	Date		Author			Description
	----		------			-----------
	8/1/01		Ed Cimafonte	Get information for a product line summary page


**********************************************************************/
package com.marcomet.products;
import com.marcomet.jdbc.*;
import com.marcomet.commonprocesses.*;
import java.util.*;
import java.sql.*;

import javax.servlet.http.*;




public class ProductLineSummaryBean {
	
	private int productId = 0;
	private int prodLineId = 0;	
	private String topProdLineId = "";
	private int prodlinecount = 0;
	private String editableFlag="";		
	private String productName = "";
	private String productLineManager="";
	private String productSmallPicurl = "";
	private String productLineName = "Product Line not found.";
	private String summary = "";
	private StringBuffer tablestring = new StringBuffer("");
	private StringBuffer summaryTablestring = new StringBuffer("");	
	private StringBuffer shortTablestring = new StringBuffer("");			
	private String description = "";
	private String productFeatures = "";
	private String productDemoFile = "";	
	private String productSpecsTable = "";	
	private String productSpecDiagramPicUrl = "";	
	private String siteHostRoot="";	
	private String selectProductsSQL = "";
	private	String selectProductLineSQL = "";
	private	String selectProductLinesSQL = "";
	private String lastProdLine="";
	private String lastProdId="";
	private String editPLButtonLeft="<a href=\"/products/product_line_form.jsp?productLineId=";
	private String editPLButtonRight="\" onMouseOut=\"MM_swapImgRestore()\" onMouseOver=\"MM_swapImage('edit','','/images/buttons/editoverold.gif',1)\"><img name=\"edit\" border=\"0\" src=\"/images/buttons/editold.gif\" width=\"34\" height=\"21\"></a>";
	private String editPButtonLeft="<a href=\"/products/product_form.jsp?productId=";
	private String editPButtonRight="\" onMouseOut=\"MM_swapImgRestore()\" onMouseOver=\"MM_swapImage('edit','','/images/buttons/editoverold.gif',1)\"><img name=\"edit\" border=\"0\" src=\"/images/buttons/editold.gif\" width=\"34\" height=\"21\"></a>";
		


	public ProductLineSummaryBean(){}
	
	protected void finalize() {
		
	}

	public String getProductLineName(){
		if(productLineName != null){
			return productLineName;
		}else{
			return "";
		}
	}
	
	public String getProductLineDescription(){
		if(summary != null){
			return summary;
		}else{
			return "";
		}
	}
	
	public String getProductLineManagerId(){
		if(productLineManager != null){
			return productLineManager;
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

	public StringBuffer getSummaryTable(){
		if(tablestring != null){
			return tablestring;
		}else{
			return tablestring.append("");
		}
	}
	
	public StringBuffer getShortSummaryTable(){
		if(summaryTablestring != null){
			return summaryTablestring;
		}else{
			return summaryTablestring.append("");
		}
	}
	
	public StringBuffer getShortSummaryWithProdsTable(){
		if(shortTablestring != null){
			return shortTablestring;
		}else{
			return shortTablestring.append("");
		}
	}		
		

	
	public void setEditFlag(String temp){
		editableFlag = temp;	
	}
	
	public String getEditFlag() throws Exception{
		if(editableFlag != null){
			return editableFlag;
		}else{
			return "false";
		}
	}	
	
	public int getProdLineId() {
		return prodLineId;
	}
	
	public void setProductLineId(int temp) throws Exception {
			prodLineId=temp;
			setProductLineInfo();			
		}		

	public void setProductLineId(String temp) throws Exception {
		try {
			setProductLineId(Integer.parseInt(temp));
		}catch(NumberFormatException npe) {
		}
	
	}
	
	public String getTopProdLineId() {
		return ((topProdLineId==null)?"":topProdLineId);
	}	
	public void setTopProdLineId(String temp) throws Exception{
		topProdLineId = temp;
	}
		
	
	
	public void setSiteHostRoot(String temp) throws Exception{
		siteHostRoot = temp;		
	}
	
	
	private void populateProdLines(Connection conn, String tempId) throws Exception {
	
		if (lastProdId.equals(tempId)){	  //if sending in a repetitive id, to avoid endless loop
			return;
		}else{
			lastProdId=tempId;
		}
		ProcessProductLine pPl = new ProcessProductLine();
		ResultSet rspl;					
		ResultSet rs;	
		PreparedStatement selectProducts;
		PreparedStatement selectProdLine;
			
		selectProdLine = conn.prepareStatement(selectProductLinesSQL);
		selectProdLine.setString(1,tempId);
		rspl = selectProdLine.executeQuery();
		while(rspl.next()){
			tablestring.append("<tr><td colspan='6' class=SubProductLineTitle height='2'>"+	lastProdLine);
			summaryTablestring.append("<tr><td colspan='6' class=SubProductLineTitle height='2'>"+	lastProdLine);
			shortTablestring.append("<tr><td colspan='6' class=SubProductLineTitle height='2'>"+	lastProdLine);
			
			if (editableFlag.toUpperCase().equals("TRUE")){
				tablestring.append(editPLButtonLeft+rspl.getInt("pr.id")+ editPLButtonRight);
				summaryTablestring.append(editPLButtonLeft+rspl.getInt("pr.id")+ editPLButtonRight);				
				shortTablestring.append(editPLButtonLeft+rspl.getInt("pr.id")+ editPLButtonRight);				
				String tempTopId=pPl.getTopId(rspl.getString("pr.id"));
				if(tempTopId!=null && tempTopId.equals("0")){
					tablestring.append("<a href=\"/products/product_specs.jsp?productLineId="+rspl.getString("pr.id")+"\" onMouseOut=\"MM_swapImgRestore()\" onMouseOver=\"MM_swapImage('editspecs','','/images/buttons/editspecsover.gif',1)\"><img name=\"editspecs\" border=\"0\" src=\"/images/buttons/editspecs.gif\" width=\"110\" height=\"20\"></a>");
					summaryTablestring.append("<a href=\"/products/product_specs.jsp?productLineId="+rspl.getString("pr.id")+"\" onMouseOut=\"MM_swapImgRestore()\" onMouseOver=\"MM_swapImage('editspecs','','/images/buttons/editspecsover.gif',1)\"><img name=\"editspecs\" border=\"0\" src=\"/images/buttons/editspecs.gif\" width=\"110\" height=\"20\"></a>");					
					shortTablestring.append("<a href=\"/products/product_specs.jsp?productLineId="+rspl.getString("pr.id")+"\" onMouseOut=\"MM_swapImgRestore()\" onMouseOver=\"MM_swapImage('editspecs','','/images/buttons/editspecsover.gif',1)\"><img name=\"editspecs\" border=\"0\" src=\"/images/buttons/editspecs.gif\" width=\"110\" height=\"20\"></a>");					
				}				
			}
			
			tablestring.append(rspl.getString("prod_line_name")+((editableFlag.equals("true"))?"<br>Status:"+rspl.getString("value"):"")+"</td></tr>");
			summaryTablestring.append("<a href=\"/products/productline_summary.jsp?productLineId="+rspl.getString("pr.id")+"\" class=\"mastbutton\">"+rspl.getString("prod_line_name")+((editableFlag.equals("true"))?"<br>Status:"+rspl.getString("value"):"")+"</a></td></tr>");
			shortTablestring.append("<a href=\"/products/productline_summary.jsp?productLineId="+rspl.getString("pr.id")+"\" class=\"mastbutton\">"+rspl.getString("prod_line_name")+((editableFlag.equals("true"))?"<br>Status:"+rspl.getString("value"):"")+"</a></td></tr>");
			//get any products associated with this product line and output their table
			lastProdLine="<i>"+rspl.getString("prod_line_name")+ ": </i>";
			populateProdTable(conn, rspl.getString("pr.id"));
			lastProdLine="";	
		}
	}
	
	private void populateProdTable(Connection conn, String tempId) throws Exception {
	
		ResultSet rspl;					
		ResultSet rs;
		PreparedStatement selectProducts;
		PreparedStatement selectProdLine;
				
		selectProducts = conn.prepareStatement(selectProductsSQL);
		selectProducts.setString(1,tempId);		
		rs = selectProducts.executeQuery();
		tablestring.append("<tr><td>");
		while (rs.next()){	
			prodlinecount+=1;
			if (prodlinecount==6){
				tablestring.append("</td></tr><tr><td>");
				prodlinecount=1;
			}	
			shortTablestring.append("</td></tr><tr><td>");						
			tablestring.append("<table width=154 border='1' cellspacing='10' cellpadding='2' align='left'><tr><td colspan='2' class='prodSumProductName' height='21'>");
			shortTablestring.append("<table width=154 border='1' cellspacing='10' cellpadding='2' align='left'><tr><td colspan='2' class='prodSumProductName' height='21'>");
			if (!rs.getString("template").equals("NA")){
				tablestring.append("<a href='/products/"+rs.getString("template")+"?productId="+rs.getString("pr.id")+"' target='main' class='prodSumProductName'>");
				shortTablestring.append("<a href='/products/"+rs.getString("template")+"?productId="+rs.getString("pr.id")+"' target='main' class='prodSumProductName'>");
			}else{
				tablestring.append("<a href=\"#\">");
				shortTablestring.append("<a href=\"#\">");				
			}
			if (editableFlag.equals("true")){
				tablestring.append(editPButtonLeft+rs.getInt("pr.id")+ editPButtonRight);
				shortTablestring.append(editPButtonLeft+rs.getInt("pr.id")+ editPButtonRight);				
			}			
			tablestring.append(rs.getString("prod_name")+"</a>"+((editableFlag.equals("true"))?"<br>Status:"+rs.getString("value"):"")+"</td></tr><tr ><td colspan='2' class='productimage' height='127'>");
			shortTablestring.append(rs.getString("prod_name")+"</a>"+((editableFlag.equals("true"))?"<br>Status:"+rs.getString("value"):"")+"</td></tr>");
			
			if (!rs.getString("template").equals("NA")){
				tablestring.append("<a href='/products/"+rs.getString("template")+"?productId="+rs.getString("pr.id")+"' target='main' class='prodSumProductName'>");
			}else{
				tablestring.append("<a href=\"#\" class='prodSumProductName'>");
			}
			tablestring.append("<img src=\""+siteHostRoot+"/fileuploads/product_images/"+rs.getString("small_picurl")+"\" width='144' height='144' border='0'></a></td></tr><tr><td colspan='2' height='135' valign='top' class='prodSumproductSummary'>");
			tablestring.append(rs.getString("summary")+"</td></tr><tr><td colspan='2' height='5' class='prodSumProductLinks' align='center'>");
			if ( rs.getString("show_sample_request").equals("1") )	{
				tablestring.append("<a href='/files/useremailform.jsp?productId="+rs.getString("pr.id")+"&emailType=4' class='prodSumProductLinks'>Request Sample</a><br>");		 	 			 
			}			
			if ( rs.getString("show_drivers").equals("1") )	{
				tablestring.append("<a href='/files/support_page.jsp?relatedTable=products&relatedId="+rs.getString("pr.id")+"&type=product_driver' class='prodSumProductLinks'>Download Drivers</a><br>");		
			}
			if ( rs.getString("show_manuals").equals("1") )	{		
				tablestring.append("<a href='/files/support_page.jsp?relatedTable=products&relatedId="+rs.getString("pr.id")+"&type=product_manual' class='prodSumProductLinks'>Product Manual</a><br>");
			}
			if ( rs.getString("show_support_request").equals("1") )	{
				tablestring.append("<a href='/files/useremailform.jsp?productId="+rs.getString("pr.id")+"&emailType=2' class='prodSumProductLinks'>Request Support</a><br>");		 	 			 
			}
			tablestring.append("&nbsp;</td></tr></table>");	
			shortTablestring.append("&nbsp;</td></tr></table>");						
		}
		populateProdLines(conn,tempId);
		tablestring.append("</td></tr>");
		shortTablestring.append("</td></tr>");		
		prodlinecount=0;
	}
	
	
	private void setProductLineInfo()throws Exception{

		Connection conn = null; 

		try {			
			conn = DBConnect.getConnection();
				
			ResultSet rspl;					
			ResultSet rs;		

			PreparedStatement selectProducts;
			PreparedStatement selectProdLine;
			
			selectProductsSQL = "select * from products pr,lu_product_status lu where prod_line_id=? and lu.id=pr.status_id";
			if (!editableFlag.equals("true")){
				selectProductsSQL+=" and value=\"Release\"  ";
			}
			selectProductsSQL+=" order by prod_name";
			
			selectProductLineSQL = "select * from product_lines pr,lu_product_status lu where pr.id=? and lu.id=pr.status_id";
			if (!editableFlag.equals("true")){
				selectProductLineSQL+=" and value=\"Release\"  ";
			}
			selectProductLineSQL+=" order by pr.sequence,pr.prod_line_name";	
			
			selectProductLinesSQL = "select * from product_lines pr,lu_product_status lu where prod_line_id=? and lu.id=pr.status_id";
			if (!editableFlag.equals("true")){
				selectProductLinesSQL+=" and value=\"Release\"  ";
			}
			selectProductLinesSQL+=" order by pr.sequence,pr.prod_line_name";			
			
			
			//get Product Line Info
			selectProdLine = conn.prepareStatement(selectProductLineSQL);
			selectProdLine.setInt(1,prodLineId);
			rspl = selectProdLine.executeQuery();
			if(rspl.next()){
				productLineName = rspl.getString("prod_line_name");
				productLineManager = rspl.getString("prod_manager_id");
				summary = rspl.getString("description");
				setTopProdLineId(rspl.getString("top_level_prod_line_id"));					
				//get any products associated with this product line and output their table
				selectProducts = conn.prepareStatement(selectProductsSQL);
				selectProducts.setInt(1,prodLineId);		
				rs = selectProducts.executeQuery();
				tablestring.append("<tr><td>");	
				shortTablestring.append("<tr><td>");					
				while (rs.next()){	
					prodlinecount+=1;
					if (prodlinecount==6){
						tablestring.append("</td></tr><tr><td>");
						summaryTablestring.append("</td></tr><tr><td>");	
						shortTablestring.append("</td></tr><tr><td>");												
						prodlinecount=1;
					}							
					tablestring.append("<table width=154 border='1' cellspacing='10' cellpadding='2' align='left'><tr><td colspan='2' class='prodSumProductName' height='21'>");
					shortTablestring.append("<table width=154 border='1' cellspacing='10' cellpadding='2' align='left'><tr><td colspan='2' class='prodSumProductName' height='21'>");					
					if (!rs.getString("template").equals("NA")){
						tablestring.append("<a href='/products/"+rs.getString("template")+"?productId="+rs.getString("pr.id")+"' target='main' class='prodSumProductName'>");
						shortTablestring.append("<a href='/products/"+rs.getString("template")+"?productId="+rs.getString("pr.id")+"' target='main' class='prodSumProductName'>");
					}else{
						tablestring.append("<a href=\"#\">");
						shortTablestring.append("<a href=\"#\">");						
					}
					if (editableFlag.equals("true")){
						tablestring.append(editPButtonLeft+rs.getInt("pr.id")+ editPButtonRight);
						shortTablestring.append(editPButtonLeft+rs.getInt("pr.id")+ editPButtonRight);						
					}		
					tablestring.append(rs.getString("prod_name")+"</a>"+((editableFlag.equals("true"))?"<br>Status:"+rs.getString("value"):"")+"</td></tr><tr ><td colspan='2' class='productimage' height='127'>");
					shortTablestring.append(rs.getString("prod_name")+"</a>"+((editableFlag.equals("true"))?"<br>Status:"+rs.getString("value"):"")+"</td></tr>");
							
					if (!rs.getString("template").equals("NA")){
						tablestring.append("<a href='/products/"+rs.getString("template")+"?productId="+rs.getString("pr.id")+"' target='main' class='prodSumProductName'>");
					}else{
						tablestring.append("<a href=\"#\" class='prodSumProductName'>");
					}
					tablestring.append("<img src='"+siteHostRoot+"/fileuploads/product_images/"+rs.getString("small_picurl")+"' width='144' height='144' border='0'></a></td></tr><tr><td colspan='2' height='135' valign='top' class='prodSumproductSummary'>");
					tablestring.append(rs.getString("summary")+"</td></tr><tr><td colspan='2' height='5' class='prodSumProductLinks' align='center'>");
					if ( rs.getString("show_sample_request").equals("1") )	{
						tablestring.append("<a href='/files/useremailform.jsp?productId="+rs.getString("pr.id")+"&emailType=4' class='prodSumProductLinks'>Request Sample</a><br>");		 	 			 
					}			
					if ( rs.getString("show_drivers").equals("1") )	{
						tablestring.append("<a href='/files/support_page.jsp?relatedTable=products&relatedId="+rs.getString("pr.id")+"&type=product_driver' class='prodSumProductLinks'>Download Drivers</a><br>");		
					}
					if ( rs.getString("show_manuals").equals("1") )	{		
						tablestring.append("<a href='/files/support_page.jsp?relatedTable=products&relatedId="+rs.getString("pr.id")+"&type=product_manual' class='prodSumProductLinks'>Product Manual</a><br>");
					}
					if ( rs.getString("show_support_request").equals("1") )	{
						tablestring.append("<a href='/files/useremailform.jsp?productId="+rs.getString("pr.id")+"&emailType=2' class='prodSumProductLinks'>Request Support</a><br>");		 	 			 
					}
					tablestring.append("&nbsp;</td></tr></table>");
					shortTablestring.append("&nbsp;</td></tr></table>");					
				}
				tablestring.append("</td></tr>");
				shortTablestring.append("</td></tr>");				
				prodlinecount=0;				

				//cycle through any product lines associated with this product line	
				populateProdLines(conn, rspl.getString("pr.id"));
												
			}
		}finally{
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}			
	}
	
	
	
}