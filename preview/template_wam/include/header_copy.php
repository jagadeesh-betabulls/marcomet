<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<title><?=htmlspecialchars($applicationname)?></title>
<link href="<?=$baseurl?>/css/wrdsnpics_copy.css" rel="stylesheet" type="text/css" media="screen,projection,print" />
<?
$styleindicator = "whitegry";
if(!(isset($_COOKIE["marcomet_photoserver_style"]))) {
}
else {
$styleindicator = $_COOKIE["marcomet_photoserver_style"];
}
?>
<link href="<?=$baseurl?>/css/Col-greyblufixed.css" rel="stylesheet" type="text/css" media="screen,projection,print" id="colourcss" />
<!--[if IE 7]> <link href="<?=$baseurl?>/css/wrdsnpicsIE.css" rel="stylesheet" type="text/css"  media="screen,projection,print" /> <![endif]-->	
<!--[if lte IE 6]> <link href="<?=$baseurl?>/css/wrdsnpicsIE.css" rel="stylesheet" type="text/css"  media="screen,projection,print" /> <![endif]-->
<!--[if lte IE 5.6]> <link href="<?=$baseurl?>/css/wrdsnpicsIE5.css" rel="stylesheet" type="text/css"  media="screen,projection,print" /> <![endif]-->
<script type="text/javascript" src="minmax.js"></script>  
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
# if (!top.collections && '<?=$frameless?>'!='1' && '<?=$breakout?>'=='1') {document.location='<?=$baseurl?>/index.php?url=' + escape(document.location);} // Missing frameset? redirect to frameset.
</script>
<? } ?>

<? hook("headblock"); ?>

</head>
<body <? if (isset($bodyattribs)) { ?><?=$bodyattribs?><? } ?>>
<div id="onLoadTab" onLoad="javascript:alert("dd");">a</div>
<? hook("bodystart"); ?>
<?
# Commented as it was causing IE to 'jump'
# <body onLoad="if (document.getElementById('searchbox')) {document.getElementById('searchbox').focus();}">
?>

<!--Global Header-->
<?
if (($pagename=="terms") && (getval("url","")=="index.php")) {$loginterms=true;} else {$loginterms=false;}
if ($pagename!="preview") { ?>
<div id="AltHeader" style="display:<? if ((checkperm("t"))!=false){ ?>none<? } ?>"><img src="/images/spacer.gif" height="25"></div>
<div id="Header" style="display:<? if ((checkperm("t"))==false){ ?>none<? } ?>">
<? 
if (!isset($allow_password_change)) {$allow_password_change=true;}

if (isset($username) && ($pagename!="login") && ($loginterms==false)) { ?>
<div id="HeaderNav1" class="HorizontalNav ">

<? if (isset($anonymous_login) && ($username==$anonymous_login))
	{
	?>
	<ul>
	<li><a href="<?=$baseurl?>/login.php" target="_top"><?=$lang["login"]?></a></li>
	<li><a href="<?=$baseurl?>/contact.php"><?=$lang["contactus"]?></a></li>
	</ul>
	<?
	}
else
	{
	?>
	<ul>
	<li><? if ($allow_password_change) { ?><a href="<?=$baseurl?>/change_password.php"><? } ?><?=$userfullname?><? if ($allow_password_change) { ?></a><? } ?></li>
	<li><a href="<?=$baseurl?>/login.php?logout=true&nc=<?=time()?>" target="_top"><?=$lang["logout"]?></a></li>
	<?hook("addtologintoolbarmiddle");?>
	<li><a href="<?=$baseurl?>/contact.php"><?=$lang["contactus"]?></a></li>
	</ul>
	<?
	}
?>
</div>


<div id="HeaderNav2" class="HorizontalNav HorizontalWhiteNav">
		
		<ul>
		<? if (!$use_theme_as_home) { ?><li><a href="<?=$baseurl?>/home.php" target="main"><?=$lang["home"]?></a></li><? }  ?>
		
		<? if 	(
			(checkperm("s"))
		&&
			(
				(strlen(@$_COOKIE["search"])>0)
			||
				((strlen(@$search)>0) && (strpos($search,"!")===false))
			)
		)
		{?><li><a target="main" href="<?=$baseurl?>/search.php"><?=$lang["searchresults"]?></a></li><? } ?>
		<? if (checkperm("s")) { ?><li><a target="main" href="<?=$baseurl?>/themes.php"><?=$lang["themes"]?></a></li><? } ?>
		<? if (checkperm("s") && $recent_link) { ?><li><a target="main" href="<?=$baseurl?>/search.php?search=<?=urlencode("!last1000")?>"><?=$lang["recent"]?></a></li><? } ?>
		<? if (checkperm("s") && $mycollections_link) { ?><li><a target="main" href="<?=$baseurl?>/collection_manage.php"><?=$lang["mycollections"]?></a></li><? } ?>
		<? if (checkperm("d")) { ?><li><a target="main" href="<?=$baseurl?>/contribute.php"><?=$lang["mycontributions"]?></a></li><? } ?>
		<? if (($research_request) && (checkperm("s")) && (checkperm("q"))) { ?><li><a target="main" href="<?=$baseurl?>/research_request.php"><?=$lang["researchrequest"]?></a></li><? } ?>
		
		<? if ($speedtagging && checkperm("s") && checkperm("n")) { ?><li><a target="main" href="<?=$baseurl?>/tag.php"><?=$lang["tagging"]?></a></li><? } ?>
		
		<li><a target="main" href="<?=$baseurl?>/help.php"><?=$lang["helpandadvice"]?></a></li>
		<? if (checkperm("t")) { ?><li><a target="main" href="<?=$baseurl?>/team_home.php"><?=$lang["teamcentre"]?></a></li><? } ?>

<? hook("toptoolbaradder"); ?>

		</ul>

		
</div>

<? }  else { # Empty Header?>
<div id="HeaderNav1" class="HorizontalNav ">&nbsp;</div>
<div id="HeaderNav2" class="HorizontalNav HorizontalWhiteNav">&nbsp;</div>
<? } ?>
</div>
<? } ?>

<? hook("headerbottom"); ?>

<div class="clearer"></div>
<? if (checkperm("s") && ($pagename!="search_advanced") && ($pagename!="preview") && ($pagename!="admin_header") && ($loginterms==false)) { ?>
<? include "searchbar.php"; ?>
<? } ?>

<? 
# Determine which content holder div to use
if (($pagename=="login") || ($pagename=="user_password") || ($pagename=="user_request")) {$div="CentralSpaceLogin";}
else {$div="CentralSpace";}
?>
<!--Main Part of the page-->
<? if (($pagename!="login") && ($pagename!="user_password") && ($pagename!="user_request")) { ?><div id="CentralSpaceContainer"><? } ?>
<div id="<?=$div?>">