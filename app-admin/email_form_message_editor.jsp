<%@ page import="java.sql.*,com.marcomet.tools.*,com.marcomet.jdbc.*;" %>
<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<%@ include file="/includes/SessionChecker.jsp" %>
<%@ taglib uri="/WEB-INF/tld/taglib.tld" prefix="taglib" %>
<%    
Connection conn = com.marcomet.jdbc.DBConnect.getConnection();
Statement st = conn.createStatement();
Statement st2 = conn.createStatement();
String messageId = ( (request.getParameter("messageId")==null)?"":request.getParameter("messageId")); 
String sql="";
String imagePath=(String)session.getAttribute("siteHostRoot")+"/fileuploads/page_images/";
String imageURL=(String)session.getAttribute("siteHostRoot")+"/fileuploads/page_images/";%>
<html>
<head>
<title>Edit Email Messages</title>
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
<script language="JavaScript" src="/javascripts/mainlib.js"></script>
<body bgcolor="#FFFFFF" text="#000000" onLoad="MM_preloadImages('/images/buttons/submitover.gif')" background="<%=(String)session.getAttribute("siteHostRoot")%>/images/back.jpg" leftmargin="10" topmargin="10">
<form method="post" action="/app-admin/email_form_message_editor.jsp?type=save&messageId=<%=messageId%>">
  <p class="MainTitle">Marcomet Admin</p>
  <p class="Title">Edit Email Messages</p>
  <%if (request.getParameter("type")==null || request.getParameter("type").equals("list")){ 
%><table><tr><td class="minderheader">EMail Key</td>
      <td class="minderheader">EMail Subject</td>
    </tr><%
	sql="select * from email_form_letters";
	ResultSet rs = st.executeQuery(sql);
	while (rs.next()){
		%><tr><td class=lineitem><a href="/app-admin/email_form_message_editor.jsp?type=edit&messageId=<%=rs.getString("id")%>"><%=rs.getString("email_key")%></a></td><td><%=rs.getString("email_subject")%></td></tr><%
	}
	%></table><%
}else if (request.getParameter("type")!=null && request.getParameter("type").equals("edit")){ 
	sql="select * from email_form_letters where id="+messageId;
	ResultSet rs = st2.executeQuery(sql);
	if (rs.next()){
		%><p class="subtitle">Edit Email Message for Key - <%=rs.getString("email_key")%>:</p>
 <textarea name="message" cols="80" rows="20"><%=rs.getString("email_body")%></textarea>
  <br>
  <input type="button" name="Cancel" value="Cancel" onClick="window.history.back()">
  <input type="submit" name="Submit" value="Submit">
<%
	}
}else if (request.getParameter("type")!=null && request.getParameter("type").equals("save")){ 	
	sql="update email_form_letters set email_body=? where id="+messageId;
	PreparedStatement update = conn.prepareStatement(sql);
	update.setString(1,request.getParameter("message"));
	update.executeUpdate();
//	update=null;
	%><script>window.location.replace("/app-admin/email_form_message_editor.jsp?type=list");</script><%

}%>
</form>
</body>
</html><%
st.close();
conn.close();%>

