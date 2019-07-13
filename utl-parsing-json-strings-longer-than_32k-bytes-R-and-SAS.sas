
Parsing json strings longer than 32k bytes

Suppose the long json string is 48,000 characters and within the 48,000 byte string are
three strings of 16,000 characters separated by '@'.

Obviously, the dumb json file below can be manually programmed to parse the long string.
However, suppose there are 30 more fields and some nesting in the json nfile.

github
https://tinyurl.com/y333y8zl
https://github.com/rogerjdeangelis/utl-parsing-json-strings-longer-than_32k-bytes-R-and-SAS

SAS Forum
https://tinyurl.com/y38p8oba
https://communities.sas.com/t5/SAS-Programming/CSV-file-with-JSON-field-where-the-JSON-field-is-bigger-than-32K/m-p/573115




*_                   _
(_)_ __  _ __  _   _| |_
| | '_ \| '_ \| | | | __|
| | | | | |_) | |_| | |_
|_|_| |_| .__/ \__,_|\__|
        |_|
;

d:/json/longchar.json

Jason file with a 48k string consisting of 3 16k substrings separated by '@'.

[
  {
    "STATUS": "Y",
    "CODE": 13,
    "NAME": "Larry"
  },
  {
    "STATUS": "Y",
    "CODE": 11,
                   One 48k string
             ---16K--- ---16K--- run;quit;
    "NAME": "aaa...aaa@bbb...bbb@ccc...ccc"
  }
]


* MAKE JSON INPUT:

filename json "d:/json/longchar.json" lrecl=64000 recfm=v;

data _null_;

   length str1 str2 str3 $16001;

   str1=cats(repeat('a',15999),"@");
   str2=cats(repeat('b',15999),"@");
   str3=cats(repeat('c',15999));

   input;

   file json;

   if index(_infile_,'b"')>0 then
      put '"NAME": "'  str1 +(-1) str2 +(-1) str3 +(-1) '"';
   else put _infile_;

cards4;
[
  {
    "STATUS": "Y",
    "CODE": 13,
    "NAME": "Larry"
  },
  {
    "STATUS": "Y",
    "CODE": 11,
    "NAME": "Bob"
  }
]
;;;;
run;quit;

*            _               _
  ___  _   _| |_ _ __  _   _| |_
 / _ \| | | | __| '_ \| | | | __|
| (_) | |_| | |_| |_) | |_| | |_
 \___/ \__,_|\__| .__/ \__,_|\__|
                |_|
;

* Two SAS tables;

Up to 40 obs from HAVE total obs=2

Obs    STATUS    CODE     NAME

 1       Y        13     Larry
 2       Y        11     REMOVED  ** substituted REMOVED for the 48k byte string


* Long string split into three 16k pieces;

WORK.WANT total obs=3

Obs                                      V1

 1  aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa...
 2  bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb...
 3  cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc...

                  Variables in Creation Order

#    Variable    Type      Len    Format     Informat    Label

1    V1          Char    16000    $16000.    $16000.     V1

*          _       _   _
 ___  ___ | |_   _| |_(_) ___  _ __
/ __|/ _ \| | | | | __| |/ _ \| '_ \
\__ \ (_) | | |_| | |_| | (_) | | | |
|___/\___/|_|\__,_|\__|_|\___/|_| |_|

;

%utl_submit_r64('
library(rio);
library(haven);
library(SASxport);
library(data.table);
have<-import("d:/json/longchar.json");
want<-as.data.table(strsplit(have$NAME[2], "@"));
have[2,3]<-"REMOVED";
write_sav(have,"d:/sav/have.sav");
write_sav(want,"d:/sav/want.sav");
');


filename imp 'd:/sav/want.sav' lrecl=32756;
proc import
   out=work.want
   file=imp
   dbms=sav replace;
run;

filename imp 'd:/sav/have.sav' lrecl=32756;
proc import
   out=work.have
   file=imp
   dbms=sav replace;
run;


