<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<%@ page import="java.math.*,java.text.*,java.sql.*,com.marcomet.users.security.*,com.marcomet.tools.*,com.marcomet.environment.*,java.util.*,com.marcomet.catalog.*;" %>
<%@ taglib uri="/WEB-INF/tld/iterationTagLib.tld" prefix="iterate" %>
<%@ include file="/includes/SessionChecker.jsp" %>
<%@ taglib uri="/WEB-INF/tld/taglib.tld" prefix="taglib" %>
<jsp:useBean id="sl" class="com.marcomet.tools.SimpleLookups" scope="page" />
<jsp:useBean id="connection" class="com.marcomet.jdbc.ConnectionBean" scope="session" />
<jsp:useBean id="formater" class="com.marcomet.tools.FormaterTool" scope="page" />
<jsp:useBean id="shipper" class="com.marcomet.commonprocesses.ProcessShippingCost" scope="page" />
<jsp:useBean id="cB" class="com.marcomet.beans.SBPContactBean" scope="page" />
<jsp:setProperty name="cB" property="*"/>  


<%
    if (request.getParameter("firstName") == null || request.getParameter("firstName").trim().equals("")) {
      cB.setContactId((String) session.getAttribute("contactId"));
    }
    
    UserProfile up = (UserProfile) session.getAttribute("userProfile");
	boolean isProxy=((session.getAttribute("proxyId")!=null)?true:false);
    DecimalFormat numberFormatter = new DecimalFormat("#,###,###");
    String previewTemplate = "/preview/brochure_from_sc.jsp";
    SiteHostSettings shs = (SiteHostSettings) session.getAttribute("siteHostSettings");
    boolean editor = (((RoleResolver) session.getAttribute("roles")).roleCheck("editor"));
    boolean overLimit = false;
    boolean notOverLimit = false;
    String shipmentOption = ((request.getParameter("shipmentOptionStr")==null)?sl.getValue("site_hosts","id",shs.getSiteHostId(),"shipping_options_default"):request.getParameter("shipmentOptionStr"));
    int proppastdue = 0;
    int pastdue = 0;
    int shipId=0;
    String shipZip="";
    String shipState="";
    String taxExempt="";
    String taxJob="0";
    String taxShipping="0";
    String dollarAmount="0";
    String taxEntity="153";
    String taxState="";
    String taxable="1";
    int taxRate=0;
    int decimalPlace = 2;
    String shipLocationIdChoice = ((request.getParameter("shipLocationIdChoice")==null)?"0":request.getParameter("shipLocationIdChoice"));
    String coStep = ((request.getParameter("coStep")==null)?"step1":request.getParameter("coStep"));
	boolean shipTBD=false;
	double totalPrice=0.00;
	String promoTitle ="";
	String promoNotes="";
	String promoDescription="";
	String promoPriceSuffix="";
	String promoStartDate="";
	String promoEndDate="";	
	String promoStatusId="";
	String promoProgramCode="";
	String promoSalesContactId="";
	int promoType=0;
	double promoFixedAmount=0.00;
	double promoPercentage=0.00;
	double promoMinimumPerOrder=0.00;
	double promoPerOrderCap=0.00;
	double promoPerCustomerCap=0.00;
	double amountUsable=0;
	String promoSuffix="";
	int promoJobs=0;
	boolean showProdPromoText=true;
	boolean showPromoDetails=true;
	
	int promoPerCustomerUses=0;
	
	double amountUsed=0.00;
	int numberUsed=0;
	
	boolean promoAllowOnAccount=true;
	String promoStatus = "";
	boolean promoIncludesShipping=false;
	boolean promoShippingOnly=false;
	boolean excludeSitehostFromPromo=false;
	boolean excludeCustomerFromPromo=false;
	Connection conn = com.marcomet.jdbc.DBConnect.getConnection();
    Statement st = conn.createStatement();
	String promoCode=((session.getAttribute("promoCode")==null)?"":session.getAttribute("promoCode").toString());
// if the shipping address was changed save the new shipping address and apply it to the shopping cart,
//   else if there is no shipping address in the cart already check and see if the default mailing address matches a shiping_location already saved
//      if it does, apply that , else save it as a new shipping_location record and apply it to the shopping cart.
    ShoppingCart shoppingCart1 = (ShoppingCart) session.getAttribute("shoppingCart");
    if (shoppingCart1 != null && shoppingCart1.getProjects().size()==0){
    	session.removeAttribute("shoppingCart");
    	shoppingCart1=null;
    }
    if (shoppingCart1 != null) {
	    Vector projects0 = shoppingCart1.getProjects();
		if (projects0.size() > 0) {
			for (int jjj = 0; jjj < projects0.size(); jjj++) {
	  			ProjectObject po0 = (ProjectObject) projects0.elementAt(jjj);
	  			Vector jobs0 = po0.getJobs();
	  			for (int kkj = 0; kkj < jobs0.size(); kkj++) {
	    			JobObject jo0 = (JobObject) jobs0.elementAt(kkj);
	    			jo0.setPromoCode("");
	    			jo0.setDiscount(0.00);
	    			jo0.setPromoProdMessage("");
					jo0.setDiscountPercentage(0.00);
					jo0.setDiscountType(0);
					jo0.setDiscountIncludesShipping(0);
	    		}
	    	}
	    }
    	if (!promoCode.equals("")){
    	    ResultSet rsPromoSH = st.executeQuery("Select * from promo_sitehost_bridge where promo_code='"+promoCode+"' and exclude_sitehost=0");
	 		if (rsPromoSH.next() && rsPromoSH.getString("id")!=null ){
	 			excludeSitehostFromPromo=true;
	 		}
	 		ResultSet rsPromoSH2 = st.executeQuery("Select * from promo_sitehost_bridge where promo_code='"+promoCode+"' and sitehost_id='"+shs.getSiteHostId()+"'");
	 		if(rsPromoSH2.next()){
	 			excludeSitehostFromPromo=((rsPromoSH2.getString("exclude_sitehost")==null || rsPromoSH2.getString("exclude_sitehost").equals("0"))?false:true);
	 		}
	 		if (excludeSitehostFromPromo){
    	 		promoStatus="This promotion is not valid on this site.";
    	 	}else{
		 		rsPromoSH = st.executeQuery("Select * from promo_customer_bridge where promo_code='"+promoCode+"' and exclude_customer=0");
		 		if (rsPromoSH.next() && rsPromoSH.getString("id")!=null ){
		 			excludeCustomerFromPromo=true;
		 		}
		 		ResultSet rsPromoSH3 = st.executeQuery("Select * from promo_customer_bridge where promo_code='"+promoCode+"' and site_number='"+up.getSiteNumber()+"'");
	 			if(rsPromoSH3.next()){
	 				excludeCustomerFromPromo=((rsPromoSH3.getString("exclude_customer")!=null && rsPromoSH3.getString("exclude_customer").equals("1"))?true:false);
		 		}
       			if (excludeCustomerFromPromo){
    	 			promoStatus="This promotion is not valid for this customer.";
    			}
    		}
       if (excludeSitehostFromPromo || excludeCustomerFromPromo){
       	
       }else{
		String promoSQL="select p.*,if(max(pcb.number_of_uses_allowed) is null or max(pcb.number_of_uses_allowed)=0,promo_cap_uses_allowed,pcb.number_of_uses_allowed) as 'numberAllowed',if(max(pcb.max_amount) is null or max(pcb.max_amount)=0,promo_cap_amount_per_customer,pcb.max_amount) as 'amountAllowed',  if(sum(pcb.number_used) is null,0,sum(pcb.number_used)) as 'numberUsed',if(sum(pcb.amount_used) is null,0,sum(pcb.amount_used)) as 'amountUsed', if(end_date<NOW(),'Promotion has expired and will not be applied.',if(start_date>NOW(),'Promotion has not started yet and will not be applied.','Valid')) as 'status' from promotions p left join promo_customer_bridge pcb on exclude_customer=0 and pcb.promo_code=p.promo_code and (pcb.company_id='"+up.getCompanyId()+"' or if('"+up.getSiteNumber()+"'='','',pcb.site_number='"+up.getSiteNumber()+"') or if('"+up.getTaxId()+"'='','',pcb.tax_id='"+up.getTaxId()+"')) where p.promo_code='"+promoCode+"' group by p.promo_code";
	
		ResultSet rsPromo = st.executeQuery(promoSQL);
	 	if (rsPromo.next()){
			promoTitle =rsPromo.getString("title");
			promoNotes=rsPromo.getString("internal_notes");
			promoDescription=rsPromo.getString("description");
			promoPriceSuffix=rsPromo.getString("price_code_suffix");
			promoStartDate=rsPromo.getString("start_date");
			promoEndDate=rsPromo.getString("end_date");
			promoStatusId=rsPromo.getString("status_id");
			promoProgramCode=rsPromo.getString("program_code");
			promoSalesContactId=rsPromo.getString("salesperson_contact_id");
			promoType=rsPromo.getInt("promo_type");
			promoIncludesShipping=((rsPromo.getString("include_shipping").equals("0"))?false:true);
			promoShippingOnly=((rsPromo.getString("include_shipping").equals("2"))?true:false);
			promoFixedAmount=rsPromo.getDouble("promo_fixed_amount");
			promoPercentage=rsPromo.getDouble("promo_percentage");
			promoPerOrderCap=rsPromo.getDouble("promo_cap_amount_per_order");
			promoMinimumPerOrder=rsPromo.getDouble("promo_minimum_per_order");
			promoPerCustomerCap=rsPromo.getDouble("amountAllowed");
			promoPerCustomerUses=rsPromo.getInt("numberAllowed");
			amountUsed=rsPromo.getDouble("amountUsed");
			numberUsed=rsPromo.getInt("numberUsed");
			promoAllowOnAccount=((rsPromo.getString("prepay_only")== null || rsPromo.getString("prepay_only").equals("0"))?true:false);
			promoStatus = rsPromo.getString("status");
			promoSuffix = ((rsPromo.getString("price_code_suffix")==null)?"":rsPromo.getString("price_code_suffix"));
			showProdPromoText=((rsPromo.getString("hide_ineligible_text").equals("0"))?true:false);
			showPromoDetails=((rsPromo.getString("hide_promo_details").equals("0"))?true:false);		
	 	}
	}
	String pJobSQL="Select count(o.id) as 'numberUsed',sum(j.discount) as 'amountUsed' from orders o left join projects p on p.order_id=o.id left join jobs j on j.project_id=p.id left join companies c on jbuyer_company_id=c.id where j.status_id<>9 and  (jbuyer_contact_id="+up.getContactId()+" or if('"+up.getSiteNumber()+"'='','',site_number='"+up.getSiteNumber()+"') or if('"+up.getTaxId()+"'='','',c.taxid='"+up.getTaxId()+"')) and promo_code='"+promoCode+"' group by o.id";
		ResultSet rsPJobs = st.executeQuery(pJobSQL);
		if(rsPJobs.next()){
			numberUsed=rsPJobs.getInt("numberUsed");
			amountUsed=rsPJobs.getDouble("amountUsed");
		}
		amountUsable=((promoPerCustomerCap>0)?promoPerCustomerCap-amountUsed:-999);
	if (promoStatus.equals("Valid")){
		if(promoPerCustomerCap>0){
			if(promoPerCustomerCap<=amountUsed){
				promoStatus="You've reached the maximum allowable amount for this promotion; promo code is not valid.";
			}
		}
		if(promoPerCustomerUses>0){
			if(promoPerCustomerUses<=numberUsed){
				promoStatus="You've reached the maximum allowable uses for this promotion; promo code is not valid.";
			}
		}
		if(promoMinimumPerOrder>0){
			if(promoMinimumPerOrder>shoppingCart1.getOrderPrice()){
				promoStatus="You haven't reached the minimum order amount required to use this promotion; promo code is not valid.";
			}
		}
	  }
	}
    
    
    
    
    	if(request.getParameter("changeShipAddress")!=null && request.getParameter("changeShipAddress").equals("true")){
    		
    		String newAddr="insert into shipping_locations ( address2, address1, state, zip, country_id, contactid, location_title, city, ship_to_name,companyid) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
	    	PreparedStatement cAddr = conn.prepareStatement(newAddr);   
	    	cAddr.clearParameters(); 
    		cAddr.setString(1, request.getParameter("addressMail2E"));
    		cAddr.setString(2, request.getParameter("addressMail1E"));
    		cAddr.setString(3, request.getParameter("stateMailIdE"));
    		cAddr.setString(4, request.getParameter("zipcodeMailE"));
    		cAddr.setString(5, request.getParameter("countryMailIdE"));
    		cAddr.setString(6, up.getContactId());
    		cAddr.setString(7, request.getParameter("addressTitleE"));
    		cAddr.setString(8, request.getParameter("cityMailE"));
    		cAddr.setString(9, request.getParameter("shipToCompany"));
    		cAddr.setString(10, up.getCompanyId());
    	 	cAddr.executeUpdate();
    	 	
    	 	ResultSet lId = st.executeQuery("select max(id) as id from shipping_locations");
    	 	if (lId.next()){
    	 		shipId=lId.getInt("id");
		    	shoppingCart1.setShippingLocationId(shipId);
    	 	}
    	
    	} else{
		    String compAddr="select id from shipping_locations where address2=? and address1=? and state=? and zip=? and country_id=? and contactid=? and city=? and companyid=?";
			PreparedStatement cAddr = conn.prepareStatement(compAddr);
			cAddr.clearParameters();
			cAddr.setString(1, cB.getAddressMail2());
			cAddr.setString(2, cB.getAddressMail1());
			cAddr.setString(3, cB.getStateMailIdString());
			cAddr.setString(4, cB.getZipcodeMail());
			cAddr.setString(5, cB.getCountryMailIdString());
			cAddr.setString(6, up.getContactId());
			cAddr.setString(7, cB.getCityMail());
			cAddr.setString(8, up.getCompanyId());
			
		 	ResultSet lId = cAddr.executeQuery();
		 	if (lId.next() && lId.getString("id")!=null){
		 	
		 		if(shoppingCart1.getShippingLocationId()==0){
		 			shipId=lId.getInt("id");
		 			shoppingCart1.setShippingLocationId(shipId);
		 		}
		 		
		 	}else{
		 		//If there isn't a shipping location yet for the current user mailing address (or if the current address changed)
		 		
		 		//Change the existing 'default' titles to 'prior address'
		 		compAddr="select id from shipping_locations where contactid=? and location_title='Default' and active_flag=1";
	    		PreparedStatement cML = conn.prepareStatement(compAddr);
				cML.clearParameters();
				cML.setString(1, up.getContactId());
	    	 	ResultSet lML = cML.executeQuery();  	 	
	    	 	while (lML.next() && lML.getString("id")!=null){
					String updSL="update shipping_locations set location_title='Prior Address' where id=?";
					PreparedStatement uSL = conn.prepareStatement(updSL);
					uSL.clearParameters(); 
					uSL.setString(1, lML.getString("id"));
					uSL.executeUpdate();
					uSL.close();
	    	 	}
	    	 	
	    	 	//Insert the current mailing address as the 'Default' address   	 	
		 		String newAddr="insert into shipping_locations ( address2, address1, state, zip, country_id, contactid, location_title, city, companyid) values ( ?, ?, ?, ?, ?, ?, ?, ?, ?)";
				cAddr = conn.prepareStatement(newAddr);   
				cAddr.clearParameters(); 
		 		cAddr.setString(1, cB.getAddressMail2());
				cAddr.setString(2, cB.getAddressMail1());
				cAddr.setString(3, cB.getStateMailIdString());
				cAddr.setString(4, cB.getZipcodeMail());
				cAddr.setString(5, cB.getCountryMailIdString());
				cAddr.setString(6, up.getContactId());
				cAddr.setString(7, "Default");					
				cAddr.setString(8, cB.getCityMail());
				cAddr.setString(9, up.getCompanyId());
				cAddr.executeUpdate();
				
				lId = st.executeQuery("select max(id) as id from shipping_locations");
	    		if (lId.next()){
	    			shipId=lId.getInt("id");
	    			shoppingCart1.setShippingLocationId(shipId);
	    		}
    		}
    		
    			
    		//if there was a change in the shiplocation as per a user choice
			if(!shipLocationIdChoice.equals("0")){
				shipId=Integer.parseInt(shipLocationIdChoice);
				shoppingCart1.setShippingLocationId(shipId);
			} else {
    	 		shipId=shoppingCart1.getShippingLocationId();
    	 	}
    	 	
    	}
    	
/*
2. For each job in the cart validate whether the promo code applies to the product on that job
	- Is promotion disabled? If yes, then don't apply to job.
	- Does the total order amount meet the minimum amount for the promotion? (if promo amount=0 then all apply)
	- If no, then doesn't apply
	- If yes then does the product match the list of products included in the promotion? (if no products listed then all apply)
	- If yes then does the product match the list of products excluded from the promotion
	- If no then does the amount of product ordered meet the minimum to qualify for this promotion?
	- If yes then apply the promotion to the product and calculate the discount.
*/
	int checkForProdInclusion=0;
	int jobCount=0;

	if(promoStatus.equals("Valid")){
  		ResultSet rsPProds = st.executeQuery("select exclude_from_promo from product_promo_bridge where  status_id=2 and promo_code='"+promoCode+"'");
		while(rsPProds.next()){
			checkForProdInclusion=((rsPProds.getString("exclude_from_promo").equals("1") && checkForProdInclusion<2)?1:2);
      	}
		Vector projects1 = shoppingCart1.getProjects();
  		if (projects1.size() > 0) {
    		for (int jj = 0; jj < projects1.size(); jj++) {
      			jobCount = jj;
      			ProjectObject po1 = (ProjectObject) projects1.elementAt(jj);
      			Vector jobs1 = po1.getJobs();
      			for (int kk = 0; kk < jobs1.size(); kk++) {
        			JobObject jo1 = (JobObject) jobs1.elementAt(kk);
        			boolean excludeProd = false;
        			int triggerAmount=0;
        			jo1.setPromoCode("");
        			jo1.setDiscount(0.00);
        			if(checkForProdInclusion>0){
	        			ResultSet rsPP = st.executeQuery("select * from product_promo_bridge where status_id=2 and promo_code='"+promoCode+"' and prod_id='"+((jo1.getProductId()==null)?"0":jo1.getProductId())+"'");
	    	 			if (rsPP.next()){
	    	 				excludeProd=((rsPP.getString("exclude_from_promo").equals("1"))?true:false);
	    	 			}
    				}
    				if(checkForProdInclusion>1){
    					excludeProd=true;
	        			ResultSet rsPP = st.executeQuery("select * from product_promo_bridge where  status_id=2 and exclude_from_promo=0 and promo_code='"+promoCode+"' and prod_id='"+((jo1.getProductId()==null)?"0":jo1.getProductId())+"'");
	    	 			if (rsPP.next()){
	    	 				excludeProd=false;
	    	 				triggerAmount=rsPP.getInt("trigger_amount");
	    	 			}
    				}
    				
    				if (excludeProd){
    					jo1.setPromoProdMessage(((showProdPromoText)?"This product is not eligible for the current promotion.":""));
    				}else{
    					if(!promoSuffix.equals("")){
    						//see if there is a special price code set up for the amount of this purchase
    						boolean ppNotFound=true;
    						String ppcSQL="select pp.price-ppp.price as price,pp.id,ppp.id from products p left join product_prices pp on pp.prod_price_code = p.prod_price_code and pp.quantity='"+jo1.getQuantity()+"' and pp.site_id='"+shs.getSiteHostId()+"' left join product_prices ppp on ppp.prod_price_code=concat(p.prod_price_code,'_"+promoSuffix+"') where p.id='"+jo1.getProductId()+"'  and ppp.quantity='"+jo1.getQuantity()+"'";
							ResultSet rsPPC = st.executeQuery(ppcSQL);
 							if (rsPPC.next()){
 								if(rsPPC.getString("price")!=null){
 									jo1.setDiscount(rsPPC.getDouble("price"));
 									jo1.setPromoCode(promoCode);
 									ppNotFound=false;
 								}
 							}
 							if(ppNotFound){
 								ppcSQL="select pp.price-ppp.price as price,pp.id,ppp.id from products p left join product_prices pp on pp.prod_price_code = p.prod_price_code and pp.quantity='"+jo1.getQuantity()+"' left join product_prices ppp on ppp.prod_price_code=concat(p.prod_price_code,'_"+promoSuffix+"') where p.id='"+jo1.getProductId()+"'  and ppp.quantity='"+jo1.getQuantity()+"'";
								rsPPC = st.executeQuery(ppcSQL);
	 							if (rsPPC.next()){
	 								if(rsPPC.getString("price")!=null){
	 									jo1.setDiscount(rsPPC.getDouble("price"));
 										jo1.setPromoCode(promoCode);
	 									ppNotFound=false;
	 								}
	 							}
 							
 							}
    					}else{
	    					if(triggerAmount>jo1.getQuantity()){
	    						jo1.setPromoProdMessage("You have not ordered the minimum amount of "+triggerAmount+" for this product to qualify for the promotion.");
	    					}else{
								jo1.setDiscountPercentage(promoPercentage);
								jo1.setDiscountType(promoType);
								jo1.setDiscountIncludesShipping(((promoIncludesShipping)?1:0));
								jo1.setPromoCode(promoCode);
								promoJobs++;
								
	    					}
    					}
    				}
    			}
    		}
		}
	}
    	
    } else{
    
    %><script>window.parent.location='/';</script><%
    }
	String shipSQL="select l.*,c.tax_exempt as tax_exempt,state_tax_rate,tax_job_flag,tax_shipping_flag,state_abreviation as 'taxState' from shipping_locations l left join companies c on c.id=l.companyid left join lu_states st on st.state_number=l.state where l.id='"+shipId+"'";
	ResultSet lId = st.executeQuery(shipSQL);
 	if (lId.next()){
 		shipZip=lId.getString("zip");
 		shipState=lId.getString("state");
 		taxExempt=lId.getString("tax_exempt");
 		taxEntity=lId.getString("state");
 		taxJob=lId.getString("tax_job_flag");
  		taxShipping=lId.getString("tax_shipping_flag");
  		taxState=lId.getString("taxState");
  		taxRate=lId.getInt("state_tax_rate");
 	}

//boolean returned = (request.getParameter("returned") != null && request.getParameter("returned").equals("true")) ? true : false;
//boolean shippingCalculated = (request.getParameter("shippingCalculated") != null && request.getParameter("shippingCalculated").equals("true")) ? true : false;

    int creditStatus = 0;
    int countryId = 0;
    String nonUSTxt = "";
    String pageId = "";
    String orderSummaryTxt = "";
    String spPageId = "";
    int co_days = 0;
    int jobId = 0;
    String fileName = "";
    boolean useCC=false;
    boolean useOnAccount=false;    
    boolean useACH=false;
    boolean usePrePayByCheck=false;
    int poId = 0;
    ResultSet coRS = st.executeQuery("select distinct if(b.id is not null,b.default_number,a.default_number) as 'default_number',use_cc,use_ach,use_on_account,use_prepay_by_check from site_hosts sh, sys_defaults a left join sys_defaults b on a.title=b.title and b.sitehost_id='" + shs.getSiteHostId() + "' where sh.id='" + shs.getSiteHostId() + "' and a.title='checkout_hold'");
    if (coRS.next()) {
      	co_days = coRS.getInt("default_number");
        useCC=((coRS.getString("use_cc").equals("0"))?false:true);
     	useOnAccount=((coRS.getString("use_on_account").equals("0"))?false:promoAllowOnAccount);    
     	useACH=((coRS.getString("use_ach").equals("0"))?false:true);
		usePrePayByCheck=((coRS.getString("use_prepay_by_check").equals("0"))?false:true);
    }

    int orderBalance = 0;
    String balanceSQL = "select (sum(t.price) +  sum(t.shipprice)) - sum(t.payments) balance from (select  sum(j.price) price, 0 as shipprice, 0 as  payments from contacts c, jobs  j  where if(c.default_site_number=0,c.companyid=j.jbuyer_company_id,j.site_number=c.default_site_number)  and  c.id=" + up.getContactId() + " and j.status_id<>9 and j.status_id < 120  group by c.id union select 0 as  price, 0 as shipprice,  sum(arcd.payment_amount) payments from contacts c, jobs  j left join ar_invoice_details ari on ari.jobid=j.id left join ar_collection_details arcd on ari.ar_invoiceid=arcd.ar_invoiceid   where if(c.default_site_number =0,c.companyid=j.jbuyer_company_id,j.site_number=c.default_site_number)  and  c.id=" + up.getContactId() + " and j.status_id<>9 and j.status_id < 120  group by c.id union select 0 as  price, sum(s.price) as shipprice, 0 as payments from contacts c, jobs  j left join shipping_data s on s.job_id=j.id  where if(c.default_site_number=0,c.companyid=j.jbuyer_company_id,j.site_number=c.default_site_number)  and  c.id=" + up.getContactId() + " and j.status_id<>9 and j.status_id < 120  group by c.id) as t";

    ResultSet balRS = st.executeQuery(balanceSQL);
    while (balRS.next()) {
      orderBalance = balRS.getInt("balance");
    }
	String taxID="";
    int creditLimit = 0;
    double invoiceBalance = 0.00;
    double propInvoiceBalance = 0.00;
    String creditQuery = "select cs.credit_status,country_id,p.body as body,sp.body as spBody,p.id pageId,sp.id spPageId, cs.credit_limit,c.taxid from v_credit_status cs left join companies c on c.id=cs.company_id,locations l left join pages p on p.title='Non US Shipments' left join pages sp on sp.page_name='orderSummaryText' where l.companyid=c.id  and c.id="+up.getCompanyId()+" group by c.id";
    ResultSet creditRS = st.executeQuery(creditQuery);
    while (creditRS.next()) {
      creditStatus = creditRS.getInt("credit_status");
      countryId = creditRS.getInt("country_id");
      creditLimit = creditRS.getInt("credit_limit");
      nonUSTxt = creditRS.getString("body");
      pageId = creditRS.getString("pageId");
      orderSummaryTxt = creditRS.getString("spBody");
      spPageId = creditRS.getString("spPageId");
      taxID = ((creditRS.getString("taxid")==null)?"":creditRS.getString("taxid"));
    }
%><html>
<head><%
if (session.getAttribute("selfDesigned") == null || session.getAttribute("selfDesigned").toString().equals("false")) {
    %><title>Order Summary</title>
  <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
  <link rel="stylesheet" href="/styles/marcomet.css" type="text/css">
  <link rel="stylesheet" href='<%=(String) session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css' type="text/css">
  <META HTTP-EQUIV="Cache-Control" CONTENT="no-cache">
  <META HTTP-EQUIV="Pragma" CONTENT="no-cache">
  <META HTTP-EQUIV="Expires" CONTENT="-1">
  <style type="text/css">
	.nonUSTxt {background-color: #ffffcc;}
	
	.stepHeader{
		background-image: url('/images/gray_white_back.jpg');
		border-bottom:1px gray solid;
		vertical-align: middle;
		padding: 5px;
		height: 21px;
	}
	.oldStepHeader{
		color:gray;
	}
	a.oldStepHeader:link{
		color:gray;
	}
	a.oldStepHeader:visited{
		color:gray;
	}
	a.oldStepHeader:hover{
		color:red;
	}
	
	.errorBox{
		font-size: 9pt;
		text-align: left;
		background-color: #f4ecda;
		border: 1px red solid;
		color:black;
		
	}
	</style>
  <script language="javascript" src="/javascripts/mainlib.js" type="text/javascript"></script>
  <script type="text/javascript">
  	
	function showSection(section){
		document.getElementById('step1').style.display='none';
		document.getElementById('step2').style.display='none';
		document.getElementById('step3').style.display='none';
		document.getElementById(section).style.display='';
		document.forms[0].coStep.value=section;
	}
	function showPaymentForm(section){
		<%=((useCC)?"document.getElementById('cc').style.display='none';":"")%>
		<%=((useACH)?"document.getElementById('ach').style.display='none';":"")%>
		<%=((useOnAccount)?"document.getElementById('account').style.display='none';":"")%>
		<%=((usePrePayByCheck)?"document.getElementById('check').style.display='none';":"")%>
		document.getElementById(section).style.display='';
		document.getElementById("paySelect1").style.display='none';
		document.getElementById("paySelect2").style.display='none';		
	}
	
	function submitFinalOrder(){
		var errMsg="";
		var payType="";
		var acctType="";
		var workflowId="1";
		for (var i=0; i < document.forms[0].pay_type.length; i++) {
		   if (document.forms[0].pay_type[i].checked){
      			payType = document.forms[0].pay_type[i].value;
      		}
   		}
   		for (var j=0; j < document.forms[0].acct_type.length; j++) {
		   if (document.forms[0].acct_type[j].checked){
      			acctType = document.forms[0].acct_type[j].value;
      		}
   		}
		if (payType == null || payType == ''){
			errMsg="Please choose a payment type before proceeding.";
		} else if (payType == 'cc'){
			workflowId="120";
			if (document.forms[0].pastref.value=='' || document.forms[0].pastref.value=='NEW'){
				if(document.forms[0].ccNumber.value==''){
					errMsg="Please enter a credit card number before proceeding.";
				} else if(document.forms[0].ccvNumber.value==''){
					errMsg="Please enter a CCV number before proceeding.";
				} else{
					document.forms[0].dollarAmount.value=document.forms[0].totalDollarAmount.value;
				}
			}
		} else if (payType == 'check'){
			workflowId="121";
		
		} else if (payType == 'ach'){
			workflowId="120";
				if(acctType==''){
					errMsg="Please choose an account type before proceeding.";
				} else if(document.forms[0].accountName.value==''){
					errMsg="Please enter the name on the account before proceeding.";
				} else if(document.forms[0].bankName.value==''){
					errMsg="Please enter the bank name before proceeding.";
				} else if(document.forms[0].accountNumber.value==''){
					errMsg="Please enter the account number before proceeding.";
				} else if(document.forms[0].routingNumber.value==''){
					errMsg="Please enter the bank routing number before proceeding.";
				} else if(document.forms[0].bankCity.value==''){
					errMsg="Please enter the bank city before proceeding.";
				} else if(document.forms[0].bankState.value==''){
					errMsg="Please enter the bank state before proceeding.";
				} else {
					document.forms[0].dollarAmount.value=document.forms[0].totalDollarAmount.value;
				} 
		}else{
			document.forms[0].dollarAmount.value='0';
		}

		if (errMsg==""){
			 moveWorkFlow(workflowId);
		}else{
			alert(errMsg);
		}
	}
	
	function submitForm(){
		document.forms[0].submit();
	}
	
</script>
</head>
<body style="margin-left:20px;margin-top:10px;font-size:9pt;">
<form method="post" action="/servlet/com.marcomet.sbpprocesses.ProcessJobSubmit" >
<%
    int validprop = 0;
    String propertyvalidationQuery = "SELECT  distinct contacts.id,contacts.default_site_number AS csite,v_properties.site_number AS wsite FROM contacts Inner Join locations on locations.contactid=contacts.id and locations.locationtypeid=1 Left Join v_properties ON contacts.default_site_number = v_properties.site_number and ( left(v_properties.zip,5) =left(locations.zip,5) or  left(v_properties.alt_zip,5) =left(locations.zip,5)) WHERE contacts.id= " + up.getContactId() + "  and ((v_properties.site_number IS NOT NULL  AND contacts.default_site_number is not null and contacts.default_site_number <> '0' and contacts.default_site_number <> '') or bypass_site_number_validation_flag=1 or contacts.default_site_number='000') order by contacts.default_site_number";

    ResultSet propRS = st.executeQuery(propertyvalidationQuery);
    while (propRS.next()) {
      validprop = 1;
    }

    String proparQuery = "select ari.invoice_number, ari.creation_date, ari.ar_invoice_amount, sum(arcd.payment_amount) as invoice_payments, ari.ar_invoice_amount - (if(sum(arcd.payment_amount) is null,0,sum(arcd.payment_amount))) as invoice_balance, (TO_DAYS(NOW()) - TO_DAYS(ari.creation_date)) as age from contacts c left join jobs j on  if(c.default_site_number is null or c.default_site_number=0 or TRIM(LEADING '0' from default_site_number)='' ,j.jbuyer_company_id=c.companyid, j.site_number=c.default_site_number)  inner join ar_invoice_details arid on arid.jobid=j.id left join ar_invoices ari on ari.id=arid.ar_invoiceid left join ar_collection_details arcd on arcd.ar_invoiceid=ari.id  where  c.id =" + up.getContactId() + "  and arid.ar_invoiceid=ari.id and  (ari.exclude_from_credit_check<>1 and ari.exclude_from_statements<>1)  and  (ari.vendor_id = 105 or ari.vendor_id = 2 or ari.vendor_id = 0)  group by ari.invoice_number having (invoice_balance) >0.001 or (invoice_balance) < -0.001  order by ari.creation_date";

    ResultSet proparRS = st.executeQuery(proparQuery);
    while (proparRS.next()) {
      propInvoiceBalance += (proparRS.getString("invoice_balance") == null || proparRS.getDouble("invoice_balance") > 0 ? 0 : proparRS.getDouble("invoice_balance"));
      if ((proparRS.getString("invoice_balance") != null && proparRS.getDouble("invoice_balance") > .001) && proparRS.getInt("age") > co_days) {
        propInvoiceBalance += proparRS.getDouble("invoice_balance");
        proppastdue = 1;
      } else if ((proparRS.getString("invoice_balance") != null && proparRS.getDouble("invoice_balance") < .001)) {
        propInvoiceBalance += proparRS.getDouble("invoice_balance");
      }
    }

if(!taxID.equals("")){
   proparQuery = "select ari.invoice_number, ari.creation_date, ari.ar_invoice_amount, sum(arcd.payment_amount) as invoice_payments, ari.ar_invoice_amount - (if(sum(arcd.payment_amount) is null,0,sum(arcd.payment_amount))) as invoice_balance, (TO_DAYS(NOW()) - TO_DAYS(ari.creation_date)) as age from contacts c,companies cp left join companies ct on ct.taxid=cp.taxid left join jobs j on j.jbuyer_company_id=ct.id inner join ar_invoice_details arid on arid.jobid=j.id left join ar_invoices ari on ari.id=arid.ar_invoiceid left join ar_collection_details arcd on arcd.ar_invoiceid=ari.id  where c.companyid=cp.id and cp.taxid is not null and cp.taxid<>'' and c.id =" + up.getContactId() + "  and arid.ar_invoiceid=ari.id and  (ari.exclude_from_credit_check<>1 and ari.exclude_from_statements<>1)  and  (ari.vendor_id = 105 or ari.vendor_id = 2 or ari.vendor_id = 0)  group by ari.invoice_number having (invoice_balance) >0.001 or (invoice_balance) < -0.001  order by ari.creation_date";

   proparRS = st.executeQuery(proparQuery);
    while (proparRS.next()) {
      propInvoiceBalance += (proparRS.getString("invoice_balance") == null || proparRS.getDouble("invoice_balance") > 0 ? 0 : proparRS.getDouble("invoice_balance"));
      if ((proparRS.getString("invoice_balance") != null && proparRS.getDouble("invoice_balance") > .001) && proparRS.getInt("age") > co_days) {
        propInvoiceBalance += proparRS.getDouble("invoice_balance");
        proppastdue = 1;
      } else if ((proparRS.getString("invoice_balance") != null && proparRS.getDouble("invoice_balance") < .001)) {
        propInvoiceBalance += proparRS.getDouble("invoice_balance");
      }
    }

}
    proppastdue = ((propInvoiceBalance < .01) ? 0 : proppastdue);

    invoiceBalance = 0;
    String arQuery = "select ari.invoice_number, ari.creation_date, ari.ar_invoice_amount, sum(arcd.payment_amount) as invoice_payments, ari.ar_invoice_amount - (if(sum(arcd.payment_amount) is null,0,sum(arcd.payment_amount))) as invoice_balance, (TO_DAYS(NOW()) - TO_DAYS(ari.creation_date)) as age from ar_invoices ari left join ar_collection_details arcd on arcd.ar_invoiceid=ari.id where (ari.exclude_from_credit_check<>1 and ari.exclude_from_statements<>1) and  (ari.vendor_id = 105 or ari.vendor_id = 2 or ari.vendor_id = 0) and ari.bill_to_companyid =" + up.getCompanyId() + " group by ari.invoice_number having (invoice_balance) >0.001 or (invoice_balance) < -0.001 order by ari.creation_date";

    ResultSet arRS = st.executeQuery(arQuery);
    while (arRS.next()) {
      invoiceBalance += ((arRS.getString("invoice_balance") == null || arRS.getDouble("invoice_balance") > 0) ? 0 : arRS.getDouble("invoice_balance"));
      if ((arRS.getString("invoice_balance") != null && arRS.getDouble("invoice_balance") > .001) && arRS.getInt("age") > co_days) {
        invoiceBalance += arRS.getDouble("invoice_balance");
        pastdue = 1;
      } else if ((arRS.getString("invoice_balance") != null && arRS.getDouble("invoice_balance") < .001)) {
        invoiceBalance += arRS.getDouble("invoice_balance");
      }
    }

    pastdue = ((invoiceBalance < .01) ? 0 : pastdue);

//Start the main content area
%><div class="title" id="title">Order Review / Checkout - site: <%= up.getSiteNumber() %></div><%
        
//Begin Ship Info
%><div id="step1" class="bodyblack" style="border:1px black solid;"><div class='stepHeader'><span class="subtitle">STEP 1: SHIPPING ADDRESS<span class="oldStepHeader">&nbsp;&raquo;&nbsp;STEP 2: ORDER REVIEW&nbsp;&raquo;&nbsp;STEP 3: PAYMENT OPTIONS&nbsp;&raquo;&nbsp;STEP 4: RECEIPT</span></div>
              <jsp:include page="/includes/OrderCheckOutFormInc.jsp" flush="true">
                <jsp:param name="shippingLocationId" value="<%=shipId%>"></jsp:param>
              </jsp:include>
              <br><br>
<div align="center"  id="processButtons">
		<a href='javascript:parent.window.location.replace("/index.jsp?contents=<%=(String) session.getAttribute("siteHostRoot")%>/contents/SiteHostIndex.jsp")' class="menuLINK">CONTINUE&nbsp;SHOPPING</a>
		&nbsp;&nbsp;&nbsp;
<a href='javascript:showSection("step2")' class="menuLINK">&nbsp;NEXT&nbsp;&raquo;&nbsp;</a></div>
</div>
<%

//End Ship Info

//Start the Order Summary Table
%><div id="step2" style="border: 1px black solid;display:none;"><div class='stepHeader'><span class="subtitle"><a href="javascript:showSection('step1')" class="oldStepHeader">STEP 1: SHIPPING ADDRESS&nbsp;&raquo;&nbsp;</a>STEP 2: ORDER REVIEW<span  class="oldStepHeader">&nbsp;&raquo;&nbsp;STEP 3: PAYMENT OPTIONS&nbsp;&raquo;&nbsp;STEP 4: RECEIPT</span></div>
	<table width="98%" class="body">
          <tr>
            <td class="planheader1" width="7%" height="9">Remove</td>
            <td class="planheader1" width="40%" height="9">Item / Job Name (Click to view Details)</td>
            <td class="planheader1" width="8%" height="9">Quantity</td>
            <td class="planheader1" width="9%" height="9">
              Price
            </td>
            <!--<td class="planheader1" width="9%" height="8"><div align="right">Deposit/Payment&nbsp;</div></td>-->
            <%if(promoStatus.equals("Valid")){%><td class="planheader1" width="9%" height="9"><div align="right">Discount</div></td><%}%>
            <td class="planheader1" width="9%" height="9">
              <div align="right">Shipping</div>
            </td>
            <td class="planheader1" width="9%" height="9">Total</td>
          </tr><%
          
    double priceSubtotal = 0.00;
    double shipSubtotal = 0.00;
    double depositSubtotal = 0.00;
    double joStdShippingPrice = 0.00;
    boolean ordersPresent = false;
    double salesTaxTotal=0.00;

    int jobCount = -1;
    String shippingType = "";
    //String shipPolicy = "1";

    int jobNo = (request.getParameter("jobNo") != null) ? Integer.parseInt(request.getParameter("jobNo")) : -1;
    String shipType = request.getParameter("shipType");

    ShoppingCart shoppingCart = (ShoppingCart) session.getAttribute("shoppingCart");
    CatalogShipmentCreationServlet shipment = new CatalogShipmentCreationServlet();
    if (shipmentOption != null) {
      shipment.setShipmentOption(shipmentOption);
    }
    
    shipment.createShipment(session);
    
    //ShoppingCart shoppingCart = (ShoppingCart) session.getAttribute("shoppingCart");
    
    if (shoppingCart != null) {
      Vector shipments = shoppingCart.getShipments();	
      Vector wareHouses = new Vector();
      if (shipments.size() > 0) {
        for (int j = 0; j < shipments.size(); j++) {
          jobCount = j;
          ShipmentObject so = (ShipmentObject) shipments.elementAt(j);
          Vector jobs = so.getJobs();
          double soWeight = so.getWeight();
          double soShippingCost = 0.00;
          //soShippingCost = so.getShippingCost() + so.getHandlingCost();
          if (wareHouses.size() == 0) {
            wareHouses.addElement(so.getZipFrom());
            so.calculateSVFee(request);
          } else if (!wareHouses.contains(so.getZipFrom())) {
            so.calculateSVFee(request);
          }

          for (int k = 0; k < jobs.size(); k++) {
            JobObject jo = (JobObject) jobs.elementAt(k);
            int projectId = so.getProjectId(k);

            //if this page was entered as a result of a self-help designed file run that was turned into an order push the price and quantity values into the job and remove the 'usePreview' from session....
            if (request.getParameter("priorJobId") != null && !request.getParameter("priorJobId").equals("")) {
              jo.setPriorJobId(((request.getParameter("priorJobId") == null || request.getParameter("priorJobId").equals("")) ? "" : request.getParameter("priorJobId")));
            }

            if (request.getParameter("orderFromSelfDesigned") != null && request.getParameter("orderFromSelfDesigned").equals("true")) {
              //push quantity and price into job
              jo.setQuantity(Integer.parseInt(((request.getParameter("quantity") == null || request.getParameter("quantity").equals("")) ? "0" : request.getParameter("quantity"))));
              double jPrice = Double.parseDouble(((request.getParameter("price") == null || request.getParameter("price").equals("")) ? "0" : request.getParameter("price")));
              JobSpecObject jso = new JobSpecObject(99999, 99999, "Base Price", jPrice, 0.00, Integer.parseInt(up.getContactId()), Integer.parseInt(shs.getSiteHostId()), false);

              jo.addJobSpec(jso);
              session.setAttribute("usePreview", "false");
              session.setAttribute("selfDesigned", "false");
            }

            double price = jo.getPrice();
            double deposit = jo.getEscrowDollarAmount();
            double discount =jo.getDiscount();
            double handlingCost = 0.00;
            int shipmentId = 0;
            int shipPricePolicy = 0;
            jo.setDiscount(discount);
            ordersPresent = true;

            String productId = "", contactId = "", shipPolicy = "";
            int amount = 0, state = 0, shipPriceSource = 0;
            double joTotalWeight = 0.00;
            double joPercentShipment = 0.00, ppShipPercentage = 0.00, pShipPercentage = 0.00;

            state = so.getZipToStateCode();
            if (state > 53 || state == 2 || state == 12) {
              System.out.println("from outside of the U.S. continent..");
              joStdShippingPrice = 0.00;
              shipPricePolicy = 0;
              shipPriceSource = 0;
            } else {
              JobSpecObject jsoProductCode = (JobSpecObject) jo.getJobSpecs().get("9001");
              String query = "SELECT id FROM products WHERE prod_code='" + jsoProductCode.getValue() + "'";
              ResultSet rs = st.executeQuery(query);
              if (rs.next()) {
                productId = rs.getString("id");
              }
              rs.close();
              contactId = (String) session.getAttribute("contactId");
              JobSpecObject jsoQuantity = (JobSpecObject) jo.getJobSpecs().get("705");
              amount = ((jsoQuantity==null || jsoQuantity.getValue()==null || jsoQuantity.getValue().equals(""))?0:Integer.parseInt(jsoQuantity.getValue()));


              query = "SELECT pp.weight_per_box 'weight', pp.number_of_boxes FROM product_prices pp, products p WHERE pp.quantity=" + amount + " AND pp.prod_price_code=p.prod_price_code AND p.id=" + productId;
              ResultSet rs1 = st.executeQuery(query);
              if (rs1.next()) {
                joTotalWeight = (Double.parseDouble(rs1.getString("number_of_boxes")) * Double.parseDouble(rs1.getString("weight")));
              }


              query = "SELECT pp.ship_price_policy, pp.std_ship_price, pp.pp_default_ship_percentage, p.default_ship_percentage,p.taxable FROM product_prices pp, products p WHERE pp.quantity=" + amount + " AND pp.prod_price_code=p.prod_price_code AND p.id=" + productId;
              ResultSet rs2 = st.executeQuery(query);
              if (rs2.next()) {
              	taxable=((taxExempt.equals("1"))?"0":rs2.getString("taxable"));
                shipPolicy = rs2.getString("ship_price_policy");
                ppShipPercentage = rs2.getDouble("pp_default_ship_percentage");
                pShipPercentage = rs2.getDouble("default_ship_percentage");
                if (shipPolicy.equals("0")) {
                  if (soWeight == 0.00) {
                    if (ppShipPercentage == 0.00) {
                      if (pShipPercentage == 0.00) {
                        joStdShippingPrice = 0.00;
                        shipPricePolicy = 0;
                        shipPriceSource = 1;
                      } else {
                        joStdShippingPrice = (price * (pShipPercentage / 100));
                        shipPricePolicy = 2;
                        shipPriceSource = 1;
                      }
                    } else {
                      joStdShippingPrice = (price * (ppShipPercentage / 100));
                      shipPricePolicy = 2;
                      shipPriceSource = 1;
                    }
                  } else {
                    //joStdShippingPrice = joStdShippingPrice;
                    so.calculateShippingCost(request);
                    soShippingCost = so.getShippingPrice();
                    if (soShippingCost != 0.00) {
                      joPercentShipment = ((joTotalWeight / soWeight) * 100);
                      joStdShippingPrice = (soShippingCost * (joPercentShipment / 100));
                      shippingType = so.getShipType();
                      shipmentId = so.getId();

                    } else {
                      if (ppShipPercentage == 0.00) {
                        if (pShipPercentage == 0.00) {
                          joStdShippingPrice = 0.00;
                          shipPricePolicy = 0;
                          shipPriceSource = 1;
                        } else {
                          joStdShippingPrice = (price * (pShipPercentage / 100));
                          shipPricePolicy = 2;
                          shipPriceSource = 1;
                        }
                      } else {
                        joStdShippingPrice = (price * (ppShipPercentage / 100));
                        shipPricePolicy = 2;
                        shipPriceSource = 1;
                      }
                    }

                    shipPricePolicy = 2;
                    shipPriceSource = 0;
                  }
                } else if (shipPolicy.equals("1")) {
                  joStdShippingPrice = 0.00;
                  shipPricePolicy = 1;
                  shipPriceSource = 1;
                } else if (shipPolicy.equals("2")) {
                  joStdShippingPrice = Double.parseDouble(rs1.getString("std_ship_price"));
                  shipPricePolicy = 2;
                  shipPriceSource = 1;
                } else if (shipPolicy.equals("3")) {
                  if (ppShipPercentage == 0.00) {
                    if (pShipPercentage == 0.00) {
                      joStdShippingPrice = 0.00;
                      shipPricePolicy = 0;
                      shipPriceSource = 1;
                    } else {
                      joStdShippingPrice = (price * (pShipPercentage / 100));
                      shipPricePolicy = 3;
                      shipPriceSource = 1;
                    }
                  } else {
                    joStdShippingPrice = (price * (ppShipPercentage / 100));
                    shipPricePolicy = 3;
                    shipPriceSource = 1;
                  }
                } else if (shipPolicy.equals("4")) {
                  joStdShippingPrice = 0.00;
                  shipPricePolicy = 4;
                  shipPriceSource = 0;
                }
              } 
            }

            System.out.println("shipPricePolicy : " + shipPricePolicy);
            System.out.println("shipPriceSource : " + shipPriceSource);
            jo.setShipPricePolicy(shipPricePolicy);
            jo.setShipPriceSource(shipPriceSource);
            jo.setShippingPrice(joStdShippingPrice);
            jo.setShippingType(shippingType);
            jo.setShipmentId(shipmentId);
            /*

Calculate the Discount:
	- If there is already a discount applied on the job from a suffix on the prod price code use that and don't calculate further
	- If promotion is % then discount= % * (job price + (if price only is flagged before shipping, else + shipping price))
	- If promotion is $$ then discount= (job price (with or without shipping depending on flag)/total price of eligible jobs (with/without shipping depending on flag)) * $$
	- If promotion is % off shipping then discount= % * calculated shipping price
	- If promotion is $$ off shipping then discount=$$
	- If promotion is Free Shipping then discount=calculated shipping price
*/
			double shipDiscount=0.00;
            if(promoStatus.equals("Valid") && (jo.getPromoProdMessage()==null || jo.getPromoProdMessage().equals(""))){
              if(jo.getDiscount()>0.00){
              	//use the discount already applied to the job.
              }else{
            	if (promoShippingOnly){
		            if (jo.getDiscountPercentage()>0.00){
		            	if(amountUsable>-999){
		            		shipDiscount=((jo.getDiscountPercentage()*jo.getShippingPrice()<amountUsable)?jo.getDiscountPercentage()*jo.getShippingPrice():amountUsable);
		            		amountUsable=(((amountUsable-jo.getDiscountPercentage()*jo.getShippingPrice())>0)?amountUsable-jo.getDiscountPercentage()*jo.getShippingPrice():0);
		            	}else{
		            		shipDiscount=jo.getDiscountPercentage()*jo.getShippingPrice();
		            	}
		            	jo.setDiscount(shipDiscount);
		            }else if (promoFixedAmount>0){
		            	if(amountUsable>-999){
			            	shipDiscount=((promoFixedAmount/promoJobs<amountUsable)?promoFixedAmount/promoJobs:amountUsable);
			            	amountUsable=(((amountUsable-promoFixedAmount/promoJobs)>0)?amountUsable-promoFixedAmount/promoJobs:0);
			            }else{
			            	shipDiscount=promoFixedAmount/promoJobs;
			            }
		            	jo.setDiscount(((shipDiscount>jo.getShippingPrice())?jo.getShippingPrice():shipDiscount));	
	            	}
            	}else{
		            if (jo.getDiscountPercentage()>0.00){
		            	if(amountUsable>-999){
		            		jo.setDiscount(((jo.getDiscountPercentage()* ((promoIncludesShipping)?jo.getPrice()+jo.getShippingPrice():jo.getPrice()))<amountUsable)?(jo.getDiscountPercentage()*((promoIncludesShipping)?jo.getPrice()+jo.getShippingPrice():jo.getPrice())):amountUsable);
		            		amountUsable=((amountUsable-(jo.getDiscountPercentage()*((promoIncludesShipping)?jo.getPrice()+jo.getShippingPrice():jo.getPrice()))>0)?amountUsable-(jo.getDiscountPercentage()*((promoIncludesShipping)?jo.getPrice()+jo.getShippingPrice():jo.getPrice())):0);
		            	}else{
		            		jo.setDiscount(jo.getDiscountPercentage()*((promoIncludesShipping)?jo.getPrice()+jo.getShippingPrice():jo.getPrice()));
		            	}
		            }else if (promoFixedAmount>0){
		            	if(amountUsable>-999){
		            		jo.setDiscount(((promoFixedAmount/promoJobs<amountUsable)?promoFixedAmount/promoJobs:amountUsable));
		            		amountUsable=(((amountUsable-promoFixedAmount/promoJobs)>0)?amountUsable-promoFixedAmount/promoJobs:0);	
		            	}else{
		            		jo.setDiscount(promoFixedAmount/promoJobs);
		            	}
	            	}
	            }
	          }
            }

			
    		BigDecimal jbd = new BigDecimal(((taxShipping.equals("1"))?taxRate*(jo.getShippingPrice()/100):0.00) + ((taxJob.equals("1"))? ((taxRate*(jo.getPrice()-jo.getDiscount()))/100):0.00) );
    		jbd = jbd.setScale(decimalPlace,BigDecimal.ROUND_UP);
    		double stax=((taxable.equals("0"))?0.00:jbd.doubleValue());
    		jo.setSalesTax(stax);
			salesTaxTotal+=stax;
            
            jo.setPercentageOfShipment(joPercentShipment);
            jobId=jo.getId();
            shipTBD=(( (shipPricePolicy==0 && joStdShippingPrice == 0.00) || shipPricePolicy==0 || shipPricePolicy==4)?true:shipTBD);
            
            
          %><tr>
            <td class="lineitems">
				<div align="center"><a href='/catalog/summary/RemoveProjectConfirmation.jsp?projectId=<%= projectId + ""%>&amp;confirm=true&amp;shipmentOption=<%= shipmentOption + ""%>' class="minderACTION"><img src="/images/delete.jpg" border="0" alt="Remove Job from Shopping Cart"></a></div></td>
            <td class="lineitems"><a href="javascript:pop('/catalog/summary/OrderSummaryJobDetails.jsp?jobId=<%= jo.getId()%>','500','500')" class="minderACTION"><%=jo.getJobName()%></a><%if(jo.getPromoProdMessage()!=null && !jo.getPromoProdMessage().equals("")){%><font color='red'><br><%=jo.getPromoProdMessage()%></font><%}%></td>
            <td class="lineitems"><div align="right"><%=((jo.getQuantity() == 0) ? "NA" : numberFormatter.format(jo.getQuantity()))%></div></td>
            <td class="lineitems"><div align="right"><%= (jo.isRFQ()) ? "RFQ" : formater.getCurrency(price)%></div></td>
            <!--<td class="lineitems"><div align="right"><%= formater.getCurrency(deposit)%></div></td>-->
          <% if (promoStatus.equals("Valid")){
          %>  <td class="lineitems"><div align="right"><%= formater.getCurrency(jo.getDiscount())%></div></td>
          <%}%>
            <td class="lineitems"><div align="right"><%= (((shipPricePolicy==0 && joStdShippingPrice == 0.00) || shipPricePolicy==0 || shipPricePolicy==4)? "TBD *" : formater.getCurrency(joStdShippingPrice))%></div></td><%
            
			double total = ((jo.isRFQ() ? 0.00 : price)) - deposit + joStdShippingPrice;
	
%>			<td class="lineitems"><div align="right"><%= formater.getCurrency(total-jo.getDiscount())%></div></td>
          </tr><%
                } 
              }  
              totalPrice = shoppingCart.getOrderPrice() - shoppingCart.getDiscount() - shoppingCart.getOrderEscrowTotal() + shoppingCart.getShippingPrice();
          %><tr>
            <td>&nbsp;</td>
            <td>&nbsp;</td>
            <td class="lineitems"><div align="right">Totals:</div></td>
            <td class="lineitems"><div align="right"><%= formater.getCurrency(shoppingCart.getOrderPrice())%></div></td>
<!--            <td class="lineitems"><div align="right"><%= formater.getCurrency(shoppingCart.getOrderEscrowTotal())%></div></td>-->
<%if(promoStatus.equals("Valid")){%><td class="lineitems"><div align="right"><%= formater.getCurrency(shoppingCart.getDiscount())%></div></td><%}%>
            <td class="lineitems"><div align="right"><%= formater.getCurrency(shoppingCart.getShippingPrice())%></div></td>
            <td class="lineitems"><div align="right"><%= formater.getCurrency(totalPrice)%></div></td>
          </tr><%
          

    		double bd = salesTaxTotal;
    		double da = bd+totalPrice;
    		DecimalFormat twoDForm = new DecimalFormat("#.##");
    		//da = da.setScale(decimalPlace,BigDecimal.ROUND_UP);
    		
    		dollarAmount= Double.valueOf(twoDForm.format(da))+"";
    		overLimit = (((orderBalance + Double.valueOf(twoDForm.format(da))) > creditLimit && creditLimit > 1) ? true : false);
      		notOverLimit = ((overLimit) ? false : true);
    		 
          %>
          <tr><td colspan="<%=((promoStatus.equals("Valid"))?"6":"5")%>" class="lineitems"><div align="right"><%=((taxExempt.equals("1"))?"(Customer is exempt from sales tax) ":"")%><%=taxState%> Sales Tax (<%=taxRate%>%):</div></td><td class="lineitems"><div align="right"><input type="hidden" name="salestaxAmount" value="<%=formater.getCurrency(bd)%>"><%= formater.getCurrency(bd)%></div></td></tr>
          <tr><td colspan="<%=((promoStatus.equals("Valid"))?"6":"5")%>" class="lineitems"><div align="right">Total:</div></td><td class="lineitems"><div align="right"><input type="hidden" name="dollarAmount" value="<%= dollarAmount%>"><input type="hidden" name="totalDollarAmount" value="<%= dollarAmount%>"><%= formater.getCurrency((bd+totalPrice))%></div></td></tr>
		<tr align="left">
		    <td>&nbsp;</td>
            <td colspan="5"><%=((shipTBD)?"<div class='bodyBlack'>* TBD: Shipping cost could not be determined at this time. Shipping will be calculated and billed prior to order shipment.<br><br></div>":"")%><%
       if(sl.getValue("site_hosts","id",shs.getSiteHostId(),"hide_shipping_options").equals("0")){
            %><input type="hidden" name="shipmentOptionStr" value="<%=shipmentOption%>" >
              <input name="shipmentOption" value="0" type="radio" onclick="if(this.checked) {document.forms[0].action='';document.forms[0].shipmentOptionStr.value='1';document.forms[0].submit();}" <%= ((shipmentOption.equals("1"))?"checked":"")%> >&nbsp;Hold and Ship items together where possible to minimize shipping cost
              <br>
              <input name="shipmentOption" value="1" type="radio" onclick="if(this.checked) {document.forms[0].action='';document.forms[0].shipmentOptionStr.value='2';document.forms[0].submit();}" <%=((shipmentOption.equals("2"))?"checked":"")%>  >&nbsp;Ship items as they become available
              <%}else{%>
              	<input name="shipmentOption" type=hidden value="<%=shipmentOption%>">
              <%}%>
            </td>
          </tr>
          <tr>
            <td>&nbsp;</td>
            <td colspan="5"><%
            
            if(showPromoDetails){
	            if (session.getAttribute("promoCode") == null || session.getAttribute("promoCode").toString().equals("")) {
	            	%><a href="javascript:pop('/popups/PromoCode.jsp','250','150')" class='graybutton'  style="padding:2px;font-size:10pt;">&nbsp;&raquo;&nbsp;Apply&nbsp;Promo&nbsp;Code&nbsp;</a><span align="right" id="promoCode" class='lineitems'></span><%
	            } else {
	            	%><a href="javascript:pop('/popups/PromoCode.jsp','250','150')" class='graybutton'  style="padding:2px;font-size:10pt;">&nbsp;&raquo;&nbsp;Change&nbsp;Promo&nbsp;Code&nbsp;</a><br><span align="right" id="promoCode" class='lineitems'>Promo Code:&nbsp;<%=session.getAttribute("promoCode").toString()%><br><%=promoDescription%><br>&nbsp;<%
	            
		            if (promoStatus == null || promoStatus.equals("")) {
						//session.removeAttribute("promoCode");
						%><font color='red'>NOTE:Invalid&nbsp;Promo&nbsp;Code</font><%
					} else if (!promoStatus.equals("Valid")) {
						//session.removeAttribute("promoCode");
						%><font color='red'>NOTE:<%=promoStatus%></font><%
					}
				}
				
			}
			
			%></span><%
		} 
			%><br><br></td>
          </tr><%
    }else{
          		%><tr><td class="lineitems" colspan="10">Empty No Orders Present</td></tr><%
	}
	%></table><%

	if (ordersPresent) {
	
%><div align="center">
		<a href='javascript:parent.window.location.replace("/index.jsp?contents=<%=(String) session.getAttribute("siteHostRoot")%>/contents/SiteHostIndex.jsp")' class="menuLINK">CONTINUE&nbsp;SHOPPING</a>
		&nbsp;&nbsp;&nbsp;
		<a href='javascript:showSection("step1")' class="menuLINK">&nbsp;&laquo;&nbsp;BACK TO SHIPPING ADDRESS&nbsp;</a>
		&nbsp;&nbsp;&nbsp;
		<a href='javascript:showSection("step3")' class="menuLINK">&nbsp;NEXT&nbsp;&raquo;&nbsp;</a>
	</div>
</div><%
//End Job Summary Table
int numChoices=0;
boolean creditOK=((validprop != 0 && (creditStatus==2 || isProxy ||(creditStatus==0 && creditLimit>1 && notOverLimit)))?true:false);
creditOK=((creditStatus==0 && (pastdue > 0 || proppastdue > 0))?((isProxy)?true:false):creditOK);

//Begin Payment Section
%><div id="step3" class="bodyblack" style="border:1px black solid;display:none;">
	<div class='stepHeader'><span class="subtitle"><a href="javascript:showSection('step1')" class="oldStepHeader">STEP 1: SHIPPING ADDRESS&nbsp;&raquo;&nbsp;</a><a href="javascript:showSection('step2'	)" class="oldStepHeader">STEP 2: ORDER REVIEW&nbsp;&raquo;&nbsp;</a>STEP 3: PAYMENT OPTIONS<span class="oldStepHeader">&nbsp;&raquo;&nbsp;STEP 4: RECEIPT</span></div>
	<blockquote>
	<div class='lineitems' style="font-size:10pt; width:180px;">Total to be Billed: <%= formater.getCurrency(totalPrice+salesTaxTotal)%></div><br>
	    <table>
	     <td width="20%" valign="top"><div class="subtitle1">Payment Type</div><span class='bodyBlack'><%
	     if(useOnAccount){
	    	numChoices++;
	     %><input type="radio" name="pay_type" value="account" <%=((request.getParameter("pay_type")!=null && request.getParameter("pay_type").equals("account"))?"checked":"")%> onClick="showPaymentForm('account')" <%=((creditOK)?">On Account":"disabled ><span style='color:gray;font-style:italic;'> On Account</span> ")%><br><%}
	     if(useCC){
	     	numChoices++;
	    	 %><input type="radio" name="pay_type" value="cc" onclick="showPaymentForm('cc')" <%=((request.getParameter("pay_type")!=null && request.getParameter("pay_type").equals("cc"))?"checked":"")%>>Credit Card<br><%}
	     if(useACH){
	    	numChoices++;
	    	 %><input type="radio" name="pay_type" value="ach" onclick="showPaymentForm('ach')" <%=((request.getParameter("pay_type")!=null && request.getParameter("pay_type").equals("ach"))?"checked":"")%>>Electronic Check (ACH)<br><%}
	     if(usePrePayByCheck){
	     	numChoices++;
	    	 %><input type="radio" name="pay_type" value="check" onclick="showPaymentForm('check')" <%=((request.getParameter("pay_type")!=null && request.getParameter("pay_type").equals("check"))?"checked":"")%>>Pre-pay by Check<%
	   	 }
	    	 %></span></td><td valign="top"><div style="font-size:<%=((numChoices<4)?"72":"80")%>;color:red;" id="paySelect1">}</div></td>
		<td valign="left"><br><div class="subtitle" id="paySelect2" style="padding-top:<%=((numChoices<4)?"23":"30")%>px;">Please select a method of payment<br><br></div>
	    <%=(((proppastdue + pastdue) > 0) ? "<div class='bodyBlack' style='border:1px red solid;padding:15px;'>"+((pastdue>0)?"Balance Over " + co_days + " days for all buyers on this account: " + formater.getCurrency(propInvoiceBalance)+"<br>":"") +((proppastdue > 0) ? "Balance Over " + co_days + " days for this account: " + formater.getCurrency(invoiceBalance) : "") + "</div>" : "")%><%
	    
  String credMessage="";      
  if (creditStatus != 2 && overLimit) {
            credMessage="<li>An increase to your existing credit limit is required. <a href='/forms/mc_credit_app.pdf' style='color:red;font-decoration:none;' target=_blank>Click here to download a credit application.</a></li>";
  }
  if (creditStatus != 2 && pastdue == 1) {
            credMessage+="<li>Overdue invoices on your account need to be paid.</li>";
  }

  if (creditStatus != 2 && proppastdue == 1) {
            credMessage+="<li>Overdue invoices from other accounts related to your property need to be paid.</li>";
  } 
  if (creditLimit < 2) {
            credMessage+="<li>Credit approval / account validation required. <a href='/forms/mc_credit_app.pdf' style='color:red;font-decoration:none;' target=_blank>Click here to download a credit application.</a></li>";
  }
    if (creditStatus == 1) {
            credMessage+="<li>Account is on hold, please contact Customer Service.</li>";
  }
    if (validprop == 0) {
            credMessage+="<li>Account validation required, please contact Customer Service.</li>";
  }

  if(!credMessage.equals("") && useOnAccount){
  	%><div class="errorbox"  >Ordering 'On Account' is not currently available for the following reason(s):<ul style="margin-left:10px;"><%=credMessage%></ul>Please click "contact info" below to reach Marketing Services for more information regarding our payment options, otherwise please choose another method of payment and process the order.</b><br><br><div align="center"><a class='graybutton'  style="padding:2px;" href='javascript:pop("<%=(String) session.getAttribute("siteHostRoot")%>/popups/help.jsp","650","450")'>&raquo;&nbsp;CONTACT&nbsp;INFO</a></div><br></div><%
  }
          %></td></tr>
        </table>
		
      
      <!-- Begin Process CC -->
    <div id="cc" style="display: none;"><jsp:include page="/includes/ProcessCredCard.jsp" flush="true"></jsp:include><hr size=1 color=gray><br><%if (editor){%><a href="javascript:pop(&quot;/popups/QuickChangeHTMLForm.jsp?cols=60&amp;rows=3&amp;question=Change%20ON%20Account%20Text&amp;primaryKeyValue=<%=sl.getValue("pages","page_name","'checkout_credit_card'","id")%>&amp;columnName=body&amp;tableName=pages&amp;valueType=string&quot;,500,350)">&raquo;</a>&nbsp;<%}%><%=sl.getValue("pages","page_name","'checkout_credit_card'","html")%>
    </div>
      <!-- End Process CC -->
      
      <!-- Begin Process ACH -->
    <div id="ach" style="display: none;"><jsp:include page="/includes/ProcessACH.jsp" flush="true"></jsp:include><hr size=1 color=gray><br><%if (editor){%><a href="javascript:pop(&quot;/popups/QuickChangeHTMLForm.jsp?cols=60&amp;rows=3&amp;question=Change%20ON%20Account%20Text&amp;primaryKeyValue=<%=sl.getValue("pages","page_name","'checkout_ach'","id")%>&amp;columnName=body&amp;tableName=pages&amp;valueType=string&quot;,500,350)">&raquo;</a>&nbsp;<%}%><%=sl.getValue("pages","page_name","'checkout_ach'","html")%>
    </div>
      <!-- End Process ACH -->
      
      <!-- Begin Prepay by Check -->
      <div id="check"  style="display: none;"><hr size=1 color=gray><br><%if (editor){%><a href="javascript:pop(&quot;/popups/QuickChangeHTMLForm.jsp?cols=60&amp;rows=3&amp;question=Change%20ON%20Account%20Text&amp;primaryKeyValue=<%=sl.getValue("pages","page_name","'checkout_prepay_by_check'","id")%>&amp;columnName=body&amp;tableName=pages&amp;valueType=string&quot;,500,350)">&raquo;</a>&nbsp;<%}%><%=sl.getValue("pages","page_name","'checkout_prepay_by_check'","html")%>
      </div>
      <!-- End Prepay by Check -->
      <!-- Begin On Account -->
      <div id="account" style="display: none;"><hr size=1 color=gray><br><%if (editor){%><a href="javascript:pop(&quot;/popups/QuickChangeHTMLForm.jsp?cols=60&amp;rows=3&amp;question=Change%20ON%20Account%20Text&amp;primaryKeyValue=<%=sl.getValue("pages","page_name","'checkout_on_account'","id")%>&amp;columnName=body&amp;tableName=pages&amp;valueType=string&quot;,500,350)">&raquo;</a>&nbsp;<%}%><%=sl.getValue("pages","page_name","'checkout_on_account'","html")%>
      </div>
      <!-- End On Account -->
 </blockquote><%
	
		String editTxt2 = ((editor) ? "<a href= 'javascript:pop(\"/popups/QuickChangeInnerForm.jsp?inner=orderSummaryTxt&cols=70&rows=6&question=Change%20Order%20Text%20Text&primaryKeyValue=" + spPageId + "&columnName=body&tableName=pages&valueType=string\",600,200)'>&raquo;</a>&nbsp;" : "");
        %><div class='bodytext'  style="margin-left:15px;"><%=editTxt2%><span id='orderSummaryTxt'><%=orderSummaryTxt%></span>
        <br><%String editTxt = ((editor) ? "<a href= 'javascript:pop(\"/popups/QuickChangeInnerForm.jsp?inner=nonUSTxt&cols=70&rows=6&question=Change%20Non-US%20Text&primaryKeyValue=" + pageId + "&columnName=body&tableName=pages&valueType=string\",600,200)'>&raquo;</a>&nbsp;" : "");%><%=((countryId != 1 || editor) ? "<div class=nonUSTxt>" + editTxt + "<span id=nonUSTxt>" + nonUSTxt + "</span></div>" : "")%></div>
	<div align="center">
			<a href='javascript:parent.window.location.replace("/index.jsp?contents=<%=(String) session.getAttribute("siteHostRoot")%>/contents/SiteHostIndex.jsp")' class="menuLINK">CONTINUE&nbsp;SHOPPING</a>
		&nbsp;&nbsp;&nbsp;
		<a href='javascript:showSection("step2")' class="menuLINK">&nbsp;&laquo;&nbsp;BACK TO ORDER REVIEW&nbsp;</a>
		&nbsp;&nbsp;&nbsp;
		<a href="javascript:submitFinalOrder()" class="menuLINK">SUBMIT&nbsp;ORDER</a>
	</div>
</div>
<script>
  function processOrder(){
    document.getElementById("process").style.display='none';
    document.getElementById("waitSection").style.display='';
    moveWorkFlow('1');
  }
</script>
<input type="hidden" name="nextStepActionId" value="">
<input type="hidden" name="jobId" value="<%=jobId%>">
<input type="hidden" name="coStep" value="<%=coStep%>">
<input type="hidden" name="errorPage" value="/catalog/checkout/Checkout.jsp">
<input type="hidden" name="companyId" value="<%=up.getCompanyId()%>">
<input type="hidden" name="$$Return" value="[/catalog/checkout/ThankYouForOrder.jsp]">
<input type="hidden" name="tax_entity" value="<%=taxEntity%>">
   <!--</div>-->
	<script>
<%		if(request.getAttribute("errorMessage") != null){
			%>	showSection('step3');<%
			if(request.getParameter("pay_type")!=null){
				%>showPaymentForm('<%=request.getParameter("pay_type")%>');<%
			}
		}else{
			%>showSection('<%=coStep%>');<%
		}%>
	</script>
   <div id="waitSection" style="display:none;">
      <br><br><br><br><br><br>
      <div align="center">
        <h2>Processing Order<img src="/images/generic/dotdot.gif" width="72" height="10"></h2>
      </div>
    </div>
    <div id="formSection" style="display:block;">
    <%

} //if orders present

%><!--<br><hr size=2 color=red><table width="100%" align="center" class="body">
    <tr>
      <td class="Title" height="1" colspan="10">
        <span class="offeringTITLE">Shipment Details</span>
      </td>
    </tr>
    <tr>
      <td class="planheader1">Shipment #</td>
      <td class="planheader1"># of Boxes</td>
      <td class="planheader1"># of Jobs</td>
      <td class="planheader1">Shipment Weight</td>
      <td class="planheader1">Shipment Price</td>
      <td class="planheader1">Handling Query</td>
    </tr><%
    if (shoppingCart != null) {
      Vector shipments = shoppingCart.getShipments();
      if (shipments.size() > 0) {
        for (int j = 0; j < shipments.size(); j++) {
          ShipmentObject so = (ShipmentObject) shipments.elementAt(j);
    %>
    <tr>
      <td class="lineitems" align="right"><%= j + 1%></td>
      <td class="lineitems" align="right"><%= so.getShipmentBoxes().size()%></td>
      <td class="lineitems" align="right"><%= so.getJobs().size()%></td>
      <td class="lineitems" align="right"><%= so.getWeight()%></td>
      <td class="lineitems" align="right">$<%= so.getCalculatedShipPrice()%> (from UPS) + $<%= so.getSVFee()%> SVFee + $<%= so.getMCFee()%> MCFee = $<%= so.getCalculatedShipPrice() + so.getHandlingCost()%></td>
      <td class="lineitems" align="right"><%= so.getHandlingQuery()%></td>
    </tr>
    <%
        }
      }
    }
    %>
  </table>
  <table width="100%" align="center" class="body">
    <tr>
      <td class="Title" height="1" colspan="10">
        <span class="offeringTITLE">
          Shipment Box Details
        </span>
      </td>
    </tr>
    <tr>
      <td class="planheader1">Box #</td>
      <td class="planheader1">Shipment ID</td>
      <td class="planheader1">Box Weight</td>
      <td class="planheader1">Box Dimension (HxWxL)</td>
      <td class="planheader1">Box Contents</td>
      <td class="planheader1">UPS AccountNumber</td>
      <td class="planheader1">UPS UserName</td>
      <td class="planheader1">UPS Password</td>
      <td class="planheader1">UPS XMLKey</td>
      <td class="planheader1">ZipFrom Code</td>
      <td class="planheader1">ZipTo Code</td>
    </tr><%

    if (shoppingCart != null) {
      Vector shipments = shoppingCart.getShipments();
      if (shipments.size() > 0) {
        for (int j = 0; j < shipments.size(); j++) {
          ShipmentObject so = (ShipmentObject) shipments.elementAt(j);
          Vector boxes = so.getShipmentBoxes();
          for (int k = 0; k < boxes.size(); k++) {
            ShipmentBoxObject sbo = (ShipmentBoxObject) boxes.elementAt(k);

%><tr>
      <td class="lineitems" align="right"><%= sbo.getBoxNumber()%> of <%= so.getShipmentBoxes().size()%></td>
      <td class="lineitems" align="right"><%= sbo.getShipmentId()%></td>
      <td class="lineitems" align="right"><%= sbo.getWeight()%></td>
      <td class="lineitems" align="right"><%= sbo.getHeight()%> x <%= sbo.getWidth()%> x <%= sbo.getLength()%></td>
      <td class="lineitems" align="right"><%= sbo.getContents()%></td>
      <td class="lineitems" align="right"><%= so.getShipperAccountNumber()%></td>
      <td class="lineitems" align="right"><%= so.getShipperUserName()%></td>
      <td class="lineitems" align="right"><%= so.getShipperPassword()%></td>
      <td class="lineitems" align="right"><%= so.getShipperXMLKey()%></td>
      <td class="lineitems" align="right"><%= so.getZipFrom()%></td>
      <td class="lineitems" align="right"><%= so.getZipTo()%></td>
    </tr>
    <%}
        }
      }
    }
    %>-->
  </table>
  <input type="hidden" name="priorJobId" value="<%=request.getParameter("priorJobId")%>">
</form>
<%
    if (session.getAttribute("reprintJob") != null) {
      session.removeAttribute("reprintJob");
      session.removeAttribute("priorJobId");
    }






  } else {

    /*********************************************************************************************************
    //if this is the result of a self-designed 'run'
     **********************************************************************************************************/
    String rePrint = ((request.getParameter("rePrint") == null || request.getParameter("rePrint").equals("") || request.getParameter("rePrint").equals("false")) ? "false" : "true");
    session.setAttribute("reprintJob", rePrint);

%>  <title>Self-Designed Item Summary</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link rel="stylesheet" href="<%=(String) session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css">
<link rel="stylesheet" href="/styles/marcomet.css" type="text/css">
<META HTTP-EQUIV="Cache-Control" CONTENT="no-cache">
<META HTTP-EQUIV="Pragma" CONTENT="no-cache">
<META HTTP-EQUIV="Expires" CONTENT="-1">
<style>.nonUSTxt{background-color:#ffffcc;}</style>
<script language="javascript" src="/javascripts/mainlib.js"></script>
</head>
<body leftmargin="10" topmargin="0" marginwidth="0" marginheight="0" onLoad="populateTitle('Self-Designed Item Summary')" >
<form method="post" action="/servlet/com.marcomet.sbpprocesses.ProcessJobSubmit" >
<table border="0" cellpadding="0" cellspacing="0" width="100%" height="100%" align="center">
<tr valign="top">
  <td colspan="10" valign="top">
    <table width="100%" align="center" class="body">
      <tr>
        <p>
        <td class="Title"colspan="10" height="1" style="margin-left:10px;">
          <div class="offeringTITLE">
            New Self-Help Design Center:<br>What would you like to do with the file you've just designed:
          </div>
          <div class="bodyblack">
            Please choose how you would like to process this pdf file.
          </div>
        </td>
      </tr>
      <%
    double priceSubtotal = 0.00;
    double shipSubtotal = 0.00;
    double depositSubtotal = 0.00;
    boolean ordersPresent = false;
    String pdfPreviewTemplate = "";
    ShoppingCart shoppingCart = (ShoppingCart) session.getAttribute("shoppingCart");
    JobSpecObject jso1 = (JobSpecObject) shoppingCart.getJobSpec(9100);
    if (jso1 != null) {
      pdfPreviewTemplate = (String) jso1.getValue();
    } else {
      pdfPreviewTemplate = "";
    }

    if (shoppingCart != null) {
      overLimit = (((orderBalance + shoppingCart.getOrderPrice()) > creditLimit && creditLimit > 1) ? true : false);
      Vector projects = shoppingCart.getProjects();
      if (projects.size() > 0) {
        for (int i = 0; i < projects.size(); i++) {
          ProjectObject po = (ProjectObject) projects.elementAt(i);
          poId = po.getId();
          Vector jobs = po.getJobs();
          for (int j = 0; j < jobs.size(); j++) {
            JobObject jo = (JobObject) jobs.elementAt(j);
            if (request.getParameter("jobId").equals(jo.getId() + "")) {
              jobId = jo.getId();
              double price = jo.getPrice();
              double shipping = jo.getShippingPrice();
              int shipPricePolicy = jo.getShipPricePolicy();
              shipSubtotal = shipSubtotal + shipping;
              double deposit = jo.getEscrowDollarAmount();
              ordersPresent = true;
              fileName = jo.getPreBuiltPDFFileURL();
            }
          }
        }
      } else {
      %><tr>
        <td class="lineitems" colspan="10">Empty No Items Present</td>
      </tr>
      <%        }
      } else {%>
      <tr>
        <td class="lineitems" colspan="10" height="2">Empty No Items Present</td>
      </tr>
      <%    }%>
    </table>
  </td>
</tr>
<tr>
<td>
<table>
<tr>
<td align="left" ><blockquote style="margin-left:40px;"><a href="javascript:saveFile('<%=previewTemplate%>','<%=pdfPreviewTemplate.replace(".", "_laser.")%>','Laser','false')" class="plainLink" style="color:#0044a0;">&raquo;&nbsp;Save and Download a Laser-Printable PDF</a><span class="bodyBlack">-- Allows you to save to your PC a PDF file which can be printed on your color laser printer.</span>
  <br><br><br>
  <a href="javascript:saveFile('<%=previewTemplate%>','<%=pdfPreviewTemplate.replace(".", "_prepress.")%>','PrePress','false')" class="plainLink" style="color:#0044a0;">&raquo;&nbsp;Save and Download a Press-Ready PDF</a><span class="bodyBlack"> -- Allows you to save to your PC a professional press-ready PDF file which you can deliver to the printer of your choice.</span>
  <br><br>
  <span class="bodyBlack"><b>Place an Order to Print this File</b> -- If you'd like us to print the file you've just designed simply choose the quantity from the grid below.</span></div><div>&nbsp;&nbsp;&nbsp; <br><%
    //Create the pricing grid
    Vector vPrices = new Vector();
    int y = 0;
    String pSQL = "Select count(pp.id) as numZero from product_prices pp,products p where pp.prod_price_code=p.prod_price_code and (quantity=0 || price <=.009) and p.id=" + ((request.getParameter("productId") == null) ? "''" : request.getParameter("productId")) + " group BY pp.prod_price_code";

    ResultSet rsPriceCount = st.executeQuery(pSQL);
    int numZero = 0;
    if (rsPriceCount.next()) {
      numZero = ((rsPriceCount.getString("numZero") == null || rsPriceCount.getString("numZero").equals("")) ? 0 : rsPriceCount.getInt("numZero"));
    }

    pSQL = "Select format(quantity,0) as quantity,format(price,2) as price,format(price/quantity,3) as perItem  from product_prices pp,products p where pp.prod_price_code=p.prod_price_code and quantity>0 and price >.009 and p.id=" + ((request.getParameter("productId") == null) ? "''" : request.getParameter("productId")) + " ORDER BY pp.quantity";
    int colNum = numZero;
    ResultSet rsPrices = st.executeQuery(pSQL);
    while (rsPrices.next()) {
      vPrices.addElement(((rsPrices.getString("quantity") == null) ? "" : rsPrices.getString("quantity")));
      vPrices.addElement(((rsPrices.getString("price") == null) ? "" : rsPrices.getString("price")));
      vPrices.addElement(((rsPrices.getString("perItem") == null) ? "" : rsPrices.getString("perItem")));
      y++;

    }


    if (y > 0) {
  %><table border="0" cellpadding="0" cellspacing="0" width="100%">
    <tr><td class="catalogLABEL" colspan="<%=y + 1%>">Click on price to continue...</td></tr>
    <tr><td class="tableheader" colspan="<%=y%>">Quantity (sheet)</td></tr>
    <tr><%
    for (int z = 0; z <
            vPrices.size(); z =
                    z + 3) {
      %><td class="planheader2" align="center"><%=vPrices.get(z).toString()%></td><%
    }%>
    </tr>  <tr><%
    for (int z = 0; z <
            vPrices.size(); z =
                    z + 3) {
    %><td class="lineitems" align="center" onMouseOver="this.style.backgroundColor='#FFEBCD';" onMouseOut='this.style.backgroundColor="white"' ><a class="lineitemslink" href="javascript:orderJobFromSelfDesigned('0','<%=colNum++%>','<%=vPrices.get(z).toString().replaceAll(",", "")%>','<%=vPrices.get(z + 1).toString().replaceAll(",", "")%>','<%=previewTemplate%>','<%=pdfPreviewTemplate.replace(".", "_prepress.")%>','PrePress','true')">$<%=vPrices.get(z + 1).toString()%>&nbsp;<span class="pricePerItem"> [$<%=vPrices.get(z + 2).toString()%> each]</span></a></td><%
    }%>
  </table><%
  } else {%><table style="border: #7f8180 1px solid;" cellpadding="2" cellspacing="0">
  <tr><td class='tableHeader'>Price Quoted at Time of Order</td></tr></table><%    }
    //<br>&nbsp;&nbsp;&nbsp;<a href="javascript:orderJobFromSelfDesign()" class="greybutton">ORDER&nbsp;&raquo;</a></div></td>%>
  <br>
  <img src="/images/spacer.gif" height="40">
  <br>
  <div align="center" id="processButtons"><a href="/catalog/summary/RemoveSelfDesignedConfirmation.jsp?projectId=<%=poId%>" class="greybutton">&nbsp;&nbsp;CANCEL AND DELETE THE FILE&nbsp;&nbsp;</a><br><br></div>
</blockquote>

</td>
</tr>
</table>

</td>
</tr>
<tr><td>&nbsp;</td></tr>
</table>
<div id='pdfPrep' style="display:none;"><iframe height="0"  width="0" marginwidth="0" marginheight="0" frameborder="0" id="preview" name="preview" ></iframe></div>
<table width=100% >
  <tr>
    <td>
      <jsp:include page="/footers/inner_footer.jsp" flush="true"></jsp:include>
    </td>
  </tr>
</table>-->
<script>
  function orderJobFromSelfDesigned(rowNum,colNum,quantity,price,prodTemplate,pdfTemplate,savedFileType,rePrint){
    if (document.getElementById('processButtons').innerHTML=='<span class="menuLink">&nbsp;&nbsp;PROCESSING REQUEST . . .&nbsp;&nbsp;</span>'){
      alert('Your request is already being processed, please wait for it to complete.');
      Return;
    }
    document.forms[0].lastRow.value=rowNum;
    document.forms[0].lastCol.value=colNum;
    document.forms[0].quantity.value=quantity;
    document.forms[0].price.value=price;
    document.forms[0].orderFromSelfDesigned.value='true';
    document.forms[0].target='preview';
    saveFile(prodTemplate,pdfTemplate,savedFileType,rePrint);
  }

  function saveFile(prodTemplate,pdfTemplate,savedFileType,rePrint){
    if (document.getElementById('processButtons').innerHTML=='<span class="menuLink">&nbsp;&nbsp;PROCESSING REQUEST . . .&nbsp;&nbsp;</span>'){
      alert('Your request is already being processed, please wait for it to complete.');
      Return;
    }
    document.getElementById('processButtons').innerHTML='<span class="menuLink">&nbsp;&nbsp;PROCESSING REQUEST . . .&nbsp;&nbsp;</span>';
    document.forms[0].savedFileType.value=savedFileType;
    document.forms[0].pdfPreviewTemplate.value=pdfTemplate;
    document.forms[0].rePrint.value=rePrint;
    document.forms[0].printFileType.value=savedFileType;
    document.forms[0].action="/catalog/checkout/SaveTemplatedFile.jsp";
    document.getElementById('preview').src='http://<%=((session.getAttribute("baseURL") == null) ? "" : session.getAttribute("baseURL").toString())%>'+prodTemplate+'?saveFile=true&pdfPreviewTemplate='+pdfTemplate+'&savedFileType='+savedFileType+'&catJobId=<%=request.getParameter("catJobId")%>';
  }

</script>
<input type="hidden" name="orderFromSelfDesigned" value="">
<input type="hidden" name="quantity" value="">
<input type="hidden" name="coordinates" value="">
<input type="hidden" name="selfDesigned" value="<%=((request.getParameter("selfDesigned") == null) ? "" : request.getParameter("selfDesigned"))%>">
<input type="hidden" name="vendorId" value="<%=request.getParameter("vendorId")%>">
<input type="hidden" name="prePopId" value="<%=request.getParameter("prePopId")%>">
<input type="hidden" name="prePopTable" value="<%=request.getParameter("prePopTable")%>">
<input type="hidden" name="siteHostId" value="<%=shs.getSiteHostId()%>">
<input type="hidden" name="currentCatalogPage" value="2">
<input type="hidden" name="catJobId" value="<%=request.getParameter("catJobId")%>">
<input type="hidden" name="priorJobId" value="<%=request.getParameter("priorJobId")%>">
<input type="hidden" name="offeringId" value="<%=request.getParameter("offeringId")%>">
<input type="hidden" name="tierId" value="<%=request.getParameter("tierId")%>">
<input type="hidden" name="prodCode" value="<%=request.getParameter("prodCode")%>">
<input type="hidden" name="usePreview" value="<%=request.getParameter("usePreview")%>">
<input type="hidden" name="savedFileType" value="">
<input type="hidden" name="printFileType" value="<%=((request.getParameter("printFileType") == null) ? "" : request.getParameter("printFileType"))%>">
<input type="hidden" name="productCode" value="<%=((request.getParameter("productCode") == null) ? "" : request.getParameter("productCode"))%>">
<input type="hidden" name="productId" value="<%=((request.getParameter("productId") == null) ? "" : request.getParameter("productId"))%>">
<input type="hidden" name="price" value="">
<input type="hidden" name="pdfPreviewTemplate" value="">
<input type="hidden" name="rePrint" value="">
<input type="hidden" name="jobId" value="<%=jobId%>">
<input type="hidden" name="projectId" value="<%=poId%>">
<input type="hidden" name="lastRow" value="">
<input type="hidden" name="lastCol" value="">
</form>
<%}


    
//Reset the errormessage if one exists;
session.setAttribute("errorMessage","");

st.close();
conn.close();
if (session.getAttribute("saveFileType") != null) {
	String saveFileType = session.getAttribute("saveFileType").toString();
	session.removeAttribute("saveFileType");
}
%>
</body>
</html>