package com.marcomet.taglibs;

/**********************************************************************
Description:	This class will print a table listing job pricing details 
				for vendor roles

**********************************************************************/

import com.marcomet.jdbc.*;
import com.marcomet.tools.*;

import java.io.*;
import java.sql.*;
import javax.servlet.jsp.*;
import javax.servlet.jsp.tagext.*;

public class JobPriceDetailVendorTag extends TagSupport {

	private String jobId;
	private String tableWidth = "100%";
	
	public final  int doEndTag() throws JspException {

		
		Connection conn = null;
		SimpleLookups slups = new SimpleLookups();
		FormaterTool formater = new FormaterTool();
		
		double totCost = 0; 
		double totMu = 0; 
		double totFee = 0;		
		double totPrice = 0;

		try {		
			conn = DBConnect.getConnection();
			Statement st1 = conn.createStatement();
			
			//*************** Job Specs Section *********************************
			ResultSet rs1 = st1.executeQuery("SELECT j.discount 'discount',ls.value 'specname', js.value 'specvalue', js.cost 'cost', js.fee 'fee', js.mu 'mu', js.price 'price' FROM job_specs js left join jobs j on j.id=js.job_id, lu_specs ls, catalog_specs cs WHERE js.job_id = " + jobId + " AND cs.spec_id = ls.id AND cs.id = js.cat_spec_id AND cs.price_determinant = 1 ORDER BY ls.sequence");
			
			StringBuffer output = new StringBuffer("<table border=\"0\" width=\"");
			output.append(tableWidth);
			output.append("\"><tr><td class=\"tableheader\">Item</td><td class=\"tableheader\">Est Cost$</td>");
			output.append("<td class=\"tableheader\">Seller MU</td><td class=\"tableheader\">MC Fee</td>");
			output.append("<td class=\"tableheader\">Price</td></tr>");			
			
			while (rs1.next()){  
				//add to total
				totCost += rs1.getDouble("cost");				
				totMu += rs1.getDouble("mu");
				totFee += rs1.getDouble("fee");
				totPrice += rs1.getDouble("price");  
				  
				//output table
				if (rs1.getDouble("price")!=0){
					output.append("<tr><td class=\"label\" align=\"right\">");
					output.append(rs1.getString("specname"));
					output.append("</td><td class=\"body\" align=\"right\">");
					output.append(formater.getCurrency(rs1.getDouble("cost")));
					output.append("</td><td class=\"body\" align=\"right\">");
					output.append(formater.getCurrency(rs1.getDouble("mu")));
					output.append("</td><td class=\"body\" align=\"right\">");
					output.append(formater.getCurrency(rs1.getDouble("fee")));
					output.append("</td><td class=\"body\" align=\"right\">");
					output.append(formater.getCurrency(rs1.getDouble("price")));
					output.append("</td><td>&nbsp;</td></tr>");
				}
			}
			double discount=0.00;
			boolean discountApplied=false;
			ResultSet rs2 = st1.executeQuery("SELECT j.discount 'discount',ls.value 'specname', js.value 'specvalue',  js.cost 'cost', js.fee 'fee', js.mu 'mu', js.price 'price' FROM job_specs js left join jobs j on j.id=js.job_id , lu_specs ls WHERE js.cat_spec_id = ls.id AND ls.value = 'Base Price' AND job_id = " + jobId);
			while (rs2.next()){  
				//add to total
				discount=((discountApplied)?0:rs2.getDouble("discount"));
				discountApplied=true;
				totCost += rs2.getDouble("cost")-discount;				
				totMu += rs2.getDouble("mu");
				totFee += rs2.getDouble("fee");
				totPrice += rs2.getDouble("price")-discount;  
				  
				//output table
				if (rs2.getDouble("price")!=0){
					output.append("<tr><td class=\"label\" align=\"right\">");
					output.append(rs2.getString("specname"));
					output.append("</td><td  class=\"body\" align=\"right\">");
					output.append(formater.getCurrency(rs2.getDouble("cost")-discount));
					output.append("</td><td  class=\"body\" align=\"right\">");
					output.append(formater.getCurrency(rs2.getDouble("mu")));
					output.append("</td><td  class=\"body\" align=\"right\">");
					output.append(formater.getCurrency(rs2.getDouble("fee")));
					output.append("</td><td  class=\"body\" align=\"right\">");
					output.append(formater.getCurrency(rs2.getDouble("price")-discount));
					output.append("</td><td>&nbsp;</td></tr>");
				}
			}
		
			//******************** Check for Job Changes **************************
			//temp Changes totals
			double totChCost = 0;
			double totChMu = 0;
			double totChFee = 0;			
			double totChPrice = 0;
			
			rs1 = st1.executeQuery("SELECT DATE_FORMAT(createddate,'%m/%d/%y') 'datecreated', cost, mu, fee, price,v.text jctype from jobchanges,jobchangetypes v WHERE v.id=changetypeid and jobid = " + jobId + " AND statusid = 2 ORDER BY createddate");
			if(rs1.next()){
					if (totPrice!=0){	
						output.append("<tr><td  class=\"label\" align=\"right\">Subtotal before job changes:</td><td class=\"TopBorderLable\"  align=\"right\">");
						output.append(formater.getCurrency(totCost));
						output.append("</td><td  class=\"TopBorderLable\" align=\"right\">");
						output.append(formater.getCurrency(totFee));
						output.append("</td><td  class=\"TopBorderLable\" align=\"right\">");
						output.append(formater.getCurrency(totMu));
						output.append("</td><td  class=\"TopBorderLable\" align=\"right\">");
						output.append(formater.getCurrency(totPrice));
						output.append("</td><td>&nbsp;</td></tr>");
					}
					
					do{
						//add to total	
						totChCost += rs1.getDouble("cost");
						totChFee += rs1.getDouble("fee");
						totChMu += rs1.getDouble("mu");
						totChPrice += rs1.getDouble("price");
					
						//build change section
						if (rs1.getDouble("price")!=0){						
							output.append("<tr><td class=\"label\" align=\"right\">"+rs1.getString("jctype")+": ");
							output.append(rs1.getString("datecreated"));
							output.append("</td><td class=\"body\" align=\"right\">");
							output.append(formater.getCurrency(rs1.getString("cost")));
							output.append("</td><td class=\"body\" align=\"right\">");
							output.append(formater.getCurrency(rs1.getString("mu")));
							output.append("</td><td class=\"body\" align=\"right\">");
							output.append(formater.getCurrency(rs1.getString("fee")));
							output.append("</td><td class=\"body\" align=\"right\">");
							output.append(formater.getCurrency(rs1.getString("price")));
							output.append("</td><td>&nbsp;</td></tr>");
						}
					}while(rs1.next());
			}			
			
			
			//add Changes total to total	
			totCost += totChCost;
			totFee += totChMu;
			totMu += totChFee;
			totPrice += totChPrice;
			if (totPrice!=0){
				output.append("<tr><td class=\"label\" align=\"right\">Job Subtotal:</td><td  class=\"TopBorderlable\" align=\"right\">");
				output.append(formater.getCurrency(totCost));
				output.append("</td><td class=\"TopBorderlable\" align=\"right\">");
				output.append(formater.getCurrency(totMu));
				output.append("</td><td  class=\"TopBorderlable\" align=\"right\">");
				output.append(formater.getCurrency(totFee));			
				output.append("</td><td  class=\"TopBorderlable\" align=\"right\">");
				output.append(formater.getCurrency(totPrice));
				output.append("</td><td>&nbsp;</td></tr>");
			}
	
			//****************	Shipping Section ***************
			//temp Sales Tax totals
			double totSCost = 0;
			double totSMu = 0;
			double totSFee = 0;
			double totSPrice = 0;	
			String shipCostPolicy="";
			String shipPricePolicy="";
			String stdShipCost="";
			String stdShipPrice="";
			rs1 = st1.executeQuery("select s.*,j.ship_price_policy as price_policy, j.std_ship_price as ship_price,j.ship_cost_policy as cost_policy,j.std_ship_cost as ship_cost from  jobs j left join shipping_data s on s.job_id=j.id where j.id = " + jobId);
			while(rs1.next()){
			//add subtotals to shipping total	
				totSCost += ((shipPricePolicy!=null && shipPricePolicy.equals("1"))?0:((rs1.getString("price_policy").equals("2"))?rs1.getDouble("ship_price"):rs1.getDouble("price")));
				totSMu += rs1.getDouble("mu");
				totSFee += rs1.getDouble("fee");				
				totSPrice += ((shipPricePolicy!=null && shipPricePolicy.equals("1"))?0:((rs1.getString("price_policy").equals("2"))?rs1.getDouble("ship_price"):rs1.getDouble("price")));;
				stdShipCost=rs1.getString("ship_price");
				stdShipPrice=rs1.getString("ship_price");
				shipCostPolicy=rs1.getString("cost_policy");
				shipPricePolicy=rs1.getString("price_policy");
			}		
	        String shipPolicyText="";
	        shipPolicyText=((shipCostPolicy!=null && shipCostPolicy.equals("1"))?"Note: Shipping Cost Included<br>":"");
	        shipPolicyText+=((shipCostPolicy!=null && shipCostPolicy.equals("2"))?"Note: Standard Shipping Cost of $"+stdShipCost+" Applies<br>":"");
	        shipPolicyText+=((shipPricePolicy!=null && shipPricePolicy.equals("1"))?"Note: Shipping Price Included<br>":"");
	        shipPolicyText+=((shipPricePolicy!=null && shipPricePolicy.equals("2"))?"Note: Standard Shipping Price of $"+stdShipPrice+" Applies<br>":"");
			//add shipping to total	
			totCost += totSCost;
			totMu += totSMu;
			totFee += totSFee;			
			totPrice += totSPrice;	
			
			//display Shipping section
			output.append("<tr><td  class=\"label\" align=\"right\">Shipping:"+((shipPolicyText.equals(""))?"":"<br><i>"+shipPolicyText+"</i>"));
			output.append("</td><td  class=\"body\" align=\"right\">");
			output.append(formater.getCurrency(totSCost));
			output.append("</td><td class=\"body\" align=\"right\">");
			output.append(formater.getCurrency(totSMu));
			output.append("</td><td class=\"body\" align=\"right\">");
			output.append(formater.getCurrency(totSFee));			
			output.append("</td><td class=\"body\" align=\"right\">");
			output.append(formater.getCurrency(totSPrice));
			output.append("</td><td>&nbsp;</td></tr>");
		
			
			//***************** Sales Tax/Job Invoice  Section *******************************		
			rs1 = st1.executeQuery("select sales_tax from jobs where id = " + jobId);	
			
			if(rs1.next()){
				//add to total	
				totPrice += rs1.getDouble("sales_tax");	
				
				output.append("<tr><td class=\"label\" align=\"right\">Sales Tax:");
				output.append("</td><td class=\"body\" align=\"right\">&nbsp;</td><td class=\"body\" align=\"right\">&nbsp;</td><td class=\"body\" align=\"right\">&nbsp;</td><td class=\"body\" align=\"right\">");
				output.append(formater.getCurrency(rs1.getString("sales_tax")));
				output.append("</td><td>&nbsp;</td></tr>");			
				
				//display invoice information
				output.append("<tr><td class=\"label\" align=\"right\">Job Total:</td><td  class=\"TopBorderlable\" align=\"right\">");
				output.append(formater.getCurrency(totCost));
				output.append("</td><td class=\"Topborderlable\" align=\"right\">");
				output.append(formater.getCurrency(totMu));
				output.append("</td><td class=\"Topborderlable\" align=\"right\">");
				output.append(formater.getCurrency(totFee));
				output.append("</td><td class=\"Topborderlable\" align=\"right\">");
				output.append(formater.getCurrency(totPrice));
				output.append("</td><td class=\"Topborderlable\" >&nbsp;</td></tr>");				
			}			
			
			//***************** Total billed Section ******************
			double totIPrice = 0;
			rs1 = st1.executeQuery("SELECT SUM(id.ar_invoice_amount) FROM ar_invoices i, ar_invoice_details id, jobs j, orders o, projects p WHERE i.id = id.ar_invoiceid AND o.id = p.order_id AND p.id = j.project_id AND o.buyer_company_id = i.bill_to_companyid AND id.jobid =  j.id AND j.id = " + jobId);
			if(rs1.next()){
				totIPrice += rs1.getDouble(1);
				output.append("<tr><td class=\"label\" align=\"right\">Total Billed:");
				output.append("</td><td class=\"body\" align=\"right\">&nbsp;</td><td align=\"right\">&nbsp;</td><td align=\"right\">&nbsp;</td><td class=\"Topborderlable\" align=\"right\">");
				output.append(formater.getCurrency(rs1.getDouble(1)));
				output.append("</td><td>&nbsp;</td></tr>");			
			}		
			
			//*****************  Sum of what is to be Billed **************
			output.append("<tr><td class=\"label\"  align=\"right\">Billable Balance:");
			output.append("</td><td class=\"Topborderlable\" align=\"right\">&nbsp;</td><td class=\"Topborderlable\" align=\"right\">&nbsp;</td><td class=\"Topborderlable\" align=\"right\">&nbsp;</td><td class=\"Topborderlable\" align=\"right\">");
			output.append(formater.getCurrency(totPrice - totIPrice));
			output.append("</td><td>&nbsp;</td></tr>");			


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
