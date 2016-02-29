<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<title><?=htmlspecialchars($applicationname)?></title>
<link href="<?=$baseurl?>/css/wrdsnpics.css" rel="stylesheet" type="text/css" media="screen,projection,print" />
<?
$styleindicator = "whitegry";
if(!(isset($_COOKIE["marcomet_photoserver_style"]))) {
}
else {
	if($_COOKIE["marcomet_photoserver_style"]=="mail") {
		$styleindicator = "wam";
	} else {
		$styleindicator = "wam";
	}
}
?>
<link href="<?=$baseurl?><?="/css/Col-" . $styleindicator?>.css" rel="stylesheet" type="text/css" media="screen,projection,print" id="colourcss" />
<!--[if IE 7]> <link href="<?=$baseurl?>/css/wrdsnpicsIE.css" rel="stylesheet" type="text/css"  media="screen,projection,print" /> <![endif]-->	
<!--[if lte IE 6]> <link href="<?=$baseurl?>/css/wrdsnpicsIE.css" rel="stylesheet" type="text/css"  media="screen,projection,print" /> <![endif]-->
<!--[if lte IE 5.6]> <link href="<?=$baseurl?>/css/wrdsnpicsIE5.css" rel="stylesheet" type="text/css"  media="screen,projection,print" /> <![endif]-->
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

<?=$headerinsert?>

<? if (($pagename!="terms") && ($pagename!="change_language") && ($pagename!="login") && ($pagename!="user_request") && ($pagename!="user_password") && ($pagename!="done") && (getval("k","")=="")) { ?>
<script language="Javascript">
 if (!top.collections && '<?=$frameless?>'!='1' && '<?=$breakout?>'=='1') {document.location='<?=$baseurl?>/index.php?url=' + escape(document.location);} // Missing frameset? redirect to frameset.
 function setTabSideBar(){
 
 }
</script>
<? } ?>

<? hook("headblock"); ?>

</head>
<body style="margin-left:20px;" <? if (isset($bodyattribs)) { ?><?=$bodyattribs?><? } ?> onLoad="javascript:setTabSideBar();">

<? if(isset($addLoadingImage)) { if($addLoadingImage) {?><div style="position: absolute; left: 100px; top: 100px; z-index: 2; margin: 100px 200px 200px 200px; border: 3px solid black; width: 100px; height: 100px; background: #FFF url('search_page_loading.gif') center no-repeat;" id="searchPageLoadingImage"></div></div><? }} ?>

<? hook("bodystart"); ?>
<?
# Commented as it was causing IE to 'jump'
# <body onLoad="if (document.getElementById('searchbox')) {document.getElementById('searchbox').focus();}">
?>

<!--Global Header-->
<?
if (($pagename=="terms") && (getval("url","")=="index.php")) {$loginterms=true;} else {$loginterms=false;}
if ($pagename!="preview") { ?>
<div id="Header" style="display:<? if ((checkperm("t"))==false){ ?>none<? } ?>">
<? 
if (!isset($allow_password_change)) {$allow_password_change=true;}

if (isset($username) && ($pagename!="login") && ($loginterms==false)) { ?>
<? if (isset($anonymous_login) && ($username==$anonymous_login))
	{
	?>

	<?
	}
else
	{
	//if($usergroup==3){
	?>

	<?
	}
	//}
?>


<? }  else { # Empty Header?>
<div id="HeaderNav1" class="HorizontalNav ">&nbsp;</div>
<div id="HeaderNav2" class="HorizontalNav HorizontalWhiteNav">&nbsp;</div>
<? } ?>
</div>
<? } ?>

<? hook("headerbottom"); ?>

<div class="clearer"></div>
<? if (checkperm("s") && ($pagename!="search_advanced") && ($pagename!="preview") && ($pagename!="admin_header") && ($loginterms==false)) { ?>
<? /*include "searchbar.php"; */?>
<? } ?>

<? 
# Determine which content holder div to use
if (($pagename=="login") || ($pagename=="user_password") || ($pagename=="user_request")) {$div="CentralSpaceLogin";}
else {$div="CentralSpace";}
?>
<!--Main Part of the page-->
<? if (($pagename!="login") && ($pagename!="user_password") && ($pagename!="user_request")) { ?><div id="CentralSpaceContainer"><? } ?>
<div id="<?=$div?>">