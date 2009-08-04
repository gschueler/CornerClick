var vers=VERSION.version;
var size=VERSION.size;
var note=VERSION.note;
var urlPre = "http://greg.vario.us/cornerclick/";
var urlName="CornerClick-";
var urlSuf = ".tar.bz2";
		
var foundVers=null;
if(/^\?v?(\d+\.\d+(\.\d+)?)$/.test(document.location.search)){
	foundVers = RegExp.$1;
}
var geturl=urlPre+urlName+vers+urlSuf;
$('dllink').href=geturl;
$('dllink').innerHTML+=vers+urlSuf;
var kbs=(size/1024).toFixed(0);
new Insertion.Bottom('dlbox',kbs+" KB");
if(null!=note){
new Insertion.Bottom('dlbox',note);
}
if(foundVers!=null && vers!=foundVers){
	new Insertion.Bottom('oldvers',foundVers);
	Element.show('versionWarning');
}else{
	Element.toggle('soon');
	setTimeout(function(){Element.hide('soon');document.location=geturl;}, 5000);
}
