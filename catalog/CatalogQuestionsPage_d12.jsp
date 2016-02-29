<%@ page import="java.util.*,java.sql.*, com.marcomet.catalog.*,com.marcomet.jdbc.*,com.marcomet.environment.*,com.marcomet.users.security.*,org.apache.commons.lang.*" %>
<%@ taglib uri="/WEB-INF/tld/taglib.tld" prefix="taglib" %>
<jsp:useBean id="formatter" class="com.marcomet.tools.FormaterTool" scope="page" />
<jsp:useBean id="str" class="com.marcomet.tools.StringTool" scope="page" />
<jsp:useBean id="sl" class="com.marcomet.tools.SimpleLookups" scope="page" />
<%
String siteHostRoot=((request.getParameter("siteHostRoot")==null)?((session.getAttribute("tmpSHRoot")==null || session.getAttribute("tmpSHRoot").toString().equals(""))?(String)session.getAttribute("siteHostRoot"):(String)session.getAttribute("tmpSHRoot")):request.getParameter("siteHostRoot"));
String catQuestionLabel="";
//String DIYproductId=((session.getAttribute("DIYproductId")==null)?"":session.getAttribute("DIYproductId").toString());

%><html>
<head>
<title>Catalog Wizard</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link rel="stylesheet" href="<%=(String)session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css">
<link rel="stylesheet" href="/styles/misc_styles.css" type="text/css">
<link rel="stylesheet" href="/styles/modalbox.css" type="text/css">
<script language="JavaScript" src="/javascripts/mainlib.js"></script>
<script type="text/javascript" src="/javascripts/prototype1.js"></script>
<script type="text/javascript" src="/javascripts/scriptaculous1.js"></script>
<script type="text/javascript" src="/javascripts/modalbox1.js"></script>

<script>
function makeSelection(x, y) {
	document.forms[0].coordinates.value=x + "," + y;
	document.forms[0].submit();
}
var lastFieldValue="";
</script>
</head>

<body style="margin-left:20; margin-top:0;" onLoad="populateTitle('<%= (String)request.getAttribute("title")%>')" >

<div id="wamBrowser" style="display:none;"></div>

<form method="post" action="/servlet/com.marcomet.catalog.CatalogControllerServlet"><%

String productId=((request.getParameter("productId")==null)?"":request.getParameter("productId"));
String DIYproductId=((request.getParameter("DIYproductId")==null)?"":request.getParameter("DIYproductId"));
String continueStr="";
String continueNoSaveStr="";
String cancelStr="";
boolean editor= ((((RoleResolver)session.getAttribute("roles")).roleCheck("editor")) || (request.getParameter("editor")!=null && request.getParameter("editor").equals("true")));

//If this is a reprint/job Edit get the job specs from the previous file an prefill the spec fields
String priorJobId=((session.getAttribute("priorJobId")==null)?"":session.getAttribute("priorJobId").toString());

String baseURL = HttpUtils.getRequestURL(request).toString();
session.setAttribute("baseurl",baseURL);
int dblslashIndex = baseURL.lastIndexOf("//")+2;
baseURL = dblslashIndex != -1 ? baseURL.substring(dblslashIndex, baseURL.length()) : "";
int slashIndex = baseURL.indexOf("/");
baseURL = slashIndex != -1 ? baseURL.substring(0, slashIndex) : "";
session.setAttribute("baseURL",baseURL);
String diyText="selfHelpCatalogText";
//If this catalog was entered as a 'self-design' job 
UserProfile up = (UserProfile)session.getAttribute("userProfile");

boolean selfDesigned=((request.getParameter("selfDesigned")==null || request.getParameter("selfDesigned").equals("false"))?false:true);
if(selfDesigned){
	session.setAttribute("selfDesigned","true");
}

String imageUserName="";
Connection conn = DBConnect.getConnection();
Statement st = conn.createStatement();

ResultSet rsUser = st.executeQuery("Select default_site_number from contacts where id="+up.getContactId());
if (rsUser.next()){
	imageUserName=rsUser.getString("default_site_number");
}


Statement st2 = conn.createStatement();
Statement st3 = conn.createStatement();
   String contactId = "0";
   try {
     contactId = (String)session.getAttribute("contactId");
	 if (contactId == null) contactId = "0"; 
   } catch (Exception ex) {
     contactId = "0";
   }
int qCount=0;
Random generator = new Random();

boolean allowPrintFile=false;

String tempImagePath="/tempFiles/";  
String pageDescription="";
String paramSpecValue="";
String titleString="";
String previewHeight="400";
String previewWidth="800";
String pPageWidth="0";
String pPageHeight="0";
String catSpecIdNum0="";
String catSpecIdNum1="";
String catSpecIdNum2="";
String catSpecIdNum3="";
String catSpecIdNum9100="";
String gridType="";
boolean useRecord = false;
String catJobID=request.getParameter("catJobId");
String vendorId=request.getParameter("vendorId");
String tierId=request.getParameter("tierId");
String siteHostId=((SiteHostSettings)session.getAttribute("siteHostSettings")).getSiteHostId();
String prodCode="";
String productCode="";
String backorderaction="0";
String backorderText="";
String invSQL="";
String catScript="";
String tempString="";
int invAmount=0;
int onOrderAmount=0;
boolean autoPopPromoCode=false;
String prodPromoCode="";

int maxOrders=0;
int numOrdered=0;

String shipPolicy="";
String previewTemplate="";
String pdfPreviewTemplate="";
String currentCatalogPage=((request.getAttribute("currentCatalogPage")==null)?((request.getParameter("currentCatalogPage")==null)?"1":request.getParameter("currentCatalogPage")):(String)request.getAttribute("currentCatalogPage"));

boolean postProdCost=((request.getParameter("postProdCost")==null)?false:((request.getParameter("postProdCost").equals("true"))?true:false));
boolean reprintFile=((session.getAttribute("reprintJob")==null)?false:((session.getAttribute("reprintJob").toString().equals("true"))?true:false));
String prePopId=((request.getParameter("prePopId")==null)?"":request.getParameter("prePopId"));
String prePopTable=((request.getParameter("prePopTable")==null || request.getParameter("prePopTable").equals("null"))?"":request.getParameter("prePopTable"));
System.out.println("postProdCost is "+postProdCost);
System.out.println("reprintFile is "+reprintFile);
System.out.println("prePopId is "+prePopId);
System.out.println("prePopTable is "+prePopTable);

ArrayList headers  = new ArrayList(15);
Hashtable hPreProp=new Hashtable<String,String>();

if (!(prePopId.equals("")) && !(prePopTable.equals("")) ){
	ResultSet rsPrePop = st.executeQuery("Select * from catspec_data_bridge where table_name='"+prePopTable+"'");
	String prePopQuery="Select ";
	int x=0;
	
	while  (rsPrePop.next()){
		prePopQuery+= ((x>0)?", ":"")+rsPrePop.getString("column_name")+" as '"+rsPrePop.getString("catspecid")+"' ";
		x++;
	}
	
	prePopQuery+=" from "+prePopTable+ " where id='"+prePopId+"'";

	
	ResultSet rs = st.executeQuery(prePopQuery);
	ResultSetMetaData rsmd = rs.getMetaData();
	int numberOfColumns = rsmd.getColumnCount();
	tempString = null;
	
	for (int i=1 ;i <= numberOfColumns; i++){
		tempString = new String ((String) rsmd.getColumnLabel(i));
		headers.add(tempString);
	}
	
	while (rs.next()){
		for (int i=0;i < numberOfColumns; i++){
			hPreProp.put(headers.get(i),rs.getString(headers.get(i).toString()));
		}
	} 
}
System.out.println("catJobId is "+request.getParameter("catJobId"));
ResultSet rsCatSpecId0 = st.executeQuery("Select id from catalog_specs where spec_id='9000'and cat_job_id="+request.getParameter("catJobId"));
if (rsCatSpecId0.next()){
	catSpecIdNum0=rsCatSpecId0.getString("id");
}
rsCatSpecId0.close();
ResultSet rsCatSpecId1 = st.executeQuery("Select id from catalog_specs where spec_id='9001'and cat_job_id="+request.getParameter("catJobId"));
if (rsCatSpecId1.next()){
	catSpecIdNum1=rsCatSpecId1.getString("id");
}
rsCatSpecId1.close();
ResultSet rsCatSpecId2 = st.executeQuery("Select id from catalog_specs where spec_id='9002'and cat_job_id="+request.getParameter("catJobId"));
if (rsCatSpecId2.next()){
	catSpecIdNum2=rsCatSpecId2.getString("id");
}
rsCatSpecId2.close();
ResultSet rsCatSpecId3 = st.executeQuery("Select id from catalog_specs where spec_id='9003'and cat_job_id="+request.getParameter("catJobId"));
if (rsCatSpecId3.next()){
	catSpecIdNum3=rsCatSpecId3.getString("id");
}
rsCatSpecId3.close();

ResultSet rsCatSpecId4 = st.executeQuery("Select id from catalog_specs where spec_id='9100'and cat_job_id="+request.getParameter("catJobId"));
if (rsCatSpecId4.next()){
	catSpecIdNum9100=rsCatSpecId4.getString("id");
}
rsCatSpecId4.close();
System.out.println("currentCatalogPage is "+currentCatalogPage);
ResultSet rsDescription = st.executeQuery("SELECT description,title,use_title_flag,preview_template,preview_height,preview_width FROM catalog_pages WHERE cat_job_id = " + request.getParameter("catJobId") + " AND page = " + currentCatalogPage);

if (rsDescription.next()){
	pageDescription=((rsDescription.getString("description")==null)?"":"<tr><td class='body' valign='top'>"+rsDescription.getString("description")+"<br><br></td></tr>");
	previewTemplate=((rsDescription.getString("preview_template")==null)?"":rsDescription.getString("preview_template"));
	previewHeight=((rsDescription.getString("preview_height")==null)?"":rsDescription.getString("preview_height"));	
	previewWidth=((rsDescription.getString("preview_width")==null)?"":rsDescription.getString("preview_width"));
	titleString=((rsDescription.getString("use_title_flag") != null && rsDescription.getString("use_title_flag").equals("1"))?"<td class='title'>"+rsDescription.getString("title")+"</td></tr>":"");

	useRecord=true;

}

%><table border="0" cellpadding="0" cellspacing="0" width="100%" height="100%"><%
   boolean proxyEnabled = false;
   try {
      ProxyOrderObject poo = (ProxyOrderObject)session.getAttribute("ProxyOrderObject");
      proxyEnabled = poo.isProxyEnabled();
   } catch (Exception ex) {}
   
rsDescription.close(); %><tr> 
      <td valign="top" align="left">
        <table width="98%" border="0">
        <%if (selfDesigned){
        String subTitleText=((session.getAttribute("reprintJob")!=null)?"REPRINT / CREATE NEW FILE VERSION":"Order - Edit Design File");
        %><tr><td><jsp:include page="/catalog/SHDCHeader.jsp" flush="true" >
	<jsp:param name="subTitle" value="<%=subTitleText%>" />
</jsp:include></td></tr><%}%>
          <tr valign="top"> 
        <%
int minAmount=0;
if (request.getParameter("productId")!=null && !request.getParameter("productId").equals("") && !catSpecIdNum1.equals("")){
	ResultSet rsProdInfo = st.executeQuery("SELECT products.*,vp.promo_code,vp.display_promo_w_prod 'show_prod_promo', vp.auto_populate_promo_code,vp.max_orders,format(products.p_page_height*72,0) as pPageHeight,format(products.p_page_width*72,0) as pPageWidth,vp.title 'sale_title',vp.description 'sale_desc',vp.sale_id 'sale_id',max(ship_price_policy) as ship_policy FROM products left join v_promo_prods vp on products.id=vp.prod_id and vp.start_date<=now() and vp.end_date>=now() left join product_prices on product_prices.prod_price_code=products.prod_price_code WHERE products.id =" + request.getParameter("productId") + " group by products.id" );
	if (rsProdInfo.next()){
		previewHeight=((rsProdInfo.getString("p_preview_height")==null || rsProdInfo.getString("p_preview_height").equals("0"))?previewHeight:rsProdInfo.getString("p_preview_height"));	
		previewWidth=((rsProdInfo.getString("p_preview_width")==null || rsProdInfo.getString("p_preview_width").equals("0") )?previewWidth:rsProdInfo.getString("p_preview_width"));
		autoPopPromoCode=((rsProdInfo.getString("auto_populate_promo_code")==null||rsProdInfo.getString("auto_populate_promo_code").equals("0"))?false:true);
		pPageHeight=((rsProdInfo.getString("pPageHeight")==null || rsProdInfo.getString("pPageHeight").equals("0"))?pPageHeight:rsProdInfo.getString("pPageHeight"));	
		pPageWidth=((rsProdInfo.getString("pPageWidth")==null || rsProdInfo.getString("pPageWidth").equals("0") )?pPageWidth:rsProdInfo.getString("pPageWidth"));
		prodPromoCode=((rsProdInfo.getString("promo_code")==null)?"":rsProdInfo.getString("promo_code"));
		allowPrintFile=((rsProdInfo.getString("allow_printfile")==null || rsProdInfo.getString("allow_printfile").equals("0"))?false:true);
		diyText=((rsProdInfo.getString("diy_catalog_text_pagename")==null || rsProdInfo.getString("diy_catalog_text_pagename").equals(""))?"selfHelpCatalogText":rsProdInfo.getString("diy_catalog_text_pagename"));
		pdfPreviewTemplate=((rsProdInfo.getString("pdf_preview_template")==null)?"":rsProdInfo.getString("pdf_preview_template"));
		catScript=((rsProdInfo.getString("catalog_script")==null)?"":rsProdInfo.getString("catalog_script"));
		prodCode=rsProdInfo.getString("prod_price_code");
		maxOrders=rsProdInfo.getInt("max_orders");
		productCode=rsProdInfo.getString("prod_code");
		shipPolicy=((rsProdInfo.getString("ship_policy").equals("1"))?"Shipping is included in the purchase price for this product.":"");
		shipPolicy=((rsProdInfo.getString("ship_policy").equals("2"))?"Flat Rate Shipping applies to this product and will be added at time of invoicing.":shipPolicy);
		backorderaction="0";
		backorderText="";
		invAmount=0;
		if ((rsProdInfo.getString("inventory_product_flag").equals("1") )){
			invAmount=Integer.parseInt(((rsProdInfo.getString("inventory_amount")==null || rsProdInfo.getString("inventory_amount").equals(""))?"0":rsProdInfo.getString("inventory_amount")));
			onOrderAmount=Integer.parseInt(((rsProdInfo.getString("inv_on_order_amount")==null || rsProdInfo.getString("inv_on_order_amount").equals(""))?"0":rsProdInfo.getString("inv_on_order_amount")));
			ResultSet rsMinAmount = st2.executeQuery("Select min(pp.quantity) from product_prices pp,products p where pp.prod_price_code=p.prod_price_code and  p.id="+request.getParameter("productId"));
			if (rsMinAmount.next()){
				minAmount=Integer.parseInt(rsMinAmount.getString(1));
			}
			rsMinAmount.close();
			if (invAmount - onOrderAmount < minAmount){ //if product is on backorder
				backorderaction=rsProdInfo.getString("backorder_action"); //1=show notes and allow order, 2=disable order and show prod not available
				if (rsProdInfo.getString("backorder_action").equals("2")){
					backorderText="Product Not Currently Available";						
				}else{
					backorderText=((rsProdInfo.getString("backorder_notes").equals(""))?"**NOTE: Available for Backorder":rsProdInfo.getString("backorder_notes"));
				}
			}
		}else{
			backorderText=((rsProdInfo.getString("backorder_notes")==null || rsProdInfo.getString("backorder_notes").equals("0"))?"":rsProdInfo.getString("backorder_notes"));		
		}
		boolean csImageFlag=((rsProdInfo.getString("image_coming_soon")==null || rsProdInfo.getString("image_coming_soon").equals("0"))?false:true);
		String csImage=rsProdInfo.getString("brand_code")+"coming_soon.jpg";
		String csPDF=rsProdInfo.getString("brand_code")+"coming_soon.pdf";
		if(previewTemplate.equals("")){
        	%><td width="12%"> 
              <a href="javascript:pop('<%=((rsProdInfo.getString("full_picurl")==null || rsProdInfo.getString("full_picurl").equals(""))?csPDF:""+siteHostRoot+"/fileuploads/product_images/"+ ((csImageFlag)?csPDF:str.replaceSubstring(rsProdInfo.getString("full_picurl")," ","%20")) +"'")%>,'800','600')" ><%=((rsProdInfo.getString("small_picurl")==null || rsProdInfo.getString("small_picurl").equals(""))?csImage:"<img src='"+siteHostRoot+"/fileuploads/product_images/"+ ((csImageFlag)?csImage:str.replaceSubstring(rsProdInfo.getString("small_picurl")," ","%20")) +"'>")%></a></div>
            </td>
            <td width="2%">&nbsp;</td>
            <td width="46%">
<div align="left">
                <p class="bodyBlack"><span class="catalogLABEL"><%
           if (rsProdInfo.getString("pdf_preview_template")!=null && !rsProdInfo.getString("pdf_preview_template").equals("")){%><input type='hidden'name='^9100^<%=catSpecIdNum9100%>' value='<%=rsProdInfo.getString("pdf_preview_template")%>'><%}%>
                  <input type='hidden'name='^9000^<%=catSpecIdNum0%>' value='<%=rsProdInfo.getString("id")%>'>
				  <%=rsProdInfo.getString("prod_name")%> 
                  <input type='hidden' name='^9001^<%=catSpecIdNum1%>' value='<%=rsProdInfo.getString("prod_code")%>'>
                  <%=rsProdInfo.getString("prod_code")%> 
                  <input type='hidden' name='^9002^<%=catSpecIdNum2%>' value='<%=rsProdInfo.getString("prod_name")%>'>
                  </span><br>
            <%=((rsProdInfo.getString("product_features")==null)?"":""+rsProdInfo.getString("product_features")+"<br>")%>
            <%=((rsProdInfo.getString("detailed_description")==null)?"":""+rsProdInfo.getString("detailed_description")+"")%>
<%=((shipPolicy.equals("") || allowPrintFile)?"":"<div class='subtitle' style='color:red;'>NOTE: "+shipPolicy+"")%>
            <%=((rsProdInfo.getString("catalog_text")==null)?"":"<div class=subtitle><br>"+rsProdInfo.getString("catalog_text")+"")%>
                  <input type='hidden'name='^9003^<%=catSpecIdNum3%>' value='<%=rsProdInfo.getString("detailed_description")%>'>
                  </p></div><%if(postProdCost){%><div class='subtitle'>Please note: pricing for this job will be determined upon job completion based on time and expense for production.</div><%}%></td>
            <td width="40%"> 
              <div align="left"><%=((rsProdInfo.getString("budget_guide")==null)?"":""+rsProdInfo.getString("budget_guide")+"")%></div>
            </td>
          </tr> <%=((rsProdInfo.getString("sale_title") !=null && !rsProdInfo.getString("sale_title").equals("") && rsProdInfo.getString("show_prod_promo").equals("1"))?"<tr><td class='catSaleLINK' colspan=4><span class='catSaleLINKTitle'>"+rsProdInfo.getString("sale_title")+"</span><br>"+rsProdInfo.getString("sale_desc")+"<br><a href=\"javascript:pop('/popups/promoDetails.jsp?id="+rsProdInfo.getString("sale_id")+"',600,600)\" class='greybutton'> Click for Details </a></td></tr>":"")%>
         <%}else{
         %><td class="Title">
                  <input type='hidden'name='^9000^<%=catSpecIdNum0%>' value='<%=rsProdInfo.getString("id")%>'>
				  <%=rsProdInfo.getString("prod_name")%> 
                  <input type='hidden' name='^9001^<%=catSpecIdNum1%>' value='<%=rsProdInfo.getString("prod_code")%>'>
                  <%=rsProdInfo.getString("prod_code")%> 
                  <input type='hidden' name='^9002^<%=catSpecIdNum2%>' value='<%=rsProdInfo.getString("prod_name")%>'>
            </td><%
            if (!pageDescription.equals("")){
            	%><td class="subtitle"><%=pageDescription%></td><%
            }
         }
          	prodCode=rsProdInfo.getString("prod_price_code");
		}
		  rsProdInfo.close();

}
boolean usePreview= ( (previewTemplate.equals("") || pdfPreviewTemplate.equals(""))?false:true);
%></table>

	  <hr color="red" width="98%" size="1">
        <table width="100%" border="0"><tr><td valign="top" class="catalogItem"><div align="left"><%
	
   ShoppingCart shoppingCart = (ShoppingCart)request.getSession().getAttribute("shoppingCart");
   String pageNumber = currentCatalogPage;
   int tabIndex = 1;
   String sql = "SELECT count(cs.id) qcount  FROM catalog_specs cs left join catspec_template_bridge ctb on ctb.page>0 and ctb.catspecid=cs.id and template_name='"+pdfPreviewTemplate+"'  left join job_specs js on js.cat_spec_id=cs.id and js.job_id='"+priorJobId+"', lu_specs ls WHERE "+((usePreview)?"ctb.id is not null AND ":"")+" cat_job_id = " + request.getParameter("catJobId") + " AND cs.page = " + pageNumber + " AND ls.id = cs.spec_id AND (axis = 724 or axis=725)";

   String numQuestions="1";
   ResultSet rsQCount=st.executeQuery(sql);
   if(rsQCount.next()){
   		numQuestions=((rsQCount.getString("qcount")==null)?"1":rsQCount.getString("qcount"));
   }
   System.out.println("pageNumber is "+pageNumber);
   System.out.println("usePreview is "+usePreview);
   System.out.println("priorJobId is "+priorJobId);
   System.out.println("pdfPreviewTemplate is "+pdfPreviewTemplate);
   
      sql = "SELECT cs.id, spec_id, cs.axis, ls.value AS spec_title, if(ctb.field_label is not null and ctb.field_label<>'',ctb.field_label,label) as label, cs.field_type, reset_value, include_pic_url,if(text_case='upper',concat('upper(',if(ctb.preload_sql is not null and ctb.preload_sql<>'',ctb.preload_sql,preload_field),')'),if(text_case='title',concat('tcase(',if(ctb.preload_sql is not null and ctb.preload_sql<>'',ctb.preload_sql,preload_field),')'),if(ctb.preload_sql is not null and ctb.preload_sql<>'',ctb.preload_sql,preload_field))) as preload_field,ctb.text_case,ctb.page as pdf_page,image_height_inches,if(image_height_inches is not null,image_height_inches*72,300) as image_height_pixels,image_width_inches,if(image_width_inches is not null,image_width_inches*72,300) as image_width_pixels,pdfblock_name,entry_hints,image_dpi,js.value as specValue,ctb.default_contents as defaultSpecValue,ctb.text_case as textCase,ctb.show_field as showField  FROM catalog_specs cs left join catspec_template_bridge ctb on ctb.page>0 and ctb.catspecid=cs.id and template_name='"+pdfPreviewTemplate+"'  left join job_specs js on js.cat_spec_id=cs.id and js.job_id='"+priorJobId+"', lu_specs ls WHERE "+((usePreview)?"ctb.id is not null AND ":"")+" cat_job_id = " + request.getParameter("catJobId") + " AND cs.page = " + pageNumber + " AND ls.id = cs.spec_id AND (axis = 724 or axis=725) ORDER BY ctb.sequence,cs.sequence";
   
	ResultSet rsQuestions = st.executeQuery(sql);
	String cSQL="";
	int fFields=0;
	while (rsQuestions.next()) {
   		if (rsQuestions.getString("preload_field")!= null && !(rsQuestions.getString("preload_field").equals("")) ){
   		   		cSQL+=((fFields++==0)?"Select "+rsQuestions.getString("preload_field"):", "+rsQuestions.getString("preload_field"));
   		}
//   		String textCase=((rsQuestions.getString("text_case")==null)?"":rsQuestions.getString("text_case"));
   		String pdfPage=((rsQuestions.getString("pdf_page")==null)?"":rsQuestions.getString("pdf_page"));
   		String imageHeight=((rsQuestions.getString("image_height_inches")==null)?"":rsQuestions.getString("image_height_inches"));
   		String imageWidth=((rsQuestions.getString("image_width_inches")==null)?"":rsQuestions.getString("image_width_inches"));
   		String pdfBlockName=((rsQuestions.getString("pdfblock_name")==null)?"":rsQuestions.getString("pdfblock_name"));
   		String entryHints=((rsQuestions.getString("entry_hints")==null)?"":rsQuestions.getString("entry_hints"));
   		String specValue=((rsQuestions.getString("specValue")==null)?"":rsQuestions.getString("specValue"));
   		String defaultSpecValue=((rsQuestions.getString("defaultSpecValue")==null)?"":rsQuestions.getString("defaultSpecValue"));
   		String textCase=((rsQuestions.getString("textCase")==null)?"1":rsQuestions.getString("textCase"));
   		boolean showField=((rsQuestions.getString("showField")==null || rsQuestions.getString("showField").equals("1"))?true:((rsQuestions.getString("showField").equals("0"))?false:true));
   		if (rsQuestions.getInt("axis")==724){
    	  int fieldType = rsQuestions.getInt("field_type");
    	  int catSpecId = rsQuestions.getInt("id");
    	  int specId = ((rsQuestions.getString("spec_id")==null)?0:rsQuestions.getInt("spec_id"));
		  String existingSpecValue = "";
		  JobSpecObject jso = (JobSpecObject)shoppingCart.getJobSpec(specId);
		  if (jso != null && rsQuestions.getInt("reset_value") == 0){
		  	existingSpecValue = (String)jso.getValue();
		  }else{
		  	existingSpecValue = ((specValue.equals(""))?defaultSpecValue:specValue);
		  }
		if(showField){
		  catQuestionLabel="<div align='left' style='padding-top:10px;' Class='catalogLABEL'>"+((rsQuestions.getString("label") != null)?rsQuestions.getString("label"):((rsQuestions.getString("spec_title")==null)?"":rsQuestions.getString("spec_title")))+"<br>";
		}
		if (fieldType == 715) { //Text
			if (showField && hPreProp.get(Integer.toString(specId))==null && request.getParameter(Integer.toString(specId))==null){
				%><%=catQuestionLabel%>
				<input tabindex="<%=tabIndex++%>" type="text"id="<%=((rsQuestions.getString("preload_field") != null && !(rsQuestions.getString("preload_field").equals("")))?rsQuestions.getString("preload_field"):tabIndex)%>" <%=((usePreview)?"onFocus=\"  lastFieldValue=this.value; \" onBlur=\" updatePreview(this,'"+previewTemplate+"')\" ":"") %> size="15" name="^<%=specId%>^<%=catSpecId%>" value="<%=existingSpecValue%>"><%	
			}else{
				paramSpecValue=((request.getParameter(Integer.toString(specId))==null)?hPreProp.get(Integer.toString(specId)).toString():request.getParameter(Integer.toString(specId)));
				%><span class='lineitems'><%=paramSpecValue%><input type="hidden" name="^<%=specId%>^<%=catSpecId%>" value="<%=paramSpecValue%>"></span><%
			}
		} else if (fieldType == 716) { //Text
			if (showField && hPreProp.get(Integer.toString(specId))==null && request.getParameter(Integer.toString(specId))==null){
				%><%=catQuestionLabel%><input tabindex="<%=tabIndex++%>" type="text" size="40" id="<%=((rsQuestions.getString("preload_field") != null && !(rsQuestions.getString("preload_field").equals("")))?rsQuestions.getString("preload_field"):tabIndex)%>" <%=((usePreview)?"onFocus=\"  lastFieldValue=this.value; \" onBlur=\" updatePreview(this,'"+previewTemplate+"')\" ":"") %>name="^<%=specId%>^<%=catSpecId%>" value="<%=existingSpecValue%>"><%
			}else if (!showField && hPreProp.get(Integer.toString(specId))==null && request.getParameter(Integer.toString(specId))==null){
				%><input type="hidden" id="<%=((rsQuestions.getString("preload_field") != null && !(rsQuestions.getString("preload_field").equals("")))?rsQuestions.getString("preload_field"):tabIndex)%>" name="^<%=specId%>^<%=catSpecId%>" value="<%=existingSpecValue%>"><%
			}else{
				paramSpecValue=((request.getParameter(Integer.toString(specId))==null)?hPreProp.get(Integer.toString(specId)).toString():request.getParameter(Integer.toString(specId)));
				%><span class='lineitems'><%=paramSpecValue%><input type="hidden" name="^<%=specId%>^<%=catSpecId%>" value="<%=paramSpecValue%>"></span><%
			}
		} else if (fieldType == 1762) { //Text Input
			if (showField && hPreProp.get(Integer.toString(specId))==null && request.getParameter(Integer.toString(specId))==null){
				%><%=catQuestionLabel%><textarea tabindex="<%=tabIndex++%>" cols="40" rows="3" id="<%=((rsQuestions.getString("preload_field") != null && !(rsQuestions.getString("preload_field").equals("")))?rsQuestions.getString("preload_field"):tabIndex)%>" <%=((usePreview)?"onFocus=\"  lastFieldValue=this.value; \" onBlur=\" updatePreview(this,'"+previewTemplate+"')\" ":"") %> name="^<%=specId%>^<%=catSpecId%>"><%=existingSpecValue%></textarea><%
			}else{
				paramSpecValue=((request.getParameter(Integer.toString(specId))==null)?hPreProp.get(Integer.toString(specId)).toString():request.getParameter(Integer.toString(specId)));
				%><span class='lineitems'><%=paramSpecValue%><input type="hidden" name="^<%=specId%>^<%=catSpecId%>" value="<%=paramSpecValue%>"></span><%
			}
			
			
		} else if (fieldType == 800) { //Image Input
			if (showField && hPreProp.get(Integer.toString(specId))==null && request.getParameter(Integer.toString(specId))==null){
				%><input  type="hidden" <%
				
				%>id="<%=((rsQuestions.getString("preload_field") != null && !(rsQuestions.getString("preload_field").equals("")))?rsQuestions.getString("preload_field"):"^"+specId+"^"+catSpecId)%>" <%	
				%>name="^<%=specId%>^<%=catSpecId%>" <%
				
				%>value="<%=existingSpecValue%>"><%
				
				%><br><br><a href="javascript:updateImage('http://<%=baseURL%>','<%=((rsQuestions.getString("preload_field") != null && !(rsQuestions.getString("preload_field").equals("")))?rsQuestions.getString("preload_field"):"^"+specId+"^"+catSpecId)%>'<%
				
				%>,'<%=pdfBlockName%>',<%
				
				%>'<%=previewTemplate%>',<%
				
				%>'<%=imageUserName%>',<%
				
				//temp Image Name
				%>'<%=((existingSpecValue.equals("")||true)?productCode+"_"+pdfBlockName+"_"+(String)session.getAttribute("contactId")+".jpg":existingSpecValue)%>',<%
				
				//temp Image Path
%>'<%=((existingSpecValue.equals("")||true)?tempImagePath:((existingSpecValue.indexOf(priorJobId+"_")>0)?existingSpecValue.substring(1,existingSpecValue.indexOf(priorJobId+"_")):existingSpecValue))%>',<%
				
				%>'<%=((rsQuestions.getString("image_dpi")==null || rsQuestions.getString("image_dpi").equals(""))?"300":rsQuestions.getString("image_dpi"))%>',<%
				
				%>'<%=((rsQuestions.getString("image_width_pixels")==null || rsQuestions.getString("image_width_pixels").equals(""))?"300":rsQuestions.getString("image_width_pixels"))%>',<%
				
				%>'<%=((rsQuestions.getString("image_height_pixels")==null || rsQuestions.getString("image_height_pixels").equals(""))?"300":rsQuestions.getString("image_height_pixels"))%>')" class="plainLink"><img src="/images/photos.jpg"  border="0" align="middle">Select <%=((rsQuestions.getString("label") != null)?rsQuestions.getString("label"):((rsQuestions.getString("spec_title")==null)?"":rsQuestions.getString("spec_title")))%>&nbsp;&raquo;</a><%
				
			}else{
				paramSpecValue=((request.getParameter(Integer.toString(specId))==null)?hPreProp.get(Integer.toString(specId)).toString():request.getParameter(Integer.toString(specId)));
				%><span class='lineitems'><%=paramSpecValue%><input type="hidden" name="^<%=specId%>^<%=catSpecId%>" value="<%=paramSpecValue%>"></span><%
			}
			
		} else if (fieldType == 801) { //Auto-populated pdf, e.g. map
			if (hPreProp.get(Integer.toString(specId))==null && request.getParameter(Integer.toString(specId))==null){
				%><input  type="hidden" <%				
				%>id="<%=((rsQuestions.getString("preload_field") != null && !(rsQuestions.getString("preload_field").equals("")))?rsQuestions.getString("preload_field"):"^"+specId+"^"+catSpecId)%>" <%	
				%>name="^<%=specId%>^<%=catSpecId%>" <%	
				%>value="<%=existingSpecValue%>"><%				
			}else{
				paramSpecValue=((request.getParameter(Integer.toString(specId))==null)?hPreProp.get(Integer.toString(specId)).toString():request.getParameter(Integer.toString(specId)));
				%><span class='lineitems'><%=paramSpecValue%><input type="hidden" name="^<%=specId%>^<%=catSpecId%>" value="<%=paramSpecValue%>"></span><%
			}

		} else {
         sql = "SELECT distinct cr.value AS value, cp.pic_url, span FROM catalog_rows AS cr LEFT JOIN catalog_pic_urls AS cp ON (cr.cat_spec_id = cp.cat_spec_id AND cr.value = cp.value) WHERE cr.cat_job_id = " + request.getParameter("catJobId") + " and cr.catalog_page = " + pageNumber + " AND cr.cat_spec_id = " + catSpecId + " GROUP BY cr.value ORDER BY span";
try{
         ResultSet rsQuestionChoices = st3.executeQuery(sql);
         String questiontitle=((rsQuestions.getString("spec_title")==null)?"":rsQuestions.getString("spec_title"));
         if (fieldType == 719) { //Radio Button
            String picUrl="";
            while (rsQuestionChoices.next()) {
               picUrl=((rsQuestionChoices.getString("pic_url")!=null && !rsQuestionChoices.getString("pic_url").equals(""))?"<image src="+rsQuestionChoices.getString("pic_url")+">":"");
               String tempValue = rsQuestionChoices.getString("value");
			   if (tempValue.equals(existingSpecValue)) { %><input tabindex="<%=tabIndex++%>" type="radio" name="^<%=specId%>^<%=catSpecId%>" value="<%=tempValue%>" checked><%= (picUrl == null || picUrl.equals("")) ? tempValue:picUrl %><%
               } else { 
					%><input tabindex="<%=tabIndex++%>" type="radio" name="^<%=specId%>^<%=catSpecId%>" value="<%=tempValue%>"><%= (picUrl == null || picUrl.equals("")) ? tempValue:picUrl %><%
               }
            }
         } else if (fieldType == 717) { // Menu
			%><select tabindex="<%=tabIndex++%>" name="^<%=specId%>^<%=catSpecId%>"><%
            while (rsQuestionChoices.next()) {
            	double specPrice = 0;
				String query3 = "SELECT price FROM catalog_prices cp, catalog_price_definitions cpd WHERE price != 0 AND cpd.id = cp.catalog_price_definition_id AND vendor_id = " + request.getParameter("vendorId") + " AND cat_job_id = " + request.getParameter("catJobId") + " AND row_number = " + rsQuestionChoices.getString("span") + " AND price_tier_id = " + request.getParameter("tierId");
				ResultSet rs3 = st.executeQuery(query3);
				if (rs3.next()) {
					specPrice = rs3.getDouble("price");
				}
               String tempValue = rsQuestionChoices.getString("value");
			   if (tempValue.equals(existingSpecValue)) { %><option value="<%= rsQuestionChoices.getString("value")%>" selected><%=tempValue%><%=(specPrice == 0) ? "":"  (+" + formatter.getCurrency(CatalogCalculator.getPrice(specPrice, Integer.parseInt(contactId), Integer.parseInt(((SiteHostSettings)session.getAttribute("siteHostSettings")).getSiteHostId()), proxyEnabled)) + ")"%></option><%
              } else { 
				%><option value="<%= rsQuestionChoices.getString("value")%>"><%=tempValue%><%=(specPrice == 0) ? "":"  (+" + formatter.getCurrency(CatalogCalculator.getPrice(specPrice, Integer.parseInt(contactId), Integer.parseInt(((SiteHostSettings)session.getAttribute("siteHostSettings")).getSiteHostId()), proxyEnabled)) + ")"%></option><%
              }
            }
			%></select><%
			} else if (fieldType == 718) { // Check Box 
				%><input type="checkbox" name="^<%=rsQuestions.getString("spec_id")%>^<%=catSpecId%>" value="Yes"><%
			}
}catch (Exception e){
	%>error:<%=e%><%
}finally{

}
		}
		%></b></div>
        <%
	}else{
		gridType="product";
	}
	}
	rsQuestions.close();
	%></div></td><%if(usePreview && qCount++==0){%><td valign="top"><div id='previewD'><iframe height="<%=previewHeight%>" width="<%=previewWidth%>" marginwidth="0" marginheight="0" frameborder="0" id="preview" name="preview" ></iframe><input type="hidden" name="imageusername" id="imageusername" value='<%=imageUserName%>'></div></td><%}%></tr><%
	cSQL+=((cSQL.equals(""))?"":", contacts.default_site_number as 'imageusername' from contacts left join locations l on l.contactid=contacts.id and l.locationtypeid='1'  left join lu_abreviated_states lustate on lustate.id=l.state  left join phones phone on phone.contactid=contacts.id and phone.phonetype=1 left join phones fax on fax.contactid=contacts.id and fax.phonetype=2 left join wyndham_properties on wyndham_properties.site_number=contacts.default_site_number, companies where contacts.companyid=companies.id and contacts.id="+contactId);
	System.out.println("cSQL in cqp_d12.jsp is "+cSQL);
	%>
	
	<script>
	function preLoadValues(){
	<%
	if (!(cSQL.equals(""))){ 
		ResultSet rsPrefill = st.executeQuery(cSQL);
     	ResultSetMetaData rsmd = rsPrefill.getMetaData();
     	int col = 1;
     	int numberOfColumns = rsmd.getColumnCount();
   		if (rsPrefill.next()) {
   			imageUserName=rsPrefill.getString("imageusername");
			for (int i=1 ;i <= numberOfColumns; i++){
		%>		el=document.getElementById("<%=((String) rsmd.getColumnName(i))%>");
		
		<%if(priorJobId.equals("")){%>
			el.value="<%=((rsPrefill.getString(i)==null)?"":rsPrefill.getString(i))%>";
		<%}else{%>
			el.value=((el.value=='')?"<%=((rsPrefill.getString(i)==null)?"":rsPrefill.getString(i))%>":el.value);
<%   	}
			}
		}
   	}
%>	}
</script>
</table>
<hr color="red" width="98%" size="1"><!-- </td>
    </tr>
    <tr> 
      <td>-->
      <table border="0" cellpadding="0" cellspacing="0" width="100%" >
<% if(allowPrintFile && currentCatalogPage.equals("1") && !reprintFile){
           	%><tr><td valign="top"><%if (editor){%><a href='javascript:pop("/popups/QuickChangeHTMLForm.jsp?cols=60&rows=3&question=Change%20Intro%20Text&primaryKeyValue=<%=sl.getValue("pages","page_name","'"+diyText+"'","id")%>&columnName=body&tableName=pages&valueType=string",500,350)'>&raquo;</a>&nbsp;<%}%><%=sl.getValue("pages","page_name","'"+diyText+"'","body").replace("DIYProductId",DIYproductId)%></td></tr><% 
           }%>
          <tr>
            <td align="left" style='padding-left:10px;'><%
            if(allowPrintFile){
            	%><!-- <div class='catalogLABEL'>If we print the item for you, orders are shipped UPS Ground. <%=((shipPolicy.equals(""))?"Shipping charges not included in price.":shipPolicy)%></div>--><%
            }else{
				%><%=((backorderText.equals(""))?"":"<hr><div class='subTitle' style='color: red;'>"+backorderText+"</div><hr>")%><%if(!usePreview){%><div class='catalogLABEL'>Orders shipped UPS Ground. <%=((shipPolicy.equals(""))?"Shipping charges not included in price.":shipPolicy)%></div><%}
            }
			//If productPriceGrid is to be used
			if (!gridType.equals("product") || backorderaction.equals("2")){
				prodCode="";
			}
			//Check whether this product has already been ordered the maximum bumber of times for the current promo in either the shopping cart or previous orders
			if(maxOrders>0){
			    if (shoppingCart != null && shoppingCart.getProjects().size()>0){
    				Vector projects = shoppingCart.getProjects();
					int projectId;
    				for (int x = 0; x < projects.size(); x++) {
        				ProjectObject tempProject =  (ProjectObject) projects.elementAt(x);
						Vector tempJobs = tempProject.getJobs();
        				for (int y = 0; y < tempJobs.size(); y++) {
        					JobObject tempJob = (JobObject) tempJobs.elementAt(y);
        					if(tempJob.getProductId()!=null && tempJob.getProductId().equals(productId)){
        							numOrdered++;
        					}
        				}
					}
    			}
    			shoppingCart=null;
    			sql = "Select count(id) 'numOrdered' from jobs where product_id= '" + productId + "' AND promo_code = '" + prodPromoCode + "' and if(site_number is not null and site_number<>'',site_number='"+up.getSiteNumber()+"',jbuyer_company_id='"+up.getCompanyId()+"')";
         		ResultSet rsNumOrdered = st3.executeQuery(sql);
         		if(rsNumOrdered.next()){
         			numOrdered+=((rsNumOrdered.getString("numOrdered")!=null)?rsNumOrdered.getInt("numOrdered"):0);
         		}
         		
				if (numOrdered>=maxOrders){
					prodCode="";
					%><br><div class=subtitle align="center" style="color:Red;">NOTE: This product has already been ordered the maximum number of time allowed by this promotion, please choose another product to order.</div><%
				}
				rsNumOrdered.close();
			}
			if(autoPopPromoCode && !prodPromoCode.equals("") && (maxOrders==0 || numOrdered<maxOrders)){
		  		session.setAttribute("promoCode",prodPromoCode);
		  	}
			
			%><taglib:PricingGridTag productCode="<%=prodCode%>" catJobId="<%=catJobID%>" contactId="<%=contactId%>" vendorId="<%=vendorId%>" tierId="<%=tierId%>" siteHostId="<%=siteHostId%>" catalogPage="<%=pageNumber%>" proxyEnabled="<%=proxyEnabled%>"/><%
			//Get the footnotes for the grid labels, if any
			String glQuery = "select lgl.value from product_prices pp left join lu_price_grid_text lgl on lgl.id=pp.grid_label_description_id where lgl.id is not null and prod_price_code='"+prodCode+"' order by sequence, price desc, quantity desc";
			ResultSet gl = st.executeQuery(glQuery);
			int footNotes=0;
			while (gl.next()) {
				%><%=((footNotes>0)?"":"<br><div class='subtitle'><i>Note:</i></div>")%><div class="catalogLABEL"><%="<sup>"+ (footNotes++) + "</sup>&nbsp;" + gl.getString("value")%></div><%
			}
			%></td>
			</tr>
			<tr><td>&nbsp;</td></tr>
        </table>
 <!--       </td>
    </tr>
    <tr> 
      <td valign="top" align="center" colspan="2" valign="top"> -->
        <div align='center'><%
        if (gridExists.equals("0") && !backorderaction.equals("2") && (maxOrders==0 || numOrdered<maxOrders)) { 
			if(usePreview){
			%><div style="display:none;" id="pdfPrepDiv"><iframe height="0" width="0" marginwidth="0" marginheight="0" frameborder="0" id="pdfPrep" name="pdfPrep" ></iframe></div><%}%>
<%if(!usePreview && selfDesigned){%><table width="100%" border="0"><tr>
		<td align="left"><a href="javascript:saveFile('<%=previewTemplate%>','<%=pdfPreviewTemplate.replace(".","_laser.")%>','Laser','false')" class="plainLink">&raquo;&nbsp;Save and Download a Laser-Printable PDF</a><span class="bodyBlack">-- Allows you to save to your PC a PDF file which can be printed on your color laser printer.</span> </td>
	</tr>
	    <tr>
			<td align="left"><a href="javascript:saveFile('<%=previewTemplate%>','<%=pdfPreviewTemplate.replace(".","_prepress.")%>','PrePress','false')" class="plainLink">&raquo;&nbsp;Save and Download a Press-Ready PDF</a><span class="bodyBlack"> -- Allows you to save to your PC a professional press-ready PDF file which you can deliver to the printer of your choice.</span> </td>
	</tr>
	<tr>
		<td align="left" ><a href="javascript:saveFile('<%=previewTemplate%>','<%=pdfPreviewTemplate.replace(".","_laser.")%>','Laser','true')" class="plainLink">&raquo;&nbsp;Save This File and Place an Order to Print this File</a><span class="bodyBlack"> -- If you'd like us to print the file you've just designed.</span></td></tr></table>
			<!--<a href="javascript:preLoadValues();" class="greybutton"><span id='preFillButton'>Restore Default Values</span>--></a>&nbsp;&nbsp;&nbsp;<a href="javascript:parent.window.location.replace('/index.jsp?contents=<%=(String)session.getAttribute("siteHostRoot")%>/contents/SiteHostIndex.jsp')" class="greybutton">Cancel</a><%
          }else{
          String footerTextStr=sl.getValue("pages","page_name","'templateFooter'","html");
          footerTextStr=((footerTextStr==null || footerTextStr.equals(""))?"Special Note:  If your information is too large to fit reasonably within the design template,<br>such as if you have an exceptionally long city name, please contact customer service at 888-777-9832 for assistance. <br>-Click continue to order this item to be printed as shown in the above preview.  This will be the only proof you will receive before printing.":footerTextStr);
         if(usePreview && !allowPrintFile) {%><%=footerTextStr%><%}
          %><div id="pButtons" style="display:none;"><%
          cancelStr="<a href=\"javascript:parent.window.location.replace('/index.jsp?contents="+(String)session.getAttribute("siteHostRoot")+"/contents/SiteHostIndex.jsp')\" class='greybutton'>Cancel</a>&nbsp;&nbsp;&nbsp;";
          continueStr="&nbsp;&nbsp;&nbsp;<a href=\"javascript:"+((usePreview && session.getAttribute("selfDesigned")==null)?"saveFile('"+previewTemplate+"','"+pdfPreviewTemplate.replace(".","_prepress.")+"','PrePress','false');":"document.forms[0].submit()")+"\" class='greybutton'>Continue</a>";
          continueNoSaveStr="&nbsp;&nbsp;&nbsp;<a href='javascript:continueNoSave()' class='greybutton'>Continue w/o Saving Proof</a>";
          %><%=cancelStr+continueStr+((session.getAttribute("proxyId")!=null)?continueNoSaveStr:"")%></div>
          <div id="pCancel" style="display:none;"><%=cancelStr%><%=continueNoSaveStr%></div>
          <%          
          
         }
           
		} else { 

			%><a href="javascript:parent.window.location.replace('/index.jsp?contents=<%=(String)session.getAttribute("siteHostRoot")%>/contents/SiteHostIndex.jsp')" class="greybutton">Cancel</a><%
		}
		%></div>
      </td>
    </tr>
    <tr> 
      <td valign="bottom" colspan="10"><br><jsp:include page="/footers/inner_footer.jsp" flush="true"></jsp:include> 
      </td>
    </tr>
  </table>
  <input type="hidden" name="coordinates" value="">
  <input type="hidden" name="selfDesigned" value="<%=selfDesigned%>">
  <input type="hidden" name="priorJobId" value="<%=priorJobId%>">
  <input type="hidden" name="pdfPreviewTemplate" value="<%=pdfPreviewTemplate%>">
  <input type="hidden" name="previewWidth" value="<%=previewWidth%>">
  <input type="hidden" name="previewHeight" value="<%=previewHeight%>">
  <input type="hidden" name="pPageWidth" value="<%=pPageWidth%>">
  <input type="hidden" name="pPageHeight" value="<%=pPageHeight%>">
  <input type="hidden" name="vendorId" value="<%=request.getParameter("vendorId")%>">
  <input type="hidden" name="prePopId" value="<%=request.getParameter("prePopId")%>">
  <input type="hidden" name="prePopTable" value="<%=request.getParameter("prePopTable")%>">
  <input type="hidden" name="currentCatalogPage" value="<%=currentCatalogPage%>">
  <input type="hidden" name="catJobId" value="<%=request.getParameter("catJobId")%>">
  <input type="hidden" name="offeringId" value="<%=request.getParameter("offeringId")%>">
  <input type="hidden" name="tierId" value="<%=request.getParameter("tierId")%>">
  <input type="hidden" name="prodCode" value="<%=prodCode%>">
  <input type="hidden" name="productCode" value="<%=productCode%>">
  <input type="hidden" name="usePreview" value="<%=usePreview%>">
  <input type="hidden" name="savedFileType" value="">
  <input type="hidden" name="rePrint" value="">
  <%if (usePreview){session.setAttribute("usePreview","true");}%>
 	<input type="hidden" name="productId" value="<%=productId%>">
	<input type="hidden" name="siteID" value="<%=siteHostId%>"><%
  ProjectObject po = (ProjectObject)session.getAttribute("currentProject");
  JobObject jo = po.getCurrentJob();
  
  //set jobid and record visit.
  if(currentCatalogPage.equals("1")){
		st.execute("insert into catalog_visits ( product_id, contact_id, sitehost_id,job_id) values ( '"+productId+"', '"+contactId+"', '"+siteHostId+"','"+jo.getId()+"')");
	}
%>
<input type="hidden" name="jobId" value="<%=jo.getId()%>">
<input type="hidden" name="pdfPage" value="1">
<%=((catScript.equals(""))?"":"<script>"+catScript+"</script>")%>

<script>

function showContinue(){
	var el= document.getElementById("pButtons");
	if (el!=null){
		el.style.display="";
		document.getElementById("pCancel").style.display="none";
	}
}

function hideContinue(){
	var el= document.getElementById("pButtons");
	if (el!=null){
		el.style.display="none";
		document.getElementById("pCancel").style.display="";
	}
}

showContinue();
preLoadValues();
<%
if(usePreview){

%>function updatePreview(el,prodTemplate){
	if(el.value==lastFieldValue){
		return;
	}else{
		previewProduct(prodTemplate);
	}
}

function continueNoSave(){
	if(confirm("<%=sl.getValue("pages","page_name","'continue_no_save_dialog'","html")%>")){
		document.forms[0].submit()
	}
}

function previewProduct(prodTemplate){
	document.getElementById('previewD').style.display='block';
	var formAction=document.forms[0].action;
	document.forms[0].action='/preview/'+prodTemplate;
	var formTarget=document.forms[0].target;
	document.forms[0].target='preview';
	document.forms[0].submit();
	document.forms[0].action=formAction;
	document.forms[0].target=formTarget;
}

function saveFile(prodTemplate,pdfTemplate,savedFileType,rePrint){
	document.forms[0].savedFileType.value=savedFileType;
	var formAction=document.forms[0].action;
	document.forms[0].action='/preview/'+prodTemplate+"?saveFile=true";
	var formTarget=document.forms[0].target;
	document.forms[0].target='pdfPrep';
	document.forms[0].pdfPreviewTemplate.value=pdfTemplate;
	document.forms[0].submit();
	document.forms[0].rePrint.value=rePrint;
	document.forms[0].action=formAction;
	document.forms[0].target=formTarget;
}

function setPage(pdfPage){
	document.forms[0].pdfPage.value=pdfPage;
	previewProduct('<%=previewTemplate%>');
}

previewProduct('<%=previewTemplate%>');<%}

if(!priorJobId.equals("") ) {
	if(gridExists.equals("0")){
		%>
		document.forms[0].target='contents';
		document.forms[0].submit();<%
	}else if (session.getAttribute("lastRow")!=null && session.getAttribute("lastCol")!=null){
		%>makeSelection('<%=session.getAttribute("lastRow").toString()%>','<%=session.getAttribute("lastCol").toString()%>')<%
		session.removeAttribute("lastRow");
		session.removeAttribute("lastCol");
		session.removeAttribute("selfDesigned");
	}
}
st.close();
st2.close();
st3.close();
conn.close();
%>
</script>
</form>
</body>
</html>
