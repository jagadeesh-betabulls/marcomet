<?
include "include/config.php";
include "include/db.php";
include "include/marcomet_widget_authenticate.php"; if (!checkperm("c") && !checkperm("d")) {exit ("Permission denied.");}
include "include/general.php";
include "include/resource_functions.php";
if($CURRENT_SITE=="dolce") {
	include "drop_parser_dolce.php";
} else {
	include "drop_parser.php";
}
include "include/image_processing.php";
global $usersearchfilter;

$ref = getval("ref","");
$resURL = getval("resURL","");

$widget_user = getval('widget_user', '');

$templateName = getval('templateName', '');
$imageRef = getval('imageRef', '');
$imageDPI = getval('dpi', '');
$imageWidth = intval(getval('imageWidth', '0'));
$imageHeight = intval(getval('imageHeight', '0'));
$tempImageName = getval('tempImageName', '');
$tempImagePath = getval('tempImagePath', '');
$amsDomain = getval('amsDomain', '');


$ratioWidth = intval(getval("ratioWidth", $imageWidth));
$ratioHeight = intval(getval("ratioHeight", $imageHeight));

if($ratioWidth==0 && $ratioHeight==0) {
	$ratioWidth = $imageWidth;
	$ratioHeight = $imageHeight;
}

$width = intval(getval("width", "0"));
$height = intval(getval("height", "0"));

if($width==0) {
	$width = $imageWidth;
	while($width>500) {
		$width -= (($imageWidth/$imageHeight)*$imageWidth);
	}
}

if($height==0) {
	$height = $imageHeight;
	while($height>500) {
		$height -= (($imageWidth/$imageHeight)*$imageHeight);
	}
}

$x1 = getval("x1", "0");
$x2 = getval("x2", "0");
$y1 = getval("y1", "0");
$y2 = getval("y2", "0");
$pre_w = getval("pre_w", "0");
$pre_h = getval("pre_h", "0");

$generate_missing_dirs = false;
$scramble_path = -1;

// handle posts
if (array_key_exists("x1",$_POST) && array_key_exists("y1",$_POST) && array_key_exists("x2",$_POST) && array_key_exists("y2",$_POST) && array_key_exists("width",$_POST) && array_key_exists("height",$_POST) && array_key_exists("ref",$_POST) && array_key_exists("continue",$_POST)) {
	$ref = $_POST["ref"];
	$width = $_POST["width"];
	$height = $_POST["height"];
	$im_width = $_POST["im_width"];
	$im_height = $_POST["im_height"];
	$x1 = $_POST["x1"];
	$x2 = $_POST["x2"];
	$y1 = $_POST["y1"];
	$y2 = $_POST["y2"];
	$pre_w = $_POST["pre_w"];
	$pre_h = $_POST["pre_h"];
	
	$tempimg = "";
	# Download and save the file in the temp dir
	if($resURL=="") {
		$tempimg = file_get_contents(get_resource_path($ref, "", $generate_missing_dirs, "jpg", $scramble_path, $amsDomain));
	} else {
        #JM - I'm not sure why it should be marketwyngarden over any other random server, but I guess we have to choose something.
		$tempimg = file_get_contents("http://marketwyngarden.marcomet.com/".$resURL);
	}
	
	$filename = "$ref"."_"."$width"."_"."$height"."_"."$x1"."_"."$x2"."_"."$y1"."_"."$y2";
	
	$temp = fopen("images/$filename"."_tmp.jpg", "w");
	fwrite($temp, $tempimg);
	fclose($temp);

	//echo $x1, " ",  $y1, " ", $width, " ", $height;


	# Calculate the new width and height
	$o_width = $width;
	$o_height = $height;
	$size = getimagesize("images/$filename"."_tmp.jpg");
	$new_w = $size[0];
	$new_h = $size[1];
	$w_per = $new_w / $pre_w;
	$h_per = $new_h / $pre_h;
	
	$width = $width * $w_per;
	$height = $height * $h_per;
	
	# Calculate the new x and y
	if($x1!=0) $x_per = $new_w / $x1;
	else $x_per = 1;
	if($y1!=0) $y_per = $new_h / $y1;
	else $y_per = 1;
	
	$x1 = $x1 * $w_per;
	$y1 = $y1 * $h_per;

	# Locate imagemagick.
    $command=$imagemagick_path . "/bin/convert";
    if (!file_exists($command)) {$command=$imagemagick_path . "/convert.exe";}
    if (!file_exists($command)) {$command=$imagemagick_path . "/convert";}
    if (!file_exists($command)) {exit("Could not find ImageMagick 'convert' utility at location '$command'");}	

    $prefix="";
    
    $file = "images/$filename"."_tmp.jpg";
    $target = "../../$tempImagePath/$tempImageName";
    
    $crop_cmd = " -crop $width"."x$height"."+$x1"."+$y1";
    if($o_width==$im_width && $o_height==$im_height) $crop_cmd = "";
    
    //$command.= " " . $prefix . "\"$file\"[0] -crop $width"."x$height"."+$x1"."+$y1 -resize $o_width"."x"."$o_height \"$target\""; 
    //echo $width, " ", $height, " ", $x1, " ", $y1, " ", $im_width, " ", $im_height;exit;
    $command.= " " . $prefix . "\"$file\"[0]".$crop_cmd." \"$target\""; // -resize $im_width"."x$im_height 
    $output=shell_exec($command); 
	unlink("images/$filename"."_tmp.jpg");
	include "include/header.php";
	?><script type="text/javascript">
	parent.chooseWAM('<?=$imageRef?>', '<?=$tempImageName?>');
	</script><?
	include "include/footer.php";
	exit;
}


include "include/header.php";
?>
<script src="lib/prototype.js" type="text/javascript"></script>	
<script src="lib/scriptaculous.js?load=builder,dragdrop" type="text/javascript"></script>
<script src="cropper.js" type="text/javascript"></script>
<div style="position: absolute; left: 100px; top: 100px; z-index: 2; margin: 100px 200px 200px 200px; border: 3px solid black; width: 100px; height: 100px; background: #FFF url('search_page_loading.gif') center no-repeat; display: none;" id="searchPageLoadingImage"></div></div>


<style type="text/css">
	label { 
		clear: left;
		margin-left: 50px;
		float: left;
		width: 5em;
	}
	
	#testWrap {
		margin: 20px 0 0 50px; /* Just while testing, to make sure we return the correct positions for the image & not the window */
	}
	.imgCrop_wrap {
		border: 2px solid black;
	}
</style>

<div class="BasicsBox">
    <h1>Crop & Scale Photo</h1>

    <?
    $new_file_uploaded = getval("new_file_uploaded","");
    
    if($new_file_uploaded!="") {?>
        <div id="newFileRefNotification" style="padding: 5px; border: 1px solid #CC7915; background-color: #FAB761;">
            <p style="display: inline;">The file has been successfully uploaded. It has been placed in the "Miscellaneous" file type category for later use.</p>
        </div>
    <? } ?>
    
    <form method="post" class="form" enctype="multipart/form-data" action="">
        <div id="testWrap">
        
            <img src="<? 
            if($resURL=="") { 
                echo get_resource_path($ref, "pre", $generate_missing_dirs, "jpg", $scramble_path, $amsDomain); 
            } else { 
                echo $resURL; 
            } 
            ?>" alt="test image" id="testImage"  />
            
            <script type="text/javascript">
             //if(navigator.userAgent.indexOf("Safari")){ $('testImage').style.height = "<?=$width?> !important"; }
             //width: <?=$width?> !important; height: auto !important;
            </script>
        </div>
        <div id="bottomInfoSubmit" style="margin: 20px 0px 0px 50px; width: 335px;">
            <input type="submit" name="continue" value="Continue" style="float: right;" onclick="javascript:continueButton();" />
            <input type="button" name="newImage" value="Choose New Image" style="float: right;" onclick="javascript:window.location = '<? 
                echo "/preview/template_wam/marcomet_widget.php?amsDomain=$amsDomain&widget_user=$widget_user&ratioWidth=$ratioWidth&ratioHeight=$ratioHeight&templateName=$templateName&imageRef=$imageRef&imageDPI=$imageDPI&imageWidth=$imageWidth&imageHeight=$imageHeight&tempImageName=$tempImageName&tempImagePath=$tempImagePath&ignoreFile=yes"; 
            ?>';" />
            <input type="hidden" name="x1" id="x1" />
            <input type="hidden" name="y1" id="y1" />
            <input type="hidden" name="x2" id="x2" />
            <input type="hidden" name="y2" id="y2" />
            <input type="hidden" name="width" id="width" />
            <input type="hidden" name="height" id="height" />
            <input type="hidden" name="im_width" id="im_width" value="<?=$imageWidth?>" />
            <input type="hidden" name="im_height" id="im_height" value="<?=$imageHeight?>" />
            <input type="hidden" name="pre_w" id="pre_w" value="<?=$pre_w?>" />
            <input type="hidden" name="pre_h" id="pre_h" value="<?=$pre_h?>" />
            <input type="hidden" name="ref" id="ref" value="<?=$ref?>" />
            <input type="hidden" name="resURL" id="resURL" value="<?=$resURL?>" />
            <p style="display: inline;">
            <b style="display: inline; color: black;">Width: </b><div id="dispWidth" style="display: inline;"></div>px
            <b style="display: inline; color: black;">Height: </b><div id="dispHeight" style="display: inline;"></div>px
            </p>
            <br/><br/>
        </div>
    </form>
</div>

<script type="text/javascript" charset="utf-8">
	
	function continueButton() {
		$( 'pre_w' ).value = $("testImage").width;
	$( 'pre_h' ).value = $("testImage").height;
		//alert("x1: " + $( 'x1' ).value + " y1: " + $( 'y1' ).value + " x2: " + $( 'x2' ).value + " y2: " + $( 'y2' ).value + " width: " + $( 'width' ).value + " height: " + $( 'height' ).value + " testImage: " + $('testImage').src + " testImageWidth: " + $('testImage').width + " testImageHeight: " + $('testImage').height);
		$("searchPageLoadingImage").style.display = "block";
		//parent.chooseWAM('');
		parent.previewProduct('<?=$templateName?>');
	}
	
	function onEndCrop( coords, dimensions ) {
		$( 'x1' ).value = coords.x1;
		$( 'y1' ).value = coords.y1;
		$( 'x2' ).value = coords.x2;
		$( 'y2' ).value = coords.y2;
		$( 'width' ).value = dimensions.width;
		$( 'height' ).value = dimensions.height;
		$( 'dispWidth' ).innerHTML = dimensions.width;
		$( 'dispHeight' ).innerHTML = dimensions.height;
	}
	
	
	// with a supplied ratio
	Event.observe( 
		window, 
		'load', 
		function() { 
			new Cropper.Img( 
				'testImage', 
				{ 
					ratioDim: { x: <?=$ratioWidth?>, y: <?=$ratioHeight?> }, 
					displayOnInit: true, 
					onEndCrop: onEndCrop,
					onloadCoords: { x1: <?=$x1?>,
									x2: <?=$width?>,
									y1: <?=$y1?>,
									y2: <?=$height?>
									}
				} 
			) 
		} 
	);
	
	/*
	if( typeof(dump) != 'function' ) {
		Debug.init(true, '/');
		
		function dump( msg ) {
			// Debug.raise( msg );
		};
	} else dump( '---------------------------------------\n' );
	*/
	$( 'pre_w' ).value = $("testImage").width;
	$( 'pre_h' ).value = $("testImage").height;
</script>

<?
include "include/footer.php";
?>