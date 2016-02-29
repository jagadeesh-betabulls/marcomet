<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<%@ page import="java.sql.*,java.text.*,java.util.*,com.marcomet.tools.*,com.marcomet.workflow.*,com.marcomet.users.security.*;" %>
<%@ taglib uri="/WEB-INF/tld/taglib.tld" prefix="taglib" %>
<%@ include file="/includes/SessionChecker.jsp" %>
<jsp:useBean id="validator" class="com.marcomet.tools.FieldValidationBean" scope="page" />
<%
Connection conn = com.marcomet.jdbc.DBConnect.getConnection();
Statement st = conn.createStatement();
String sql;
ResultSet rsOrder;
ResultSet rsJobInfo;
ResultSet rsJobSpecInfo;
int x=0;
String jobId = request.getParameter("jobId");
DecimalFormat df = new DecimalFormat("0.00");  //format the dollars

%><html>
<head>
  <title>Complete Job</title>
  <link rel="stylesheet" href="<%=(String)session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css">
</head>
<jsp:getProperty name="validator" property="javaScripts" />
<script language="JavaScript" src="/javascripts/mainlib.js"></script>
<body class="body">
<p class="Title"><span class="Title">Complete Job </span> </p>
  <form method="post" action="/servlet/com.marcomet.sbpprocesses.ProcessJobSubmit">
  
  <jsp:include page="/includes/JobDetailHeader.jsp" flush="true"><jsp:param  name="jobId" value="<%=request.getParameter("jobId")%>" /></jsp:include>
<br>
<jsp:include page="/includes/ClientInfoInclude.jsp" flush="true"/>
<br>
<hr size="1">
  <table width="75%" class="body">
    <tr> 
      <td height="2" class="subtitle1">Job Specs:</td>
    </tr>
    <% String specQuery = "SELECT ls.value as label, js.value as value FROM job_specs js, lu_specs ls, catalog_specs cs WHERE ls.id != 88888 AND ls.id != 99999 AND js.cat_spec_id = cs.id AND cs.spec_id = ls.id and js.job_id = " + jobId;
     ResultSet rsSpecs = st.executeQuery(specQuery);
     while (rsSpecs.next()) { %>
    <tr> 
      <td class="label"><%= rsSpecs.getString("label") %>:</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="4" class="body"><%= rsSpecs.getString("value") %></td>
    </tr>
    <% } %>
    <tr> 
      <td class="label">&nbsp;</td>
    </tr>
    <% String fileQuery = "select file_name, description, company_id from file_meta_data where job_id = " + jobId;
     ResultSet rsFiles = st.executeQuery(fileQuery); 
     Vector fileVector = new Vector();
     while(rsFiles.next()) {
	 	fileVector.addElement(rsFiles.getString("file_name"));
		fileVector.addElement(rsFiles.getString("description"));
     }
	 if (fileVector.size() > 0) { %>
    <tr> 
      <td class="subtitle1">Supplied Files:</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="2" class="minderheadercenter">File Name</td>
      <td colspan="2" class="minderheadercenter">Description</td>
    </tr>
    <% for (int i=0; i<fileVector.size(); i=i+2) { %>
    <tr> 
      <td class="label">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="2"><a href="javascript:pop('/transfers/<%= rsFiles.getString("company_id") %>/<%= fileVector.get(i) %>',300,300)" class="minderLink" ><%= fileVector.get(i) %></a></td>
      <td colspan="2"><%= fileVector.get(i+1) %></td>
    </tr>
    <% } %>
    <tr> 
      <td class="subtitle1">Job Costs</td>
    </tr>
    <% } %>
    <tr> 
      <td class="label">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td class="minderheaderright">Est Cost</td>
      <td class="minderheaderright">Seller MU</td>
      <td class="minderheaderright">MC Fee</td>
      <td class="minderheaderright">Price</td>
      <td>&nbsp;</td>
    </tr>
    <% double totCost = 0; double totFee = 0; double totMu = 0; double totPrice = 0;
     sql = "SELECT ls.value 'specname', js.value 'specvalue',  js.cost 'cost', js.fee 'fee', js.mu 'mu', js.price 'price' FROM job_specs js, lu_specs ls, catalog_specs cs WHERE cs.price_determinant = 1 AND js.cat_spec_id = cs.id AND cs.spec_id = ls.id AND js.job_id = " + jobId + " ORDER BY ls.sequence";
     rsJobSpecInfo = st.executeQuery(sql);
     while(rsJobSpecInfo.next()){
		totCost += rsJobSpecInfo.getDouble("cost");
		totMu += rsJobSpecInfo.getDouble("mu");
		totFee += rsJobSpecInfo.getDouble("fee");
		totPrice += rsJobSpecInfo.getDouble("price"); %>
    <tr> 
      <td class="label"><span class="subtitle"><%= rsJobSpecInfo.getString("specname") %>:</span></td>
      <td class="body"></td>
      <td class="body">&nbsp;</td>
      <td align="right" class="body"><span class="body">$</span><%= df.format(rsJobSpecInfo.getDouble("cost")) %></td>
      <td align="right" class="body">$<%= df.format(rsJobSpecInfo.getDouble("mu"))%></td>
      <td align="right" class="body">$<%= df.format(rsJobSpecInfo.getDouble("fee"))%> 
      </td>
      <td align="right" class="body">$<%= df.format(rsJobSpecInfo.getDouble("price")) %></td>
      <td>&nbsp;</td>
    </tr>
    <% }
     sql = "SELECT ls.value 'specname', js.value 'specvalue',  js.cost 'cost', js.fee 'fee', js.mu 'mu', js.price 'price' FROM job_specs js , lu_specs ls WHERE js.cat_spec_id = ls.id AND ls.value = 'Base Price' AND job_id = " + jobId;
	 ResultSet rsBasePrice = st.executeQuery(sql);
	 if (rsBasePrice.next()) {
		totCost += rsBasePrice.getDouble("cost");
		totMu += rsBasePrice.getDouble("mu");
		totFee += rsBasePrice.getDouble("fee");
		totPrice += rsBasePrice.getDouble("price"); %>
    <tr> 
      <td class="label"><%= rsBasePrice.getString("specname") %>:</td>
      <td class="body"></td>
      <td class="body">&nbsp;</td>
      <td align="right" class="body">$<%= df.format(rsBasePrice.getDouble("cost")) %></td>
      <td align="right" class="body">$<%= df.format(rsBasePrice.getDouble("mu"))%></td>
      <td align="right" class="body">$<%= df.format(rsBasePrice.getDouble("fee"))%> 
      </td>
      <td align="right" class="body">$<%= df.format(rsBasePrice.getDouble("price")) %></td>
      <td>&nbsp;</td>
    </tr>
    <% } %>
    <tr> 
      <td class="label">Job Total:</td>
      <td class="body">&nbsp;</td>
      <td class="body">&nbsp;</td>
      <td align="right" class="TopborderLable">$<%= df.format(totCost)%></td>
      <td align="right" class="TopborderLable">$<%= df.format(totMu)%> </td>
      <td align="right" class="TopborderLable">$<%= df.format(totFee)%> </td>
      <td align="right" class="TopborderLable">$<%= df.format(totPrice)%></td>
      <td>&nbsp;</td>
    </tr>
    <% boolean changes = false;
	 ResultSet rsJobChanges = st.executeQuery("select * from jobchanges where jobid = " + jobId + " and statusid = 2 order by createddate");
	 while(rsJobChanges.next()){
		totCost += rsJobChanges.getDouble("cost");
		totMu += rsJobChanges.getDouble("mu");
		totFee += rsJobChanges.getDouble("fee");
		totPrice += rsJobChanges.getDouble("price");
		changes = true; %>
    <tr> 
      <td class="label">Job Change:</td>
      <td class="body">&nbsp;</td>
      <td class="body">&nbsp;</td>
      <td align="right" class="body" bordercolor="#000000">$<%= rsJobChanges.getString("cost")%></td>
      <td align="right" class="body" bordercolor="#000000">$<%= rsJobChanges.getString("mu")%></td>
      <td align="right" class="body" bordercolor="#000000">$<%= rsJobChanges.getString("fee")%></td>
      <td align="right" class="body" bordercolor="#000000">$<%= rsJobChanges.getString("price")%></td>
      <td>&nbsp;</td>
    </tr>
    <% } 
  if (changes) {%>
    <tr> 
      <td class="label">Job Total With Changes:</td>
      <td class="body">&nbsp;</td>
      <td class="body">&nbsp;</td>
      <td align="right" class="TopborderLable">$<%= df.format(totCost)%></td>
      <td align="right" class="TopborderLable">$<%= df.format(totMu)%> </td>
      <td align="right" class="TopborderLable">$<%= df.format(totFee)%> </td>
      <td align="right" class="TopborderLable">$<%= df.format(totPrice)%></td>
      <td>&nbsp;</td>
    </tr>
    <% } %>
    <tr> 
      <td colspan="8" class="label">&nbsp;</td>
    </tr>
    <tr> 
      <td class="subtitle1">Sales Tax:</td>
      <td colspan="2" class="minderheaderleft">Tax State</td>
      <td class="minderheadercenter">Tax Rate</td>
      <td class="minderheadercenter">Tax Shipping</td>
      <td class="minderheadercenter">Tax Job</td>
      <td class="minderheaderright">Buyer Exempt</td>
    </tr>
    <tr> 
      <td class="label">&nbsp;</td>
      <td align="right" colspan="2"> 
        <div align="left"><taglib:LUDropDownTag dropDownName="taxEntity" table="lu_abreviated_states" selected="31" /> 
        </div>
      </td>
      <td align="right" class="body"> 
        <div align="center">
          <input type="text" name="taxRate" size="4" value="6">
        </div>
      </td>
      <td align="right" class="body"> 
        <div align="center">
          <select name="taxShipping">
            <option value="1">yes</option>
            <option selected value="0">no</option>
          </select>
        </div>
      </td>
      <td align="right" class="body"> 
        <div align="center">
          <select name="taxJob">
            <option selected value="1">yes</option>
            <option value="0">no</option>
          </select>
        </div>
      </td>
      <td align="right" class="body"> 
        <select name="buyerExempt">
          <option value="1">yes</option>
          <option selected value="0">no</option>
        </select>
      </td>
    </tr>
    <tr> 
      <td class="subtitle1" height="56" valign="bottom">Internal Reference:</td>
      <td colspan="7" valign="bottom" height="56"> 
        <div align="left"> 
          <hr size="1">
          <p> 
            <input type="text" name="internalReference" value="" size="35">
            <span class="label">Use for Internal Tracking.</span></p>
        </div>
      </td>
    </tr>
  </table>
  <hr width="100%" size="1" align="left">
  <div align="left"></div>
  <table border="0" width="75%" align="center">
    <tr><td width="3%">&nbsp;</td>
	  <td class="graybutton" onMouseover="this.className='graybuttonOver';propButton.className='graybuttonHover'" onMouseout="this.className='graybutton';propButton.className=''"><a href="javascript:proposeChange()" id="propButton">Propose Job Change</a></td>
      <td width="3%">&nbsp;</td>
<%
	ResultSet rsJobActions = st.executeQuery("select a.id 'id', a.actionperform 'actionperform', b.id 'jobId' from jobflowactions a, jobs b where a.currentstatus = b.status_id and a.fromstatus = b.last_status_id and a.whosaction = "+ ((((RoleResolver)session.getAttribute("roles")).isVendor())?"2":"1") +" and b.id = " + jobId + " order by actionorder");
	while(rsJobActions.next()) { %>			
	    
      <td class="graybutton" onMouseover="this.className='graybuttonOver';button<%=x%>.className='graybuttonHover'" 
onMouseout="this.className='graybutton';button<%=x%>.className=''"><a href="javascript:moveReviewConfirmOrderForm('<%=rsJobActions.getString("id")%>')" 
id="button<%=x++%>"><%= rsJobActions.getString("actionperform")%></a></td>
		<td width="3%">&nbsp;</td>
<% } %>
</tr>
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
</form>
</body>
</html><%conn.close(); %>
