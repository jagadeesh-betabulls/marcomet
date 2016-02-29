<?
$BASE_URL_HTTP_GET = "http://winmarketing.marcomet-stage.com";

/*************************************************************************************
**** **** **** **** **** **** **** **** **** **** **** **** **** **** **** **** **** *

Start of Wyndham config file

Tell the daemon that we are in the Wyndham config file:
@DAEMON_CONFIG: wyndham

**** **** **** **** **** **** **** **** **** **** **** **** **** **** **** **** **** *
*************************************************************************************/
// Set the current site
$CURRENT_SITE = "wyndham";

# The directory of drop folders
$drop_folders_directory = "/home/webadmin/marcomet-ams.virtual.vps-host.net/drop_folders/";

/*if(!isset($tmpimport)) $tmpimport = "not";
if($tmpimport=="noodles") $drop_folders_directory = "/tmp/data/marcomet/";*/

$mysql_server="marcomet-ams.virtual.vps-host.net";	# Use 'localhost' if MySQL is installed on the same server as your web server.
$mysql_username="mysql";		# MySQL username
$mysql_password="m@rcmgdb08";			# MySQL password
$mysql_db="marcomet_ams";			# MySQL database name

# If true, frameset will not be used 
$frameless=false; 
# If false home will not try and breakout of other frameset
$breakout='0';
# If true header will be hidden
$hideheader=true;

$showfooter=false;

$secure=false; # Using HTTPS?
$development=true; # Development mode?
$baseurl="http://wam.marcomet.com/DigitalAssets"; # The 'base' web address for this installation. Note: no trailing slash
$headerlogo="http://wam.marcomet.com/sitehosts/wyndhamimages/images/masthead_banner.jpg"; # logo for the basic header
$email_from="images@marcomet.com"; # Where e-mails appear to come from
$email_notify="ecimafonte@marcomet.com"; # Where resource/research/user requests are sent
$spider_password="394fhlqghrum@rc3kc"; # The password required for spider.php - IMPORTANT - randomise this for each new installation. Your resources will be readable by anyone that knows this password.

include "version.php";
$applicationname="Wyndham Asset Management Service"; # The name of your implementation / installation (e.g. 'MyCompany Resource System')

# Available languages
$defaultlanguage="en"; # default language, uses iso codes (en, es etc.)
$languages["en"]="English";
#$languages["de"]="Deutsch";
#$languages["es"]="Español";
$languages["fr"]="Français";
#$languages["pt"]="Português";


# FTP settings for batch upload
# Only necessary if you plan to use the FTP upload feature.
$ftp_server="marcomet-ams.virtual.vps-host.net";
$ftp_username="ftpupload";
$ftp_password="m@rcftp";
$ftp_defaultfolder="upload/";

# Can users change passwords?
$allow_password_change=false;

# Scramble resource paths? If this is a public installation then this is a very wise idea.
# Set the scramble key to be a hard-to-guess string (similar to a password).
# To disable, set to the empty string ("").
$scramble_key="marcekc";

# search params
# Common keywords to ignore both when searching and when indexing.
$noadd=array("", "a","the","this","then","another","is","with","in","and","where","how","on","of","to", "from", "at", "for", "-", "by", "be");
$suggest_threshold=-1; # How many results trigger the 'suggestion' feature, -1 disables the feature
$max_results=50000;
$minyear=2000; # The year of the earliest resource record, used for the date selector on the search form. Unless you are adding existing resources to the system, probably best to set this to the current year at the time of installation.
$homeimages=3; # How many images are on the homepage slideshow?

# Optional 'quota size' for allocation of a set amount of disk space to this application. Value is in GB.
# Note: Unix systems only.
# $disksize=150;

# Set your time zone below (default GMT)
if (function_exists("date_default_timezone_set")) {date_default_timezone_set("GMT");}

# IPTC header - Character encoding auto-detection
# If using IPTC headers, specify any non-ascii characters used in your local language
# to aid with character encoding auto-detection.
# Several encodings will be attempted and if a character in this string is returned then this is considered
# a match.
# For English, there is no need to specify anything here (i.e. just an empty string)
# The example given is for Norwegian.
$iptc_expectedchars="æøåÆØÅ";

# Which field do we drop the EXIF data in to?
$exif_comment=18;
$exif_model=52;
$exif_date=12;

# Which field do we drop the original filename in to?
$filename_field=51;

# If using imagemagick, uncomment and set next 2 lines
 $imagemagick_path="/usr/";
 $ghostscript_path="/usr/";

# If using ffmpeg, uncomment and set next 2 lines.
# $ffmpeg_path="/Applications/ffmpegX.app/Contents/Resources";

# Allow users to request accounts?
$allow_account_request=false;

# Highlight search keywords when displaying results and resources?
$highlightkeywords=true;

# Search on day in addition to month/year?
$searchbyday=false;

# Allow download of original file for resources with "Restricted" access.
# For the tailor made preview sizes / downloads, this value is set per preview size in the system setup.
$restricted_full_download=true;

# Also search the archive and display a count with every search? (performance penalty)
$archive_search=false;

# Display the Research Request functionality?
$research_request=false;

# Country search in the right nav? (requires a field with the short name 'country')
$country_search=false;

# Use the themes page as the home page?
$use_theme_as_home=false;

# Display a 'Recent' link in the top navigation (goes to View New Material)
$recent_link=false;

# Display a 'My Collections' link in the top navigation
$mycollections_link=false;

# Require terms for download?
$terms_download=false;

# Require terms on first login?
$terms_login=false;

# In the collection frame, show or hide thumbnails by default? ("hide" is better if collections are not going to be heavily used).
$thumbs_default="show";

# Show images along with theme category headers (image selected is the most popular within the theme category)
$theme_images=true;

# How many results per page? (default)
$default_perpage=48;

# for sync
$syncdir="/DigitalAssets/filestore";
$nogo="[folder1]";
$type=1;

# Group based upload folders? (separate local upload folders for each group)
$groupuploadfolders=true;

# Enable order by rating? (require rating field updating to rating column)
$orderbyrating=true;

# Use FancyUpload for batch uploads? (Flash / Javascript based uploader)
$usefancyupload=true;

# Zip command to use to create zip archive (comment this line out to disable download collection as zip function)
$zipcommand="zip -j";

# Enable speed tagging feature? (development)
$speedtagging=true;
$speedtaggingfield=1;

# A list of types which get the extra video icon in the search results
$videotypes=array(3);

# Uncomment and set the next line to lock to one specific colour scheme (e.g. greyblu/whitegry).
# $userfixedtheme="black";

# List of active plugins.
$plugins=array("rss");

# Resource Field Default Text
# Allowable Use
$allowable_use="For use by Wyndham Worldwide employees, assignees, and its brand franchise owners and their assignees.";
$copyright="Wyndham Worldwide 2008";
?>
