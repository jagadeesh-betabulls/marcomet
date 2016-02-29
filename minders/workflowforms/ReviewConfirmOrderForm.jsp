<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<%@ page import="java.sql.*,java.text.*,java.util.*,com.marcomet.tools.*,com.marcomet.workflow.*,com.marcomet.users.security.*;" %>
<%@ taglib uri="/WEB-INF/tld/taglib.tld" prefix="taglib" %>
<%@ include file="/includes/SessionChecker.jsp" %>
<jsp:useBean id="validator" class="com.marcomet.tools.FieldValidationBean" scope="page" />
<%
Connection conn = com.marcomet.jdbc.DBConnect.getConnection();
Statement st = conn.createStatement();
boolean hideAction=false;
boolean showDetails=false;
boolean editor = ((((RoleResolver) session.getAttribute("roles")).roleCheck("editor")));
if (session.getAttribute("roles") != null && session.getAttribute("demo")==null) {
	if (((com.marcomet.users.security.RoleResolver)session.getAttribute("roles")).isVendor()) {
		hideAction=false;	
		showDetails=true;
	} else if (((com.marcomet.users.security.RoleResolver)session.getAttribute("roles")).isSiteHost()) {
		hideAction=true;
		showDetails=false;
	}
}else{
	hideAction=true;
}
String sql;
ResultSet rsOrder;
ResultSet rsJobInfo;
ResultSet rsJobSpecInfo;
int x=0;
String jobId = request.getParameter("jobId");
DecimalFormat df = new DecimalFormat("0.00");  //format the dollars

%><html>
<head>
  <title>Confirm Job</title>
  <link rel="stylesheet" href="<%=(String)session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css">
<%if (hideAction){
	%><script>
		function none(){
			alert("You do not have rights to perform this action.");
		}
	</script><%
	}%></head>
<jsp:getProperty name="validator" property="javaScripts" />
<script language="JavaScript" src="/javascripts/mainlib.js"></script>
<body class="body" background="<%=(String)session.getAttribute("siteHostRoot")%>/images/back3.jpg">
<p class="Title"><span class="Title">Review &amp; Confirm Job </span> </p>
  <form method="post" action="/servlet/com.marcomet.sbpprocesses.ProcessJobSubmit">
	<jsp:include page="/includes/JobDetailHeader.jsp" flush="true">
		<jsp:param  name="jobId" value="<%=request.getParameter("jobId")%>" />
	</jsp:include>
	<jsp:include page="/includes/MailingAddressForm.jsp" flush="true"><jsp:param name="formNeeded" value="false" /><jsp:param name="jobId" value="<%=jobId%>" /><jsp:param name="editor" value="<%=editor%>" /></jsp:include>
<br>
<jsp:include page="/includes/ClientInfoInclude.jsp" flush="true"/>
<br>
<hr size="1">
  <table width="75%" class="body">
    <tr> 
      <td height="2" class="subtitle1">Job Specs:</td>
    </tr><%

 String specQuery = "SELECT ls.value as label, js.value as value FROM job_specs js, lu_specs ls, catalog_specs cs WHERE ls.id != 88888 AND ls.id != 99999 AND js.cat_spec_id = cs.id AND cs.spec_id = ls.id and js.job_id = " + jobId;
     ResultSet rsSpecs = st.executeQuery(specQuery);
     while (rsSpecs.next()) { 
	%><tr> 
      <td class="label"><%= rsSpecs.getString("label") %>:</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="4" class="body"><%= rsSpecs.getString("value") %></td>
    </tr><% 
	} 
	%><tr> 
      <td class="label">&nbsp;</td>
    </tr><%
 	 String fileQuery = "select file_name, description, company_id from file_meta_data where job_id = " + jobId;
     ResultSet rsFiles = st.executeQuery(fileQuery); 
     Vector fileVector = new Vector();
     while(rsFiles.next()) {
	 	fileVector.addElement(rsFiles.getString("company_id"));
	 	fileVector.addElement(rsFiles.getString("file_name"));
		fileVector.addElement(rsFiles.getString("description"));
     }
	 if (fileVector.size() > 0) { 
		%><tr> 
      <td class="subtitle1">Supplied Files:</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="2" class="minderheadercenter">File Name</td>
      <td colspan="2" class="minderheadercenter">Description</td>
    </tr><%
 	for (int i=0; i<fileVector.size(); i=i+3) { 
	%><tr> 
      <td class="label">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="2"><a href="javascript:<%=((hideAction)?"none();":"pop('/transfers/"+fileVector.get(i)+"/"+fileVector.get(i+1)+"',300,300)")%>" class="minderLink" ><%= fileVector.get(i+1) %></a></td>
      <td colspan="2"><%= fileVector.get(i+2) %></td>
    </tr><% } %><tr> 
      <td class="subtitle1">Job Costs</td>
    </tr><% } %><tr> 
      <td class="label">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td><%
	if (showDetails){
      %><td class="minderheaderright">Est Cost</td>
      <td class="minderheaderright">Seller MU</td>
      <td class="minderheaderright">MC Fee</td><%
   }%><td class="minderheaderright">Price</td><td>&nbsp;</td>
    </tr><% double totCost = 0; double totFee = 0; double totMu = 0; double totPrice = 0;
     sql = "SELECT ls.value 'specname', js.value 'specvalue',  js.cost 'cost', js.fee 'fee', js.mu 'mu', js.price 'price' FROM job_specs js, lu_specs ls, catalog_specs cs WHERE cs.price_determinant = 1 AND js.cat_spec_id = cs.id AND cs.spec_id = ls.id AND js.job_id = " + jobId + " ORDER BY ls.sequence";
     rsJobSpecInfo = st.executeQuery(sql);
     while(rsJobSpecInfo.next()){
		totCost += rsJobSpecInfo.getDouble("cost");
		totMu += rsJobSpecInfo.getDouble("mu");
		totFee += rsJobSpecInfo.getDouble("fee");
		totPrice += rsJobSpecInfo.getDouble("price");
		%><tr> 
      <td class="label"><span class="subtitle"><%= rsJobSpecInfo.getString("specname") %>:</span></td>
      <td class="body"></td>
      <td class="body">&nbsp;</td><%
	if (showDetails){
      %><td align="right" class="body"><span class="body">$</span><%= df.format(rsJobSpecInfo.getDouble("cost")) %></td>
      <td align="right" class="body">$<%= df.format(rsJobSpecInfo.getDouble("mu"))%></td>
      <td align="right" class="body">$<%= df.format(rsJobSpecInfo.getDouble("fee"))%></td><%
   }%><td align="right" class="body">$<%= df.format(rsJobSpecInfo.getDouble("price")) %></td>
<td>&nbsp;</td>
    </tr><%
 }
     sql = "SELECT ls.value 'specname', js.value 'specvalue',  js.cost 'cost', js.fee 'fee', js.mu 'mu', js.price 'price' FROM job_specs js , lu_specs ls WHERE js.cat_spec_id = ls.id AND ls.value = 'Base Price' AND job_id = " + jobId;
	 ResultSet rsBasePrice = st.executeQuery(sql);
	 if (rsBasePrice.next()) {
		totCost += rsBasePrice.getDouble("cost");
		totMu += rsBasePrice.getDouble("mu");
		totFee += rsBasePrice.getDouble("fee");
		totPrice += rsBasePrice.getDouble("price"); 
		%><tr> 
      <td class="label"><%= rsBasePrice.getString("specname") %>:</td>
      <td class="body"></td>
      <td class="body">&nbsp;</td><%
	if (showDetails){
      %><td align="right" class="body">$<%= df.format(rsBasePrice.getDouble("cost")) %></td>
      <td align="right" class="body">$<%= df.format(rsBasePrice.getDouble("mu"))%></td>
      <td align="right" class="body">$<%= df.format(rsBasePrice.getDouble("fee"))%></td><%
   }%><td align="right" class="body">$<%= df.format(rsBasePrice.getDouble("price")) %></td>
      <td>&nbsp;</td>
    </tr><%
 	} 
	%><tr> 
      <td class="label">Job Total:</td>
      <td class="body">&nbsp;</td>
      <td class="body">&nbsp;</td><%
	if (showDetails){
    %><td align="right" class="TopborderLable">$<%= df.format(totCost)%></td>
      <td align="right" class="TopborderLable">$<%= df.format(totMu)%> </td>
      <td align="right" class="TopborderLable">$<%= df.format(totFee)%> </td><%
   }%><td align="right" class="TopborderLable">$<%= df.format(totPrice)%></td>
      <td>&nbsp;</td>
    </tr><%
	boolean changes = false;
	ResultSet rsJobChanges = st.executeQuery("select * from jobchanges where jobid = " + jobId + " and statusid = 2 order by createddate");
	 while(rsJobChanges.next()){
		totCost += rsJobChanges.getDouble("cost");
		totMu += rsJobChanges.getDouble("mu");
		totFee += rsJobChanges.getDouble("fee");
		totPrice += rsJobChanges.getDouble("price");
		changes = true; 
		%><tr> 
      <td class="label">Job Change:</td>
      <td class="body">&nbsp;</td>
      <td class="body">&nbsp;</td><%
	if (showDetails){
    %><td align="right" class="body" bordercolor="#000000">$<%= rsJobChanges.getString("cost")%></td>
      <td align="right" class="body" bordercolor="#000000">$<%= rsJobChanges.getString("mu")%></td>
      <td align="right" class="body" bordercolor="#000000">$<%= rsJobChanges.getString("fee")%></td><%
   }%><td align="right" class="body" bordercolor="#000000">$<%= rsJobChanges.getString("price")%></td>
      <td>&nbsp;</td>
    </tr><% } 
  if (changes) {
	%><tr> 
      <td class="label">Job Total With Changes:</td>
      <td class="body">&nbsp;</td>
      <td class="body">&nbsp;</td><%
	if (showDetails){
      %><td align="right" class="TopborderLable">$<%= df.format(totCost)%></td>
      <td align="right" class="TopborderLable">$<%= df.format(totMu)%> </td>
      <td align="right" class="TopborderLable">$<%= df.format(totFee)%> </td><%
   }%><td align="right" class="TopborderLable">$<%= df.format(totPrice)%></td>
      <td>&nbsp;</td>
    </tr><% } %><tr> 
      <td colspan="8" class="label">&nbsp;</td>
    </tr>
    <tr> 
      <td class="subtitle1">Sales Tax:</td>
      <td colspan="2" class="minderheaderleft">Tax State</td>
      <td class="minderheadercenter">Tax Rate (%)</td>
      <td class="minderheadercenter">Tax Shipping</td>
      <td class="minderheadercenter">Tax Job</td>
      <td class="minderheaderright">Buyer Exempt</td>
    </tr>
    <tr> 
      <td class="label">&nbsp;</td>
      <td align="right" colspan="2"><%
      
	String taxableState="531";String taxState="531";String taxable="1"; String taxRate="0";String taxShipping="0";String taxJob="0";String buyerExempt="1";

	sql="SELECT l.state 'stateid', co.tax_exempt 'exempt',ls.state_tax_rate 'rate',ls.tax_shipping_flag 'tax_shipping',ls.tax_job_flag 'tax_job'  FROM shipping_locations l,lu_states ls, jobs j, projects p, orders o,companies co,contacts c WHERE l.state=ls.state_number and o.id = p.order_id AND p.id = j.project_id AND l.id=j.ship_location_id  AND c.id=o.buyer_contact_id and c.companyid=co.id AND j.id = " + jobId;
	ResultSet rsTaxInfo = st.executeQuery(sql);
	if (rsTaxInfo.next()) {
		taxableState=rsTaxInfo.getString("stateid");
		buyerExempt=rsTaxInfo.getString("exempt");
		taxState=rsTaxInfo.getString("stateid");
		taxRate=rsTaxInfo.getString("rate");
		taxShipping=rsTaxInfo.getString("tax_shipping");
		taxJob=rsTaxInfo.getString("tax_job");
	}
	if (taxJob.equals("1")){
		sql = "Select p.taxable 'taxable' from jobs j, products p where  p.id=j.product_id AND j.id = " + jobId;
		rsTaxInfo = st.executeQuery(sql);
		if (rsTaxInfo.next()) {
				taxJob=rsTaxInfo.getString("taxable");
		}
	}
	
%><div align="left"><taglib:LUDropDownTag dropDownName="taxEntity" table="lu_abreviated_states" selected="<%=taxState%>" /> 
        </div>
      </td>
      <td align="right" class="body"> 
        <div align="center">
          <input type="text" name="taxRate" size="4" value="<%=taxRate%>">
        </div>
      </td>
      <td align="right" class="body"> 
        <div align="center">
          <select name="taxShipping">
            <option <%=((taxShipping.equals("0"))?"Selected":"")%> value="0">no</option>
            <option <%=((taxShipping.equals("1"))?"Selected":"")%>  value="1">yes</option>
          </select>
        </div>
      </td>
      <td align="right" class="body"> 
        <div align="center">
          <select name="taxJob">
            <option <%=((taxJob.equals("0"))?"Selected":"")%> value="0">no</option>
            <option  <%=((taxJob.equals("1"))?"Selected":"")%> value="1">yes</option>
          </select>
        </div>
      </td>
      <td align="right" class="body"> 
        <select name="buyerExempt">
          <option  <%=((buyerExempt.equals("0"))?"Selected":"")%> value="0">no</option>
          <option <%=((buyerExempt.equals("1"))?"Selected":"")%> value="1">yes</option>
        </select>
      </td>
    </tr>
<!--    <tr> 
      <td class="subtitle1" height="56" valign="bottom"> 
        <div align="left">Internal Reference:</div>
      </td>
      <td colspan="7" valign="bottom" height="56"> 
        <div align="left"> 
          <hr size="1">
          <input type="text" name="internalReference" value="" size="35">
          <span class="label">Use for Internal Tracking.</span></div>
      </td>
    </tr> -->
  </table>
  <hr width="100%" size="1" align="left">
  <div align="left"></div>
  <table border="0" align="center">
    <tr>
      <td width="3%">&nbsp;</td>
      <td><a href='javascript:<%=((hideAction)?"none();":"proposeChange()")%>' id="propButton" class="greybutton">Propose Change</a> &nbsp; &nbsp; &nbsp; <a href='javascript:<% if(hideAction){ %>none();<% }else{ %>window.location.href="/minders/workflowforms/Invoice_Form.jsp?jobId=<%=jobId%>&actionId=78"<% }%>' id="propButton" class="greybutton">Pre-Invoice Job</a></td>
      <td width="3%"></td><%
	ResultSet rsJobActions = st.executeQuery("select a.id 'id', a.actionperform 'actionperform', b.id 'jobId' from jobflowactions a, jobs b where a.currentstatus = b.status_id and a.fromstatus = b.last_status_id and a.whosaction = "+ ((((RoleResolver)session.getAttribute("roles")).isVendor())?"2":"1") +" and b.id = " + jobId + " order by actionorder");
	while(rsJobActions.next()) { 
		%><td><a href="javascript:<%=((hideAction)?"none();" : "moveReviewConfirmOrderForm('" + rsJobActions.getString("id") + "')")%>" id="button<%=x++%>" class="greybutton"><%= rsJobActions.getString("actionperform")%></a></td><td width="3%"></td><%
 } 
%></tr>
  </table>
<script>
function moveReviewConfirmOrderForm(ai){

	var form = document.forms[0];
	if(ai == "5" || ai == "2"){
		if((form.taxShipping.options[ form.taxShipping.selectedIndex ].value == '1' || form.taxJob.options[ form.taxJob.selectedIndex ].value =='1') && 
form.buyerExempt.options[ form.buyerExempt.selectedIndex ].value == '0' ){
			if(form.taxRate.value.length == 0 || form.taxEntity.options[ form.taxEntity.selectedIndex ].value == '0'){
				alert('Please enter tax information');
				form.taxRate.focus();
				return;		
			}
		}
	}
	
	if(ai == "3" || ai=="50"){
		window.location.replace('/minders/workflowforms/ProposeChangeOrder.jsp?jobId=' + form.jobId.value);
	return;
	}
		
	moveWorkFlow(ai);
}
function proposeChange() {
	document.forms[0].action="/servlet/com.marcomet.workflow.actions.ProposeChangeServlet";
	document.forms[0].submit();
}
</script>
  	<input type="hidden" name="nextStepActionId" value="">  
	<input type="hidden" name="$$Return" value="[/minders/JobMinderSwitcher.jsp]">
	<input type="hidden" name="jobId" value="<%= request.getParameter("jobId") %>" >
	<input type="hidden" name="internalReference" value="">
</form>
</body>
</html><%st.close();conn.close(); %>
