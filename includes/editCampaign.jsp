<script language="javascript" type="text/javascript" src="../javascripts/tiny_mce/tiny_mce.js"></script>
<script language="javascript" type="text/javascript">
	tinyMCE.init({
		theme : "advanced",
		mode : "exact",
		elements : "html_area",
		save_callback : "customSave",
		content_css : "<%=stylesheet1_url%>",
		extended_valid_elements : "a[href|target|name]",
		plugins : "table",
		theme_advanced_buttons3_add_before : "tablecontrols,separator",
		//invalid_elements : "a",
		theme_advanced_styles : "Header 1=header1;Header 2=header2;Header 3=header3;Table Row=tableRow1", // Theme specific setting CSS classes
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
<tr><td class="minderheader" colspan=2>EDIT HTML EMAIL MESSAGE</td></tr>
	<tr><td class=lineitem colspan=2><textarea name="html_area" style="width:100%" rows="15">
	<jsp:include page="/contents/FeaturedProducts.jsp?page=<%=campaignId%>" flush="false" />
	</textarea></td></tr>
