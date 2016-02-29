<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<%@ page import="java.sql.*,com.marcomet.tools.*;" %>
<%@ taglib uri="/WEB-INF/tld/taglib.tld" prefix="taglib" %>
<%
Connection conn = com.marcomet.jdbc.DBConnect.getConnection();
Statement st = conn.createStatement();
String tableName=((request.getParameter("tableName")==null || request.getParameter("tableName").equals(""))?"jobs":request.getParameter("tableName"));
String newValue=request.getParameter("newValue");
%><html>
<head>
  <title><%= request.getParameter("question") %></title>
  <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
  <link rel="stylesheet" href="<%=(String)session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css">
  <script language="javascript" type="text/javascript" src="/javascripts/tiny_mce/tiny_mce.js"></script>
<script language="javascript" type="text/javascript">
	tinyMCE.init({
		theme : "advanced",
		mode : "exact",
		elements : "newValue",
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

	// Custom event handler
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
<script src="/javascripts/mainlib.js"></script>
</head>
<body>
<form method="post" action="/servlet/com.marcomet.tools.QuickColumnUpdaterServlet">
<table border="0" cellpadding="5" cellspacing="0" align="center" width="100%">
  <tr><td class="tableheader"><%= request.getParameter("question") %></td></tr>
  <tr><td class="lineitems" align="center">
      <textarea name="newValue" cols="<%=request.getParameter("cols")%>" rows="<%=request.getParameter("rows")%>"><%
      if(newValue==null){
      java.sql.ResultSet rs = st.executeQuery("SELECT " + request.getParameter("columnName") + " FROM "+request.getParameter("tableName")+" j WHERE j.id = " + request.getParameter("primaryKeyValue"));
      if (rs.next()) { %><%=rs.getString(1)%><%
      } 
      }else{
      %><%=newValue%><%
      }
      %></textarea></td></tr>     
<tr>
	<td align="center">
		<a href="javascript:tinyMCE.triggerSave();document.forms[0].submit()" class="greybutton">Submit</a>&nbsp;&nbsp;<%if(request.getParameter("tableName").equals("products")){%><a href='javascript:document.forms(0).action="QuickChangeAcrossBrandsForm.jsp?noPL=false&submitted=true";tinyMCE.triggerSave();document.forms[0].submit();' class='greybutton'>Change Across Tiers</a>&nbsp;&nbsp;<%}%>&nbsp;&nbsp;<a href='javascript:self.close();' class='greybutton'>Cancel</a>&nbsp;&nbsp;<%if(request.getParameter("tableName").equals("products")){%><br><br><a href='javascript:document.forms(0).action="QuickChangeAcrossBrandsForm.jsp?noPL=true&noCID=true&submitted=true";tinyMCE.triggerSave();document.forms[0].submit();' class='greybutton'>Change Across Brands AND Tiers</a><%}%></td></tr>
</table>
<input type="hidden" name="columnName" value="<%=request.getParameter("columnName")%>">
<input type="hidden" name="valueType" value="<%=request.getParameter("valueType")%>">
<input type="hidden" name="primaryKeyValue" value="<%=request.getParameter("primaryKeyValue")%>">
<input type="hidden" name="tableName" value="<%=request.getParameter("tableName")%>">
<input type="hidden" name="$$Return" value="<script><%=((request.getParameter("refreshOpener")!=null)?"":"parent.window.opener.location.reload();")%>setTimeout('close()',500);</script>">
<%=((request.getParameter("autosubmit")!=null && request.getParameter("autosubmit").equals("true"))?"<script>document.forms[0].submit()</script>":"")%>
</form></body>
</html><%st.close();conn.close();%>