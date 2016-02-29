<%/*
The form that contains this include must contain enctype="multipart/form-data" in the form tag
The servlet that processes the form must do the following:
1.  import com.marcomet.files.*
2.  Instantiate a new FileManipulator:  											FileManipulator fm = new FileManipulator();
3.	Process the request, retrieving a MultipartRequest object:  					MultipartRequest mr = fm.uploadFile(request, response);
4.	Any fields you wish to retrieve from the form can then be handled as follows:	mr.getParameter("name");
Metadata:
<input type='hidden' name='jobId'>
<input type='hidden' name='status'>
For pages where may not be logged in:
	Call indexer and assign a temporary userid as the session variable: Login and another for companyid and set loggedIn as 'No'
update file_meta_data set company_id="+companyid+", job_id="+jobId+",user_id="+userId+",project_id="+projectId+" where company_id="+tempcompanyid;
*/
String showComments = null;
if (request.getParameter("showComments") != null)
	showComments = request.getParameter("showComments");
%>
<body background="<%=(String)session.getAttribute("siteHostRoot")%>/images/back3.jpg">
<table>
  <tr> 
    <td class="minderheaderleft">&nbsp;File:</td>
    <td class="minderheaderleft">&nbsp;Description:</td>
    <%
	if (showComments != null) {
  %>
    <td class="minderheaderleft">&nbsp;Sender's Comments:</td>
    <% } %>
  </tr>
  <tr>
    <td height="2"> 
      <input type="file" name="file0" size="33">
    </td>
    <td height="2"> 
      <textarea cols="35" rows="1" name="description0"></textarea>
    </td><%
	if (showComments != null) {
  %>
    <td height="2"> 
      <textarea cols="37" rows="1" name="comments0"></textarea>
    </td><% } %>
  </tr>
  <tr>
    <td> 
      <input type="file" name="file1" size="33">
    </td>
    <td> 
      <textarea cols="35" rows="1" name="description1"></textarea>
    </td><%
	if (showComments != null) {
  %>
    <td> 
      <textarea cols="37" rows="1" name="comments1"></textarea>
    </td><% } %>
  </tr>
  <tr>
    <td height="2"> 
      <input type="file" name="file2" size="33">
    </td>
    <td height="2"> 
      <textarea cols="35" rows="1" name="description2"></textarea>
    </td><%
	if (showComments != null) {
  %>
    <td height="2"> 
      <textarea cols="37" rows="1" name="comments2"></textarea>
    </td><% } %>
  </tr>
</table>