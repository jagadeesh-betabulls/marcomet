<%@ page import="javax.servlet.*,javax.servlet.http.*,java.util.*,java.sql.*,com.marcomet.jdbc.*, com.marcomet.environment.*" %><jsp:useBean id="str" class="com.marcomet.tools.StringTool" scope="session" /><%  

	//new environment object for sitehost information/settings
	SiteHostSettings siteHostSettings;
	if(session.getAttribute("siteHostSettings")== null){
		siteHostSettings = new SiteHostSettings();
		session.setAttribute("siteHostSettings",siteHostSettings);
	}else{
		siteHostSettings = (SiteHostSettings)session.getAttribute("siteHostSettings");
	}	
	
	String baseURL = HttpUtils.getRequestURL(request).toString();
	int dblslashIndex = baseURL.lastIndexOf("//")+2;
	baseURL = dblslashIndex != -1 ? baseURL.substring(dblslashIndex, baseURL.length()) : "";
	int slashIndex = baseURL.indexOf("/");
	baseURL = slashIndex != -1 ? baseURL.substring(0, slashIndex) : "";
	int colonIndex = baseURL.indexOf(":");
	baseURL = colonIndex != -1 ? baseURL.substring(0, colonIndex) : baseURL;
    String dynamicHost = "";
	baseURL=str.replaceSubstring(baseURL,"www.","");
	//baseURL=str.replaceSubstring(baseURL,"WWW.","");	
	if(session.getAttribute("siteHostRoot") == null) {
   		StringTokenizer st = new StringTokenizer(baseURL, ".");
   		if (st.hasMoreElements()) {
      		dynamicHost = st.nextToken();
   		}

	   	if (dynamicHost != "" && dynamicHost != null) {
    		session.setAttribute("siteHostRoot","/sitehosts/" + dynamicHost);
			siteHostSettings.setSiteHostRoot("/sitehosts/" + dynamicHost);
   		}else{
      		session.setAttribute("siteHostRoot","");
   		}
	}
	
	//load Vendor Specific Information since that is global information for a site.
	//String sql = "SELECT * FROM site_hosts WHERE domain_name='"+ baseURL +"'";
	String sql = "SELECT sh.id AS site_host_id, c.id AS contact_id, company_id, site_host_global_markup, marcomet_global_fee, domain_name, outer_frame_set_height, inner_frame_set_height, process_credit_cards, buyer_minder_filter FROM site_hosts sh, contacts c WHERE sh.company_id = c.companyid AND site_host_name = '"+ dynamicHost +"'";
		
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
		siteHostSettings.setBuyerMinderFilter(rsSiteHostInfo.getInt("buyer_minder_filter"));		
	}
	conn.close();	
	qs = null;
	conn = null;
	%>