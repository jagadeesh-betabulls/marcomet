<?
include "include/config.php";
include "include/db.php";
include "include/marcomet_widget_authenticate.php"; if (!checkperm("c") && !checkperm("d")) {exit ("Permission denied.");}
include "include/general.php";
include "include/resource_functions.php";

include "drop_parser.php";

include "include/image_processing.php";
global $usersearchfilter;

# Archive state
$archive=getvalescaped("archive",0);


//if (!checkperm("e" . $archive)) {exit ("Permission denied.");}

$status="";
$maxsize="200000000";

$resource_type=getvalescaped("resource_type","");
$brand=getvalescaped("brand","");


if ($resource_type!="") {
	// handle posts
	if (array_key_exists("userfile",$_FILES)) {
		
		$resource_type_name = sql_query("SELECT * FROM resource_type WHERE ref = $resource_type");
		$resource_type_name = $resource_type_name[0]["name"];
		if(!$resource_type_name) {
			$status = "Invalid resource type.";
		} else {
		
			// Work out which file has been posted
			if (isset($_FILES['userfile'])) {$processfile=$_FILES['userfile'];} else {$processfile=$_FILES['Filedata'];}
			
			//['tmp_name'], $processfile['name']
			global $drop_folders_directory;
			$original_filename = basename($processfile['name']);
			
			
			if($resource_type==1 || $resource_type==2) {
				if(!is_dir($drop_folders_directory."Site Photos/")) mkdir($drop_folders_directory."Site Photos/");
				$original_filepath = $drop_folders_directory."Site Photos/".$original_filename;
			} else {
				if(!is_dir($drop_folders_directory.$resource_type_name."/".$brand)) mkdir($drop_folders_directory.$resource_type_name."/".$brand);
				$original_filepath = $drop_folders_directory.$resource_type_name."/".$brand."/".$original_filename;
			}
			$filename = $original_filename;
			$safe_path = str_replace("\"", "\\\"", str_replace("\\", "\\\\", $original_filepath));
			
			if(!move_uploaded_file($processfile['tmp_name'], $original_filepath))  {
				$status = "An error occured while uploading.";
			} else {
				if(!is_file($original_filepath)) {
					$status = "An error occured while uploading.";
				} else {	
					if ($filename!="") {
						global $created_by_ref;
						$created_by_ref = $userref;
						$ref=parse_drop_filename($original_filepath, true);
						if ($ref<10) {
							// Check the return code of parse_uploaded_file and display the corresponding error message.
							//$status="File upload error. Please check the size of the file you are trying to upload.";
							$status = "Parsing error.";
						 } else {
								// Log this			
								daily_stat("Resource upload",$ref);
								resource_log($ref,"u",0);
								$status="Your file has been uploaded.";
								redirect("edit.php?ref=" . $ref . "&refresh=yes");
						 }
					}
				}
				
			}
		}
	}
}

include "include/header.php";
?>

<div class="BasicsBox">
<h1><?=$lang["createnewresource"]?></h1>

<form method="post" class="form" enctype="multipart/form-data">
<input type=hidden name="archive" value="<?=$archive?>">


<div class="Question">
<?
if($usersearchfilter!="") {
$brand = split("brand=", $usersearchfilter);
$brand = $brand[1];
?>

<input type=hidden name="brand" value="<?=$brand?>">

<? } else { ?>

<div class="Inline"><label for="brand">Brand: </label><select name="brand" class="shrtwidth">
<?
$brands=sql_query("SELECT distinct value FROM resource_data WHERE resource_type_field = 63");
if($brands) {
for ($n=0;$n<count($brands);$n++)
	{
	?><option value="<?=$brands[$n]["value"]?>"><?=$brands[$n]["value"]?></option><?
	}
}
?></select></div>

<? } ?>
<br/><br/>

<label for="resourcetype"><?=$lang["resourcetype"]?></label>
<div class="tickset">
<div class="Inline"><select name="resource_type" class="shrtwidth">
<?
$types=get_resource_types();
for ($n=0;$n<count($types);$n++)
	{
	?><option value="<?=$types[$n]["ref"]?>"><?=$types[$n]["name"]?></option><?
	}
?></select></div>
<? /*<div class="Inline"><input name="Submit" type="submit" value="&nbsp;&nbsp;<?=$lang["create"]?>&nbsp;&nbsp;" /></div>*/ ?>
</div>

<br/>

</div>




<input type="hidden" name="MAX_FILE_SIZE" value="<?=$maxsize?>">

<br/>
<? if ($status!="") { ?><?=$status?><? } ?>
</td></tr>

<div class="Question">
<label for="userfile"><?=$lang["clickbrowsetolocate"]?></label>
<input type=file name=userfile id=userfile>
<div class="clearerleft"> </div>
</div>

<div class="QuestionSubmit">
<label for="buttons"> </label>			
<input name="save" type="submit" value="&nbsp;&nbsp;Upload&nbsp;&nbsp;" onclick="javascript:document.getElementById('searchPageLoadingImage').style.display = 'block';" />
</div>

<div style="position: absolute; left: 100px; top: 100px; z-index: 2; margin: 100px 200px 200px 200px; border: 3px solid black; width: 100px; height: 100px; background: #FFF url('search_page_loading.gif') center no-repeat; display: none;" id="searchPageLoadingImage"></div></div>

<div class="Question">
<?=text("file_conventions")?>
</div>

<? /*<p><a href="edit.php?ref=<?=$ref?>">&gt; <?=$lang["backtoeditresource"]?></a></p> */ ?>

</form>

</div>

<?
include "include/footer.php";
?>