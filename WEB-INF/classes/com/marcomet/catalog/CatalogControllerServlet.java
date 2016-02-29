package com.marcomet.catalog;

/**********************************************************************
Description:	This servlet controls the page to page catalog job processing

**********************************************************************/

import java.io.IOException;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.Enumeration;
import java.util.Hashtable;
import java.util.StringTokenizer;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.marcomet.environment.SiteHostSettings;
import com.marcomet.jdbc.DBConnect;
import com.marcomet.tools.Indexer;

public class CatalogControllerServlet extends HttpServlet {


public JobObject createJob(int prodId, int catJobId, int vendorId, int siteHostId, ProjectObject po) throws ServletException {
               JobObject jo = new JobObject(); 
               Connection conn = null; 

       		try {			
       			conn = DBConnect.getConnection();
                    jo.setId(Indexer.getNextId("jobs", conn));
                    String query0 = "SELECT ljt.value AS job_value, job_type_id, lst.value AS service_value, service_type_id, marcomet_global_fee, site_host_global_markup FROM catalog_jobs cj, lu_job_types ljt, lu_service_types lst, site_hosts sh WHERE ljt.id = cj.job_type_id AND lst.id = cj.service_type_id AND cj.id = " + catJobId + " AND sh.id = " + siteHostId;
                       Statement st0 = conn.createStatement(); 
                       ResultSet rs0 = st0.executeQuery(query0); 
                       if (rs0.next()) {
                                jo.setJobName(rs0.getString("job_value") + ", " + rs0.getString("service_value"));
                                jo.setJobTypeId(rs0.getInt("job_type_id"));
                                jo.setServiceTypeId(rs0.getInt("service_type_id"));
                                jo.setSiteHostMarkup(rs0.getDouble("site_host_global_markup"));
                                jo.setMarcometFee(rs0.getDouble("marcomet_global_fee"));
                        }
                        query0 = "Select prod_code, prod_name from products where id="+prodId;
                        st0 = conn.createStatement();
                        rs0 = st0.executeQuery(query0);
                        jo.setProductName("");
                        if (rs0.next()) {
                                 jo.setJobName(rs0.getString("prod_code") + " - " + rs0.getString("prod_name"));
                                 jo.setProductName(rs0.getString("prod_name"));
                        }
                        jo.setProductId(prodId);
//            			String glQuery = "SELECT grid_label FROM products p left join product_prices pp on p.prod_price_code=pp.prod_price_code WHERE p.id="+prodId +" and pp.price="+jo.getPrice()+ " and pp.quantity="+jo.getQuantity()+" and pp.grid_label is not null and pp.grid_label<>''";
//            			Statement st1 = conn.createStatement();
//            			ResultSet rsGl = st1.executeQuery(glQuery);
//            			if (rsGl.next()) {
//            			    jo.setJobName(jo.getJobName()+"; "+rsGl.getString("grid_label"));
//            			} 
			double escrowPercentage = 0;
			String query1 = "SELECT escrow_percentage FROM catalog_markup WHERE cat_job_id = " + catJobId + " AND site_host_id = " + siteHostId;
			Statement st1 = conn.createStatement();
			ResultSet rs1 = st1.executeQuery(query1);
			if (rs1.next()) {
			    escrowPercentage = rs1.getDouble("escrow_percentage");
			} else {
			    escrowPercentage = 0;
			}
			jo.setEscrowPercentage(escrowPercentage);
			jo.setVendorId(vendorId);

			String query2 = "SELECT contacts.id, companyid FROM contacts, vendors, companies WHERE vendors.company_id = companies.id and companies.id = contacts.companyid and vendors.id = " + vendorId;
			Statement st2 = conn.createStatement();
			ResultSet rs2 = st2.executeQuery(query2);
			if (rs2.next()) {
				jo.setVendorContactId(rs2.getInt("id"));
				jo.setVendorCompanyId(rs2.getInt("companyid"));
			}

		} catch (SQLException ex) {
			throw new ServletException("createJob() SQL Error: " + ex.getMessage());
		} catch (Exception ex) {
			throw new ServletException("createJob() Error: " + ex.getMessage());
		} finally {
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}

		return jo;

	}
	public void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException {

		try {
			this.processRequest(request, response);
		} catch (ServletException ex) {
			throw new ServletException("CatalogControllerServlet Error: " + ex.getMessage());
		}

	}
	public void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException {

		try {
			this.processRequest(request, response);
		} catch (ServletException ex) {
			throw new ServletException("CatalogControllerServlet Error: " + ex.getMessage());
		}

	}
	public String examineNavigation(HttpServletRequest request, String nextPageType, int catJobId) throws ServletException {

		String nextPage = "";

		try {

			ProjectObject po = (ProjectObject)request.getSession().getAttribute("currentProject");
			boolean proxyEnabled = false;
			try {
				ProxyOrderObject poo = (ProxyOrderObject)request.getSession().getAttribute("ProxyOrderObject");
				proxyEnabled = poo.isProxyEnabled();
			} catch (Exception ex) {}

			if (nextPageType.equals("intro")) {
				nextPage = "/catalog/CatalogIntroPage.jsp";
			} else if (nextPageType.equals("questions")) {
				nextPage = "/catalog/CatalogQuestionsPage.jsp";
			} else if (nextPageType.equals("fileupload") && po.uploadComplete == false && proxyEnabled == false) {
				nextPage = "/catalog/CatalogFilesPage.jsp";
			} else if (nextPageType.equals("summary") || po.uploadComplete == true || proxyEnabled == true) {
				nextPage = "/servlet/com.marcomet.catalog.CatalogFlowServlet";
			}

		} catch (Exception ex) {
			throw new ServletException("processNavigation() Error: " + ex.getMessage());
		}

		return nextPage;

	} // examineNavigation
	public void getGridSelection(HttpServletRequest request, JobObject jo, int catJobId, int catalogPage, int vendorId, int siteHostId) throws ServletException {

		Connection conn = null; 

		try {			
			conn = DBConnect.getConnection();
			String query0="";
			int rownum=0;
			double priceVal=0;
			String quantity=""; String gridLabel="";
			String foundFlag="";
			int rfq=0;
			String x = null; String y = null;
			Object o = request.getParameter("coordinates");

			if (o != null) {

				StringTokenizer tokenizer = new StringTokenizer((String)request.getParameter("coordinates"), ",");
				if (tokenizer.hasMoreElements()) {
					x = tokenizer.nextToken();
					y = tokenizer.nextToken();
					if (request.getParameter("prodCode")!=null && !request.getParameter("prodCode").equals("null") && !request.getParameter("prodCode").equals("")){
						query0= "Select * from product_prices where prod_price_code='" + request.getParameter("prodCode") + "' AND site_id = " + siteHostId;
						Statement st0a = conn.createStatement();
						ResultSet rs0a = st0a.executeQuery(query0);
						if (rs0a.next()){
							query0="Select quantity, price, rfq,grid_label,std_ship_price,ship_price_policy FROM product_prices pp WHERE pp.site_id="+siteHostId+" and pp.prod_price_code='"+request.getParameter("prodCode")+"' ORDER BY sequence,quantity ASC";
						}	else {
							query0="Select quantity, price, rfq,grid_label,std_ship_price,ship_price_policy FROM product_prices pp WHERE pp.site_id='0' AND pp.prod_price_code='"+request.getParameter("prodCode")+"' ORDER BY sequence,quantity ASC";
						}	
						st0a = conn.createStatement();
						rs0a = st0a.executeQuery(query0);
						rownum=0;
						while (rs0a.next()) {
							if ( rownum == Integer.parseInt(y)){
								priceVal=rs0a.getDouble("price");
								quantity=rs0a.getString("quantity"); jo.setQuantity(rs0a.getInt("quantity")); gridLabel=((rs0a.getString("grid_label")==null)?"":rs0a.getString("grid_label")); jo.setGridLabel(gridLabel); jo.setJobName(jo.getJobName()+((gridLabel=="")?"":"; "+gridLabel));jo.setShippingPrice(rs0a.getDouble("std_ship_price")); jo.setShipPricePolicy(rs0a.getInt("ship_price_policy")); 
								rfq=rs0a.getInt("rfq");
								foundFlag="Y";
							}
							rownum++;
						}
						int contactId;
						boolean proxyEnabled = false;
						double escrowPercentage;
						if (foundFlag.equals("Y")) {
							try {
								contactId = Integer.parseInt((String)request.getSession().getAttribute("contactId"));
							} catch (Exception ex) {
								contactId = -1;
							}
							

							try {
								ProxyOrderObject poo = (ProxyOrderObject)request.getSession().getAttribute("ProxyOrderObject");
								proxyEnabled = poo.isProxyEnabled();
							} catch (Exception ex) {}
							
								escrowPercentage = jo.getEscrowPercentage();
								JobSpecObject jso = new JobSpecObject(88888, 88888, "Base Price",  priceVal, escrowPercentage, contactId, siteHostId, proxyEnabled);
								jo.addJobSpec(jso, catalogPage);
								JobSpecObject jsoa = new JobSpecObject(705, 999,quantity, 0, escrowPercentage, contactId, siteHostId, proxyEnabled);
								jo.addJobSpec(jsoa, catalogPage);
								if (rfq == 1) {
									jo.setAsRFQ();
								}
							//}
						//}
							//Put the quantity directly in to a spec object
						
							
					} else {
							throw new Exception(query0 +quantity+"<br>No valid grid components found for cell (" + x + "," + y + ")");
					}
						
					}else{

					 query0 = "SELECT spec_id, cat_spec_id, value, cpd.id AS price_definition_id FROM catalog_specs cs, catalog_rows cr, catalog_grid_bridge cgb, catalog_price_definitions cpd WHERE cs.id = cr.cat_spec_id AND cpd.id = cgb.catalog_price_definition_id AND cr.id = cgb.catalog_row_id  AND cpd.cat_job_id = cgb.cat_job_id AND cpd.cat_job_id = " + catJobId + " AND cpd.row_number = " + x + " AND cpd.column_number = " + y + " AND cr.catalog_page = cgb.catalog_page AND cgb.catalog_page = cpd.catalog_page AND cpd.catalog_page = " + catalogPage;
						Statement st0 = conn.createStatement();
						ResultSet rs0 = st0.executeQuery(query0);
						if (rs0.next()) {
							int contactId;
							try {
								contactId = Integer.parseInt((String)request.getSession().getAttribute("contactId"));
							} catch (Exception ex) {
								contactId = -1;
							}
							boolean proxyEnabled = false;
							try {
								ProxyOrderObject poo = (ProxyOrderObject)request.getSession().getAttribute("ProxyOrderObject");
								proxyEnabled = poo.isProxyEnabled();
							} catch (Exception ex) {}
							
							double escrowPercentage = jo.getEscrowPercentage();
							
							String query1 = "SELECT price, rfq FROM catalog_prices WHERE vendor_id = " + vendorId + " AND price_tier_id = " + request.getParameter("tierId") + " AND catalog_price_definition_id = " + rs0.getInt("price_definition_id");
							Statement st1 = conn.createStatement();
							ResultSet rs1 = st1.executeQuery(query1);
							if (rs1.next()) {
								if (rs1.getDouble("price") >= 0) {
									JobSpecObject jso = new JobSpecObject(88888, 88888, "Base Price",  rs1.getDouble("price"), escrowPercentage, contactId, siteHostId, proxyEnabled);
									jo.addJobSpec(jso, catalogPage);
								}
							}
							
							do {
								String specValue = (String)rs0.getString("value");
								JobSpecObject jso = new JobSpecObject(rs0.getInt("spec_id"), rs0.getInt("cat_spec_id"), specValue, 0, escrowPercentage, contactId, siteHostId, proxyEnabled);
								jo.addJobSpec(jso);
								if (rs1.getInt("rfq") == 1) {
									jo.setAsRFQ();
								}
							} while (rs0.next());
							
						} else {
							throw new Exception(query0 +"<br>No valid grid components found for cell (" + x + "," + y + ")");
						}
					}

		}
			}

		} catch (SQLException ex) {
			throw new ServletException("getGridSelection() SQL Error: " + ex.getMessage());
		} catch (Exception ex) {
			throw new ServletException("getGridSelection() Error: " + ex.getMessage());
		} finally {
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}

	} // getGridSelection
	
	public String getNextPageType(HttpServletRequest request, int catJobId, int currentCatalogPage) throws ServletException {

		String nextPageType = "";
		
		Connection conn = null; 

		try {			
			conn = DBConnect.getConnection();

			int nextCatalogPage = 0;
			String query0 = "SELECT page, page_type, title FROM catalog_pages WHERE cat_job_id = " + catJobId + " AND page = 1 + " + currentCatalogPage;
			Statement st0 = conn.createStatement();
			ResultSet rs0 = st0.executeQuery(query0);
			if (rs0.next()) {
				nextCatalogPage = rs0.getInt("page");
				nextPageType = rs0.getString("page_type");
				request.setAttribute("title",rs0.getString("title"));
			} else {
				nextCatalogPage = 0;
				nextPageType = "summary";
				request.setAttribute("title","");
			}

			if (nextCatalogPage != 0) {
				request.setAttribute("currentCatalogPage", new Integer(nextCatalogPage).toString());
			} else {
				request.setAttribute("currentCatalogPage", "0");
			}	

		} catch (SQLException ex) {
			throw new ServletException("getNextPageType() SQL Error: " + ex.getMessage());
		} catch (Exception ex) {
			throw new ServletException("getNextPageType() Error: " + ex.getMessage());
		} finally {
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}
	
		return nextPageType;

	} // getNextPageType
	public void populateCart(HttpServletRequest request, int prodId, int catJobId, int vendorId, int siteHostId, ShoppingCart shoppingCart, int catalogPage) throws ServletException {

		Connection conn = null; 

		try {			
			conn = DBConnect.getConnection();
			ProjectObject po = null;

			String newProject = (String)request.getAttribute("newProject");
			if (newProject == null)
				newProject = (String)request.getParameter("newProject");
			if (newProject == null)
				newProject = "0";
			if (newProject.equals("1")) {			
				po = new ProjectObject();
			    po.setId(Indexer.getNextId("projects", conn));
				po.setProjectSequence(0);
				if((request.getParameter("selfDesigned")!=null && request.getParameter("selfDesigned").equals("true")) || (request.getSession().getAttribute("selfDesigned")!=null && request.getSession().getAttribute("selfDesigned").toString().equals("true"))){
					request.getSession().setAttribute("currentDIYProject", po);
				} else {
					request.getSession().setAttribute("currentProject", po);
				}
			}else{
				po = (ProjectObject)request.getSession().getAttribute("currentProject");
			}

		    boolean addBasePrice = false;

			JobObject jo = po.getCurrentJob();

			String newJob = (String)request.getAttribute("newJob");
			if (newJob == null)
				newJob = (String)request.getParameter("newJob");
			if (newJob == null)
				newJob = "0";
			if (newJob.equals("1") || jo == null) {
				jo = this.createJob(prodId,catJobId, vendorId, siteHostId, po);
				addBasePrice = true;
				po.addJob(jo);
			}

			double escrowPercentage = jo.getEscrowPercentage();

			if (request.getAttribute("YourTicketHasBeenPunched") == null) {
				this.getGridSelection(request, jo, catJobId, catalogPage, vendorId, siteHostId);
			}

			
			String query0="";
			int rownum=0;
			double priceVal=0;
			String quantity="";
			int rfq=0;
			String x = null; String y = null;
			Object o = request.getParameter("coordinates");
			Hashtable priceIndex = new Hashtable();
			Hashtable valueIndex = new Hashtable();
			if (o != null) {
				
				StringTokenizer tokenizer = new StringTokenizer((String)request.getParameter("coordinates"), ",");
				if (tokenizer.hasMoreElements()) {
					x = tokenizer.nextToken();
					y = tokenizer.nextToken();
				}
			}
			if (request.getParameter("selfDesigned")!=null && request.getParameter("selfDesigned").equals("true")){
				priceVal=0;
				quantity="0";
				rfq=0;
			} else if (request.getParameter("prodCode")!=null && !request.getParameter("prodCode").equals("null") && !request.getParameter("prodCode").equals("")){
				query0= "Select * from product_prices where prod_price_code='" + request.getParameter("prodCode") + "' AND site_id = " + siteHostId;
				Statement st0a = conn.createStatement();
				ResultSet rs0a = st0a.executeQuery(query0);
				if (rs0a.next()){
					query0="Select quantity, price, rfq FROM product_prices pp WHERE pp.site_id="+siteHostId+" and pp.prod_price_code='"+request.getParameter("prodCode")+"' ORDER BY sequence,quantity ASC";
				}	else {
					query0="Select quantity, price, rfq FROM product_prices pp WHERE pp.site_id='0' AND pp.prod_price_code='"+request.getParameter("prodCode")+"' ORDER BY sequence,quantity ASC";
				}	
				st0a = conn.createStatement();
				rs0a = st0a.executeQuery(query0);
				rownum=0;
				while (rs0a.next()) {
					if ( rownum == Integer.parseInt(y)){
						priceVal=rs0a.getDouble("price");
						quantity=rs0a.getString("quantity");
						rfq=rs0a.getInt("rfq");
					}
					rownum++;
				}
				String specId = "705";
				valueIndex = (Hashtable)priceIndex.get( new Integer(specId).toString() );
					if (valueIndex == null) {
						valueIndex = new Hashtable();
						valueIndex.put(quantity, new Double(priceVal));
						priceIndex.put(specId, valueIndex);
					} else {
						valueIndex.put(quantity, new Double(priceVal));
					}
			}else{
			String query1 = "SELECT cat_spec_id, value, price FROM catalog_price_definitions cpd, catalog_prices cp, catalog_rows cr WHERE row_number > 99999 AND row_number = span AND cp.catalog_price_definition_id = cpd.id AND vendor_id = " + request.getParameter("vendorId") + " AND price_tier_id = " + request.getParameter("tierId") + " AND cr.cat_job_id = cpd.cat_job_id AND cr.cat_job_id = " + catJobId;
			Statement st1 = conn.createStatement();
			ResultSet rs1 = st1.executeQuery(query1);
			while (rs1.next()) {
				String specId = rs1.getString("cat_spec_id");
				valueIndex = (Hashtable)priceIndex.get( new Integer(specId).toString() );
				if (valueIndex == null) {
				    valueIndex = new Hashtable();
				    valueIndex.put(rs1.getString("value"), new Double(rs1.getDouble("price")));
				    priceIndex.put(specId, valueIndex);
				} else {
				    valueIndex.put(rs1.getString("value"), new Double(rs1.getDouble("price")));
				}
			}
		}

			int contactId;
			try {
				contactId = Integer.parseInt((String)request.getSession().getAttribute("contactId"));
			} catch (Exception ex) {
				contactId = -1;
			}

		    boolean proxyEnabled = false;
			try {
		          ProxyOrderObject poo = (ProxyOrderObject)request.getSession().getAttribute("ProxyOrderObject");
		          proxyEnabled = poo.isProxyEnabled();
		    } catch (Exception ex) {}

			for (Enumeration e = request.getParameterNames(); e.hasMoreElements(); ) {
				String currentSpec = (String)e.nextElement();
				int isSpec = currentSpec.indexOf("^");
				if (isSpec == 0) {
					StringTokenizer tokenizer = new StringTokenizer(currentSpec, "^");
					int specId = 0;
					int catSpecId = 0;
					if (tokenizer.hasMoreElements()) {
						specId = Integer.parseInt((String)tokenizer.nextElement());
						catSpecId =Integer.parseInt((String)tokenizer.nextElement());
					}
					String specValue = (String)request.getParameter(currentSpec);
					// Calculate pricing info
					double cost = 0;
					try {
						valueIndex = (Hashtable)priceIndex.get((new Integer(specId)).toString());
						cost = Double.parseDouble((String)valueIndex.get(specValue).toString());
					} catch (NullPointerException npe) {
						cost = 0;
					}
					JobSpecObject jso = new JobSpecObject(specId, catSpecId, specValue, cost, escrowPercentage, contactId, siteHostId, proxyEnabled);
					jo.addJobSpec(jso);
					if(shoppingCart!=null){
						shoppingCart.addJobSpec(jso);
					}else{
						System.out.println("Shopping Cart Null");
					}
				}
			}

			if (addBasePrice) {
			    String query2 = "SELECT price, rfq FROM catalog_prices cp, catalog_price_definitions cpd WHERE row_number = 99999 AND cpd.id = cp.catalog_price_definition_id AND cat_job_id = " + catJobId + " and vendor_id = " + vendorId + " AND price_tier_id = " + request.getParameter("tierId");
			    Statement st2 = conn.createStatement();
			    ResultSet rs2 = st2.executeQuery(query2);
			    if (rs2.next()) {
					JobSpecObject jso = new JobSpecObject(99999, 99999, "Base Price", rs2.getDouble("price"), escrowPercentage, contactId, siteHostId, proxyEnabled);
					jo.addJobSpec(jso);
					if (rs2.getInt("rfq") == 1) {
						jo.setAsRFQ();
					}
			    }
			}

		} catch (Exception ex) {
			throw new ServletException("populateCart() Error: " + ex.getMessage());
		} finally {
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}

	} // populateCart
	
	
	public void processRequest(HttpServletRequest request, HttpServletResponse response) throws ServletException {

		Connection conn = null; 
		String s="";
		try {			
			conn = DBConnect.getConnection();

			int vendorId = Integer.parseInt((String)request.getParameter("vendorId"));
			int catJobId = Integer.parseInt((String)request.getParameter("catJobId"));
			int prodId=0;	
			if (request.getParameter("productId")!=null) {
				prodId = Integer.parseInt((String)request.getParameter("productId"));
			}
			int offeringId = Integer.parseInt((String)request.getParameter("offeringId"));
			int siteHostId = Integer.parseInt(((SiteHostSettings)request.getSession().getAttribute("siteHostSettings")).getSiteHostId());
			int tierId = Integer.parseInt((String)request.getParameter("tierId"));
			int currentCatalogPage = 0;

			try {
				currentCatalogPage = Integer.parseInt((String)request.getParameter("currentCatalogPage"));
			} catch (Exception ex) {
				String query0 = "SELECT start_page FROM site_host_offerings sho, site_host_offering_choices shoc, offerings o, offering_sequences os WHERE shoc.offering_id = o.id AND o.id = os.offering_id AND shoc.site_host_offering_id = sho.id AND site_host_id = " + siteHostId + " AND o.id = " + offeringId;
				Statement st0 = conn.createStatement();
				ResultSet rs0 = st0.executeQuery(query0);
				if (rs0.next()) {
					currentCatalogPage = rs0.getInt("start_page") - 1;
				} else {
					currentCatalogPage = 0;
				}
			}
			if((request.getParameter("selfDesigned")!=null && request.getParameter("selfDesigned").equals("true")) || (request.getSession().getAttribute("selfDesigned")!=null && request.getSession().getAttribute("selfDesigned").toString().equals("true"))){
				ShoppingCart shoppingCart = (ShoppingCart) request.getSession().getAttribute("DIYshoppingCart");
				if(shoppingCart==null){
					shoppingCart = new ShoppingCart();
					request.getSession().setAttribute("DIYshoppingCart", shoppingCart);	
				}
				this.populateCart(request, prodId, catJobId, vendorId, siteHostId, shoppingCart, currentCatalogPage);		
			}else{
				ShoppingCart shoppingCart = (ShoppingCart) request.getSession().getAttribute("shoppingCart");
				this.populateCart(request, prodId, catJobId, vendorId, siteHostId, shoppingCart, currentCatalogPage);
			}

			String nextPageType = this.getNextPageType(request, catJobId, currentCatalogPage);
			String nextPage = this.examineNavigation(request, nextPageType, catJobId);

			request.setAttribute("YourTicketHasBeenPunched", "true");
			s=nextPage + "?catJobId=" + catJobId + "&offeringId=" + offeringId + "&tierId=" + tierId;
			System.out.println("s is "+s);
			RequestDispatcher rd = getServletContext().getRequestDispatcher(s);
			System.out.println("rd is "+rd);
			//s="rd";
			rd.forward(request, response);
			s="after rd";
		} catch (IOException ex) {
			throw new ServletException("processRequest IO Error: " + ex.getMessage());
		} catch (SQLException ex) {
			throw new ServletException("processRequest SQL Error: " + ex.getMessage());
		} catch (Exception ex) {
			throw new ServletException("processRequest Error: S="+s+" E:" + ex.getMessage());
		} finally {
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}

	} // processRequest
}
