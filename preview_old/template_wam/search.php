<?
include "include/db.php";
include "include/marcomet_widget_authenticate.php";
include "include/general.php";
include "include/search_functions.php";
include "include/collections_functions.php";

$search=getvalescaped("search","");
$auxsearch = "";

$addedids = array();

// Look for siteids in $search and strip leading zeros from them
$splitsearch = explode(" ", $search);
for($i=0;$i<count($splitsearch);$i++) {
	// Make sure this portion of the search is numeric and has a leading zero
	if(!is_numeric($splitsearch[$i]) || substr($splitsearch[$i], 0, 1)!="0") continue; 
	// Make sure what we are about to add to the end is not already in the search
	$dont = false;
	for($j=0;$j<count($splitsearch);$j++) {
		if(($splitsearch[$i]==$splitsearch[$j]) && (strlen($splitsearch[$j])==strlen(ltrim($splitsearch[$i], "0")))) $dont = true;
	}
	if(!$dont) {
		$splitsearch[$i] = ltrim($splitsearch[$i], "0");
	} else {
		$splitsearch[$i] = "";
	}
}

$splitsearch = implode(" ", $splitsearch);

# Append extra search parameters
$country=getvalescaped("country","");
if ($country!="") {$search=(($search=="")?"":join(", ",split_keywords($search)) . ", ") . "country:" . $country;}
$year=getvalescaped("year","");
if ($year!="") {$search=(($search=="")?"":join(", ",split_keywords($search)) . ", ") . "year:" . $year;}
$month=getvalescaped("month","");
if ($month!="") {$search=(($search=="")?"":join(", ",split_keywords($search)) . ", ") . "month:" . $month;}
$day=getvalescaped("day","");
if ($day!="") {$search=(($search=="")?"":join(", ",split_keywords($search)) . ", ") . "day:" . $day;}
$brand_type = getvalescaped("brand_type", "");
$initiative_type = getvalescaped("initiative_type", "");


function remove_element($a, $index) {
$tmp = array_splice($a,$index,1);
sort($a);
return $a;
}

function RemoveElement($Position, $Array)
{
for($Index = $Position; $Index < count($Array) - 1; $Index++)
$Array[$Index] = $Array[$Index + 1];
array_pop($Array);
return $Array;
} 

hook("searchstringprocessing");


if (strpos($search,"!")===false) {setcookie("search",$search);} # store the search in a cookie if not a special search
$offset=getvalescaped("offset",0);if (strpos($search,"!")===false) {setcookie("saved_offset",$offset);}
if ((!is_numeric($offset)) || ($offset<0)) {$offset=0;}
$order_by=getvalescaped("order_by","relevance");if (strpos($search,"!")===false) {setcookie("saved_order_by",$order_by);}
$display=getvalescaped("display","thumbs");setcookie("display",$display);
$per_page=getvalescaped("per_page",$default_perpage);setcookie("per_page",$per_page);
$archive=getvalescaped("archive",0);if (strpos($search,"!")===false) {setcookie("saved_archive",$archive);}
$jumpcount=0;

# Enable/disable the reordering feature. Just for collections for now.
$allow_reorder=false;
$collection_reorder_caption = true;
$viewing_collection = false;
if (substr($search,0,11)=="!collection" && $collection_reorder_caption)
	{
	$viewing_collection = true;
	# Check to see if this user can edit (and therefore reorder) this resource
	$collection=substr($search,11);
	$collectiondata=get_collection($collection);
	if (($userref==$collectiondata["user"]) || ($collectiondata["allow_changes"]==1) || (checkperm("h")))
		{
		$allow_reorder=true;
		}
	}


# fetch resource types from query string and generate a resource types cookie
if (getval("resetrestypes","")=="")
	{
	$restypes=getvalescaped("restypes","");
	}
else
	{
	$restypes="";
	reset($_GET);foreach ($_GET as $key=>$value)
		{
		if (substr($key,0,8)=="resource") {if ($restypes!="") {$restypes.=",";} $restypes.=substr($key,8);}
		}
	setcookie("restypes",$restypes);
	
	# This is a new search, log this activity
	if ($archive==2) {daily_stat("Archive search",0);} else {daily_stat("Search",0);}
	}
	
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
	$url="search.php?search=" . urlencode($search) . "&order_by=" . urlencode($order_by) . "&archive=" . $archive . "&offset=" . $offset;
	
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
	
	        $url .= '&form_sitephoto='.$sitephoto;
		$url .= '&form_sitephoto_1='.$sitephoto_1;
		$url .= '&form_sitephoto_2='.$sitephoto_2;
		$url .= '&form_personnel='.$personnel;
		$url .= '&form_city='.$city;
		$url .= '&form_state='.$state;
		$url .= '&form_firstname='.$firstname;
		$url .= '&form_lastname='.$lastname;
		$url .= '&form_businessunit='.$bunit;
		$url .= '&form_department='.$dept;
		$url .= '&form_jobtitle='.$jobtitle;
		$url .= "&brand_type=$brand_type";
		$url .= "&initiative_type=$initiative_type";
	
	// THIS MIGHT NEED TO BE TAKEN OUT
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


// Get the GET variables
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
// Set the form field to the previous values
$prevserviceval = array();
$prevserviceval["city"] = $city;
$prevserviceval["state"] = $state;
$prevserviceval["firstname"] = $firstname;
$prevserviceval["lastname"] = $lastname;
$prevserviceval["businessunit"] = $bunit;
$prevserviceval["department"] = $dept;
$prevserviceval["jobtitle"] = $jobtitle;

// Display the header with the loading image
if(getvalescaped("form_issiteuser","")!="yes") {
	$addLoadingImage = true;
}

include "include/header.php";


if (true) #search condition
	{
	$refs=array();
	#echo "search=$search";
	
	# Special query? Ignore restypes
	if (strpos($search,"!")!==false) {$restypes="";}
	
	# Story only? Display as list
	#if ($restypes=="2") {$display="list";}

	// Filter the results by the specified brand and initiative type
	if($brand_type=="anybrand") $brand_type = "";
	if($initiative_type=="anyinitiative") $initiative_type = "";

	$result = array();

	$restypes_first = "";
	$query1 = "";
	$query2 = "";
	$query3 = "";
	$query4 = "";
	$arrayrestypes = array();
	$result_count = 0;
	
	// This is the non-Service user search
	if(getvalescaped("form_issiteuser","")=="yes" || $viewing_collection) {
		$result=do_search($search,$restypes,$order_by,$archive,$per_page+$offset, $brand_type, $initiative_type, $filtersql=array(), $variants=getval("showvariants", ""));
		$result_count = count($result);
		if(isset($result[0])) {
			if($result_count==0 || is_string($result[0])) {
				$result=do_search($splitsearch,$restypes,$order_by,$archive,$per_page+$offset, $brand_type, $initiative_type, $filtersql=array(), $variants=getval("showvariants", ""));
				$result_count = count($result);
			}
		} else {
			if($result_count==0) {
				$result=do_search($splitsearch,$restypes,$order_by,$archive,$per_page+$offset, $brand_type, $initiative_type, $filtersql=array(), $variants=getval("showvariants", ""));
				$result_count = count($result);
			}
		}
		
	// This is the Service search
	} else {
	$result=do_search($search.' '.$state.' '.$city.' '.' '.$firstname.' '.$lastname.' '.$bunit.' '.$dept.' '.$jobtitle,$restypes,$order_by,$archive,$per_page+$offset, $brand_type, $initiative_type, $filtersql=array(), $variants=getval("showvariants", ""));
		$result_count = count($result);
		if(isset($result[0])) {
			if($result_count==0 || is_string($result[0])) {
				$result=do_search($splitsearch.' '.$state.' '.$city.' '.' '.$firstname.' '.$lastname.' '.$bunit.' '.$dept.' '.$jobtitle,$restypes,$order_by,$archive,$per_page+$offset, $brand_type, $initiative_type, $filtersql=array(), $variants=getval("showvariants", ""));
				$result_count = count($result);
			}
		} else {
			if($result_count==0) {
				$result=do_search($splitsearch.' '.$state.' '.$city.' '.' '.$firstname.' '.$lastname.' '.$bunit.' '.$dept.' '.$jobtitle,$restypes,$order_by,$archive,$per_page+$offset, $brand_type, $initiative_type, $filtersql=array(), $variants=getval("showvariants", ""));
				$result_count = count($result);
			}
		}
	}if($result_count==0 || !is_array($result)) {?>
    
    
    <div class="BasicsBox"> 
  <div class="NoFind">
    <p><?=$lang["searchnomatches"]?></p>
	<? if ($result!="")
	{
	?>
    <p><?=$lang["try"]?>:
    <? if(is_array($result)) {?>
    Check for misspelling or improper search terms.</p>
	<? } else { ?>
	<a href="search.php?search=<?=urlencode(strip_tags($result))?>"><?=stripslashes($result)?></a></p>
	<? }
	}
	else
	{
	?>
	<p><? if (strpos($search,"country:")!==false) { ?><p><?=$lang["tryselectingallcountries"]?> <? } 
	elseif (strpos($search,"year:")!==false) { ?><p><?=$lang["tryselectinganyyear"]?> <? } 
	elseif (strpos($search,"month:")!==false) { ?><p><?=$lang["tryselectinganymonth"]?> <? } 
	else 		{?><?=$lang["trybeinglessspecific"]?><? } ?> <?=$lang["enteringfewerkeywords"]?></p>
	<?
	}
  ?><? if(getvalescaped("form_issiteuser","")!="yes") { ?>
<!-- The results are loaded so remove the loading image -->
<script type="text/javascript">
document.getElementById("searchPageLoadingImage").style.display = "none";
//document.getElementById("searchPageLoadingImage").parentNode.removeChild(document.getElementById("searchPageLoadingImage"));
</script>
<? } ?>
  </div>
</div>
    
    
    <?
    
	exit;
    }
	
	$showStandards = false;
	for($i=0;$i<count($result);$i++) {
		if($result[$i]["resource_type"]=="5") {
			$showStandards = true;
			break;
		}
	}
	if($showStandards) {
	?>
	<style type="text/css">
		#brandStandardsBox {
			display: block !important;
		}
	</style>
	<?
	}
	
	
	if (is_array($result))
		{

			
		$url="search.php?search=" . urlencode($search) . "&order_by=" . $order_by . "&offset=" . $offset . "&archive=" . $archive;
		        $url .= '&form_sitephoto='.$sitephoto;
		$url .= '&form_sitephoto_1='.$sitephoto_1;
		$url .= '&form_sitephoto_2='.$sitephoto_2;
		$url .= '&form_personnel='.$personnel;
		$url .= '&form_city='.$city;
		$url .= '&form_state='.$state;
		$url .= '&form_firstname='.$firstname;
		$url .= '&form_lastname='.$lastname;
		$url .= '&form_businessunit='.$bunit;
		$url .= '&form_department='.$dept;
		$url .= '&form_jobtitle='.$jobtitle;
		$url .= "&brand_type=$brand_type";
		$url .= "&initiative_type=$initiative_type";
		
		?>
		<div class="TopInpageNav TopInpageNav">
		<div class="InpageNavLeftBlock"><?=$lang["youfound"]?>:<br /><span class="Selected"><?=number_format($result_count)?><?=($result_count==$max_results)?"+":""?></span> <?=$lang["youfoundresources"]?></div>
		<div class="InpageNavLeftBlock"><?=$lang["display"]?>:<br />
		<? if ($display=="thumbs") { ?><span class="Selected"><?=$lang["largethumbs"]?></span><? } else { ?><a href="<?=$url?>&display=thumbs"><?=$lang["largethumbs"]?></a><? } ?>&nbsp;|&nbsp; 
			<? if ($smallthumbs==true) { ?>		
		<? if ($display=="smallthumbs") { ?><span class="Selected"><?=$lang["smallthumbs"]?></span><? } else { ?><a href="<?=$url?>&display=smallthumbs"><?=$lang["smallthumbs"]?></a><? } ?>&nbsp; |&nbsp;<? } ?>
		<? if ($display=="list") { ?><span class="Selected"><?=$lang["list"]?></span><? } else { ?><a href="<?=$url?>&display=list"><?=$lang["list"]?></a><? } ?>&nbsp; |&nbsp;
		<? if(!isset($filter)) { ?> <? if ($display=="detail") { ?><span class="Selected"><?=$lang["detail"]?></span><? } else { ?><a href="<?=$url?>&display=detail"><?=$lang["detail"]?></a><? } ?><? } ?>
		&nbsp; |&nbsp;
		<? if ($display=="thumblist") { ?><span class="Selected"><?=$lang["thumblist"]?></span><? } else { ?><a href="<?=$url?>&display=thumblist"><?=$lang["thumblist"]?></a><? } ?>
		
	<? hook("adddisplaymode"); ?>	
		
		 </div>
		<?
		
		# order by
		#if (strpos($search,"!")===false)
		if (true) # Ordering enabled for collections/themes too now at the request of N Ward / Oxfam
			{
			$rel=$lang["relevance"];
			if (strpos($search,"!")!==false) {$rel=$lang["asadded"];}
			?>
			<div class="InpageNavLeftBlock "><?=$lang["sortorder"]?>:<br /><? if ($order_by=="relevance") {?><span class="Selected"><?=$rel?></span><? } else { ?><a href="search.php?search=<?=urlencode($search)?>&order_by=relevance&archive=<?=$archive?>"><?=$rel?></a><? } ?>
			&nbsp;|&nbsp;
			<? if ($order_by=="popularity") {?><span class="Selected"><?=$lang["popularity"]?></span><? } else { ?><a href="search.php?search=<?=urlencode($search)?>&order_by=popularity&archive=<?=$archive?>"><?=$lang["popularity"]?></a><? } ?>
			
			<? if ($orderbyrating) { ?>
			&nbsp;|&nbsp;
			<? if ($order_by=="rating") {?><span class="Selected"><?=$lang["rating"]?></span><? } else { ?><a href="search.php?search=<?=urlencode($search)?>&order_by=rating&archive=<?=$archive?>"><?=$lang["rating"]?></a><? } ?>
			<? } ?>
			
			&nbsp;|&nbsp;
			<? if ($order_by=="date") {?><span class="Selected"><?=$lang["date"]?></span><? } else { ?><a href="search.php?search=<?=urlencode($search)?>&order_by=date&archive=<?=$archive?>"><?=$lang["date"]?></a><? } ?>
			&nbsp;|&nbsp;
			<? if ($order_by=="colour") {?><span class="Selected"><?=$lang["colour"]?></span><? } else { ?><a href="search.php?search=<?=urlencode($search)?>&order_by=colour&archive=<?=$archive?>"><?=$lang["colour"]?></a><? } ?>
			<? if ($country_sort) { ?>
			&nbsp;|&nbsp;
			<? if ($order_by=="country") {?><span class="Selected"><?=$lang["country"]?></span><? } else { ?><a href="search.php?search=<?=urlencode($search)?>&order_by=country&archive=<?=$archive?>"><?=$lang["country"]?></a><? } ?>
			<? } ?>
			
			&nbsp;|&nbsp;
			<? if ($order_by=="file_extension") {?><span class="Selected"><?=$lang["file_extension"]?></span><? } else { ?><a href="search.php?search=<?=urlencode($search)?>&order_by=file_extension&archive=<?=$archive?>"><?=$lang["file_extension"]?></a><? } ?>
			
			&nbsp;|&nbsp;
			<? if ($order_by=="name") {?><span class="Selected"><?=$lang["name"]?></span><? } else { ?><a href="search.php?search=<?=urlencode($search)?>&order_by=name&archive=<?=$archive?>"><?=$lang["name"]?></a><? } ?>
			
			</div>
			<?
			}
			
		$results=$result_count;
	    $totalpages=ceil($results/$per_page);
	    if ($offset>$results) {$offset=0;}
    	$curpage=floor($offset/$per_page)+1;
        $url="search.php?search=" . urlencode($search) . "&order_by=" . urlencode($order_by) . "&archive=" . $archive . "&form_issiteuser=" . getval("form_issiteuser","");
        $url .= '&form_sitephoto='.$sitephoto;
		$url .= '&form_sitephoto_1='.$sitephoto_1;
		$url .= '&form_sitephoto_2='.$sitephoto_2;
		$url .= '&form_personnel='.$personnel;
		$url .= '&form_city='.$city;
		$url .= '&form_state='.$state;
		$url .= '&form_firstname='.$firstname;
		$url .= '&form_lastname='.$lastname;
		$url .= '&form_businessunit='.$bunit;
		$url .= '&form_department='.$dept;
		$url .= '&form_jobtitle='.$jobtitle;
		$url .= "&brand_type=$brand_type";
		$url .= "&initiative_type=$initiative_type";

		pager();
		$draw_pager=true;
		?></div>
		
		
			<td><?
			$brandstands = sql_query("SELECT default_text FROM default_text WHERE ref=-1 AND resource_type_field_id=99");?><?=$brandstands[0]["default_text"]?></td>
		<?		
		hook("beforesearchresults");

		if ($display=="detail" && !isset($filter))
			{
			?>
			<!--detail-->
			<div class="Listview">
			<table border="0" cellspacing="0" cellpadding="0" class="ListviewStyle">
	
			<!--Title row-->	
			<tr class="ListviewTitleStyle">
			<td><?=$lang["titleandcountry"]?></td>
			<td>&nbsp;</td>
			<td><?=$lang["id"]?></td>
			<td><?=$lang["type"]?></td>
			<td><?=$lang["date"]?> </td>
			<td><div class="ListTools">Actions</div></td>
			<td><?=$lang["colorspace"]?></td>
			<td><?=$lang["filetype"]?></td>
			<td><?=$lang["brand"]?> </td>
			<td>City</td>
			<? if(checkperm("v")) { ?>
				<td><?=$lang["site"]?> </td>
			<? } ?>
			</tr>
			<?
			}
		
		if ($display=="thumblist")
			{
			?>
			<!--list-->
			<div class="Listview">
			<table border="0" cellspacing="0" cellpadding="0" class="ListviewStyle">
	
			<!--Title row-->	
			<tr class="ListviewTitleStyle">
			<td></td>
			<td><?=$lang["titleandcountry"]?></td>
			<td>&nbsp;</td>
			<td><?=$lang["sitebrand"]?></td>
			<td><?=$lang["type"]?></td>
			<td><?=$lang["date"]?> </td>
			<td><div class="ListTools">Actions</div></td>
			</tr>
			<?
			}
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
			<td><?=$lang["sitebrand"]?></td>
			<td><?=$lang["type"]?></td>
			<td><?=$lang["date"]?> </td>
			<td><div class="ListTools">Actions</div></td>
			</tr>
			<?
			}
			
			
			
			
		// Set the results to the contents of a collection if !collection is set
		if (substr($search,0,11)=="!collection") $result=do_search($search,$restypes,$order_by,$archive,$per_page+$offset);			
			
			
			
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
					?><a  href="search.php?search=<?= urlencode(strip_tags($suggest[$n])) ?>"><?=stripslashes($suggest[$n])?></a><?
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
		//for ($n=$offset;(($n<count($result)) && ($n<($offset+$per_page)));$n++)	
		$offset2 = $offset;
		for ($n=$offset2;(($n<count($result)) && ($n<($offset2+$per_page)));$n++)				
			{
			$ref=$result[$n]["ref"];
			$url="view.php?ref=" . $ref . "&search=" . urlencode($search) . "&order_by=" . urlencode($order_by) . "&offset=" . urlencode($offset) . "&archive=" . $archive;
				        $url .= '&form_sitephoto='.$sitephoto;
		$url .= '&form_sitephoto_1='.$sitephoto_1;
		$url .= '&form_sitephoto_2='.$sitephoto_2;
		$url .= '&form_personnel='.$personnel;
		$url .= '&form_city='.$city;
		$url .= '&form_state='.$state;
		$url .= '&form_firstname='.$firstname;
		$url .= '&form_lastname='.$lastname;
		$url .= '&form_businessunit='.$bunit;
		$url .= '&form_department='.$dept;
		$url .= '&form_jobtitle='.$jobtitle;
		$url .= "&brand_type=$brand_type";
		$url .= "&initiative_type=$initiative_type";
			
			
			$url = "javascript:void(0);";
			 ?>
			
				<?	
				if ($display=="thumbs") { #Thumbnails view
				?>
			 
<? if (!hook("renderresultthumb")) { ?>

	<!--Resource Panel-->
		<div class="ResourcePanelShell" id="ResourceShell<?=$ref?>">
		<div class="ResourcePanel" onMouseOver="InfoBoxSetResource(<?=$ref?>);" onMouseOut="InfoBoxSetResource(0);">
		
<? if (!hook("renderimagethumb")) { ?>			
		
		<table border="0" class="ResourceAlign<? if (in_array($result[$n]["resource_type"],$videotypes)) { ?> IconVideo<? } ?>"><tr><td>
		<a href="<?=$url?>" <? if (!$infobox) { ?>title="<?=str_replace(array("\"","'"),"",htmlspecialchars($result[$n]["title"]))?>"<? } ?>><? if ($result[$n]["has_image"]==1) { ?><img width="<?=$result[$n]["thumb_width"]?>" height="<?=$result[$n]["thumb_height"]?>" src="<?=get_resource_path($ref,"thm",false,$result[$n]["preview_extension"])?>" class="ImageBorder" /><? } else { ?><img border=0 src="gfx/type<?=$result[$n]["resource_type"]?>.gif"><? } ?></a>
			</td>
			</tr></table>
<? } ?> <!-- END HOOK Renderimagethumb-->	
			
<? if (!hook("rendertitlethumb")) { ?>			

			<div class="ResourcePanelInfo"><a href="<?=$url?>" <? if (!$infobox) { ?>title="<?=str_replace(array("\"","'"),"",htmlspecialchars($result[$n]["title"]))?>"<? } ?>><?=highlightkeywords(htmlspecialchars(tidy_trim($result[$n]["title"],22)),$search)?></a>&nbsp;</div>

<? } ?> <!-- END HOOK Rendertitlethumb -->			
			
			<div class="ResourcePanelCountry"><? if (!$allow_reorder) { # Do not display the country if reordering (to create more room) ?><?=highlightkeywords(tidy_trim(TidyList(i18n_get_translated($result[$n]["country"])),14),$search)?><? } ?>&nbsp;</div>				
			<span class="IconPreview"><a href="preview.php?from=search&ref=<?=$ref?>&ext=<?=$result[$n]["preview_extension"]?>&search=<?=urlencode($search)?>&offset=<?=$offset?>&order_by=<?=$order_by?>&archive=<?=$archive?>" <? if (!$infobox) { ?>title="<?=$lang["fullscreenpreview"]?>"<? } ?>><img src="gfx/interface/sp.gif" alt="" width="22" height="12" /></a></span>
			<? if (!checkperm("nh")) { ?><span class="IconCollect"><a href="collections.php?add=<?=$ref?>&nc=<?=time()?>&search=<?=urlencode($search)?>" target="collections" <? if (!$infobox) { ?>title="<?=$lang["addtocurrentcollection"]?>"<? } ?>><img src="gfx/interface/sp.gif" alt="" width="22" height="12" /></a></span><? } ?>
			<span class="IconEmail"><a href="resource_email.php?ref=<?=$ref?>" <? if (!$infobox) { ?>title="<?=$lang["emailresource"]?>"<? } ?>><img src="gfx/interface/sp.gif" alt="" width="16" height="12" /></a></span>
			<? if ($result[$n]["rating"]>0) { ?><div class="IconStar"></div><? } ?>
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
			<a href="<?=$url?>" <? if (!$infobox) { ?>title="<?=str_replace(array("\"","'"),"",htmlspecialchars($result[$n]["title"]))?>"<? } ?>><? if ($result[$n]["has_image"]==1) { ?><img  src="<?=get_resource_path($ref,"col",false,$result[$n]["preview_extension"])?>" class="ImageBorder" /><? } else { ?><img border=0 src="gfx/type<?=$result[$n]["resource_type"]?>_col.gif"><? } ?></a>
			</td>
			</tr></table>
			<div class="ResourcePanelCountry"><span class="IconPreview"><a href="preview.php?from=search&ref=<?=$ref?>&ext=<?=$result[$n]["preview_extension"]?>&search=<?=urlencode($search)?>&offset=<?=$offset?>&order_by=<?=$order_by?>&archive=<?=$archive?>" <? if (!$infobox) { ?>title="<?=$lang["fullscreenpreview"]?>"<? } ?>><img src="gfx/interface/sp.gif" alt="" width="22" height="12" /></a></span><? if (!checkperm("nh")) { ?><span class="IconCollect"><a href="collections.php?add=<?=$ref?>&nc=<?=time()?>&search=<?=urlencode($search)?>" target="collections" <? if (!$infobox) { ?>title="<?=$lang["addtocurrentcollection"]?>"<? } ?>><img src="gfx/interface/sp.gif" alt="" width="22" height="12" /></a></span><? } ?></div>
<div class="clearer"></div></div>	
<div class="PanelShadow"></div></div>
			 
			<?
			} else if ($display=="list") { # List view
			?>
			<!--List Item-->
			<tr onMouseOver="InfoBoxSetResource(<?=$ref?>);" onMouseOut="InfoBoxSetResource(0);">
			<td><div class="ListTitle"><a href="<?=$url?>"><?=highlightkeywords(tidy_trim($result[$n]["title"],45) . ((strlen(trim($result[$n]["country"]))>1)?(", " . tidy_trim(TidyList(i18n_get_translated($result[$n]["country"])),25)):""),$search) ?></a></div></td>
			<td><? if ($result[$n]["rating"]>0) { ?><div class="IconStar"> </div><? } else { ?>&nbsp;<? } ?></td>
			<td>
				<?
				$siteid = sql_query("SELECT value FROM resource_data WHERE resource=$ref AND resource_type_field=60 OR resource=$ref AND resource_type_field=61 OR resource=$ref AND resource_type_field=64 OR resource=$ref AND resource_type_field=65");
				if($siteid[0]["value"]=="na") {
					$idf_brand = sql_query("SELECT value FROM resource_data WHERE resource=$ref AND resource_type_field=63");
					echo $idf_brand[0]["value"];
				} else {
					echo $siteid[0]["value"];
				}
				?>
			</td>
			<td><? if (array_key_exists($result[$n]["resource_type"],$rtypes)) { ?><?=i18n_get_translated($rtypes[$result[$n]["resource_type"]])?><? } ?></td>
			<td><?=nicedate($result[$n]["creation_date"],false,true)?></td>
			<td ><div class="ListTools"><? if (!checkperm("nh")) { ?><a href="<?=$url?>">&gt;&nbsp;<?=$lang["action-view"]?></a> &nbsp;<a href="collections.php?add=<?=$ref?>&nc=<?=time()?>&search=<?=urlencode($search)?>" target="collections">&gt;&nbsp;<?=$lang["action-addtocollection"]?></a><? } ?> &nbsp;<a href="resource_email.php?ref=<?=$ref?>">&gt;&nbsp;<?=$lang["action-email"]?></a></div></td>
			</tr>
			<?
			} else if ($display=="thumblist") { # List view
			?>
			<!--List Item-->
			<tr onMouseOver="InfoBoxSetResource(<?=$ref?>);" onMouseOut="InfoBoxSetResource(0);">
			<td><a href="<?=$url?>" <? if (!$infobox) { ?>title="<?=str_replace(array("\"","'"),"",htmlspecialchars($result[$n]["title"]))?>"<? } ?>><? if ($result[$n]["has_image"]==1) { ?><img  src="<?=get_resource_path($ref,"col",false,$result[$n]["preview_extension"])?>" class="ImageBorder" /><? } else { ?><img border=0 src="gfx/type<?=$result[$n]["resource_type"]?>_col.gif"><? } ?></a></td>
			<td><div class="ListTitle"><a href="<?=$url?>"><?=highlightkeywords(tidy_trim($result[$n]["title"],45) . ((strlen(trim($result[$n]["country"]))>1)?(", " . tidy_trim(TidyList(i18n_get_translated($result[$n]["country"])),25)):""),$search) ?></a></div></td>
			<td><? if ($result[$n]["rating"]>0) { ?><div class="IconStar"> </div><? } else { ?>&nbsp;<? } ?></td>
			<td>
				<?
				$siteid = sql_query("SELECT value FROM resource_data WHERE resource=$ref AND resource_type_field=60 OR resource=$ref AND resource_type_field=61 OR resource=$ref AND resource_type_field=64 OR resource=$ref AND resource_type_field=65");
				if(isset($siteid[0])) {
				
				if($siteid[0]["value"]=="na") {
					$idf_brand = sql_query("SELECT value FROM resource_data WHERE resource=$ref AND resource_type_field=63");
					echo $idf_brand[0]["value"];
				} else {
					echo $siteid[0]["value"];
					$idf_brand = sql_query("SELECT value FROM resource_data WHERE resource=$ref AND resource_type_field=63");
					echo "/".$idf_brand[0]["value"];
				}
				
				} else {
					$idf_brand = sql_query("SELECT value FROM resource_data WHERE resource=$ref AND resource_type_field=63");
					if(isset($idf_brand[0])) echo $idf_brand[0]["value"];
				}
				
				?>
			</td>
			<td><? if (array_key_exists($result[$n]["resource_type"],$rtypes)) { ?><?=i18n_get_translated($rtypes[$result[$n]["resource_type"]])?><? } ?></td>
			<td><?=nicedate($result[$n]["creation_date"],false,true)?></td>
			<td ><div class="ListTools"><? if (!checkperm("nh")) { ?><a href="<?=$url?>">&gt;&nbsp;<?=$lang["action-view"]?></a> &nbsp;<a href="collections.php?add=<?=$ref?>&nc=<?=time()?>&search=<?=urlencode($search)?>" target="collections">&gt;&nbsp;<?=$lang["action-addtocollection"]?></a> &nbsp;<? } ?><a href="resource_email.php?ref=<?=$ref?>">&gt;&nbsp;<?=$lang["action-email"]?></a></div></td>
			</tr>
			<?
			} else if ($display=="detail") { # List Detail
			?>
			<!--Detail Item-->
			<tr onMouseOver="InfoBoxSetResource(<?=$ref?>);" onMouseOut="InfoBoxSetResource(0);">
			<td><div class="ListTitle"><a href="<?=$url?>"><?=highlightkeywords(tidy_trim($result[$n]["title"],45) . ((strlen(trim($result[$n]["country"]))>1)?(", " . tidy_trim(TidyList(i18n_get_translated($result[$n]["country"])),25)):""),$search) ?></a></div></td>
			<td><? if ($result[$n]["rating"]>0) { ?><div class="IconStar"> </div><? } else { ?>&nbsp;<? } ?></td>
			<td><?=$result[$n]["ref"]?></td>
			<td><? if (array_key_exists($result[$n]["resource_type"],$rtypes)) { ?><?=i18n_get_translated($rtypes[$result[$n]["resource_type"]])?><? } ?></td>
			<td><?=nicedate($result[$n]["creation_date"],false,true)?></td>
			<td ><div class="ListTools"><? if (!checkperm("nh")) { ?><a href="<?=$url?>">&gt;&nbsp;<?=$lang["action-view"]?></a> &nbsp;<a href="collections.php?add=<?=$ref?>&nc=<?=time()?>&search=<?=urlencode($search)?>" target="collections">&gt;&nbsp;<?=$lang["action-addtocollection"]?></a> &nbsp;<? } ?><a href="resource_email.php?ref=<?=$ref?>">&gt;&nbsp;<?=$lang["action-email"]?></a></div></td>
			
			<td><? $s_s_result = sql_query("SELECT value FROM resource_data WHERE resource = ".$result[$n]["ref"]." AND resource_type_field = 67"); if(isset($s_s_result[0])) {?><?=$s_s_result[0]["value"]?><? } else { ?>RGB<? } ?></td>
			<td><?=$result[$n]["file_extension"]?></td>
			
			<td><? $s_s_result = sql_query("SELECT value FROM resource_data WHERE resource = ".$result[$n]["ref"]." AND resource_type_field = 63"); if(isset($s_s_result[0])) {?><?=$s_s_result[0]["value"]?><? } else { ?>none<? } ?></td>
			
			
			<td><? $s_s_result = sql_query("SELECT value FROM resource_data WHERE resource = ".$result[$n]["ref"]." AND resource_type_field = 80 OR resource = ".$result[$n]["ref"]." AND resource_type_field = 82"); if(isset($s_s_result[0])) {?><?=$s_s_result[0]["value"]?><? } else { ?>none<? } ?></td>
			
			<? if(checkperm("v")) { ?>
			<td><? $s_s_result = sql_query("SELECT value FROM resource_data WHERE resource = ".$result[$n]["ref"]." AND resource_type_field = 60 OR resource_type_field = 61 OR resource_type_field = 64 OR resource_type_field = 65"); if(isset($s_s_result[0])) {?><?=$s_s_result[0]["value"]?><? } else { ?>none<? } ?></td>
			<? } ?>
			
			
			</tr>
			<?
			}
		
		
		hook("customdisplaymode");
		
			}
			
		if ($display=="list" || $display=="detail" || $display=="thumblist")
			{
			?>
	    	</table>
			</div>
			<?
			}
		?>
		<!--Key to Panel-->
		<div class="BottomInpageKey" style="display: none;"> 
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
		<?
		}
	else
		{
		?>
		<div class="BasicsBox"> 
		  <div class="NoFind">
		    <p><?=$lang["searchnomatches"]?></p>
    		<? if ($result!="")
			{
			?>
		    <p><?=$lang["try"]?>: <a href="search.php?search=<?=urlencode(strip_tags($result))?>"><?=stripslashes($result)?></a></p>
   			<?
			}
			else
			{
			?>
			<p><? if (strpos($search,"country:")!==false) { ?><p><?=$lang["tryselectingallcountries"]?> <? } 
			elseif (strpos($search,"year:")!==false) { ?><p><?=$lang["tryselectinganyyear"]?> <? } 
			elseif (strpos($search,"month:")!==false) { ?><p><?=$lang["tryselectinganymonth"]?> <? } 
			else 		{?><?=$lang["trybeinglessspecific"]?><? } ?> <?=$lang["enteringfewerkeywords"]?></p>
   			<?
			}
		  ?>
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
				<div class="InpageNavLeftBlock"><a href="search.php?search=<?=urlencode($search)?>&archive=2">&gt;&nbsp;<?=$lang["view"]?> <span class="Selected"><?=number_format($arcresults)?></span> <?=($arcresults==1)?$lang["match"]:$lang["matches"]?> <?=$lang["inthearchive"]?></a></div>
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
			<? if (!checkperm("nh")) { ?><div class="InpageNavLeftBlock"><a href="collections.php?addsearch=<?=urlencode($search)?>&restypes=<?=urlencode($restypes)?>&archive=<?=$archive?>" target="collections">&gt;&nbsp;<?=$lang["savethissearchtocollection"]?></a></div>
			<div class="InpageNavLeftBlock"><a href="collections.php?addsearch=<?=urlencode($search)?>&restypes=<?=urlencode($restypes)?>&archive=<?=$archive?>&mode=resources" target="collections">&gt;&nbsp;<?=$lang["savesearchitemstocollection"]?></a></div><? } ?>
			<? } ?>
			<div class="InpageNavLeftBlock"><a href="search_batch.php?search=<?=urlencode($search)?>&restypes=<?=urlencode($restypes)?>&archive=<?=$archive?>&mode=resources&order_by=<?=urlencode($order_by)?>&offset=<?=urlencode($offset)?>&per_page=<?=urlencode($per_page)?>&<? 
			
	echo "&brand_type=$brand_type";
	echo "&initiative_type=$initiative_type";
	// Get the GET variables
	echo "&form_sitephoto=$sitephoto";
	echo "&form_sitephoto_1=$sitephoto_1";
	echo "&form_sitephoto_2=$sitephoto_2";
	echo "&form_state=$state";
	echo "&form_city=$city";
	echo "&form_personnel=$personnel";
	echo "&form_firstname=$firstname";
	echo "&form_lastname=$lastname";
	echo "&form_businessunit=$bunit";
	echo "&form_department=$dept";
	echo "&form_jobtitle=$jobtitle";
	echo "&form_issiteuser=".getvalescaped("form_issiteuser","");
			
			
			 ?>">&gt;&nbsp;<? if($username=="Service") { echo "Email Found Files"; } else { echo $lang["executebatchjobonsearchitems"]; }?></a></div>
			<? hook("resultsbottomtoolbar"); ?>
			
			<? 
	        $url="search.php?search=" . urlencode($search) . "&order_by=" . urlencode($order_by) . "&archive=" . $archive . "&form_issiteuser=" . getval("form_issiteuser","");	

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


<? if(getvalescaped("form_issiteuser","")!="yes") { ?>
<!-- The results are loaded so remove the loading image -->
<script type="text/javascript">
document.getElementById("searchPageLoadingImage").style.display = "none";
//document.getElementById("searchPageLoadingImage").parentNode.removeChild(document.getElementById("searchPageLoadingImage"));
</script>
<? } ?>

<? 
include "include/footer.php";
?>
