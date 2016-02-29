<?
include "include/db.php";
# External access support (authenticate only if no key provided, or if invalid access key provided)
$k=getvalescaped("k","");if (($k=="") || (!check_access_key(getvalescaped("ref",""),$k))) {include "include/marcomet_widget_authenticate.php";}
include "include/general.php";
include "include/search_functions.php";

$ref=getval("ref","");
$ext=getval("ext","");

$border=true;
if ($ext!="" && $ext!="gif" && $ext!="jpg" && $ext!="png") {$ext="jpg";$border=false;} # Supports types that have been created using ImageMagick

$search=getvalescaped("search","");
$offset=getvalescaped("offset","");
$order_by=getvalescaped("order_by","");
$archive=getvalescaped("archive","");
$restypes=getvalescaped("restypes","");
if (strpos($search,"!")!==false) {$restypes="";}

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

include "include/marcomet_widget_header.php";
?>

<p style="margin-left:7px; margin-right:7px;"><a href="marcomet_view.php?ref=<?=$ref?>&search=<?=urlencode($search)?>&offset=<?=$offset?>&order_by=<?=$order_by?>&archive=<?=$archive?>">&lt; <?=$lang["backtoview"]?></a>
<? if ($k=="") { ?>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
<a href="marcomet_preview.php?from=<?=getval("from","")?>&ref=<?=$ref?>&search=<?=urlencode($search)?>&offset=<?=$offset?>&order_by=<?=$order_by?>&archive=<?=$archive?>&go=previous">&lt;&nbsp;<?=$lang["previousresult"]?></a>
|
<a href="marcomet_widget_nav.php<? if (strpos($search,"!")!==false) {?>?search=<?=urlencode($search)?>&offset=<?=$offset?>&order_by=<?=$order_by?><? } ?>"><?=$lang["viewallresults"]?></a>
|
<a href="marcomet_preview.php?from=<?=getval("from","")?>&ref=<?=$ref?>&search=<?=urlencode($search)?>&offset=<?=$offset?>&order_by=<?=$order_by?>&archive=<?=$archive?>&go=next"><?=$lang["nextresult"]?>&nbsp;&gt;</a>
<? } ?>

</p>
<a href="<?=((getval("from","")=="search")?"marcomet_widget_nav.php?":"marcomet_view.php?ref=" . $ref . "&")?>search=<?=urlencode($search)?>&offset=<?=$offset?>&order_by=<?=$order_by?>&archive=<?=$archive?>&k=<?=$k?>"><img src="marcomet_download.php?ref=<?=$ref?>&size=scr&ext=<?=$ext?>&noattach=true&k=<?=$k?>" alt="" <? if ($border) { ?>style="border:1px solid white;"<? } ?> /></a>


<?
include "include/footer.php";
?>