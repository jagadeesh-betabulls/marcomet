<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<%@ page import="java.sql.*,java.util.*,com.marcomet.jdbc.*,com.marcomet.workflow.*,com.marcomet.users.security.*;" %>
<%@ taglib uri="/WEB-INF/tld/taglib.tld" prefix="taglib" %>
<%@ include file="/includes/SessionChecker.jsp" %>
<jsp:useBean id="validator" class="com.marcomet.tools.FieldValidationBean" scope="page" />
<%
String jobId = request.getParameter("jobId");
String query = "select price, escrow_amount, shipping_price as shipping from jobs where id = " + jobId;

boolean editor= ((((RoleResolver)session.getAttribute("roles")).roleCheck("editor")) && !(print));
Connection conn = DBConnect.getConnection();
Statement st = conn.createStatement();
ResultSet rs = st.executeQuery(query);

Hashtable rehash = new Hashtable();

if (rs.next()) {
	//rehash.put("price", (new Double(rs.getDouble("price"))).toString());
	rehash.put("escrow", (new Double(rs.getDouble("escrow_amount"))).toString());
	rehash.put("shipping", (new Double(rs.getDouble("shipping"))).toString());
}else{
	rehash.put("price", "0");
	rehash.put("escrow", "0");
	rehash.put("shipping", "0");
}

//get price
String queryJSPrice = "SELECT SUM(js.price) 'price' FROM job_specs js WHERE cost != -1 AND js.job_id = " + jobId;
ResultSet rsPrice = st.executeQuery(queryJSPrice);
if(rsPrice.next()){
	String price = rsPrice.getString("price");
	if (price == null)
		price = "0";
	rehash.put("price", price);
}else{
	rehash.put("price", "0");
}

int counter = 0;
double sum = 0;
String changesQuery = "select price from jobchanges where jobid = " + jobId;
ResultSet rs2 = st.executeQuery(changesQuery);
while (rs2.next()) {
	rehash.put("change" + counter, (new Double(rs2.getDouble("price"))).toString());
	sum = sum + rs2.getDouble("price");
	counter++;
}
rehash.put("sum", (new Double(sum)).toString());


String taxQuery = "select entity, rate, tax_shipping, tax_job, buyer_exempt from sales_tax where job_id = " + jobId;
ResultSet rs3 = st.executeQuery(taxQuery);
if (rs3.next()) {
	rehash.put("taxEntity", rs3.getString("entity"));
	rehash.put("taxRate", rs3.getString("rate"));
	rehash.put("taxShipping", rs3.getString("tax_shipping"));
	rehash.put("taxJob", rs3.getString("tax_job"));
	rehash.put("buyerExempt", rs3.getString("buyer_exempt"));
}else{
	rehash.put("taxEntity", "0");
	rehash.put("taxRate", "0");
	rehash.put("taxShipping", "0");
	rehash.put("taxJob", "0");
	rehash.put("buyerExempt", "0");
}	
try { st.close(); } catch (Exception e) {}
try { conn.close(); } catch (Exception e) {}
%>

<html>
<head>
  <title>Final Invoice</title>
  <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
  <link rel="stylesheet" href="<%=(String)session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css">
 <script language="javascript" type="text/javascript" src="/javascripts/tiny_mce/tiny_mce.js"></script>
  <script language="javascript" type="text/javascript">
	tinyMCE.init({
		theme : "advanced",
		mode : "exact",
		elements : "message",
		submit_patch : false,
		content_css : "<%=(String)session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css",
		extended_valid_elements : "link[rel|href|type]",
		plugins : "table,visualchars",
		theme_advanced_buttons3_add_before : "tablecontrols,separator,visualchars",
		//invalid_elements : "a",
		theme_advanced_styles : "Title=title;Subtitle=subtitle;", // Theme specific setting CSS classes
		//execcommand_callback : "myCustomExecCommandHandler",
		debug : false
	});
	function myCustomExecCommandHandler(editor_id, elm, command, user_interface, value) {
		var linkElm, imageElm, inst;
		switch (command) {
				case "mceLink":
				inst = tinyMCE.getInstanceById(editor_id);
				linkElm = tinyMCE.getParentElement(inst.selection.getFocusElement(), "a");
				if (linkElm)
					alert("Link dialog has been overriden. Found link href: " + tinyMCE.getAttrib(linkElm, "href"));
				else
					alert("Link dialog has been overriden.");
				return true;
			case "mceImage":
				inst = tinyMCE.getInstanceById(editor_id);
				imageElm = tinyMCE.getParentElement(inst.selection.getFocusElement(), "img");

				if (imageElm)
					alert("Image dialog has been overriden. Found image src: " + tinyMCE.getAttrib(imageElm, "src"));
				else
					alert("Image dialog has been overriden.");
				return true;
		}
		return false; // Pass to next handler in chain
	}
</script>
</head>

<jsp:getProperty name="validator" property="javaScripts" />
<script language="JavaScript" src="/javascripts/mainlib.js"></script>

<body class="body" onLoad="MM_preloadImages('/images/buttons/continueover.gif')">
<form method="post" action="/minders/workflowforms/ConfirmFinalInvoice.jsp">
  <p class="Title">Final Invoice<br>
  <p> <b>Instructions:</b> Complete this form to initiate a final billing to your 
    customer. You may use this opportunity to review and or apply your sales tax 
    calculations for final billing. The Sales Tax Calculator will apply the appropriate amount to the final invoice when 
    submitted.</p>
  <jsp:include page="/includes/JobDetailHeader.jsp" flush="true"><jsp:param  name="jobId" value="<%=request.getParameter("jobId")%>" /></jsp:include>
  <jsp:include page="/includes/MailingAddressForm.jsp" flush="true"><jsp:param name="jobId" value="<%=jobId%>" /><jsp:param name="editor" value="<%=editor%>" />
  <p> <span class=contentstitle>Sender's Message:</span><br>
    
    <%String domainName=session.getAttribute("domainName").toString();%>
    <textarea name="message" cols="80" rows="20"></textarea><br>

    <br>
</p>

<jsp:include page="/includes/ShippingDataInclude.jsp" flush="true"/>
  <hr width="100%" size="1" align="left">
  <span class="contentstitle">Sales Tax Calculator </span> 
  <hr width="100%" size="1" align="left">
  <table width="317">
    <tr> 
      <td class='tableheader'> 
        <div align="right">Tax Entity</div>
      </td>
      <td> 
        <div align="right"><taglib:LUDropDownTag dropDownName="taxEntity" table="lu_abreviated_states" selected="<%= (String)rehash.get("taxEntity")%>"/> 
        </div>
      </td>
    </tr>
    <tr> 
      <td class='tableheader'> 
        <div align="right">Tax Rate</div>
      </td>
      <td> 
        <div align="right"> 
          <input type="text" size="5" name="taxRate" value="<%= (String)rehash.get("taxRate") %>" >
        </div>
      </td>
    </tr>
    <tr> 
      <td class='tableheader'> 
        <div align="right">Tax Shipping</div>
      </td>
      <td> 
        <div align="right"> 
          <select name="taxShipping">
            <% if (Integer.parseInt((String)rehash.get("taxShipping")) == 1) { %>
            <option selected value="1">yes</option>
            <option value="0">no</option>
            <% } else { %>
            <option value="1">yes</option>
            <option selected value="0">no</option>
            <% } %>
          </select>
        </div>
      </td>
    </tr>
    <tr> 
      <td class='tableheader'> 
        <div align="right">Tax Job</div>
      </td>
      <td> 
        <div align="right"> 
          <select name="taxJob">
            <% if (Integer.parseInt((String)rehash.get("taxJob")) == 1) { %>
            <option selected value="1">yes</option>
            <option value="0">no</option>
            <% } else { %>
            <option value="1">yes</option>
            <option selected value="0">no</option>
            <% } %>
          </select>
        </div>
      </td>
    </tr>
    <tr> 
      <td class='tableheader'> 
        <div align="right">Buyer Exempt</div>
      </td>
      <td> 
        <div align="right"> 
          <select name="buyerExempt">
            <% if (Integer.parseInt((String)rehash.get("buyerExempt")) == 1) { %>
            <option selected value="1">yes</option>
            <option value="0">no</option>
            <% } else { %>
            <option value="1">yes</option>
            <option selected value="0">no</option>
            <% } %>
          </select>
        </div>
      </td>
    </tr>
  </table>
<br>
<table border="0" width="25%" align="center">
  <tr>
    <a href="javascript:tinyMCE.triggerSave();document.forms[0].submit()" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('Image1','','/images/buttons/continueover.gif',1)"><img name="Image1" border="0" src="/images/buttons/continue.gif" width="74" height="20"></a>
  </tr>
</table>

<input type="hidden" name="jobId" value="<%= request.getParameter("jobId") %>" >
<input type="hidden" name="$$Return" value="[/minders/JobMinderSwitcher.jsp]">

</form>
</body>
</html><%conn.close();%>