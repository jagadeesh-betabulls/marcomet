<%
String showComments = null;
if (request.getParameter("showComments") != null)
	showComments = request.getParameter("showComments");
%>

<table width="100%">
  <tr> 
    <td class="minderheaderleft">Reference name of hard copy sent</td>
    <td class="minderheaderleft">Description</td>
    <%
	if (showComments != null) {
  %>
    <td class="minderheaderleft">Sender's Comments</td>
    <% } %>
  </tr>
  <tr>
    <td height="2"> 
      <input type="text" name="material0" size="36">
    </td>
    <td height="2"> 
      <textarea cols="40" rows="1" name="mDescription0"></textarea>
    </td><%
	if (showComments != null) {
  %>
    <td height="2"> 
      <textarea cols="40" rows="1" name="mComments0"></textarea>
    </td><% } %>
  </tr>
  <tr>
    <td>
      <input type="text" name="material1" size="36">
    </td>
    <td>
      <textarea cols="40" rows="1" name="mDescription1"></textarea>
    </td><%
	if (showComments != null) {
  %><td>
      <textarea cols="40" rows="1" name="mComments1"></textarea>
    </td><% } %>
  </tr>
  <tr>
    <td>
      <input type="text" name="material2" size="36">
    </td>
    <td>
      <textarea cols="40" rows="1" name="mDescription2"></textarea>
    </td><%
	if (showComments != null) {
  %><td>
      <textarea cols="40" rows="1" name="mComments2"></textarea>
    </td><% } %>
  </tr>
</table>
