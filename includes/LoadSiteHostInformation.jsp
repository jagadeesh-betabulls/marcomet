<%@ page import="javax.servlet.*,javax.servlet.http.*,java.util.*,java.sql.*,com.marcomet.jdbc.*, com.marcomet.environment.*" %>
<jsp:useBean id="str" class="com.marcomet.tools.StringTool" scope="session" />
<%  
	//new environment object for sitehost information/settings
	SiteHostSettings siteHostSettings;
	if(session.getAttribute("siteHostSettings")== null){
		siteHostSettings = new SiteHostSettings();
		session.setAttribute("siteHostSettings",siteHostSettings);
	}else{
		siteHostSettings = (SiteHostSettings)session.getAttribute("siteHostSettings");
	}		
	String baseURL = HttpUtils.getRequestURL(request).toString();
	session.setAttribute("baseurl",baseURL);
	int dblslashIndex = baseURL.lastIndexOf("//")+2;
	String demoStr="";
	String demoFlag="false";
	if (baseURL.indexOf("demo")>0 || (request.getParameter("demo")!=null && request.getParameter("demo").equals("true"))){
		demoFlag="true";  //session.setAttribute("demo","true");
		demoStr="/demo";
	}
	demoStr=((session.getAttribute("demo")==null)?"":"/demo");
	baseURL = dblslashIndex != -1 ? baseURL.substring(dblslashIndex, baseURL.length()) : "";
	int slashIndex = baseURL.indexOf("/");
	baseURL = slashIndex != -1 ? baseURL.substring(0, slashIndex) : "";
	int colonIndex = baseURL.indexOf(":");
	baseURL = colonIndex != -1 ? baseURL.substring(0, colonIndex) : baseURL;
    String dynamicHost = "";
	baseURL=str.replaceSubstring(baseURL,"www.","");
	//baseURL=str.replaceSubstring(baseURL,"demo.","");
	//baseURL=str.replaceSubstring(baseURL,"WWW.","");	
 	StringTokenizer st = new StringTokenizer(baseURL, ".");
   	if (st.hasMoreElements()) {
    	dynamicHost = st.nextToken();
   	}
	//load Vendor Specific Information since that is global information for a site.
	//String sql = "SELECT * FROM site_hosts WHERE domain_name='"+ baseURL +"'";
	String sql = "SELECT sh_target,allow_guest_login,guest_encrypted_contact_id, sh.id AS site_host_id, c.id AS contact_id, company_id, site_host_global_markup, marcomet_global_fee, domain_name, outer_frame_set_height, inner_frame_set_height, process_credit_cards, buyer_minder_filter, if(sa.id is null,'"+demoStr+"',sa.subfolder) 'subfolder',site_host_name,if(sa.id is null,'"+demoFlag+"',sa.demo_flag) demo_flag,use_property_product_filter,use_cc,use_ach,use_on_account,use_prepay_by_check,allow_deferred_ach,use_full_shipcharge,hide_shipping_options,shipping_options_default,require_site_validation,use_warehouse_handling,site_name,site_type,site_field_1_label,site_field_2_label,site_field_3_label,default_credit_limit,show_tax_id,ams_domain FROM contacts c, site_hosts sh left join sitehost_aliases sa on sh.id=sa.sitehost_id and sa.sitehost_alias='"+dynamicHost+"' WHERE sh.company_id = c.companyid AND (site_host_name = '"+dynamicHost+"'   or sa.sitehost_alias='"+dynamicHost+"' ) group by sh.id";
//	session.setAttribute("tempsql",sql);
	
	Connection conn = DBConnect.getConnection();
	Statement qs = conn.createStatement();	
	ResultSet rsSiteHostInfo = qs.executeQuery(sql);
	if (rsSiteHostInfo.next()) {
		siteHostSettings.setSiteHostId(rsSiteHostInfo.getString("site_host_id"));
		siteHostSettings.setSiteHostContactId(rsSiteHostInfo.getString("contact_id"));
		siteHostSettings.setSiteHostCompanyId(rsSiteHostInfo.getString("company_id"));
		siteHostSettings.setSiteHostGlobalMarkup(rsSiteHostInfo.getDouble("site_host_global_markup"));
		siteHostSettings.setMarcometGlobalFee(rsSiteHostInfo.getDouble("marcomet_global_fee"));
		siteHostSettings.setDomainName(rsSiteHostInfo.getString("domain_name"));
		siteHostSettings.setOuterFrameSetHeight(rsSiteHostInfo.getString("outer_frame_set_height"));
		siteHostSettings.setInnerFrameSetHeight(rsSiteHostInfo.getString("inner_frame_set_height"));
		siteHostSettings.setCCommerce(rsSiteHostInfo.getString("process_credit_cards"));
		siteHostSettings.setSiteTarget(rsSiteHostInfo.getString("sh_target"));
		siteHostSettings.setBuyerMinderFilter(rsSiteHostInfo.getInt("buyer_minder_filter"));
		
		siteHostSettings.setUsePropertyProductFilter(rsSiteHostInfo.getString("use_property_product_filter"));
		siteHostSettings.setUseCC(rsSiteHostInfo.getString("use_cc"));
		siteHostSettings.setUseACH(rsSiteHostInfo.getString("use_ach"));
		siteHostSettings.setUseOnAccount(rsSiteHostInfo.getString("use_On_Account"));
		siteHostSettings.setUsePrepayByCheck(rsSiteHostInfo.getString("use_prepay_by_check"));
		siteHostSettings.setAllowDeferredACH(rsSiteHostInfo.getString("allow_Deferred_ACH"));
		siteHostSettings.setUseFullShipCharge(rsSiteHostInfo.getString("use_full_shipcharge"));
		siteHostSettings.setHideShippingOptions(rsSiteHostInfo.getString("hide_shipping_options"));
		siteHostSettings.setShippingOptionsDefault(rsSiteHostInfo.getString("shipping_options_default"));
		siteHostSettings.setRequireSiteValidation(rsSiteHostInfo.getString("require_site_validation"));
		siteHostSettings.setUseWarehouseHandling(rsSiteHostInfo.getString("use_warehouse_handling"));
		siteHostSettings.setSiteName(rsSiteHostInfo.getString("site_name"));
		siteHostSettings.setSiteType(rsSiteHostInfo.getString("site_type"));
		siteHostSettings.setSiteFieldLabel1(rsSiteHostInfo.getString("site_field_1_label"));
		siteHostSettings.setSiteFieldLabel2(rsSiteHostInfo.getString("site_field_2_label"));
		siteHostSettings.setSiteFieldLabel3(rsSiteHostInfo.getString("site_field_3_label"));
		siteHostSettings.setDefaultCreditLimit(rsSiteHostInfo.getDouble("default_credit_limit"));
		siteHostSettings.setShowTaxID(rsSiteHostInfo.getString("show_tax_id"));

		session.setAttribute("allowGuestLogin",rsSiteHostInfo.getString("allow_guest_login"));
		session.setAttribute("amsDomain",rsSiteHostInfo.getString("ams_domain"));				
        session.setAttribute("guestEID",rsSiteHostInfo.getString("guest_encrypted_contact_id"));
        demoStr=rsSiteHostInfo.getString("subfolder");
        demoFlag=rsSiteHostInfo.getString("demo_flag");
        dynamicHost=rsSiteHostInfo.getString("site_host_name");
	}
	if (demoFlag.equals("true")){
		session.setAttribute("demo","true");
	}
	rsSiteHostInfo.close();
	qs.close();
	conn.close();
	if (dynamicHost != "" && dynamicHost != null) {
		session.setAttribute("siteHostRoot","/sitehosts/" + dynamicHost+demoStr);
		siteHostSettings.setSiteHostRoot("/sitehosts/" + dynamicHost+demoStr);
	}else{
		session.setAttribute("siteHostRoot","");
	}
	
	//only set the referring domain attribute once, on initial entry
	String referringDomain= ((request.getHeader("referer")==null)?baseURL:request.getHeader("referer"));
	if (session.getAttribute("referringDomain")==null || session.getAttribute("referringDomain").equals("")){
		dblslashIndex = referringDomain.lastIndexOf("//")+2;
		referringDomain = dblslashIndex != -1 ? referringDomain.substring(dblslashIndex, referringDomain.length()) : "";
		slashIndex = referringDomain.indexOf("/");
		referringDomain = slashIndex != -1 ? referringDomain.substring(0, slashIndex) : "";
		colonIndex = referringDomain.indexOf(":");
		referringDomain = colonIndex != -1 ? referringDomain.substring(0, colonIndex) : referringDomain;
		dynamicHost = "";
		referringDomain=str.replaceSubstring(referringDomain,"www.","");
		session.setAttribute("referringDomain",referringDomain);
	}
	%><!--<%=dynamicHost%><%=session.getAttribute("referringDomain")%>-->
