<%@ page import="java.sql.*, com.marcomet.catalog.*,com.marcomet.jdbc.*,com.marcomet.environment.*" %>
<%@ taglib uri="/WEB-INF/tld/taglib.tld" prefix="taglib" %>
<jsp:useBean id="formatter" class="com.marcomet.tools.FormaterTool" scope="page" />
<jsp:useBean id="str" class="com.marcomet.tools.StringTool" scope="page" />
<html>
<head>
<title>Catalog Wizard</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link rel="stylesheet" href="<%=(String)session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css">
<link rel="stylesheet" href="/styles/misc_styles.css" type="text/css">

</head>
<script language="javascript" src="/javascripts/mainlib.js"></script>
<script>
function makeSelection(x, y) {
	document.forms[0].coordinates.value=x + "," + y;
	document.forms[0].submit();
}
</script>
<body leftmargin="0" topmargin="0" marginwidth="0" marginheight="0" onLoad="MM_preloadImages('/images/buttons/continueover.gif', '/images/buttons/cancelbtover.gif');populateTitle('<%= (String)request.getAttribute("title")%>')" background="<%=(String)session.getAttribute("siteHostRoot")%>/images/back3.jpg">
<form method="post" action="/servlet/com.marcomet.catalog.CatalogControllerServlet"><%

Connection conn = DBConnect.getConnection();
Statement st = conn.createStatement();
Statement st2 = conn.createStatement();
Statement st3 = conn.createStatement();
   String contactId = "0";
   try {
     contactId = (String)session.getAttribute("contactId");
	 if (contactId == null) contactId = "0"; 
   } catch (Exception ex) {
     contactId = "0";
   }
String titleString="";
String catSpecIdNum0="";
String catSpecIdNum1="";
String catSpecIdNum2="";
String catSpecIdNum3="";
String gridType="";
boolean useRecord = false;
String catJobID=request.getParameter("catJobId");
String vendorId=request.getParameter("vendorId");
String tierId=request.getParameter("tierId");
String siteHostId=((SiteHostSettings)session.getAttribute("siteHostSettings")).getSiteHostId();
String prodCode="";
String backorderaction="0";
String backorderText="";
String invSQL="";
String catScript="";
int invAmount=0;
int onOrderAmount=0;

String prePopId=((request.getParameter("prePopId")==null || request.getParameter("prePopId").equals(""))?"":request.getParameter("prePopId"));
String prePopTable=((request.getParameter("prePopTable")==null || request.getParameter("prePopTable").equals(""))?"":request.getParameter("prePopTable"));
Vector headers  = new Vector(15);
Hashtable hPreProp=new Hashtable<String,String>();

if (!(prePopId.equals("")) && !(prePopTable.equals("")) )){
	ResultSet rsPrePop = st.executeQuery("Select * from from catspec_data_bridge where table_name='"+prePopTable+"'");
	String prePopQuery="Select ";
	int x=0;
	
	while  (rsPrePop.next()){
		prePopQuery+= ((x>0)?", ":"")+rsPrePop.getString("field_name")+" as '"+rsPrePop.getString("catspecid")+"'";
	}
	prePopQuery+=" from "+prePopTable+ " where id='"+prePropId+"'";
	
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
			hPreProp.put(headers[i],rs.getString(headers[i]));
		}
	} 
}

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
ResultSet rsDescription = st.executeQuery("SELECT description,title,use_title_flag FROM catalog_pages WHERE cat_job_id = " + request.getParameter("catJobId") + " AND page = " + request.getAttribute("currentCatalogPage"));

if (rsDescription.next()){

	titleString=((rsDescription.getString("use_title_flag") != null && rsDescription.getString("use_title_flag").equals("1"))?"<td class='title'>"+rsDescription.getString("title")+"</td></tr>":"");

	useRecord=true;

}%><table border="0" cellpadding="0" cellspacing="0" width="100%" height="100%"><%
   boolean proxyEnabled = false;
   try {
      ProxyOrderObject poo = (ProxyOrderObject)session.getAttribute("ProxyOrderObject");
      proxyEnabled = poo.isProxyEnabled();
   } catch (Exception ex) {}
   
   if (useRecord && (rsDescription.getString("description") != null || !titleString.equals(""))) { 
	%><tr> 
      <td align="center"> <table width="98%">
          <tr><%=titleString%><%=((rsDescription.getString("description")==null)?"":"<tr><td class='body' valign='top'>"+rsDescription.getString("description")+"<br><br></td></tr>")%> </table></td>
    </tr><%
  }
rsDescription.close(); %><tr> 
      <td valign="top" align="center">
        <table width="98%" border="0">
          <tr valign="top"> 
            <td width="12%"> 
              <div align="center"><%
int minAmount=0;
if (request.getParameter("productId")!=null && !request.getParameter("productId").equals("") && !catSpecIdNum1.equals("")){
	ResultSet rsProdInfo = st.executeQuery("SELECT *,vp.title 'sale_title',vp.description 'sale_desc' FROM products left join v_promo_prods vp on products.id=vp.prod_id and vp.start_date<=now() and vp.end_date>=now() WHERE id = " + request.getParameter("productId") );
	if (rsProdInfo.next()){
		catScript=((rsProdInfo.getString("catalog_script")==null)?"":rsProdInfo.getString("catalog_script"));
		prodCode=rsProdInfo.getString("prod_price_code");
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
		
%><a href="javascript:pop('<%=((rsProdInfo.getString("full_picurl")==null || rsProdInfo.getString("full_picurl").equals(""))?csPDF:""+(String)session.getAttribute("siteHostRoot")+"/fileuploads/product_images/"+ ((csImageFlag)?csPDF:str.replaceSubstring(rsProdInfo.getString("full_picurl")," ","%20")) +"'")%>,'800','600')" ><%=((rsProdInfo.getString("small_picurl")==null || rsProdInfo.getString("small_picurl").equals(""))?csImage:"<img src='"+(String)session.getAttribute("siteHostRoot")+"/fileuploads/product_images/"+ ((csImageFlag)?csImage:str.replaceSubstring(rsProdInfo.getString("small_picurl")," ","%20")) +"'>")%></a>
              </div>
            </td>
            <td width="2%">&nbsp;</td>
            <td width="46%">
<div align="left"> ``````````````
                <p class="bodyBlack"><span class="Title">
                  <input type='hidden'name='^9000^<%=catSpecIdNum0%>' value='<%=rsProdInfo.getString("id")%>'>
				  <%=rsProdInfo.getString("prod_name")%> 
                  <input type='hidden' name='^9001^<%=catSpecIdNum1%>' value='<%=rsProdInfo.getString("prod_code")%>'>
                  <%=rsProdInfo.getString("prod_code")%> 
                  <input type='hidden' name='^9002^<%=catSpecIdNum2%>' value='<%=rsProdInfo.getString("prod_name")%>'>
                  </span><br>
            <%=((rsProdInfo.getString("product_features")==null)?"":""+rsProdInfo.getString("product_features")+"<br>")%>
<div class='subTitle'>
            <%=((rsProdInfo.getString("detailed_description")==null)?"":""+rsProdInfo.getString("detailed_description")+"")%>
            <%=((rsProdInfo.getString("catalog_text")==null)?"":"<div class=subtitle><br>"+rsProdInfo.getString("catalog_text")+"</div>")%>
                  <input type='hidden'name='^9003^<%=catSpecIdNum3%>' value='<%=rsProdInfo.getString("detailed_description")%>'>
                  </p></div></td>
            <td width="40%"> 
              <div align="left"><%=((rsProdInfo.getString("budget_guide")==null)?"":""+rsProdInfo.getString("budget_guide")+"")%></div>
            </td>
          </tr> <%=((rsProdInfo.getString("sale_title") !=null && !rsProdInfo.getString("sale_title").equals(""))?"<tr><td class='catSaleLINK' colspan=4><span class='catSaleLINKTitle'>"+rsProdInfo.getString("sale_title")+"</span><br>"+rsProdInfo.getString("sale_desc")+"</td></tr>":"")%>
         <%
          	prodCode=rsProdInfo.getString("prod_price_code");
		  }
		  rsProdInfo.close();

}%></table>

	  <hr color="red" width="98%" size="1">
        <table width="98%"><%
   ShoppingCart shoppingCart = (ShoppingCart)request.getSession().getAttribute("shoppingCart");
   String pageNumber = (String)request.getAttribute("currentCatalogPage");
   int tabIndex = 1;
   String sql = "SELECT cs.id, spec_id, cs.axis, ls.value AS spec_title, label, field_type, reset_value, include_pic_url FROM catalog_specs cs, lu_specs ls WHERE cat_job_id = " + request.getParameter("catJobId") + " AND page = " + pageNumber + " AND ls.id = cs.spec_id AND (axis = 724 or axis=725) ORDER BY cs.sequence";

   ResultSet rsQuestions = st.executeQuery(sql);

   while (rsQuestions.next()) {
   if (rsQuestions.getInt("axis")==724){
      int fieldType = rsQuestions.getInt("field_type");
      int catSpecId = rsQuestions.getInt("id");
      int specId = rsQuestions.getInt("spec_id");
	  String existingSpecValue = "";
	  JobSpecObject jso = (JobSpecObject)shoppingCart.getJobSpec(specId);
	  if (jso != null && rsQuestions.getInt("reset_value") == 0)
	  	existingSpecValue = (String)jso.getValue();
		%><tr> 
            <td class="catalogITEM" valign="top" align="left" width="45%"><%=((rsQuestions.getString("label") != null)?rsQuestions.getString("label"):rsQuestions.getString("spec_title"))%></td>
            <td class="bodyBlack"> <b><%
		if (fieldType == 715) { //Text
			if (hPreProp.get(catSpecId)==null){
				%><input tabindex="<%=tabIndex++%>" type="textsm" size="15" name="^<%=specId%>^<%=catSpecId%>" value="<%=existingSpecValue%>"><%	
			}else{
				%><div class='lineitems'><%=hPreProp.get(catSpecId)%><input type="hidden" name="^<%=specId%>^<%=catSpecId%>" value="<%=hPreProp.get(catSpecId)%>"></div><%
			}
		} else if (fieldType == 716) { //Text
			if (hPreProp.get(catSpecId)==null){
				%><input tabindex="<%=tabIndex++%>" type="text" size="40" name="^<%=specId%>^<%=catSpecId%>" value="<%=existingSpecValue%>"><%
			}else{
				%><div class='lineitems'><%=hPreProp.get(catSpecId)%><input type="hidden" name="^<%=specId%>^<%=catSpecId%>" value="<%=hPreProp.get(catSpecId)%>"></div><%
			}
		} else if (fieldType == 1762) { //Text Input
			if (hPreProp.get(catSpecId)==null){
				%><textarea tabindex="<%=tabIndex++%>" cols="65" rows="3" name="^<%=specId%>^<%=catSpecId%>"><%=existingSpecValue%></textarea><%
			}else{
				%><div class='lineitems'><%=hPreProp.get(catSpecId)%><input type="hidden" name="^<%=specId%>^<%=catSpecId%>" value="<%=hPreProp.get(catSpecId)%>"></div><%
			}
		} else {
         sql = "SELECT distinct cr.value AS value, cp.pic_url, span FROM catalog_rows AS cr LEFT JOIN catalog_pic_urls AS cp ON (cr.cat_spec_id = cp.cat_spec_id AND cr.value = cp.value) WHERE cr.cat_job_id = " + request.getParameter("catJobId") + " and cr.catalog_page = " + pageNumber + " AND cr.cat_spec_id = " + catSpecId + " GROUP BY cr.value ORDER BY span";
try{
         ResultSet rsQuestionChoices = st3.executeQuery(sql);
         String questiontitle=rsQuestions.getString("spec_title");
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
		%></b></td>
        </tr><%
	}else{
		gridType="product";
	}
	}
	rsQuestions.close();
%></table>
<hr color="red" width="98%" size="1"> </td>
    </tr>
    <tr> 
      <td> <table border="0" cellpadding="0" cellspacing="0" width="100%" height="100%">
          <tr> 
            <td></td>
          </tr>
          <tr> 
            <td align="center"><%=((backorderText.equals(""))?"":"<hr><div class='subTitle' style='color: red;'>"+backorderText+"</div><hr>")%> <%
			//If productPriceGrid is to be used
			if (!gridType.equals("product") || backorderaction.equals("2")){
				prodCode="";
			}%><taglib:PricingGridTag productCode="<%=prodCode%>" catJobId="<%=catJobID%>" contactId="<%=contactId%>" vendorId="<%=vendorId%>" tierId="<%=tierId%>" siteHostId="<%=siteHostId%>" catalogPage="<%=pageNumber%>" proxyEnabled="<%=proxyEnabled%>"/><%
			%></td>
          </tr>
        </table></td>
    </tr>
    <tr> 
      <td valign="top" align="center" colspan="2"> 
        <table width="20%"><%
        if (gridExists.equals("0") && !backorderaction.equals("2")) { 
			%><tr> 
            <td align="right" width="48%"><a href="javascript:parent.window.location.replace('/index.jsp?contents=<%=(String)session.getAttribute("siteHostRoot")%>/contents/SiteHostIndex.jsp')" class="greybutton">Cancel</a></td>
            <td width="4%">&nbsp;</td>
            <td align="left" width="48%"><a href="javascript:document.forms[0].submit()" class="greybutton">Continue</a></td>
          </tr><%
		} else { 
			%><tr> 
            <td align="center" colspan="3"><a href="javascript:parent.window.location.replace('/index.jsp?contents=<%=(String)session.getAttribute("siteHostRoot")%>/contents/SiteHostIndex.jsp')" class="greybutton">Cancel</a></td>
          </tr><%
		} 
		st.close();
		st2.close();
		st3.close();
		conn.close();
		%></table>
      </td>
    </tr>
    <tr> 
      <td valign="bottom" colspan="10"><br><jsp:include page="/footers/inner_footer.jsp" flush="true"></jsp:include> 
      </td>
    </tr>
  </table>
  <input type="hidden" name="coordinates" value="">
  <input type="hidden" name="vendorId" value="<%=request.getParameter("vendorId")%>">
  <input type="hidden" name="currentCatalogPage" value="<%=request.getAttribute("currentCatalogPage")%>">
  <input type="hidden" name="catJobId" value="<%=request.getParameter("catJobId")%>">
  <input type="hidden" name="offeringId" value="<%=request.getParameter("offeringId")%>">
  <input type="hidden" name="tierId" value="<%=request.getParameter("tierId")%>">
  <input type="hidden" name="prodCode" value="<%=prodCode%>">
<input type="hidden" name="siteID" value="<%=siteHostId%>">
<%=((catScript.equals(""))?"":"<script>"+catScript+"</script>")%>
</form>
</body>
</html>
