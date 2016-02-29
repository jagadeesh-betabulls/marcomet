<?
include "include/db.php";
# External access support (authenticate only if no key provided, or if invalid access key provided)
$k=getvalescaped("k","");if (($k=="") || (!check_access_key(getvalescaped("ref",""),$k))) {include "include/marcomet_widget_authenticate.php";}

include "include/general.php";
include "include/search_functions.php";
include "include/resource_functions.php";

$brand_type = getvalescaped("brand_type", "");
$initiative_type = getvalescaped("initiative_type", "");
$ref=getvalescaped("ref","");

# Reindex the exif headers, really for debug
if (getval("exif","")!="")
	{
	include "include/image_processing.php";
	include "include/resource_functions.php";
	extract_exif_comment($ref);
	exit();
	}

# fetch the current search (for finding simlar matches)
$search=getvalescaped("search","");
$order_by=getvalescaped("order_by","relevance");
$offset=getvalescaped("offset",0);
$restypes=getvalescaped("restypes","");
if (strpos($search,"!")!==false) {$restypes="";}
$archive=getvalescaped("archive",0);

# next / previous resource browsing
$go=getval("go","");
if ($go!="")
	{
	# Re-run the search and locate the next and previous records.
	$result=do_search($search,$restypes,$order_by,$archive,72+$offset+1);
	if (is_array($result))
		{
		# Locate this resource
		$pos=-1;
		for ($n=0;$n<count($result);$n++)
			{
			if ($result[$n]["ref"]==$ref) {$pos=$n;}
			}
		if ($pos!=-1)
			{
			if (($go=="previous") && ($pos>0)) {$ref=$result[$pos-1]["ref"];}
			if (($go=="next") && ($pos<($n-1))) {$ref=$result[$pos+1]["ref"];if (($pos+1)>=($offset+72)) {$offset=$pos+1;}} # move to next page if we've advanced far enough
			}
		}
	}

# Load resource data
$resource=get_resource_data($ref);

$sitephoto = getvalescaped("form_sitephoto","");
$sitephoto_1 = getvalescaped("form_sitephoto_1","");
$sitephoto_2 = getvalescaped("form_sitephoto_2","");
$state = getvalescaped("form_state","");
$city = getvalescaped("form_city","");
$personnel=getvalescaped("form_personnel","");
$firstname = getvalescaped("form_firstname","");
$lastname = getvalescaped("form_lastname","");
$bunit = getvalescaped("form_businessunit","");
$dept = getvalescaped("form_department","");
$jobtitle = getvalescaped("form_jobtitle","");

// The resource is invalid
if(!isset($resource["ref"])) {
include "include/header.php";



?>

<div class="BasicsBox">
    <h1><?=$lang["resourcenotfound"]?></h1>
    <p><?=text(getvalescaped("text",""))?></p>
    
    <? if (getval("user","")!="") { # User logged in? ?>
    <p><a href="home.php">&gt;&nbsp;<?=$lang["backtohome"]?></a></p>
    <p><a href="search.php?notfound=false<? if (strpos($search,"!")!==false) {?>?search=<?=urlencode($search)?>&offset=<?=$offset?>&order_by=<?=$order_by?><? } ?><?
echo  '&form_sitephoto='.$sitephoto;
echo  '&form_sitephoto_1='.$sitephoto_1;
echo  '&form_sitephoto_2='.$sitephoto_2;
echo  '&form_personnel='.$personnel;
echo  '&form_city='.$city;
echo  '&form_state='.$state;
echo  '&form_firstname='.$firstname;
echo  '&form_lastname='.$lastname;
echo  '&form_businessunit='.$bunit;
echo  '&form_department='.$dept;
echo  '&form_jobtitle='.$jobtitle;
echo "&brand_type=$brand_type";
echo "&initiative_type=$initiative_type";

?>">&gt;&nbsp;<?=$lang["backtosearch"]?></a></p>
    <? } else {?>
    <p><a href="login.php">&gt;&nbsp;<?=$lang["backtouser"]?></a></p>
    <? } ?>
</div>

<?
include "include/footer.php";
exit;
}

# Load access level
$access=$resource["access"];
if (checkperm("v"))
	{
	$access=0; # Permission to access all resources
	}
else
	{
	if ($k!="")
		{
		#if ($access==3) {$access=2;} # Can't support custom group permissions for non-users
		if ($access==3) {$access=0;}
		}
	elseif ($access==3)
		{
		# Load custom access level
		$access=get_custom_access($ref,$usergroup);
		}
	}

# check permissions (error message is not pretty but they shouldn't ever arrive at this page unless entering a URL manually)
if ($access==2) 
		{ 
		exit("This is a confidential resource.");
		}

# Update the hitcounts for the search keywords (if search specified)
# (important we fetch directly from $_GET and not from a cookie
$usearch=@$_GET["search"];
if ((strpos($usearch,"!")===false) && ($usearch!="")) {update_resource_keyword_hitcount($ref,$usearch);}

# Log this activity
daily_stat("Resource view",$ref);

include "include/header.php";
?>

<? if(getvalescaped("showheader", "")!="") { ?> <img src="<?=$headerlogo?>" alt="Asset Management Services" ><br/><br/> <? } ?>

<!--Panel for record and details-->
<div class="RecordBox">
<div class="RecordPanel"> 

<div class="RecordHeader">
<? if (!hook("renderinnerresourceheader")) { ?>
<? if ($k=="") { ?>
<div class="backtoresults">
<a href="view.php?notfound=false&ref=<?=$ref?>&search=<?=urlencode($search)?>&offset=<?=$offset?>&order_by=<?=$order_by?>&archive=<?=$archive?>&go=previous<?

$sitephoto = getvalescaped("form_sitephoto","");
$sitephoto_1 = getvalescaped("form_sitephoto_1","");
$sitephoto_2 = getvalescaped("form_sitephoto_2","");
$state = getvalescaped("form_state","");
$city = getvalescaped("form_city","");
$personnel=getvalescaped("form_personnel","");
$firstname = getvalescaped("form_firstname","");
$lastname = getvalescaped("form_lastname","");
$bunit = getvalescaped("form_businessunit","");
$dept = getvalescaped("form_department","");
$jobtitle = getvalescaped("form_jobtitle","");

echo  '&form_sitephoto='.$sitephoto;
echo  '&form_sitephoto_1='.$sitephoto_1;
echo  '&form_sitephoto_2='.$sitephoto_2;
echo  '&form_personnel='.$personnel;
echo  '&form_city='.$city;
echo  '&form_state='.$state;
echo  '&form_firstname='.$firstname;
echo  '&form_lastname='.$lastname;
echo  '&form_businessunit='.$bunit;
echo  '&form_department='.$dept;
echo  '&form_jobtitle='.$jobtitle;
echo "&brand_type=$brand_type";
echo "&initiative_type=$initiative_type";
	
?>">&lt;&nbsp;<?=$lang["previousresult"]?></a>
|
<a href="search.php?notfound=false<? if (strpos($search,"!")!==false) {?>?search=<?=urlencode($search)?>&offset=<?=$offset?>&order_by=<?=$order_by?><? } ?><?
echo  '&form_sitephoto='.$sitephoto;
echo  '&form_sitephoto_1='.$sitephoto_1;
echo  '&form_sitephoto_2='.$sitephoto_2;
echo  '&form_personnel='.$personnel;
echo  '&form_city='.$city;
echo  '&form_state='.$state;
echo  '&form_firstname='.$firstname;
echo  '&form_lastname='.$lastname;
echo  '&form_businessunit='.$bunit;
echo  '&form_department='.$dept;
echo  '&form_jobtitle='.$jobtitle;
echo "&brand_type=$brand_type";
echo "&initiative_type=$initiative_type";

?>"><?=$lang["viewallresults"]?></a>
|
<a href="view.php?ref=<?=$ref?>&search=<?=urlencode($search)?>&offset=<?=$offset?>&order_by=<?=$order_by?>&archive=<?=$archive?>&go=next<?

echo  '&form_sitephoto='.$sitephoto;
echo  '&form_sitephoto_1='.$sitephoto_1;
echo  '&form_sitephoto_2='.$sitephoto_2;
echo  '&form_personnel='.$personnel;
echo  '&form_city='.$city;
echo  '&form_state='.$state;
echo  '&form_firstname='.$firstname;
echo  '&form_lastname='.$lastname;
echo  '&form_businessunit='.$bunit;
echo  '&form_department='.$dept;
echo  '&form_jobtitle='.$jobtitle;
echo "&brand_type=$brand_type";
echo "&initiative_type=$initiative_type";

?>"><?=$lang["nextresult"]?>&nbsp;&gt;</a>
</div>
<? } ?>

<h1><? if ($resource["archive"]==2) { ?><span class="ArchiveResourceTitle">ARCHIVE RESOURCE:</span>&nbsp;<? } ?><?=highlightkeywords(htmlspecialchars($resource["title"]),$search)?>: <?= strtoupper($resource["file_extension"]) ?> Format<? $s_s_result = sql_query("SELECT value FROM resource_data WHERE resource = ".$resource["ref"]." AND resource_type_field = 80 OR resource = ".$resource["ref"]." AND resource_type_field = 82"); if(isset($s_s_result[0])) {?>, <?=$s_s_result[0]["value"]?><? } else { ?><? } ?><? $s_s_result = sql_query("SELECT value FROM resource_data WHERE resource = ".$resource["ref"]." AND resource_type_field = 81 OR resource = ".$resource["ref"]." AND resource_type_field = 83"); if(isset($s_s_result[0])) {?>, <?=$s_s_result[0]["value"]?><? } else { ?><? } ?></h1>
<? } /* End of renderinnerresourceheader hook */ ?>
</div>

<? hook("renderbeforeresourceview"); ?>



<div class="RecordResouce">
<div id="PictureBox">
<? if (!hook("renderinnerresourceview")) { ?>
<? if (!hook("renderinnerresourcepreview")) { ?>
<?
$flvfile=get_resource_path($ref,"",false,"flv");
if (file_exists("plugins/players/type" . $resource["resource_type"] . ".php"))
	{
	include "plugins/players/type" . $resource["resource_type"] . ".php";
	}
elseif (file_exists($flvfile) && (strpos(strtolower($flvfile),".flv")!==false))
	{
	# Include the Flash player if an FLV file exists for this resource.
	include "flv_play.php";
	}
elseif ($resource["has_image"]==1)
	{
	$imagepath=get_resource_path($ref,"pre",false,$resource["preview_extension"]);
	$previewpath=get_resource_path($ref,"scr",false,$resource["preview_extension"]);
	if (!file_exists($previewpath)) {$previewpath=get_resource_path($ref,"",false,$resource["preview_extension"]);}
	
	if (file_exists($previewpath) ) { ?><a href="preview.php?ref=<?=$ref?>&ext=<?=$resource["preview_extension"]?>&k=<?=$k?>&search=<?=urlencode($search)?>&offset=<?=$offset?>&order_by=<?=$order_by?>&archive=<?=$archive?>
	<?
	echo  '&form_sitephoto='.$sitephoto;
echo  '&form_sitephoto_1='.$sitephoto_1;
echo  '&form_sitephoto_2='.$sitephoto_2;
echo  '&form_personnel='.$personnel;
echo  '&form_city='.$city;
echo  '&form_state='.$state;
echo  '&form_firstname='.$firstname;
echo  '&form_lastname='.$lastname;
echo  '&form_businessunit='.$bunit;
echo  '&form_department='.$dept;
echo  '&form_jobtitle='.$jobtitle;
echo "&brand_type=$brand_type";
echo "&initiative_type=$initiative_type";
	
	?>
	
	"><? }
	if (file_exists($imagepath))
		{ ?><img src="<?=$imagepath?>?nc=<?=time()?>" alt="" class="Picture" /><? } 
	else # use the thumbnail instead, the uploaded file wasn't big enough to create a preview.
		{ ?><img src="<?=get_resource_path($ref,"pre",false)?>" alt="" class="Picture" /><? }
	if (file_exists($previewpath)) { ?></a><? }
	}
else
	{
	?>
	<img src="gfx/type<?=$resource["resource_type"]?>.gif" alt="" class="Picture" style="border:none;" />
	<?
	}
?>
<? } /* End of renderinnerresourcepreview hook */ ?>
<style type="text/css">
.Picture {
	display: block;
}
#PictureBox {
	width: 400px;
	float: left;
}
#EnlargeDirections {
	float: left;
	width: 400px;
	display: inline;
}
#UsageRecord {
	float: left;
	width: 400px;
	margin-top: 0px;
}
</style>
<? /*<div id="EnlargeDirections"><p>Click on picture to enlarge</p></div>
<div class="RecordDownload" id="UsageRecord">
<div class="RecordDownloadSpace">
<h1><?=text("fileusageinformation")?></h1>
<p style="display: inline;"><?=text("fileusageinformationcontents")?></p>
</div> 
</div>*/ ?>
</div>
<? hook("renderbeforerecorddownload"); ?>


<script type="text/javascript">
setAsset = function() {
	//parent.
}
</script>

<div class="RecordDownload" id="RecordDownload" style="margin-right: 20px; margin-left: 10px; float: left; border: 1px solid black;">
<div class="RecordDownloadSpace">
<? if (!hook("renderinnerresourcedownloadspace")) { ?>
<a href="javascript:void(0);"><h2 style="font-weight: bold; text-decoration: underline !important; color: black; text-align: center;" onclick="javascript:setAsset();">Select WAM Asset</h2></a>
<? } /* End of renderinnerresourcedownloadspace hook */ ?>
</div>
<? } /* End of renderinnerresourceview hook */ ?>
</div>





<script type="text/javascript">
function remove_picture_frame() {
	//this.location.href = '/DigitalAssets/remove_photoframe.php?resource=<?=$ref?>';
	var XMLHttpRequestObject = false;
	if(window.XMLHttpRequest) {
		XMLHttpRequestObject = new XMLHttpRequest();
	}
	else if(window.ActiveXObject) {
		XMLHttpRequestObject = new ActiveXObject("Microsoft.XMLHTTP");
	}
	if(XMLHttpRequestObject) {
		XMLHttpRequestObject.open("GET", "/DigitalAssets/remove_photoframe.php?resource=<?=$ref?>");
		XMLHttpRequestObject.onreadystatechange = function() {
			if(XMLHttpRequestObject.readyState == 4 && XMLHttpRequestObject.status == 200) {
				ret = XMLHttpRequestObject.responseText;
				if(XMLHttpRequestObject.responseText!="OK") {
					alert("An error occurred when adding the image to the photoframe.");
				} else {
					document.getElementById('photoframe_button').value = "Display in Picture Frame";
					document.getElementById('photoframe_button').onclick = Function("display_picture_frame();");
				}
			}
		}
	} else {
		alert("Please upgrade your web browsers to ATLEAST Internet Explorer 6.0, Firefox 1.0, or a compatible browser.");
	}
	XMLHttpRequestObject.send(null);
}

function display_picture_frame() {
	//this.location.href = '/DigitalAssets/add_photoframe.php?resource=<?=$ref?>';
	var XMLHttpRequestObject = false;
	if(window.XMLHttpRequest) {
		XMLHttpRequestObject = new XMLHttpRequest();
	}
	else if(window.ActiveXObject) {
		XMLHttpRequestObject = new ActiveXObject("Microsoft.XMLHTTP");
	}
	if(XMLHttpRequestObject) {
		XMLHttpRequestObject.open("GET", "/DigitalAssets/add_photoframe.php?resource=<?=$ref?>");
		XMLHttpRequestObject.onreadystatechange = function() {
			if(XMLHttpRequestObject.readyState == 4 && XMLHttpRequestObject.status == 200) {
				ret = XMLHttpRequestObject.responseText;
				if(XMLHttpRequestObject.responseText!="OK") {
					alert("An error occurred when adding the image to the photoframe.");
				} else {
					document.getElementById('photoframe_button').value = "Remove From Picture Frame";
					document.getElementById('photoframe_button').onclick = Function("remove_picture_frame();");
				}
			}
		}
	} else {
		alert("Please upgrade your web browsers to ATLEAST Internet Explorer 6.0, Firefox 1.0, or a compatible browser.");
	}
	XMLHttpRequestObject.send(null);
}
</script>


<?
if(!$k) {
global $userref;
$username =  sql_query("SELECT * from user WHERE ref=$userref"); // Get the username
$username = $username[0]["username"];

$can_photoframe = sql_query("SELECT * from resource_data WHERE resource_type_field = 60 AND value = '$username' AND resource = $ref OR resource_type_field = 61 AND value = '$username' AND resource = $ref OR resource_type_field = 64 AND value = '$username' AND resource = $ref OR resource_type_field = 65 AND value = '$username' AND resource = $ref");
//if(count($can_photoframe)>0 || $username=="MarComet" || $usergroup=='13' || $usergroup=='14' || $usergroup=='15' || $usergroup=='17' || $usergroup=='20' || $usergroup=='23' || $usergroup=='26' || $usergroup=='29' || $usergroup=='32') {
// Make sure this resource has the keyword photoframe assigned to it
if(false && $username=="MarComet" || $usergroup=='13' || $usergroup=='14' || $usergroup=='15' || $usergroup=='17' || $usergroup=='20' || $usergroup=='23' || $usergroup=='26' || $usergroup=='29' || $usergroup=='32') {
$photoframe_enabled = sql_query("select distinct k.ref,k.keyword value from keyword k,resource_keyword r,resource_type_field f where k.ref=r.keyword and r.resource='$ref' and f.ref=r.resource_type_field and f.use_for_similar=1 and k.keyword='photoframe'");
if(count($photoframe_enabled)>0) {
?>
<input type="button" value="Remove From Picture Frame" onclick="javascript:remove_picture_frame();" style="display: block !important;" id="photoframe_button" />

<?
} else {
?>
<input type="button" value="Display in Picture Frame" onclick="javascript:display_picture_frame();" style="display: block !important;" id="photoframe_button" />
<?
}
}
}
?>

<? hook("renderbeforeresourcedetails"); ?>
<div class="Title"><?=$lang["resourcedetails"]?></div>

<?
$extra="";
$tabname="";
$tabnames = array("", " ", ",");
$tabcount=0;
$fields=get_resource_field_data($ref);
if (count($fields)>0) // && $fields[0]["tab_name"]!="")
	{ ?>
	<div class="TabBar">
	<?
	# Draw tabs.
	$extra="";
	$tabname="";
	$tabcount=0;
	for ($n=0;$n<count($fields);$n++)
		{
		$value=$fields[$n]["value"];

		# draw new tab?
		if (!(in_array($fields[$n]["tab_name"], $tabnames)) && ($value!="") && ($value!=",") && ($fields[$n]["display_field"]==1))
			{
			?><div id="tabswitch<?=$tabcount?>" class="Tab<? if ($tabcount==0) { ?> TabSelected<? } ?>"><a href="#" onclick="SelectTab(<?=$tabcount?>);return false;"><?=$fields[$n]["tab_name"]?></a></div><?
			$tabcount++;
			$tabname=$fields[$n]["tab_name"];
			array_push($tabnames, $fields[$n]["tab_name"]);
			}
		}
	?>
	</div>
	<script language="Javascript">
	function SelectTab(tab)
		{
		// Deselect all tabs
		<? for ($n=0;$n<$tabcount;$n++) { ?>
		document.getElementById("tab<?=$n?>").style.display="none";
		document.getElementById("tabswitch<?=$n?>").className="Tab";
		<? } ?>
		document.getElementById("tab" + tab).style.display="inline-block";
		document.getElementById("tabswitch" + tab).className="Tab TabSelected";
		}
	</script>
	<SCRIPT SRC="http://slayeroffice.com/code/gradient/gradient.js"></SCRIPT>
	<?
	}
?>

<div id="tab0" class="TabbedPanel<? if ($tabcount>0) { ?> StyledTabbedPanel<? } ?>" style="display:inline-block;">
<div class="clearerleft"> </div>
<? 
# Draw standard fields
?><? if (checkperm("u")) { ?>
<div class="itemNarrow"><h3><?=$lang["resourceid"]?></h3><p><?=$ref?></p></div>
<div class="itemNarrow"><h3><?=$lang["access"]?></h3><p><?=@$lang["access" . $resource["access"]]?></p></div><? } ?>
<?
# contributed by field
$udata=get_user($resource["created_by"]);
if ($udata!==false)
	{
	?>
	<div class="itemNarrow"><h3><?=$lang["contributedby"]?></h3><p><? if (checkperm("u")) { ?><a href="team_user_edit.php?ref=<?=$udata["ref"]?>"><? } ?><?=$udata["fullname"]?><? if (checkperm("u")) { ?></a><? } ?></p></div>
	<?
	}


# Show field data
$tabname="";
$tabcount=0;
$fieldcount=0;
$extra="";
for ($n=0;$n<count($fields);$n++)
	{
	$value=$fields[$n]["value"];
	
	# Handle expiry fields
	if ($fields[$n]["type"]==6 && $value!="" && $value<=date("Y-m-d"))
		{
		$extra.="<div class=\"RecordStory\"> <h1>" . $lang["warningexpired"] . "</h1><p>" . $lang["warningexpiredtext"] . "</p><p id=\"WarningOK\"><a href=\"#\" onClick=\"document.getElementById('RecordDownload').style.display='block';document.getElementById('WarningOK').style.display='none';\">" . $lang["warningexpiredok"] . "</a></p></div><style>#RecordDownload {display:none;}</style>";
		}
	
	
	if (($value!="") && ($value!=",") && ($fields[$n]["display_field"]==1))
		{
		$title=htmlspecialchars(str_replace("Keywords - ","",i18n_get_translated($fields[$n]["title"])));
		if ($fields[$n]["type"]==4 || $fields[$n]["type"]==6) {$value=NiceDate($value,false,true);}

		# Value formatting
		$value=i18n_get_translated($value);
		if (($fields[$n]["type"]==2) || ($fields[$n]["type"]==30)) {$value=TidyList($value);}
		$value=highlightkeywords(nl2br(htmlspecialchars($value)),$search);
		
		# draw new tab panel?
		if (($tabname!=$fields[$n]["tab_name"]) && ($fieldcount>0) && $tabcount!=2) // Added $tabcount!=2 to fix display bug 
			{
			$tabcount++;
			# Also display the custom formatted data $extra at the bottom of this tab panel.
			?><div class="clearerleft"> </div><?=$extra?></div><div class="TabbedPanel StyledTabbedPanel" style="display:none;" id="tab<?=$tabcount?>"><?	
			$extra="";
			}
		$tabname=$fields[$n]["tab_name"];
		$fieldcount++;		

		if (trim($fields[$n]["display_template"])!="")
			{
			# Process the value using a plugin
			$plugin="plugins/value_filter_" . $fields[$n]["name"] . ".php";
			if (file_exists($plugin)) {include $plugin;}
			
			# Use a display template to render this field
			$template=$fields[$n]["display_template"];
			$template=str_replace("[title]",$title,$template);
			$template=str_replace("[value]",$value,$template);
			$template=str_replace("[ref]",$ref,$template);
			$extra.=$template;
			}
		else
			{
			# Draw this field normally.
			?>
			<div class="itemNarrow"><h3><?=$title?></h3><p><?=$value?></p></div>
			<?
			}
		}
	}
?>
<div class="clearerleft"> </div>

<?=$extra?>

</div><!-- end of tabbed panel-->

</div>
</div>


<div class="PanelShadow"></div>
</div>


<?
# -------- Related Resources (must be able to search for this to work)
if (checkperm("s")) {
$result=do_search("!related" . $ref);
if (count($result)>0) 
	{
	?><!--Panel for related resources-->
<div class="RecordBox">
<div class="RecordPanel">  

<div class="RecordResouce">
<div class="Title"><?=$lang["relatedresources"]?></div>
<?
	# loop and display the results
	for ($n=0;$n<count($result);$n++)			
		{
		$rref=$result[$n]["ref"];
		?>
		<!--Resource Panel-->
		<div class="CollectionPanelShell">
			<table border="0" class="CollectionResourceAlign"><tr><td>
			<a target="main" href="view.php?ref=<?=$rref?>&search=<?=urlencode("!related" . $ref)?>"><? if ($result[$n]["has_image"]==1) { ?><img border=0 src="<?=get_resource_path($rref,"col",false,$result[$n]["preview_extension"])?>" class="CollectImageBorder"/><? } else { ?><img border=0 width=56 height=75 src="gfx/type<?=$result[$n]["resource_type"]?>_col.gif"/><? } ?></a></td>
			</tr></table>
			<div class="CollectionPanelInfo"><a target="main" href="view.php?ref=<?=$rref?>"><?=tidy_trim($result[$n]["title"],25)?></a>&nbsp;</div>
		</div>
		<?		
		}
	?>
	<div class="clearerleft"> </div>
		<a href="search.php?search=<?=urlencode("!related" . $ref) ?>"><?=$lang["clicktoviewasresultset"]?></a>

	</div>
	</div>
	<div class="PanelShadow"></div>
	</div><?
	}


if ($show_related_themes==true){
# -------- Public Collections / Themes
$result=get_themes_by_resource($ref);
if (count($result)>0) 
	{
	?><!--Panel for related themes / collections -->
	<div class="RecordBox">
	<div class="RecordPanel">  
	
	<div class="RecordResouce BasicsBox">
	<div class="Title"><?=$lang["collectionsthemes"]?></div>
	<div class="VerticalNav">
	<ul>
	<?
		# loop and display the results
		for ($n=0;$n<count($result);$n++)			
			{
			?>
			<li><a href="search.php?search=!collection<?=$result[$n]["ref"]?>"><?=(strlen($result[$n]["theme"])>0)?htmlspecialchars($result[$n]["theme"] . " / "):$lang["public"] . " : " . htmlspecialchars($result[$n]["fullname"] . " / ")?><?=htmlspecialchars($result[$n]["name"])?></a></li>
			<?		
			}
		?>
	</ul>
	</div>
	</div>
	</div>
	<div class="PanelShadow"></div>
	</div><?
	}} 
?>



<? /*
<!--Panel for search for similar resources-->
<div class="RecordBox">
<div class="RecordPanel"> 


<div class="RecordResouce">
<div class="Title"><?=$lang["searchforsimilarresources"]?></div>
<? if ($resource["has_image"]==1) { ?>

<!--
<p>Find resources with a <a href="search.php?search=<?=urlencode("!rgb:" . $resource["image_red"] . "," . $resource["image_green"] . "," . $resource["image_blue"])?>">similar colour theme</a>.</p>
<p>Find resources with a <a href="search.php?search=<?=urlencode("!colourkey" . $resource["colour_key"]) ?>">similar colour theme (2)</a>.</p>
-->

<? } ?>
<script language="Javascript">
function UpdateResultCount()
	{
	// set the target of the form to be the result count iframe and submit
	document.getElementById("findsimilar").target="resultcount";
	document.getElementById("countonly").value="yes";
	document.getElementById("findsimilar").submit();
	document.getElementById("findsimilar").target="";
	document.getElementById("countonly").value="";
	}
</script>

<form method="post" action="find_similar.php" id="findsimilar">
				        
		        <? 
		        if(is_numeric($username)) { ?>
		      	  <input type="hidden" name="form_issiteuser" id="form_issiteuser" value="yes" />
		        <? } else { ?>
		          <input type="hidden" name="form_issiteuser" id="form_issiteuser" value="no" />
		        <? } ?>
		        <input type="hidden" name="form_sitephoto" id="form_sitephoto" value="<?=$sitephoto?>" />
		        <input type="hidden" name="form_sitephoto_1" id="form_sitephoto_1" value="<?=$sitephoto_1?>" />
		        <input type="hidden" name="form_sitephoto_2" id="form_sitephoto_2" value="<?=$sitephoto_2?>" />
		        <input type="hidden" name="form_personnel" id="form_personnel" value="<?=$personnel?>" />
		        
		        <input type="hidden" name="form_city" id="form_city" value="<?=$city?>" />
		        <input type="hidden" name="form_state" id="form_state" value="<?=$state?>" />
		        <input type="hidden" name="form_firstname" id="form_firstname" value="<?=$firstname?>" />
		        <input type="hidden" name="form_lastname" id="form_lastname" value="<?=$lastname?>" />
		        <input type="hidden" name="form_businessunit" id="form_businessunit" value="<?=$bunit?>" />
		        <input type="hidden" name="form_department" id="form_department" value="<?=$dept?>" />
		        <input type="hidden" name="form_jobtitle" id="form_jobtitle" value="<?=$jobtitle?>" />
		        
		        
		        
<input type="hidden" name="resource_type" value="<?=$resource["resource_type"]?>">
<input type="hidden" name="countonly" id="countonly" value="">
<?
$keywords=get_resource_top_keywords($ref,30);
$searchwords=split_keywords($search);
for ($n=0;$n<count($keywords);$n++)
	{
	?>
	<div class="SearchSimilar"><input type=checkbox name="keyword_<?=urlencode($keywords[$n])?>" value="yes"
	<? if (in_array($keywords[$n],$searchwords)) {?>checked<?}?> onClick="UpdateResultCount();">&nbsp;<?=$keywords[$n]?></div>
	<?
	}
?>
<div class="clearerleft"> </div>
<br />
<input name="search" type="submit" value="&nbsp;&nbsp;<?=$lang["search"]?>&nbsp;&nbsp;" id="dosearch"/>
<iframe frameborder=0 scrolling=no width=1 height=1 style="visibility:hidden;" name="resultcount" id="resultcount"></iframe>
</form>
<div class="clearerleft"> </div>
</div>
</div>
<div class="PanelShadow"></div>
</div>*/ ?>
<? } # end of block that requires search permissions?>

<?
include "include/footer.php";
?>
