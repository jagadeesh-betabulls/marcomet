<?
include "include/db.php";
include "include/marcomet_widget_authenticate.php";
include "include/general.php";
include "include/search_functions.php";
include "include/collections_functions.php";

function array_insert($array,$pos,$val)
{
	$array2 = array_splice($array,$pos);
	$array[] = $val;
	$array = array_merge($array,$array2);
  
	return $array;
}

function array_delete($array,$loc)
{
	$array1 = array_slice($array,0,$loc+1);
	$array2 = array_slice($array,$loc+2);
	return array_merge($array1,$array2);
}

function sortIDToTop(&$result, $pID) {
	if(!is_array($result)) {
		return false;
	}
	for($i=0;$i<count($result);$i++) {
		$ires = $result[$i];
		if($ires["ref"]==$pID) {
			$result[$i] = array_merge($result[$i], array("current_wam_block_image" => "yes"));
			$result = array_insert($result, 0, $result[$i]);
			$result = array_delete($result, $i);
			return true;
		}
	}
	return false;
}

$widget_user = getval("widget_user", "");

$width = getval("width", "0");
$height = getval("height", "0");
$search=getvalescaped("search","");

$previousID = getval("previousID", "0");
$previousURL = getval("previousURL", "");

$templateName = getval('templateName', '');
$imageRef = getval('imageRef', '');
$imageDPI = getval('dpi', '');
$imageWidth = getval('imageWidth', '');
$imageHeight = getval('imageHeight', '');
$tempImageName = getval('tempImageName', '');
$tempImagePath = getval('tempImagePath', '');
$amsDomain = getval('amsDomain', '');

//print "AMS Domain: $amsDomain<br />";
//print "BASE_URL_HTTP_GET: $BASE_URL_HTTP_GET<br />";

if(file_exists("../../$tempImagePath".'/'.$tempImageName) && getval('ignoreFile', '')!='yes') {
	//redirect("/preview/template_wam/marcomet_widget_cropscale.php?widget_user=$widget_user&ratioWidth=$width&ratioHeight=$height&x1=0&y1=0&x2=100&y2=100" . '&templateName=' . $templateName. '&imageRef=' . $imageRef. '&imageDPI=' . $imageDPI. '&imageWidth=' . $imageWidth. '&imageHeight=' . $imageHeight. '&tempImageName=' . $tempImageName. '&tempImagePath=' . $tempImagePath . "&resURL=/" . $tempImagePath . "/" . $tempImageName);
}



# Append extra search parameters
$country=getvalescaped("country","");
if ($country!="") {$search=(($search=="")?"":join(", ",split_keywords($search)) . ", ") . "country:" . $country;}
$year=getvalescaped("year","");
if ($year!="") {$search=(($search=="")?"":join(", ",split_keywords($search)) . ", ") . "year:" . $year;}
$month=getvalescaped("month","");
if ($month!="") {$search=(($search=="")?"":join(", ",split_keywords($search)) . ", ") . "month:" . $month;}
$day=getvalescaped("day","");
if ($day!="") {$search=(($search=="")?"":join(", ",split_keywords($search)) . ", ") . "day:" . $day;}
# fetch brand from query string and generate a brand cookie
	$brand=getvalescaped("brand","");
	setcookie("brand",$brand);

hook("searchstringprocessing");


if (strpos($search,"!")===false) {setcookie("search",$search);} # store the search in a cookie if not a special search
$offset=getvalescaped("offset",0);if (strpos($search,"!")===false) {setcookie("saved_offset",$offset);}
if ((!is_numeric($offset)) || ($offset<0)) {$offset=0;}
$order_by=getvalescaped("order_by","date");if (strpos($search,"!")===false) {setcookie("saved_order_by",$order_by);}
$display=getvalescaped("display","thumbs");setcookie("display",$display);
$per_page=getvalescaped("per_page",$default_perpage);setcookie("per_page",$per_page);
$archive=getvalescaped("archive",0);if (strpos($search,"!")===false) {setcookie("saved_archive",$archive);}
$jumpcount=0;

# Enable/disable the reordering feature. Just for collections for now.
$allow_reorder=false;
if (substr($search,0,11)=="!collection" && $collection_reorder_caption)
	{
	# Check to see if this user can edit (and therefore reorder) this resource
	$collection=substr($search,11);
	$collectiondata=get_collection($collection);
	if (($userref==$collectiondata["user"]) || ($collectiondata["allow_changes"]==1) || (checkperm("h")))
		{
		$allow_reorder=true;
		}
	}


if (getval("resetrestypes","")=="")
{
	$restypes=getvalescaped("restypes","");
} else {
	$restypes="";
	reset($_GET);
	foreach ($_GET as $key=>$value)
	{
		if (substr($key,0,8)=="resource") 
		{
			if ($restypes!="") { $restypes.=","; } 
			$restypes.=substr($key,8);
		}
	}
	
	//setcookie("restypes",$restypes);
	# This is a new search, log this activity
	if ($archive == 2) {
		daily_stat("Archive search",0);
	} else {
		daily_stat("Search",0);
	}
}

if($restypes=="") { $restypes = "1"; }
		
	
	
# If returning to an old search, restore the page/order by
if (!array_key_exists("search",$_GET))
	{
	$offset=getvalescaped("saved_offset",0);setcookie("saved_offset",$offset);
	$order_by=getvalescaped("saved_order_by","relevance");setcookie("saved_order_by",$order_by);
	$archive=getvalescaped("saved_archive",0);setcookie("saved_archive",$archive);
	}
	
# If requested, refresh the collection frame (for redirects from saves)
if (getval("refreshcollectionframe","")!="")
	{
	refresh_collection_frame();
	}

# Include scriptaculous for infobox panels.
$headerinsert.="
<script src=\"js/prototype.js\" type=\"text/javascript\"></script>
<script src=\"js/scriptaculous.js\" type=\"text/javascript\"></script>
<script src=\"js/infobox.js\" type=\"text/javascript\"></script>
";

if ($infobox)
	$bodyattribs="OnMouseMove='InfoBoxMM(event);'";

# Include function for reordering
if ($allow_reorder)
	{
	$url= "marcomet_widget_nav.php?widget_user=". $_GET["widget_user"] ."&search=" . urlencode($search) . "&order_by=" . urlencode($order_by) . "&archive=" . $archive . "&offset=" . $offset . "&restypes=" . $restypes . "&previousID=" . $previousID . '&templateName=' . $templateName. '&imageRef=' . $imageRef. '&imageDPI=' . $imageDPI. '&imageWidth=' . $imageWidth. '&imageHeight=' . $imageHeight. '&tempImageName=' . $tempImageName. '&tempImagePath=' . $tempImagePath . "&ignoreFile=" . getval('ignoreFile', '');
	?>
	<script type="text/javascript">
	function ReorderResources(id1,id2)
	{
		document.location='<?=$url?>&reorder=' + id1 + '-' + id2;
	}
	</script>
	<?
	
	# Also check for the parameter and reorder as necessary.
	$reorder=getvalescaped("reorder","");
	if ($reorder!="")
	{
		$r=explode("-",$reorder);
		swap_collection_order(substr($r[0],13),$r[1],substr($search,11));
		refresh_collection_frame();
	}
}




if (true) #search condition
{
	$refs=array();
	#echo "search=$search";
	
	# Special query? Ignore restypes
	if (strpos($search,"!")!==false) {$restypes="";}
	
	# Story only? Display as list
	#if ($restypes=="2") {$display="list";}
	
	$brand_type = getvalescaped("brand_type", "");
	$initiative_type = getvalescaped("initiative_type", "");
	//$result=do_search($search,$restypes,$order_by,$archive,$per_page+$offset,$brand);
	if($brand_type=="") {
		if($brand=="baymont") $brand_type =  "Baymont Inn & Suites";
		if($brand=="microtel") $brand_type =  "Microtel Inns & Suites";
	}
	
	$result=do_search($search,$restypes,$order_by,$archive,$per_page+$offset, $brand_type, $initiative_type, $filtersql=array(), 
	$variants=getval("showvariants", ""));
	// array_merge($result[$i], array("current_wam_block_image" => "yes"));
	$topSorted = false;
	if($previousID!=0) {
		$topSorted = sortIDToTop(&$result, $previousID);
	}
	
	if(!$topSorted && $previousID!=0) {
		if(is_array($result)) {
			$result = array_merge(array(get_resource_data($previousID)), $result);
		} else {
			$result = array(get_resource_data($previousID));
		}
		$topSorted = sortIDToTop(&$result, $previousID);
	}
	//echo "(".$search. ", ". $restypes. ", ". $order_by.", ".$archive. ", ". ($per_page+$offset). ", ". $brand. ")";exit;

			
		$url="marcomet_widget_nav.php?widget_user=". $_GET["widget_user"] ."&initiative_type=".urlencode($initiative_type)."&search=" . urlencode($search) . "&order_by=" . $order_by . "&offset=" . $offset . "&archive=" . $archive . "&restypes=" . $restypes . "&previousID=" . $previousID . '&templateName=' . $templateName. '&imageRef=' . $imageRef. '&imageDPI=' . $imageDPI. '&imageWidth=' . $imageWidth. '&imageHeight=' . $imageHeight. '&tempImageName=' . $tempImageName. '&tempImagePath=' . $tempImagePath . "&ignoreFile=" . getval('ignoreFile', '');
		?>
		
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<title><?=htmlspecialchars($applicationname)?></title>
<link href="<?=$baseurl?>/css/Col-whitegry.css" rel="stylesheet" type="text/css" media="screen,projection,print" id="colourcss" />
<link href="<?=$baseurl?>/css/wrdsnpics.css" rel="stylesheet" type="text/css" media="screen,projection,print" />
<!--[if lte IE 6]> <link href="<?=$baseurl?>/css/wrdsnpicsIE.css" rel="stylesheet" type="text/css"  media="screen,projection,print" /> <![endif]-->
<!--[if lte IE 5.6]> <link href="<?=$baseurl?>/css/wrdsnpicsIE5.css" rel="stylesheet" type="text/css"  media="screen,projection,print" /> <![endif]-->
<!--<?=$search?> -->
<?
# Include CSS files for for each of the plugins too (if provided)
for ($n=0;$n<count($plugins);$n++)
	{
	$csspath=dirname(__FILE__)."/../plugins/" . $plugins[$n] . "/css/style.css";
	if (file_exists($csspath))
		{
		?>
		<link href="<?=$baseurl?>/plugins/<?=$plugins[$n]?>/css/style.css" rel="stylesheet" type="text/css" media="screen,projection,print" />
		<?
		}
	}
	
?>
<style type="text/css">
		.SelectedWamBlockResource .ResourcePanel {
			background: #203B5E none !important;
		}
</style>
	<script src="//ajax.googleapis.com/ajax/libs/jquery/2.1.3/jquery.min.js"></script>
</head>
<script>
function InfoBoxSetResource(resId){

}
</script>
<body><? if(getval("show_search", "")=="yes") { include "include/searchbar.php"; } ?>
<div style="position: absolute; left: 100px; top: 100px; z-index: 2; margin: 100px 200px 200px 200px; border: 3px solid black; width: 100px; height: 100px; background: #FFF url('/preview/template_wam/search_page_loading.gif') center no-repeat; display: none;" id="searchPageLoadingImage"></div></div>
		<div class="TopInpageNav TopInpageNav">
		<style type="text/css">
		.resTab {
			background: transparent url('<?=$baseurl?>/gfx/greyblu/interface/resourcepanel.gif') repeat-x top;
			border: 1px solid #385D90;
			height: 15px;
			text-align: center;
			margin: 10px 0px 10px 2px;
			padding: 3px 5px 3px 5px;
			cursor: pointer;
			display: block;
		}
		.selectedTab { 
			background: transparent url('<?=$baseurl?>/gfx/greyblu/interface/resourcepanel.gif') repeat-x bottom !important;
			border: 1px solid #203B5D !important;
		}
		.selectedTab p {
			color: #203B5D;
		}
		#widgetTabBar {
			float: left;
			height: 45px;width: 900px;
		}
		</style>
		<script type="text/javascript">
		var fileFormOn = false;
		function toggleFileFormBox() {
			if(fileFormOn) {
				document.getElementById('uploadANewFileFormBox').style.display = "none";
				document.getElementById('fileFormBoxButton').style.display = "inline";
				fileFormOn = false;
			} else {
				document.getElementById('uploadANewFileFormBox').style.display = "inline";
				document.getElementById('fileFormBoxButton').style.display = "none";
				fileFormOn = true;
			}
		}
		</script>
		<div id="widgetTabBar">
			<div style="float: left; width: 180px; height: 20px; padding: 4px; background: #E5ECEE no-repeat 7px 6px url('/preview/template_wam/add.png'); border: #779CA8 2px solid; font-size: 15px; text-align: right; margin: 10px 0px 0px 20px; cursor: pointer;" onclick="javascript:toggleFileFormBox();" id="fileFormBoxButton"><p style="display: inline; color: #203B5D; font-weight: bold;">Upload a New Image</p></div>
				
			<div style="top: 10px; left: 10px; position:absolute; float: left; width: 220px; height: 80px; padding: 4px; background: #E5ECEE no-repeat none; border: #779CA8 2px solid; font-size: 12px; text-align: right; 20px; display: none;" id="uploadANewFileFormBox">
				<b style="display: inline; float: left; color: #203B5D; font-weight: bold;">Upload a New Image</b>

				<form method="post" class="form" enctype="multipart/form-data" action="http://<?php echo $amsDomain; ?>/DigitalAssets/marcomet_widget_create.php?widget_user=<?=$username?>&ignoreFile=<?=getval('ignoreFile', '')?>" style="display: inline; float: right;" id="uploadANewFileForm" >
					<input type="file" name="userfile" id="userfile" style="display: inline;" />
					<input type="hidden" name="archive" value="0" />
					<input type="hidden" name="new_file_return_url" id="new_file_return_url" value="<?=$BASE_URL_HTTP_GET?>/preview/template_wam/marcomet_widget_cropscale.php?widget_user=<?=$username?>&ratioWidth=<?=$width?>&ratioHeight=<?=$height?>&x1=0&y1=0&x2=100&y2=100&templateName=<?=$templateName?>&imageRef=<?=$imageRef?>&imageDPI=<?=$imageDPI?>&imageWidth=<?=$imageWidth?>&imageHeight=<?=$imageHeight?>&tempImageName=<?=$tempImageName?>&tempImagePath=<?=$tempImagePath?>&ignoreFile=<?=getval('ignoreFile', '')?>" />
					<?
					if($usersearchfilter!="") {
					
					$brand = explode("brand=", $usersearchfilter);
					$brand = $brand[1];
					$brand = explode("\|", $brand);
					$brand = $brand[0];

					?>
					<input type=hidden name="brand" value="<?=$brand?>">
					<? } else { ?><div class="Inline"><label for="brand">Brand: </label><select name="brand" class="shrtwidth"><?
					$brands=sql_query("SELECT distinct value FROM resource_data WHERE resource_type_field = 63");
					if($brands) {
						for ($n=0;$n<count($brands);$n++)
						{
							?><option value="<?=$brands[$n]["value"]?>"><?=$brands[$n]["value"]?></option><?
						}
					}?></select></div><?
					}
					?>
					<input type="hidden" name="resource_type" value="3" />
					<input type="hidden" name="MAX_FILE_SIZE" value="200000000">
					
					<div style="float: left; cursor: pointer; width: 14px; height: 14px; background: url('/preview/template_wam/remove.png') top left no-repeat black; margin: 0px 0px 0px 5px;display: inherit;" onclick="javascript:toggleFileFormBox();"></div>
					<input type="submit" name="save" id="upload_new_file" value="Upload" style="display: inherit; float: right;" onclick="javascript:document.getElementById('searchPageLoadingImage').style.display = 'block';" />
				</form>
			</div>
			<div style="float: left; margin: 13px 5px 5px 15px; height: 20px;"><b>Image Type:</b></div>
		<form>
		<script type="text/javascript">
		function goToResChoice() {
			window.location='/preview/template_wam/marcomet_widget_nav.php?widget_user=<? echo getvalescaped("widget_user", ""); ?>&initiative_type=<?=urlencode($initiative_type)?>&amsDomain=<?=urlencode($amsDomain)?>&search=<?=urlencode($search)?>&order_by=<?=$order_by?>&archive=0&restypes='+document.getElementById('resourceTypeSelect').value+'&width=<?=$width?>&height=<?=$height?>&previousID=<?=$previousID?>&templateName=<?=$templateName?>&imageRef=<?=$imageRef?>&imageDPI=<?=$imageDPI?>&imageWidth=<?=$imageWidth?>&imageHeight=<?=$imageHeight?>&tempImageName=<?=$tempImageName?>&tempImagePath=<?=$tempImagePath?>&ignoreFile=<?=getval('ignoreFile', '')?>';		}
			$(function() {
				$("#resourceTypeSelect").change(function(e) {
					goToResChoice();
				});
			});
		</script>
		<select id="resourceTypeSelect" name="resourceType" style="float: left; margin-top: 15px;">
		<?
		$tabTypes = get_resource_types();
		for($i=0;$i<count($tabTypes);$i++) { 
		if($tabTypes[$i]["name"]=="Document" || $tabTypes[$i]["name"]=="Multimedia: Video or Audio") { continue; }
		?>
			<option value="<?=$tabTypes[$i]["ref"]?>" a="javascript:window.location='/preview/template_wam/marcomet_widget_nav.php?widget_user=<? echo getvalescaped("widget_user", ""); ?>&initiative_type=<?=urlencode($initiative_type)?>&amsDomain=<?=urlencode($amsDomain)?>&search=<?=urlencode($search)?>&order_by=<?=$order_by?>&archive=0&restypes=<?=$tabTypes[$i]["ref"]?>&width=<?=$width?>&height=<?=$height?>&previousID=<?=$previousID?>&templateName=<?=$templateName?>&imageRef=<?=$imageRef?>&imageDPI=<?=$imageDPI?>&imageWidth=<?=$imageWidth?>&imageHeight=<?=$imageHeight?>&tempImageName=<?=$tempImageName?>&tempImagePath=<?=$tempImagePath?>&ignoreFile=<?=getval('ignoreFile', '')?>'" <? if($restypes==$tabTypes[$i]["ref"]) { echo "selected"; } ?>><p><?=$tabTypes[$i]["name"]?></p></option>		<? } ?>
		</select></form>
		</div><br/><br/><br/>
		
		<? if (is_array($result))
		{?>
		<div class="InpageNavLeftBlock"><?=$lang["youfound"]?>:<br /><span class="Selected"><?=number_format(count($result))?><?=(count($result)==$max_results)?"+":""?></span> <?=$lang["youfoundresources"]?></div>
	<div class="InpageNavLeftBlock"><?=$lang["display"]?>:<br />
		<? if ($display=="thumbs") { ?><span class="Selected"><?=$lang["largethumbs"]?></span><? } else { ?><a href="<?=$url?>&display=thumbs&restypes=<?=$restypes?>&width=<?=$width?>&height=<?=$height?>"><?=$lang["largethumbs"]?></a><? } ?>&nbsp;|&nbsp; 
			<? if ($smallthumbs==true) { ?>		
		<? if ($display=="smallthumbs") { ?><span class="Selected"><?=$lang["smallthumbs"]?></span><? } else { ?><a href="<?=$url?>&display=smallthumbs&restypes=<?=$restypes?>&width=<?=$width?>&height=<?=$height?>"><?=$lang["smallthumbs"]?></a><? } ?>&nbsp; |&nbsp;<? } ?>
		<? if ($display=="list") { ?><span class="Selected"><?=$lang["list"]?></span><? } else { ?><a href="<?=$url?>&display=list&restypes=<?=$restypes?>&width=<?=$width?>&height=<?=$height?>"><?=$lang["list"]?></a><? } ?> <? hook("adddisplaymode"); ?> </div>
		<?
		
		# order by
		#if (strpos($search,"!")===false)
		if (true) # Ordering enabled for collections/themes too now at the request of N Ward / Oxfam
			{
			$rel=$lang["relevance"];
			if (strpos($search,"!")!==false) {$rel=$lang["asadded"];}
			?>
			<div class="InpageNavLeftBlock "><?=$lang["sortorder"]?>:<br /><? if ($order_by=="relevance") {?><span class="Selected"><?=$rel?></span><? } else { ?><a href="marcomet_widget_nav.php?widget_user=<? echo $_GET["widget_user"]; ?>&search=<?=urlencode($search)?>&order_by=relevance&archive=<?=$archive?>&previousID=<?=$previousID?>&restypes=<?=$restypes?>&width=<?=$width?>&height=<?=$height?>&templateName=<?=$templateName?>&imageRef=<?=$imageRef?>&imageDPI=<?=$imageDPI?>&imageWidth=<?=$imageWidth?>&imageHeight=<?=$imageHeight?>&tempImageName=<?=$tempImageName?>&tempImagePath=<?=$tempImagePath?>&ignoreFile=<?=getval('ignoreFile', '')?>"><?=$rel?></a><? } ?>
			&nbsp;|&nbsp;
			<? if ($order_by=="popularity") {?><span class="Selected"><?=$lang["popularity"]?></span><? } else { ?><a href="marcomet_widget_nav.php?widget_user=<? echo $_GET["widget_user"]; ?>&search=<?=urlencode($search)?>&order_by=popularity&archive=<?=$archive?>&previousID=<?=$previousID?>&restypes=<?=$restypes?>&width=<?=$width?>&height=<?=$height?>&templateName=<?=$templateName?>&imageRef=<?=$imageRef?>&imageDPI=<?=$imageDPI?>&imageWidth=<?=$imageWidth?>&imageHeight=<?=$imageHeight?>&tempImageName=<?=$tempImageName?>&tempImagePath=<?=$tempImagePath?>&ignoreFile=<?=getval('ignoreFile', '')?>"><?=$lang["popularity"]?></a><? } ?>
			
			<? if ($orderbyrating) { ?>
			&nbsp;|&nbsp;
			<? if ($order_by=="rating") {?><span class="Selected"><?=$lang["rating"]?></span><? } else { ?><a href="marcomet_widget_nav.php?widget_user=<? echo $_GET["widget_user"]; ?>&search=<?=urlencode($search)?>&order_by=rating&archive=<?=$archive?>&previousID=<?=$previousID?>&restypes=<?=$restypes?>&width=<?=$width?>&height=<?=$height?>&templateName=<?=$templateName?>&imageRef=<?=$imageRef?>&imageDPI=<?=$imageDPI?>&imageWidth=<?=$imageWidth?>&imageHeight=<?=$imageHeight?>&tempImageName=<?=$tempImageName?>&tempImagePath=<?=$tempImagePath?>&ignoreFile=<?=getval('ignoreFile', '')?>"><?=$lang["rating"]?></a><? } ?>
			<? } ?>
			
			&nbsp;|&nbsp;
			<? if ($order_by=="date") {?><span class="Selected"><?=$lang["date"]?></span><? } else { ?><a href="marcomet_widget_nav.php?widget_user=<? echo $_GET["widget_user"]; ?>&search=<?=urlencode($search)?>&order_by=date&archive=<?=$archive?>&previousID=<?=$previousID?>&restypes=<?=$restypes?>&width=<?=$width?>&height=<?=$height?>&templateName=<?=$templateName?>&imageRef=<?=$imageRef?>&imageDPI=<?=$imageDPI?>&imageWidth=<?=$imageWidth?>&imageHeight=<?=$imageHeight?>&tempImageName=<?=$tempImageName?>&tempImagePath=<?=$tempImagePath?>&ignoreFile=<?=getval('ignoreFile', '')?>"><?=$lang["date"]?></a><? } ?>
			&nbsp;|&nbsp;
			<? if ($order_by=="colour") {?><span class="Selected"><?=$lang["colour"]?></span><? } else { ?><a href="marcomet_widget_nav.php?widget_user=<? echo $_GET["widget_user"]; ?>&search=<?=urlencode($search)?>&order_by=colour&archive=<?=$archive?>&previousID=<?=$previousID?>&restypes=<?=$restypes?>&width=<?=$width?>&height=<?=$height?>&templateName=<?=$templateName?>&imageRef=<?=$imageRef?>&imageDPI=<?=$imageDPI?>&imageWidth=<?=$imageWidth?>&imageHeight=<?=$imageHeight?>&tempImageName=<?=$tempImageName?>&tempImagePath=<?=$tempImagePath?>&ignoreFile=<?=getval('ignoreFile', '')?>"><?=$lang["colour"]?></a><? } ?>
			<? if ($country_sort) { ?>
			&nbsp;|&nbsp;
			<? if ($order_by=="country") {?><span class="Selected"><?=$lang["country"]?></span><? } else { ?><a href="marcomet_widget_nav.php?widget_user=<? echo $_GET["widget_user"]; ?>&search=<?=urlencode($search)?>&order_by=country&archive=<?=$archive?>&previousID=<?=$previousID?>&restypes=<?=$restypes?>&width=<?=$width?>&height=<?=$height?>&templateName=<?=$templateName?>&imageRef=<?=$imageRef?>&imageDPI=<?=$imageDPI?>&imageWidth=<?=$imageWidth?>&imageHeight=<?=$imageHeight?>&tempImageName=<?=$tempImageName?>&tempImagePath=<?=$tempImagePath?>&ignoreFile=<?=getval('ignoreFile', '')?>"><?=$lang["country"]?></a><? } ?>
			<? } ?>
			</div>
			<?
			}
			
		$results=count($result);
		$totalpages=ceil($results/$per_page);
		if ($offset>$results) {$offset=0;}
		$curpage=floor($offset/$per_page)+1;
		$url="marcomet_widget_nav.php?widget_user=". $_GET["widget_user"] ."&search=" . urlencode($search) . "&order_by=" . urlencode($order_by) . "&archive=" . $archive . "&restypes=" . $restypes . "&previousID=" . $previousID . '&templateName=' . $templateName. '&imageRef=' . $imageRef. '&imageDPI=' . $imageDPI. '&imageWidth=' . $imageWidth. '&imageHeight=' . $imageHeight. '&tempImageName=' . $tempImageName. '&tempImagePath=' . $tempImagePath . "&ignoreFile=" . getval('ignoreFile', '');

		pager();
		$draw_pager=true;
		?></div>
		
		<?		
		hook("beforesearchresults");
		
		if ($display=="list")
			{
			?>
			<!--list-->
			<div class="Listview">
			<table border="0" cellspacing="0" cellpadding="0" class="ListviewStyle">
	
			<!--Title row-->	
			<tr class="ListviewTitleStyle">
			<td><?=$lang["titleandcountry"]?></td>
			<td>&nbsp;</td>
			<td><?=$lang["id"]?></td>
			<td><?=$lang["type"]?></td>
			<td><?=$lang["date"]?> </td>
			<td><div class="ListTools"><?=$lang["tools"]?></div></td>
			</tr>
			<?
			}
			
		# work out common keywords among the results
		if ((count($result)>$suggest_threshold) && (strpos($search,"!")===false) && ($suggest_threshold!=-1))
			{
			for ($n=0;$n<count($result);$n++)
				{
				if ($result[$n]["ref"]) {$refs[]=$result[$n]["ref"];} # add this to a list of results, for query refining later
				}
			$suggest=suggest_refinement($refs,$search);
			if (count($suggest)>0)
				{
				?><p><?=$lang["torefineyourresults"]?>: <?
				for ($n=0;$n<count($suggest);$n++)
					{
					if ($n>0) {echo ", ";}
					?><a  href="marcomet_widget_nav.php?widget_user=<? echo $_GET["widget_user"]; ?>&search=<?= urlencode(strip_tags($suggest[$n])) ?>&previousID=<?=$previousID?>&restypes=<?=$restypes?>&width=<?=$width?>&height=<?=$height?>&templateName=<?=$templateName?>&imageRef=<?=$imageRef?>&imageDPI=<?=$imageDPI?>&imageWidth=<?=$imageWidth?>&imageHeight=<?=$imageHeight?>&tempImageName=<?=$tempImageName?>&tempImagePath=<?=$tempImagePath?>&ignoreFile=<?=getval('ignoreFile', '')?>"><?=stripslashes($suggest[$n])?></a><?
					}
				?></p><?
				}
			}
		
		# Work out which resources we will be showing and pre-fetch data for those resources
		# No longer needed as we have 'resource_column' on fields that populates the main resource table for certain
		# columns
		/*
		$showrefs=array();
		for ($n=$offset;(($n<count($result)) && ($n<($offset+$page_size)));$n++)			
			{
			$showrefs[]=$result[$n]["ref"];
			}
		$resdata=get_resource_field_data_batch($showrefs);
		*/
		# Pre-fetch resource types for the list view
		
/*		
		if ($display=="list")
			{
*/			 
			$rtypes=array();
			$types=get_resource_types();
			for ($n=0;$n<count($types);$n++) {$rtypes[$types[$n]["ref"]]=$types[$n]["name"];}
/*			
			} 
*/		
		# loop and display the results
		for ($n=$offset;(($n<count($result)) && ($n<($offset+$per_page)));$n++)			
		{
			$ref=$result[$n]["ref"];
			$extension=sql_value("select file_extension value from resource where ref='$ref'","jpg");
			if ($extension=="") {$extension="jpg";}
			$extension2=sql_value("select preview_extension value from resource where ref='$ref'","jpg");
			if ($extension2=="") {$extension2="jpg";}
			
			$generate_missing_dirs = false;
			$scramble_path = -1;
			
			//print_r(get_image_sizes($ref,false,$result[$n]["file_extension"])); continue;
			$url = "marcomet_widget_cropscale.php?widget_user=$widget_user&ref=$ref&ratioWidth=$width&ratioHeight=$height&x1=0&y1=0&x2=100&y2=100&templateName=$templateName&imageRef=$imageRef&imageDPI=$imageDPI&imageWidth=$imageWidth&imageHeight=$imageHeight&tempImageName=$tempImageName&tempImagePath=$tempImagePath&amsDomain=$amsDomain&ignoreFile=" . getval('ignoreFile', '');
			
			?>			

			<?	
			if ($display=="thumbs") { #Thumbnails view
			?>
			 
				<? if(isset($result[$n]["current_wam_block_image"])) { echo '<div class="SelectedWamBlockResource">'; } ?>
				 
				<? if (!hook("renderresultthumb")) { ?>
					<!--Resource Panel-->
					<div class="ResourcePanelShell" id="ResourceShell<?=$ref?>">
					<div class="ResourcePanel" onMouseOver="InfoBoxSetResource(<?=$ref?>);" onMouseOut="InfoBoxSetResource(0);">

					<? if (!hook("renderimagethumb")) { ?>		
						<table border="0" class="ResourceAlign<? if (in_array($result[$n]["resource_type"],$videotypes)) { ?> IconVideo<? } ?>"><tr><td>
							<a href="<?=$url?>" <? if (!$infobox) { ?>title="<?=str_replace(array("\"","'"),"",htmlspecialchars($result[$n]["title"]))?>"<? } ?>>
								<? if ($result[$n]["has_image"]==1) { ?>
									<img width="<?=$result[$n]["thumb_width"]?>" height="<?=$result[$n]["thumb_height"]?>" 
										src="<?=get_resource_path($ref, "thm", $generate_missing_dirs, $result[$n]["preview_extension"], $scramble_path, $amsDomain)?>" class="ImageBorder" />
								<? } else { ?>
									<img border=0 src="gfx/type<?=$result[$n]["resource_type"]?>.gif">
								<? } ?>
							</a>
						</td></tr></table>
					<? } ?> <!-- END HOOK Renderimagethumb-->	
				
					<? if (!hook("rendertitlethumb")) { ?>
						<div class="ResourcePanelInfo">
							<a href="<?=$url?>" <? if (!$infobox) { ?>title="<?=str_replace(array("\"","'"),"",htmlspecialchars($result[$n]["title"]))?>"<? } ?>>
								<?=highlightkeywords(htmlspecialchars(tidy_trim($result[$n]["title"],22)),$search)?>
							</a>&nbsp;
						</div>
					<? } ?> <!-- END HOOK Rendertitlethumb -->			
						
					<div class="ResourcePanelCountry">
						<? if (!$allow_reorder) { # Do not display the country if reordering (to create more room) ?>
							<?=highlightkeywords(tidy_trim(TidyList(i18n_get_translated($result[$n]["country"])),14),$search)?>
						<? } ?>&nbsp;
					</div>				

					<? if ($result[$n]["rating"]>0) { ?>
						<div class="IconStar"></div>
					<? } ?>
					
					<? if ($collection_reorder_caption && $allow_reorder) { ?>
						<span class="IconComment"><a href="collection_comment.php?ref=<?=$ref?>&collection=<?=substr($search,11)?>" <? if (!$infobox) { ?>title="<?=$lang["addorviewcomments"]?>"<? } ?>><img src="gfx/interface/sp.gif" alt="" width="14" height="12" /></a></span>			
						<div class="IconReorder" onMouseDown="InfoBoxWaiting=false;"> </div>
					<? } ?>
					<div class="clearer"></div>
				</div>
				<div class="PanelShadow"></div>
				</div>
				<? if ($allow_reorder) { 
					# Javascript drag/drop enabling.
					?>
					<script type="text/javascript">
						new Draggable('ResourceShell<?=$ref?>',{handle: 'IconReorder', revert: true});
						Droppables.add('ResourceShell<?=$ref?>',{accept: 'ResourcePanelShell', onDrop: function(element) {ReorderResources(element.id,<?=$ref?>);}, hoverclass: 'ReorderHover'});
					</script>
				<? } ?> 
			<? } ?>

			<? 
			} elseif ($display == "smallthumbs") { #Small Thumbs view
			?>

				<div class="ResourcePanelShellSmall" id="ResourceShell<?=$ref?>">			
					<div class="ResourcePanelSmall" onMouseOver="InfoBoxSetResource(<?=$ref?>);" onMouseOut="InfoBoxSetResource(0);">	
						<table border="0" class="ResourceAlignSmall"><tr><td>
							<a href="<?=$url?>" <? if (!$infobox) { ?>title="<?=str_replace(array("\"","'"),"",htmlspecialchars($result[$n]["title"]))?>"<? } ?>>
								<? if ($result[$n]["has_image"]==1) { ?>
									<img src="<?=get_resource_path($ref, "col", $generate_missing_dirs, $result[$n]["preview_extension"], $scramble_path, $amsDomain)?>" class="ImageBorder" />
								<? } else { ?>
									<img border=0 src="gfx/type<?=$result[$n]["resource_type"]?>_col.gif">
								<? } ?>
							</a>					
						</td></tr></table>
					<div class="ResourcePanelCountry"></div>
					<div class="clearer"></div>
				</div>	
				<div class="PanelShadow"></div>
			</div>
			 
			<?
			} else if ($display=="list") { # List view
			?>
				<!--List Item-->
				<tr onMouseOver="InfoBoxSetResource(<?=$ref?>);" onMouseOut="InfoBoxSetResource(0);">
				<td nowrap><div class="ListTitle"><a href="<?=$url?>"><?=highlightkeywords(tidy_trim($result[$n]["title"],45) . ((strlen(trim($result[$n]["country"]))>1)?(", " . tidy_trim(TidyList(i18n_get_translated($result[$n]["country"])),25)):""),$search) ?></a></div></td>
				<td><? if ($result[$n]["rating"]>0) { ?><div class="IconStar"> </div><? } else { ?>&nbsp;<? } ?></td>
				<td><?=$result[$n]["ref"]?></td>
				<td><? if (array_key_exists($result[$n]["resource_type"],$rtypes)) { ?><?=i18n_get_translated($rtypes[$result[$n]["resource_type"]])?><? } ?></td>
				<td><?=nicedate($result[$n]["creation_date"],false,true)?></td>
				<td ><div class="ListTools"><a href="<?=$url?>">&gt;&nbsp;<?=$lang["action-view"]?></div></td>
				</tr>
			<? }
			if(isset($result[$n]["current_wam_block_image"])) { echo '</div>'; }
			hook("customdisplaymode");
		
		} // END FOR LOOP
			
		if ($display=="list")
		{
			?>
			</table>
			</div>
			<?
		}
		?>
		<!--Key to Panel-->
<!--
		<div class="BottomInpageKey"> 
			<?=$lang["key"]?>:
		  	
		  	<? if ($orderbyrating) { ?>
		  	<div class="KeyStar"><?=$lang["verybestresources"]?></div>
		  	<? } ?>
		  	
		  	<? if ($allow_reorder) { ?>
			<div class="KeyReorder"><?=$lang["reorderresources"]?></div>
			<div class="KeyComment"><?=$lang["addorviewcomments"]?></div>
			<? } ?>
			
			<div class="KeyEmail"><?=$lang["emailresource"]?></div>
			<div class="KeyCollect"><?=$lang["addtocurrentcollection"]?></div>
			<div class="KeyPreview"><?=$lang["fullscreenpreview"]?></div>
		</div>
-->
		<?
		}
	else
		{
		?>
		<style type="text/css">
		body {
			margin: 0px;
			padding: 20px;
			background: url('<?=$baseurl?>/gfx/greyblu/interface/back.gif') repeat top;
			font-family: sans-serif;
		}
		</style>
		
		<div class="BasicsBox"> 
		  <div class="NoFind" style="border: 1px #131B32 solid; background-color: #385D90; padding: 0px 5px 10px 5px;">
			<p>No files were found for the specified type.</p>
			<a href="javascript:history.go(-1);" style="border: 1px #203B5D solid; background: transparent url('<?=$baseurl?>/gfx/greyblu/interface/resourcepanel.gif') repeat-x; padding: 3px 3px 2px 3px; font-weight: bold; color: #203B5D; text-decoration: none;">Go Back</a>
		  </div>
		</div>
		<?
		}
	?>
		  <!--Bottom Navigation - Archive, Saved Search plus Collection-->
		<div class="BottomInpageNav">
		<? if (($archive==0) && (strpos($search,"!")===false) && $archive_search) { 
			$arcresults=do_search($search,$restypes,$order_by,2,0);
			if (is_array($arcresults)) {$arcresults=count($arcresults);} else {$arcresults=0;}
			if ($arcresults>0) 
				{
				?>
				<div class="InpageNavLeftBlock"><a href="marcomet_widget_nav.php?widget_user=<? echo $_GET["widget_user"]; ?>&search=<?=urlencode($search)?>&archive=2&previousID=<?=$previousID?>&templateName=<?=$templateName?>&imageRef=<?=$imageRef?>&imageDPI=<?=$imageDPI?>&imageWidth=<?=$imageWidth?>&imageHeight=<?=$imageHeight?>&tempImageName=<?=$tempImageName?>&tempImagePath=<?=$tempImagePath?>&ignoreFile=<?=getval('ignoreFile', '')?>">&gt;&nbsp;<?=$lang["view"]?> <span class="Selected"><?=number_format($arcresults)?></span> <?=($arcresults==1)?$lang["match"]:$lang["matches"]?> <?=$lang["inthearchive"]?></a></div>
				<? 
				}
			else
				{
				?>
				<div class="InpageNavLeftBlock">&gt;&nbsp;<?=$lang["nomatchesinthearchive"]?></div>
				<? 
				}
			} ?>
			<? if (strpos($search,"!")===false) { ?>
			<!--
<div class="InpageNavLeftBlock"><a href="collections.php?addsearch=<?=urlencode($search)?>&restypes=<?=urlencode($restypes)?>&archive=<?=$archive?>" target="collections">&gt;&nbsp;<?=$lang["savethissearchtocollection"]?></a></div>
			<div class="InpageNavLeftBlock"><a href="collections.php?addsearch=<?=urlencode($search)?>&restypes=<?=urlencode($restypes)?>&archive=<?=$archive?>&mode=resources" target="collections">&gt;&nbsp;<?=$lang["savesearchitemstocollection"]?></a></div>
-->
			<? } ?>
			
			<? hook("resultsbottomtoolbar"); ?>
			
			<? 
			$url="marcomet_widget_nav.php?widget_user=". $_GET["widget_user"] ."&search=" . urlencode($search) . "&order_by=" . urlencode($order_by) . "&archive=" . $archive . "&restypes=" . $restypes . "&previousID=" . $previousID . '&templateName=' . $templateName. '&imageRef=' . $imageRef. '&imageDPI=' . $imageDPI. '&imageWidth=' . $imageWidth. '&imageHeight=' . $imageHeight. '&tempImageName=' . $tempImageName. '&tempImagePath=' . $tempImagePath . "&ignoreFile=" . getval('ignoreFile', '');

			if (isset($draw_pager)) {pager(false);} ?>
		</div>	
	<?	
	}
	else
	{
	?>
	<div class="BasicsBox"> 
		  <div class="NoFind">
			<p><?=$lang["mustspecifyonekeyword"]?></p>
		  </div>
	</div>
	<?
	}

# Add the infobox.
?>
<div id="InfoBox"><div id="InfoBoxInner"> </div></div>
</body>
</html>
