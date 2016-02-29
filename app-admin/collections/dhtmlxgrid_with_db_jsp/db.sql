CREATE TABLE `authors` (
  `Id` int(11) NOT NULL auto_increment,
  `lastname` text,
  `firstname` text,
  PRIMARY KEY  (`Id`)
)
CREATE TABLE `books` (
  `Id` int(11) NOT NULL auto_increment,
  `name` text,
  `authorid` int(11) default NULL,
  `pubdate` text,
  `price` double default NULL,
  `instore` tinyint(1) default NULL,
  PRIMARY KEY  (`Id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
