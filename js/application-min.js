(function(){var b,a=[].slice;this.valueFn=function(c){return function(){return c}};this.attr=function(c){return function(d){return d[c]}};b=angular.module("kstep",["ng","ngSanitize","ngCookies"]);b.filters=function(e){var d,c;for(c in e){d=e[c];this.filter(c,d)}return this};b.provider({GA:function(){var c;c=[];return{setAccount:function(f,e){var d;if(!e){d=[f,e],e=d[0],f=d[1]}c.push(["_setAccount",e]);if(f){c.push(["_setDomainName",f])}return this},$get:["$window","$location","$jsload","$timeout",function(g,h,d,e){var f;g._gaq=c;f=h.protocol()==="https"?"https://ssl":"http://www";d(f+".google-analytics.com/ga.js");return function(){var i;i=1<=arguments.length?a.call(arguments,0):[];return g._gaq.push(i)}}]}}}).config(["$routeProvider","$locationProvider","$interpolateProvider","$httpProvider","GAProvider",function(g,f,c,e,d){g.when("/",{controller:"BlogCtl",templateUrl:"/partials/list.html"}).when("/tags",{controller:"TagsCtl",templateUrl:"/partials/tags.html"}).when("/tag/:tag",{controller:"TagCtl",templateUrl:"/partials/tag.html"}).when("/:year/:month/:day/:name.html",{controller:"PostCtl",templateUrl:"/partials/post.html"}).when("/:year/:month/:day",{controller:"BlogCtl",templateUrl:"/partials/date.html"}).when("/:year/:month",{controller:"BlogCtl",templateUrl:"/partials/date.html"}).when("/:year",{controller:"BlogCtl",templateUrl:"/partials/date.html"}).otherwise({redirectTo:"/"});f.html5Mode(false);f.hashPrefix("!");c.startSymbol("{:");c.endSymbol(":}");e.responseInterceptors.push(["$rootScope","$q",function(i,h){return function(j){i.$loading=true;return j.then((function(k){i.$loading=false;return k}),(function(k){i.$loading=false;return h.reject(k)}))}}]);return d.setAccount("kstep.me","UA-23938138-1")}]).filters({lpad:function(){return function(d,c,e){d=(d||"").toString();e=e||"0";if(d.length<c){d=(new Array(c-d.length+1).join(e))+d}return d}},rpad:function(){return function(d,c,e){d=(d||"").toString();e=e||"0";if(d.length<c){d=d+(new Array(c-d.length+1).join(e))}return d}},strip_tags:function(){var c;c=/<\/[a-zA-Z][a-zA-Z0-9]*>|<[a-zA-Z][a-zA-Z0-9]*(\s+[^>]*?)?\/?>/g;return function(d){return(d||"").toString().replace(c,"")}},rot13:function(){var d,c;c=/[a-zA-Z]/g;d=function(e){return String.fromCharCode((e<="Z"?90:122)>=(e=e.charCodeAt(0)+13)?e:e-26)};return function(e){return(e||"").toString().replace(c,d)}},asdate:["$filter",function(c){return function(e,d){return c("date")(new Date(e),d)}}],lower:function(){return function(c){return(c||"").toString().toLowerCase()}},upper:function(){return function(c){return(c||"").toString().toUpperCase()}},caps:function(){return function(c){return(c||"").toString().replace(/^./,function(d){return d.toUpperCase()})}},allcaps:function(){return function(c){return(c||"").toString().replace(/\b./g,function(d){return d.toUpperCase()})}}}).directive({ggSearch:["$jsload",function(c){return{restrict:"AE",template:"<gcse:search></gcse:search>",replace:true,compile:function(e,d){return c("//www.google.com/cse.js?cx="+(d.ggSearch||id))}}}],youtube:function(){return{restrict:"AE",scope:true,replace:true,template:'<iframe ng-src="http://www.youtube.com/embed/{: id :}" width="{: width :}" height="{: height :}" frameborder="0" allowfullscreen></iframe>',compile:function(f,d){var c,e,g;g=d.youtube||d.id;e=parseInt(d.width,10)||560;c=parseInt(d.height,10)||315;return function(i,j,h){i.id=g;i.width=e;return i.height=c}}}},totop:["$window",function(c){return{restrict:"AC",compile:function(e,d){var f;f=$(c);f.bind("scroll",function(g){return e.css("display",f.scrollTop()>f.height()/3?"":"none")});e.css("display","none");return function(h,i,g){return i.bind("click",function(){f.scrollTop(0);return i.css("display","none")})}}}}],disqus:["$location","$window","Disqus","$parse",function(g,f,e,d){var c;c=0;return{restrict:"ACE",terminal:true,compile:function(j,i){var k,h;h=i.disqus||i.name;k=i.id;if(!h){return}if(!k){j.attr("id",k="disqus_thread"+c++)}return function(m,n,l){f.disqus_identifier=g.path();f.disqus_url=g.absUrl();f.disqus_container_id=k;f.DISQUS=void 0;n.html("");return e(h)}}}}],ngMeta:["$parse",function(c){return{restrict:"E",terminal:true,compile:function(g,e){var h,f,d;if(!e.value&&!e.update){return}h=c(e.name);d=e.value?c(e.value):null;f=e.update?c(e.update):null;return function(j,k,i){if(d!=null){h.assign(j,d(j))}if(f!=null){return angular.extend(h(j),f(j))}}}}}],calendar:["$parse","$interpolate",function(c,d){return{restrict:"CAE",scope:true,replace:true,template:'<div ng-class="[month, leap_year]">\n    <div class="header">\n        <nobr class="clearfix"><a ng-click="prev_month()">← {: months[(date.month - 1) % 12] | caps :}</a> <strong>{: month | caps :} {: date.year :}</strong> <a ng-click="next_month()">{: months[(date.month + 1) % 12] | caps :} →</a></nobr>\n        <span class="mon">Mon</span>\n        <span class="tue">Tue</span>\n        <span class="wed">Wed</span>\n        <span class="thu">Thu</span>\n        <span class="fri">Fri</span>\n        <span class="sat">Sat</span>\n        <span class="sun">Sun</span>\n    </div>\n    <a ng-href="{: href(1) :}" class="day-1" ng-class="[weekday(1), is_today(1)]">1</a>\n    <a ng-href="{: href(2) :}" class="day-2" ng-class="[weekday(2), is_today(2)]">2</a>\n    <a ng-href="{: href(3) :}" class="day-3" ng-class="[weekday(3), is_today(3)]">3</a>\n    <a ng-href="{: href(4) :}" class="day-4" ng-class="[weekday(4), is_today(4)]">4</a>\n    <a ng-href="{: href(5) :}" class="day-5" ng-class="[weekday(5), is_today(5)]">5</a>\n    <a ng-href="{: href(6) :}" class="day-6" ng-class="[weekday(6), is_today(6)]">6</a>\n    <a ng-href="{: href(7) :}" class="day-7" ng-class="[weekday(7), is_today(7)]">7</a>\n    <a ng-href="{: href(8) :}" class="day-8" ng-class="[weekday(8), is_today(8)]">8</a>\n    <a ng-href="{: href(9) :}" class="day-9" ng-class="[weekday(9), is_today(9)]">9</a>\n    <a ng-href="{: href(10) :}" class="day-10" ng-class="[weekday(10), is_today(10)]">10</a>\n    <a ng-href="{: href(11) :}" class="day-11" ng-class="[weekday(11), is_today(11)]">11</a>\n    <a ng-href="{: href(12) :}" class="day-12" ng-class="[weekday(12), is_today(12)]">12</a>\n    <a ng-href="{: href(13) :}" class="day-13" ng-class="[weekday(13), is_today(13)]">13</a>\n    <a ng-href="{: href(14) :}" class="day-14" ng-class="[weekday(14), is_today(14)]">14</a>\n    <a ng-href="{: href(15) :}" class="day-15" ng-class="[weekday(15), is_today(15)]">15</a>\n    <a ng-href="{: href(16) :}" class="day-16" ng-class="[weekday(16), is_today(16)]">16</a>\n    <a ng-href="{: href(17) :}" class="day-17" ng-class="[weekday(17), is_today(17)]">17</a>\n    <a ng-href="{: href(18) :}" class="day-18" ng-class="[weekday(18), is_today(18)]">18</a>\n    <a ng-href="{: href(19) :}" class="day-19" ng-class="[weekday(19), is_today(19)]">20</a>\n    <a ng-href="{: href(20) :}" class="day-20" ng-class="[weekday(20), is_today(20)]">20</a>\n    <a ng-href="{: href(21) :}" class="day-21" ng-class="[weekday(21), is_today(21)]">21</a>\n    <a ng-href="{: href(22) :}" class="day-22" ng-class="[weekday(22), is_today(22)]">22</a>\n    <a ng-href="{: href(23) :}" class="day-23" ng-class="[weekday(23), is_today(23)]">23</a>\n    <a ng-href="{: href(24) :}" class="day-24" ng-class="[weekday(24), is_today(24)]">24</a>\n    <a ng-href="{: href(25) :}" class="day-25" ng-class="[weekday(25), is_today(25)]">25</a>\n    <a ng-href="{: href(26) :}" class="day-26" ng-class="[weekday(26), is_today(26)]">26</a>\n    <a ng-href="{: href(27) :}" class="day-27" ng-class="[weekday(27), is_today(27)]">27</a>\n    <a ng-href="{: href(28) :}" class="day-28" ng-class="[weekday(28), is_today(28)]">28</a>\n    <a ng-href="{: href(29) :}" class="day-29" ng-class="[weekday(29), is_today(29)]">29</a>\n    <a ng-href="{: href(30) :}" class="day-30" ng-class="[weekday(30), is_today(30)]">30</a>\n    <a ng-href="{: href(31) :}" class="day-31" ng-class="[weekday(31), is_today(31)]">31</a>\n</div>',compile:function(i,h){var k,l,e,g,j,f;e=function(m){return{year:m.getFullYear(),month:m.getMonth()+1,day:m.getDate(),dow:m.getDay()}};g=e(new Date);f=g;j=function(m){return g};j.assign=function(m,n){return g=n};k=h.date?c(h.date):j;l=d(h.href);return function(s,q,p){var o,r,t,m,n;r=1;o={};n=["sun","mon","tue","wed","thu","fri","sat","sun"];m=["december","january","february","march","april","may","june","july","august","september","october","november","december"];t=function(u){return(u%4===0)&&(u%100!==0||u%400===0)};s.href=function(u){return l({day:u,date:o})};s.weekday=function(u){return n[(r+u-1)%7]};s.months=m;s.prev_month=function(){return(k.assign||angular.noop)(s,{year:o.year,month:o.month-1,day:o.day})};s.next_month=function(){return(k.assign||angular.noop)(s,{year:o.year,month:o.month+1,day:o.day})};s.set_date=function(u){return(k.assign||angular.noop)(s,u)};s.today=f;return s.$watch(k,function(u){u=angular.isDate(u)?u:angular.isObject(u)?new Date(u.year,u.month-1,u.day):new Date(u);o=e(u);s.is_today=o.year===f.year&&o.month===f.month?(function(v){if(v===o.day){return"today"}else{return""}}):(function(v){return false});r=(8+o.dow-o.day%7)%7;s.date=o;s.month=m[o.month];return s.leap_year=t(o.year)?"leap-year":""})}}}}]}).factory({appcache:["$window","$rootScope",function(f,e){var d,c;d=f.applicationCache||{fakeAppCache:true,UNCACHED:0,IDLE:1,CHECKING:2,DOWNLOADING:3,UPDATEREADY:4,OBSOLETE:5,oncached:null,onchecking:null,ondownloading:null,onnoupdate:null,onobsolete:null,onupdateready:null,status:1,addEventListener:angular.noop,dispatchEvent:angular.noop,removeEventListener:angular.noop,swapCache:angular.noop,update:angular.noop};c={};d.bind=function(g,h){return d.addEventListener(g,(c[h]=function(i){return h.call(this,i(e.$apply()))}),false)};d.unbind=function(g,h){return d.removeEventListener(g,c[h]||h,false)};return d}],$jsload:["$timeout","$q","$document","$rootScope",function(f,e,h,g){var d,c;d={};c={};return function(k,j){var i;if(c[k]){return c[k]}i=e.defer();if(!j&&d[k]){i.resolve(d[k])}else{c[k]=i.promise;if(d[k]){d[k].parentNode.removeChild(d[k]);delete d[k]}f(function(){var l;l=h[0].createElement("script");l.type="text/javascript";l.async=true;l.src=k;l.onerror=function(m){delete c[k];i.reject(l);return g.$digest()};l.onreadystatechange=l.onload=function(m){delete c[k];if(!m.readyState||m.readyState==="loaded"){d[k]=l;i.resolve(l);return g.$digest()}};return h[0].getElementsByTagName("head")[0].appendChild(l)})}return i.promise}}],Pager:function(){return function(d,c,e){this.total_pages=0;this.pages=[];this.set_page=function(g){var f,i,h;f=Math.ceil(d.length/c);if(f!==this.total_pages){this.total_pages=f;this.pages=(function(){h=[];for(var j=1;1<=f?j<=f:j>=f;1<=f?j++:j--){h.push(j)}return h}).apply(this)}this.page=g<1?1:g>f?f:g;this.slice=d.slice((this.page-1)*c,this.page*c);return this};return this.set_page(e)}},Disqus:["$window","$jsload",function(d,c){return function(e){return c("http://"+e+".disqus.com/embed.js",true).then(function(){return d.DISQUS})}}],locales:["$http","$rootScope","$cookies",function(f,e,d){var c;c=function(g){return e.locale=f.get("/i18n/"+g+".json").then(function(h){h.data.lang=g;d.lang=g;return h.data})};c(d.lang||"en");return c}]}).controller({RootCtl:["$scope","$http","locales","appcache","$window","GA","$location",function(d,i,c,e,f,h,g){e.bind("updateready",function(){d.update_available=true;return e.swapCache()});d.page={};d.locales=c;d.reload_site=function(){return f.location.reload()};return d.social_accounts=[{url:"https://twitter.com/kstepme",icon:"http://twitter.com/favicon.ico",name:"Twitter"},{url:"http://www.linkedin.com/pub/konstantin-stepanov/54/47/450",icon:"http://www.linkedin.com/favicon.ico",name:"LinkedIn"},{url:"http://kstepme.moikrug.ru/",icon:"http://moikrug.ru/favicon.ico",name:"Мой Круг"},{url:"http://welinux.ru/user/kstep/",icon:"http://welinux.ru/favicon.ico",name:"WeLinux"},{url:"https://github.com/kstep",icon:"http://github.com/favicon.ico",name:"Github"},{url:"http://www.ohloh.net/accounts/kstep",icon:"http://www.ohloh.net/favicon.ico",name:"Ohloh"},{url:"http://search.cpan.org/~kstepme/",icon:"http://search.cpan.org/favicon.ico",name:"CPAN"},d.$on("$routeChangeSuccess",function(){return h("_trackPageview",g.path())})]}],PostCtl:["$scope","$routeParams",function(d,c){return angular.extend(d.page,{url:"/"+c.year+"/"+c.month+"/"+c.day+"/"+c.name+".html",group:"blog"})}],BlogCtl:["$scope","$routeParams","$http","Pager",function(d,c,g,f){var e;d.$watch("locale.index_title",function(h){return d.page.title=h});angular.extend(d.page,{title:d.locale.index_title,url:"/",group:"blog"});e=(""+(c.year||"")+"-"+(c.month||"")+"-"+(c.day||"")).replace(/-+$/g,"");d.date={year:c.year,month:c.month,day:c.day};return d.pager=g.get("/data/list.json").then(function(h){var j,i;i=e?(function(){var n,l,m,k;m=h.data;k=[];for(n=0,l=m.length;n<l;n++){j=m[n];if(j.date.indexOf(e)!==-1){k.push(j)}}return k})():h.data;return new f(i,40,1)})}],TagCtl:["$scope","$http","$routeParams",function(d,e,c){d.$watch("locale.tag",function(f){return d.page.title=f+" — "+c.tag});angular.extend(d.page,{url:"/tag/"+c.tag,group:"tags"});return e.get("/data/tags.json").success(function(f){d.tag=f[c.tag];return d.tag.name=c.tag})}],TagsCtl:["$scope","$http",function(c,d){c.$watch("locale.tags",function(e){return c.page.title=e});angular.extend(c.page,{url:"/tags",group:"tags"});return d.get("/data/tags.json").success(function(l){var k,i,h,e,m,f,g,j;h=Infinity;i=-Infinity;f=[];for(e in l){m=l[e];if(m.size<h){h=m.size}if(m.size>i){i=m.size}m.name=e;f.push(m)}k=i-h;for(g=0,j=f.length;g<j;g++){m=f[g];m.weight=(m.size-h)/k}return c.tags=f})}]})}).call(this);