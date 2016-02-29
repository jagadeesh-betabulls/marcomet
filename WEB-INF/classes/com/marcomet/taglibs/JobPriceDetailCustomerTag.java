package com.marcomet.taglibs;

/**********************************************************************
Description:	This class will print a table listing job specs and changes
				 for pages like Job Details.  This is the customer version.

**********************************************************************/

import com.marcomet.jdbc.*;
import com.marcomet.tools.*;

import java.io.*;
import java.sql.*;
import javax.servlet.jsp.*;
import javax.servlet.jsp.tagext.*;

public class JobPriceDetailCustomerTag extends TagSupport {

	private String jobId;
	private String tableWidth = "100%";
	
	public final  int doEndTag() throws JspException {

		
		Connection conn = null;
		FormaterTool formater = new FormaterTool();
		
		double totPrice = 0;

		try {		
			conn = DBConnect.getConnection();
			Statement st1 = conn.createStatement();
			
			//*************** Job Specs Section *********************************
			ResultSet rs1 = st1.executeQuery("SELECT ls.value 'specname', js.value 'specvalue',  js.price 'price' FROM job_specs js, lu_specs ls, catalog_specs cs WHERE js.job_id = " + jobId + " AND cs.spec_id = ls.id AND cs.id = js.cat_spec_id AND cs.price_determinant = 1 ORDER BY ls.sequence");
	
			StringBuffer output = new StringBuffer("<table border=\"0\" width=\"");
			output.append(tableWidth);
			output.append("\"><tr><td class=\"tableheader\">Item</td>");
			output.append("<td class=\"tableheader\">Price</td></tr>");			
			
			while (rs1.next()){  
				totPrice += rs1.getDouble("price");  
				  
				//output table
				if (!formater.getCurrency(rs1.getDouble("price")).equals("$0.00") ) {
					output.append("<tr><td  class=\"label\" align=\"right\">");
					output.append(rs1.getString("specname"));
					output.append(":</td><td class=\"body\" align=\"right\">");
					output.append(formater.getCurrency(rs1.getDouble("price")));
					output.append("</td></tr>");
				}
			}
			
			ResultSet rs2 = st1.executeQuery("SELECT j.discount 'discount',ls.value 'specname', js.value 'specvalue',  js.cost 'cost', js.fee 'fee', js.mu 'mu', js.price 'price' FROM job_specs js left join jobs j on j.id=js.job_id, lu_specs ls WHERE js.cat_spec_id = ls.id AND ls.value = 'Base Price' AND job_id = " + jobId);
			while (rs2.next()){  
				totPrice += rs2.getDouble("price")-rs2.getDouble("discount");
				  
				//output table
				if (!formater.getCurrency(rs2.getDouble("price")).equals("$0.00") ) {				
					output.append("<tr><td  class=\"label\" align=\"right\">");
					output.append(rs2.getString("specname"));
					output.append(":</td><td class=\"body\" align=\"right\">");
					output.append(formater.getCurrency(rs2.getDouble("price")-rs2.getDouble("discount")));
					output.append("</td></tr>");
				}
			}

	
			//******************** Check for Job Changes **************************
			double totChPrice = 0;
			
			rs1 = st1.executeQuery("SELECT DATE_FORMAT(createddate,'%m/%d/%y') 'datecreated', price,v.text jctype from jobchanges,jobchangetypes v where  v.id=changetypeid and jobid = " + jobId + " and statusid = 2 order by createddate");
			if(rs1.next()){
			  if (!formater.getCurrency(totPrice).equals("$0.00") ) {			
				output.append("<tr><td class=\"label\" align=\"right\">Subtotal before job changes:</td><td  class=\"body\" align=\"right\">");
				output.append(formater.getCurrency(totPrice));
				output.append("</td></tr>");
			  }
				do{
					totChPrice += rs1.getDouble("price");
				
					//build change section
					output.append("<tr><td class=\"label\" align=\"right\">"+rs1.getString("jctype")+": ");
					output.append(rs1.getString("datecreated"));
					output.append("</td><td class=\"body\" align=\"right\">");
					output.append(formater.getCurrency(rs1.getString("price")));
					output.append("</td></tr>");
				}while(rs1.next());
			}			
			
			
			totPrice += totChPrice;
			
			output.append("<tr><td class=\"label\" align=\"right\">Job Subtotal:</td><td class=\"Topborderlable\" align=\"right\">");
			output.append(formater.getCurrency(totPrice));
			output.append("</td></tr>");
	
			//****************	Shipping Section ***************
			double totSPrice = 0;
			String shipCostPolicy="";
			String shipPricePolicy="";
			String stdShipCost="";
			String stdShipPrice="";
			rs1 = st1.executeQuery("select s.*,j.ship_price_policy as price_policy, j.std_ship_price as ship_price,j.ship_cost_policy as cost_policy,j.std_ship_cost as ship_cost from jobs j left join shipping_data s on s.job_id=j.id where j.id =" + jobId);
			while(rs1.next()){
				totSPrice += ((rs1.getString("price_policy").equals("2"))?rs1.getDouble("ship_price"):rs1.getDouble("price"));
				stdShipCost=rs1.getString("ship_price");
				stdShipPrice=rs1.getString("ship_price");
				shipCostPolicy=rs1.getString("cost_policy");
				shipPricePolicy=rs1.getString("price_policy");
			}
	        String shipPolicyText="";
	        //shipPolicyText=((shipCostPolicy!=null && shipCostPolicy.equals("1"))?"Note: Shipping Cost Included<br>":"");
	        //shipPolicyText+=((shipCostPolicy!=null && shipCostPolicy.equals("2"))?"Note: Standard Shipping Cost of $"+stdShipCost+" Applies<br>":"");
	        shipPolicyText=((shipPricePolicy!=null && shipPricePolicy.equals("1"))?"Note: Shipping Price Included<br>":"");
	        shipPolicyText+=((shipPricePolicy!=null && shipPricePolicy.equals("2"))?"Note: Standard Shipping Price of $"+stdShipPrice+" Applies<br>":"");
			totPrice += totSPrice;
								
			//display Shipping section
			output.append("<tr><td  class=\"label\" align=\"right\">Shipping:"+((shipPolicyText.equals(""))?"":"<br><i>"+shipPolicyText+"</i>"));
			output.append("</td><td class=\"body\" align=\"right\">");
			output.append(formater.getCurrency(totSPrice));
			output.append("</td></tr>");
					
			//***************** Sales Tax/Job Invoice  Section *******************************		
			rs1 = st1.executeQuery("select sales_tax from jobs where id = " + jobId);	
			
			if(rs1.next()){
				//add to total	
				totPrice += rs1.getDouble("sales_tax");	
				
				output.append("<tr><td class=\"label\" align=\"right\">Sales Tax:</td><td class=\"body\" align=\"right\">");
				output.append(formater.getCurrency(rs1.getString("sales_tax")));
				output.append("</td></tr>");			
				
				//display invoice information
				output.append("<tr><td class=\"label\" align=\"right\">Job Total:</td><td class=\"Topborderlable\" align=\"right\">");
				output.append(formater.getCurrency(totPrice));
				output.append("</td></tr>");				
			}			
			
			//***************** Total billed Section ******************
			double totIPrice = 0;
			rs1 = st1.executeQuery("SELECT SUM(id.deposited) FROM ar_invoices i, ar_invoice_details id, jobs j, projects p, orders o WHERE i.id = id.ar_invoiceid AND o.id = p.order_id AND p.id = j.project_id AND o.buyer_company_id = i.bill_to_companyid AND id.jobid =  j.id AND j.id = " + jobId);
			if(rs1.next()){
				totIPrice += rs1.getDouble(1);
				output.append("<tr><td class=\"label\" align=\"right\">Total Billed:</td><td class=\"body\" align=\"right\">");
				output.append(formater.getCurrency(rs1.getDouble(1)));
				output.append("</td></tr>");			
			}		
			
			//*****************  Sum of what is to be Billed **************
			output.append("<tr><td class=\"label\" align=\"right\">Billable Balance:<td class=\"Topborderlable\" align=\"right\">");
			output.append(formater.getCurrency(totPrice - totIPrice));
			output.append("</td></tr>");			


			output.append("</table>");
			
			pageContext.getOut().print(output);
					
		} catch (IOException ex) {
			throw new JspException(ex.getMessage());	
		} catch (SQLException ex) {
			throw new JspException(ex.getMessage());
		} catch (Exception x) {
			throw new JspException(x.getMessage());
		} finally {
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}

		return EVAL_PAGE;
	}
	public final  void release() {
		super.release();
	}
	public final  void setJobId(String temp){
		this.jobId = temp;
	}
	public final  void setTableWidth(String temp){
		this.tableWidth = temp;
	}
}
