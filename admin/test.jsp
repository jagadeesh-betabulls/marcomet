<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
</head>

<body bgcolor="#FFFFFF" text="#000000">
<STYLE TYPE="text/css">

TABLE#tblCoolbar 

       { 

       background-color:threedface; padding:1px; color:menutext; 

       border-width:1px; border-style:solid; 

       border-color:threedhighlight threedshadow threedshadow threedhighlight;

       }

.cbtn

       {

       height:18;

       BORDER-LEFT: threedface 1px solid;

       BORDER-RIGHT: threedface 1px solid;

       BORDER-TOP: threedface 1px solid;

       BORDER-BOTTOM: threedface 1px solid; 

       }

.txtbtn {font-family:tahoma; font-size:70%; color:menutext;}

</STYLE>

 

<script LANGUAGE="JavaScript">

function button_over(eButton)

       {

       eButton.style.backgroundColor = "#B5BDD6";

       eButton.style.borderColor = "darkblue darkblue darkblue darkblue";

       }

function button_out(eButton)

       {

       eButton.style.backgroundColor = "threedface";

       eButton.style.borderColor = "threedface";

       }

function button_down(eButton)

       {

       eButton.style.backgroundColor = "#8494B5";

       eButton.style.borderColor = "darkblue darkblue darkblue darkblue";

       }

function button_up(eButton)

       {

       eButton.style.backgroundColor = "#B5BDD6";

       eButton.style.borderColor = "darkblue darkblue darkblue darkblue";

       eButton = null; 

       }

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

 

var isHTMLMode=false

 

function document.onreadystatechange()

       {

       idContent.document.designMode="On"

       }

function cmdExec(cmd,opt) 

       {

       if (isHTMLMode){alert("Please uncheck 'Edit HTML'");return;}

       idContent.document.execCommand(cmd,"",opt);idContent.focus();

       }

function setMode(bMode)

       {

       var sTmp;

       isHTMLMode = bMode;

       if (isHTMLMode){sTmp=idContent.document.body.innerHTML;idContent.document.body.innerText=sTmp;} 

       else {sTmp=idContent.document.body.innerText;idContent.document.body.innerHTML=sTmp;}

       idContent.focus();

       }

function createLink()

       {

       if (isHTMLMode){alert("Please uncheck 'Edit HTML'");return;}

       cmdExec("CreateLink");

       }

function insertImage()

       {

       if (isHTMLMode){alert("Please uncheck 'Edit HTML'");return;}

       var sImgSrc=prompt("Insert Image File (You can use your local image file) : ", "http://www.aspalliance.com/Yusuf/Article10/sample.jpg");

       if(sImgSrc!=null) cmdExec("InsertImage",sImgSrc);

       }

function Save() 

       {

       if (isHTMLMode){alert("Please uncheck 'Edit HTML'");return;}

       var sImgTag = idContent.document.body.all.tags("IMG");

       var oImg;

       for (var i = sImgTag.length - 1; i >= 0; i--) 

              {

       oImg = sImgTag[i];

       alert("Add your code to Upload local image file here. Image Inserted : " + oImg.src );

              }

       alert("Add your code to Save Document here");

       alert("Your Document : " + idContent.document.body.innerHTML);

       }

function foreColor()

       {

       var arr = showModalDialog("selcolor.htm","","font-family:Verdana; font-size:12; dialogWidth:30em; dialogHeight:34em" );

       if (arr != null) cmdExec("ForeColor",arr);      

       }

</script>

 

<P><STRONG><FONT size=3>Online Content Editor</FONT></STRONG></P>

 

<table id="tblCoolbar" width=542 cellpadding="0" cellspacing="0">

<tr valign="middle">

 

       <td colspan=16>

              <select onchange="cmdExec('formatBlock',this[this.selectedIndex].value);this.selectedIndex=0">

                     <option selected>Style</option>

                     <option value="Normal">Normal</option>

                     <option value="Heading 1">Heading 1</option>

                     <option value="Heading 2">Heading 2</option>

                     <option value="Heading 3">Heading 3</option>

                     <option value="Heading 4">Heading 4</option>

                     <option value="Heading 5">Heading 5</option>

                     <option value="Address">Address</option>

                     <option value="Formatted">Formatted</option>

                     <option value="Definition Term">Definition Term</option>

              </select> 

              <select onchange="cmdExec('fontname',this[this.selectedIndex].value);">

                     <option selected>Font</option>

                     <option value="Arial">Arial</option>

                     <option value="Arial Black">Arial Black</option>

                     <option value="Arial Narrow">Arial Narrow</option>

                     <option value="Comic Sans MS">Comic Sans MS</option>

                     <option value="Courier New">Courier New</option>

                     <option value="System">System</option>

                     <option value="Tahoma">Tahoma</option>

                     <option value="Times New Roman">Times New Roman</option>

                     <option value="Verdana">Verdana</option>

                     <option value="Wingdings">Wingdings</option>

              </select> 

              <select onchange="cmdExec('fontsize',this[this.selectedIndex].value);">

                     <option selected>Size</option>

                     <option value="1">1</option>

                     <option value="2">2</option>

                     <option value="3">3</option>

                     <option value="4">4</option>

                     <option value="5">5</option>

                     <option value="6">6</option>

                     <option value="7">7</option>

                     <option value="8">8</option>

                     <option value="10">10</option>

                     <option value="12">12</option>

                     <option value="14">14</option>

              </select> 

              

       </td>

       

</tr>

<tr>

 

       <td><div class="cbtn" onClick="cmdExec('cut')" onmouseover="button_over(this);" onmouseout="button_out(this);" onmousedown="button_down(this);" onmouseup="button_up(this);">

       <img hspace="1" vspace=1 align=absmiddle src="images/Cut.gif" alt="Cut">

       </div></td>

       

       <td><div class="cbtn" onClick="cmdExec('copy')" onmouseover="button_over(this);" onmouseout="button_out(this);" onmousedown="button_down(this);" onmouseup="button_up(this);">

       <img hspace="1" vspace=1 align=absmiddle src="images/Copy.gif" alt="Copy">

       </div></td>   

       

       <td><div class="cbtn" onClick="cmdExec('paste')" onmouseover="button_over(this);" onmouseout="button_out(this);" onmousedown="button_down(this);" onmouseup="button_up(this);">

       <img hspace="1" vspace=1 align=absmiddle src="images/Paste.gif" alt="Paste">

       </div></td>   

       

       <td><div class="cbtn" onClick="cmdExec('bold')" onmouseover="button_over(this);" onmouseout="button_out(this);" onmousedown="button_down(this);" onmouseup="button_up(this);">

       <img hspace="1" vspace=1 align=absmiddle src="images/Bold.gif" alt="Bold">

       </div></td>

       

       <td><div class="cbtn" onClick="cmdExec('italic')" onmouseover="button_over(this);" onmouseout="button_out(this);" onmousedown="button_down(this);" onmouseup="button_up(this);">

       <img hspace="1" vspace=1 align=absmiddle src="images/Italic.gif" alt="Italic">

       </div></td>   

       

       <td><div class="cbtn" onClick="cmdExec('underline')" onmouseover="button_over(this);" onmouseout="button_out(this);" onmousedown="button_down(this);" onmouseup="button_up(this);">

       <img hspace="1" vspace=1 align=absmiddle src="images/Under.gif" alt="Underline">

       </div></td>          

              

       <td><div class="cbtn" onClick="cmdExec('justifyleft')" onmouseover="button_over(this);" onmouseout="button_out(this);" onmousedown="button_down(this);" onmouseup="button_up(this);">

       <img hspace="1" vspace=1 align=absmiddle src="images/Left.gif" alt="Justify Left">

       </div></td>

       

       <td><div class="cbtn" onClick="cmdExec('justifycenter')" onmouseover="button_over(this);" onmouseout="button_out(this);" onmousedown="button_down(this);" onmouseup="button_up(this);">

       <img hspace="1" vspace=1 align=absmiddle src="images/Center.gif" alt="Center">

       </div></td>   

       

       <td><div class="cbtn" onClick="cmdExec('justifyright')" onmouseover="button_over(this);" onmouseout="button_out(this);" onmousedown="button_down(this);" onmouseup="button_up(this);">

       <img hspace="1" vspace=1 align=absmiddle src="images/Right.gif" alt="Justify Right">

       </div></td>          

       

       <td><div class="cbtn" onClick="cmdExec('insertorderedlist')" onmouseover="button_over(this);" onmouseout="button_out(this);" onmousedown="button_down(this);" onmouseup="button_up(this);">

       <img hspace="2" vspace=1 align=absmiddle src="images/numlist.GIF" alt="Ordered List">

       </div></td>   

 

       <td><div class="cbtn" onClick="cmdExec('insertunorderedlist')" onmouseover="button_over(this);" onmouseout="button_out(this);" onmousedown="button_down(this);" onmouseup="button_up(this);">

       <img hspace="2" vspace=1 align=absmiddle src="images/bullist.GIF" alt="Unordered List">

       </div></td>

              

       <td><div class="cbtn" onClick="cmdExec('outdent')" onmouseover="button_over(this);" onmouseout="button_out(this);" onmousedown="button_down(this);" onmouseup="button_up(this);">

       <img hspace="2" vspace=1 align=absmiddle src="images/deindent.gif" alt="Decrease Indent">

       </div></td>   

       

       <td><div class="cbtn" onClick="cmdExec('indent')" onmouseover="button_over(this);" onmouseout="button_out(this);" onmousedown="button_down(this);" onmouseup="button_up(this);">

       <img hspace="2" vspace=1 align=absmiddle src="images/inindent.gif" alt="Increase Indent">

       </div></td>                

       

       <td><div class="cbtn" onClick="foreColor()" onmouseover="button_over(this);" onmouseout="button_out(this);" onmousedown="button_down(this);" onmouseup="button_up(this);">

       <img hspace="2" vspace=1 align=absmiddle src="images/fgcolor.gif" alt="Forecolor">

       </div></td>                

 

       <td><div class="cbtn" onClick="cmdExec('createLink')" onmouseover="button_over(this);" onmouseout="button_out(this);" onmousedown="button_down(this);" onmouseup="button_up(this);">

       <img hspace="2" vspace=1 align=absmiddle src="images/Link.gif" alt="Link">

       </div></td>   

       

       <td><div class="cbtn" onClick="insertImage()" onmouseover="button_over(this);" onmouseout="button_out(this);" onmousedown="button_down(this);" onmouseup="button_up(this);">

       <img hspace="2" vspace=1 align=absmiddle src="images/Image.gif" alt="Image">

       </div></td>          

       

       <td><div class="cbtn" onClick="Save()" onmouseover="button_over(this);" onmouseout="button_out(this);" onmousedown="button_down(this);" onmouseup="button_up(this);">

       <img  hspace="2" vspace=1 align=left align=absmiddle src="images/Save.gif" alt="Save">

       <font class=txtbtn>Save&nbsp;&nbsp;</font>

       </div></td>          

              

       <td width=200></td>  

       

</tr>

</table>

 

<iframe width="542" id="idContent" height="350">  <textarea width="542" name="idContent" cols="60" rows="5"></textarea></iframe> 

<br>

<input type="checkbox" onclick="setMode(this.checked)"> Edit HTML

</body>
</html>
